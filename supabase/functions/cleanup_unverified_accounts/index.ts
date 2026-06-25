import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

type AuthUserListItem = {
  id: string;
  email: string | null;
  email_confirmed_at?: string | null;
  emailConfirmedAt?: string | null;
  created_at?: string | null;
  createdAt?: string | null;
};

type UserProfileRow = {
  id: string;
  profile_image_url: string | null;
};

if (import.meta.main) {
  Deno.serve((request) => handleCleanupUnverifiedAccounts(request));
}

export async function handleCleanupUnverifiedAccounts(
  request: Request,
  deps: {
    adminClient?: any;
    cronSecret?: string;
    requestId?: string;
  } = {},
): Promise<Response> {
  const requestId = deps.requestId ?? getRequestId(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method_not_allowed", request_id: requestId },
      405,
    );
  }

  const cronSecret = deps.cronSecret ?? Deno.env.get("CRON_SECRET");
  const authHeader = request.headers.get("Authorization");
  if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
    return jsonResponse({ error: "unauthorized", request_id: requestId }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(
      { error: "runtime_error", request_id: requestId },
      500,
    );
  }

  const adminClient = deps.adminClient ?? createClient(supabaseUrl, serviceRoleKey);
  const cutoffIso = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  const perPage = 100;
  let page = 1;
  let scanned = 0;
  let eligible = 0;
  let deleted = 0;
  const failures: Array<Record<string, string>> = [];

  while (true) {
    const { data, error } = await adminClient.auth.admin.listUsers({
      page,
      perPage,
    });

    if (error) {
      return jsonResponse(
        {
          error: "list_users_failed",
          message: error.message,
          request_id: requestId,
        },
        500,
      );
    }

    const users = (data?.users ?? []) as AuthUserListItem[];
    if (users.length === 0) break;

    scanned += users.length;

    for (const user of users) {
      const emailConfirmedAt = user.email_confirmed_at ?? user.emailConfirmedAt ?? null;
      if (emailConfirmedAt != null) continue;

      const createdAt = user.created_at ?? user.createdAt ?? null;
      if (createdAt == null) continue;

      if (new Date(createdAt).getTime() > new Date(cutoffIso).getTime()) {
        continue;
      }

      eligible += 1;

      const { data: profile, error: profileError } = await adminClient
        .from("users")
        .select("id, profile_image_url")
        .eq("id", user.id)
        .maybeSingle();

      if (profileError) {
        failures.push({
          user_id: user.id,
          message: `profile_lookup_failed:${profileError.message}`,
        });
        continue;
      }

      if (profile) {
        await removeProfileImage(adminClient, profile as UserProfileRow, requestId);
      }

      const deleteResult = await adminClient.auth.admin.deleteUser(user.id);
      if (deleteResult.error) {
        failures.push({
          user_id: user.id,
          message: `delete_failed:${deleteResult.error.message}`,
        });
        continue;
      }

      deleted += 1;
      await insertAuditLog(adminClient, {
        entityType: "user_account",
        entityId: user.id,
        action: "auto_deleted_unverified",
        performedBy: null,
        metadata: {
          action: "auto_deleted_unverified",
          request_id: requestId,
          result: "succeeded",
          cutoff_iso: cutoffIso,
        },
        requestId,
      });
    }

    if (users.length < perPage) break;
    page += 1;
  }

  return jsonResponse(
    {
      success: true,
      request_id: requestId,
      scanned,
      eligible,
      deleted,
      failures,
    },
    200,
  );
}

async function removeProfileImage(
  adminClient: any,
  profile: UserProfileRow,
  requestId: string,
): Promise<void> {
  const storagePath = extractStoragePath(profile.profile_image_url, "profile_images");
  if (storagePath) {
    try {
      await adminClient.storage.from("profile_images").remove([storagePath]);
    } catch (error) {
      console.error("cleanup_unverified_accounts profile image cleanup failed", {
        request_id: requestId,
        message: error instanceof Error ? error.message : String(error),
      });
    }
  }
}

async function insertAuditLog(
  adminClient: any,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string | null;
    metadata: Record<string, unknown>;
    requestId: string;
  },
): Promise<void> {
  await adminClient.from("audit_logs").insert({
    entity_type: args.entityType,
    entity_id: args.entityId,
    action: args.action,
    performed_by: args.performedBy,
    metadata: args.metadata,
  });
}

function extractStoragePath(
  url: string | null,
  bucketId: string,
): string | null {
  if (!url) return null;

  try {
    const parsed = new URL(url);
    const marker = `/storage/v1/object/public/${bucketId}/`;
    const index = parsed.pathname.indexOf(marker);
    if (index >= 0) {
      const path = parsed.pathname.slice(index + marker.length);
      return decodeURIComponent(path).trim() || null;
    }
  } catch (_) {
    // Ignore malformed URLs.
  }

  return null;
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  return headerValue?.trim() || crypto.randomUUID();
}
