import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

type DeleteAccountErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "invalid_json_body"
  | "delete_account_failed"
  | "delete_account_unknown_error";

type DeleteAccountOutcome = "deleted" | "deactivated";

type UserRow = {
  id: string;
  is_active: boolean;
  role: string | null;
  seller_status: string | null;
  profile_image_url: string | null;
};

type MinimalRow = {
  id: string;
  image_url?: string | null;
  truffle_id?: string | null;
};

if (import.meta.main) {
  Deno.serve(async (request) => {
    return await handleDeleteAccount(request);
  });
}

export async function handleDeleteAccount(
  request: Request,
  deps: {
    authClient?: any;
    adminClient?: any;
    requestId?: string;
  } = {},
): Promise<Response> {
  const requestId = deps.requestId ?? getRequestId(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      requestId,
    );
  }

  const authHeader = request.headers.get("Authorization");
  let authClient = deps.authClient ?? null;
  let adminClient = deps.adminClient ?? null;

  if (!authClient && !authHeader) {
    return errorResponse("unauthorized", "Authentication is required.", 401, requestId);
  }

  if (!authClient && authHeader) {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!supabaseUrl || !supabaseAnonKey) {
      return errorResponse(
        "delete_account_unknown_error",
        "Missing runtime configuration.",
        500,
        requestId,
      );
    }

    authClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: { Authorization: authHeader },
      },
    });
  }

  if (!adminClient) {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return errorResponse(
        "delete_account_unknown_error",
        "Missing runtime configuration.",
        500,
        requestId,
      );
    }

    adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
  }

  if (!authClient) {
    return errorResponse("unauthorized", "Authentication is required.", 401, requestId);
  }

  const {
    data: { user },
    error: authError,
  } = await authClient.auth.getUser();

  if (authError || !user) {
    return errorResponse("unauthorized", "Authentication is required.", 401, requestId);
  }

  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, is_active, role, seller_status, profile_image_url")
    .eq("id", user.id)
    .maybeSingle();

  if (currentUserError || !currentUser) {
    return errorResponse(
      "user_not_found",
      "Authenticated user profile was not found.",
      404,
      requestId,
    );
  }

  if (!(currentUser as UserRow).is_active) {
    return errorResponse(
      "inactive_account",
      "The authenticated account is inactive.",
      403,
      requestId,
    );
  }

  let payload: Record<string, unknown>;
  try {
    payload = await request.json();
  } catch {
    payload = {};
  }

  if (payload.user_id && payload.user_id !== user.id) {
    // The client-provided user_id is intentionally ignored. The JWT is the source of truth.
  }

  const hasOrderHistory = await hasAnyRows(adminClient, "orders", [
    ["buyer_id", user.id],
  ]) || await hasAnyRows(adminClient, "orders", [
    ["seller_id", user.id],
  ]);
  const hasSoldTruffles = await hasAnyRows(adminClient, "truffles", [
    ["seller_id", user.id],
    ["status", "sold"],
  ]);

  const assetCleanupSucceeded = await cleanupUserAssets(
    adminClient,
    user.id,
    currentUser as UserRow,
    requestId,
  );

  const hasHistoricalActivity = hasOrderHistory || hasSoldTruffles;
  const shouldAttemptHardDelete = !hasHistoricalActivity && assetCleanupSucceeded;

  if (shouldAttemptHardDelete) {
    const hardDeleteSucceeded = await deleteAuthUser(adminClient, user.id);
    if (hardDeleteSucceeded) {
      await insertAuditLog(adminClient, {
        entityType: "user_account",
        entityId: user.id,
        action: "deleted",
        performedBy: user.id,
        metadata: {
          action: "deleted",
          request_id: requestId,
          result: "succeeded",
          deletion_mode: "hard_delete",
        },
        requestId,
      });

      return successResponse("deleted", requestId);
    }
  }

  await deactivateUser(adminClient, user.id);
  await insertAuditLog(adminClient, {
    entityType: "user_account",
    entityId: user.id,
    action: "deactivated",
    performedBy: user.id,
    metadata: {
      action: "deactivated",
      request_id: requestId,
      result: "succeeded",
      deletion_mode: hasHistoricalActivity ? "anonymize" : "fallback_deactivate",
    },
    requestId,
  });

  return successResponse("deactivated", requestId);
}

async function cleanupUserAssets(
  adminClient: any,
  userId: string,
  currentUser: UserRow,
  requestId: string,
): Promise<boolean> {
  await Promise.all([
    safeDeleteRows(adminClient, "shipping_addresses", "user_id", userId, requestId),
    safeDeleteRows(adminClient, "favorites", "user_id", userId, requestId),
    safeDeleteRows(adminClient, "notifications", "user_id", userId, requestId),
    safeDeleteRows(adminClient, "seller_documents", "user_id", userId, requestId),
    removeProfileImage(adminClient, currentUser.profile_image_url, userId, requestId),
  ]);

  return await deleteActiveTruffles(adminClient, userId, requestId);
}

async function deleteActiveTruffles(
  adminClient: any,
  userId: string,
  requestId: string,
): Promise<boolean> {
  const { data: activeTruffles, error: trufflesError } = await adminClient
    .from("truffles")
    .select("id")
    .eq("seller_id", userId)
    .eq("status", "active");

  if (trufflesError) {
    console.error("delete_account active truffle lookup failed", {
      request_id: requestId,
      code: readErrorCode(trufflesError),
      message: readErrorMessage(trufflesError),
    });
    return false;
  }

  const rows = (activeTruffles ?? []) as MinimalRow[];
  if (rows.length === 0) return true;

  const activeTruffleIds = rows
    .map((row) => row.id)
    .filter((value) => typeof value === "string" && value.trim().length > 0);
  if (activeTruffleIds.length === 0) return true;

  const { data: imageRows, error: imageError } = await adminClient
    .from("truffle_images")
    .select("id, truffle_id, image_url")
    .in("truffle_id", activeTruffleIds);

  if (imageError) {
    console.error("delete_account truffle image lookup failed", {
      request_id: requestId,
      code: readErrorCode(imageError),
      message: readErrorMessage(imageError),
    });
  }

  const typedImageRows = (imageRows ?? []) as Array<{
    image_url?: string | null;
  }>;
  const storagePaths = typedImageRows
    .map((row) => extractStoragePath(row.image_url ?? null, "truffle_images"))
    .filter((path): path is string => path != null);

  await deleteStorageObjects(adminClient, "truffle_images", storagePaths, requestId);

  const { error: deleteError } = await adminClient
    .from("truffles")
    .delete()
    .eq("seller_id", userId)
    .eq("status", "active");

  if (deleteError) {
    console.error("delete_account active truffle delete failed", {
      request_id: requestId,
      code: readErrorCode(deleteError),
      message: readErrorMessage(deleteError),
    });
    return false;
  }

  return true;
}

async function removeProfileImage(
  adminClient: any,
  profileImageUrl: string | null,
  userId: string,
  requestId: string,
): Promise<void> {
  const storagePath = extractStoragePath(profileImageUrl, "profile_images");
  if (storagePath != null) {
    await deleteStorageObjects(adminClient, "profile_images", [storagePath], requestId);
  }

  const { error } = await adminClient
    .from("users")
    .update({ profile_image_url: null })
    .eq("id", userId);

  if (error) {
    console.error("delete_account profile image cleanup failed", {
      request_id: requestId,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

async function deleteStorageObjects(
  adminClient: any,
  bucketId: string,
  paths: string[],
  requestId: string,
): Promise<void> {
  const uniquePaths = [...new Set(paths.map((path) => path.trim()).filter(Boolean))];
  if (uniquePaths.length === 0) return;

  try {
    const result = await adminClient.storage.from(bucketId).remove(uniquePaths);
    if (Array.isArray(result) && result.length > 0) {
      return;
    }
  } catch (error) {
    console.error("delete_account storage cleanup failed", {
      request_id: requestId,
      bucket_id: bucketId,
      message: error instanceof Error ? error.message : String(error),
    });
  }
}

async function safeDeleteRows(
  adminClient: any,
  table: string,
  column: string,
  value: string,
  requestId: string,
): Promise<void> {
  const { error } = await adminClient.from(table).delete().eq(column, value);
  if (error) {
    console.error("delete_account personal data cleanup failed", {
      request_id: requestId,
      table,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

async function deleteAuthUser(adminClient: any, userId: string): Promise<boolean> {
  const result = await adminClient.auth.admin.deleteUser(userId);
  return !result?.error;
}

async function deactivateUser(adminClient: any, userId: string): Promise<void> {
  await adminClient
    .from("users")
    .update({
      is_active: false,
      deleted_at: new Date().toISOString(),
      first_name: null,
      last_name: null,
      bio: null,
      profile_image_url: null,
      country_code: null,
      region: null,
      tesserino_number: null,
      onboarding_completed: false,
    })
    .eq("id", userId);
}

async function hasAnyRows(
  adminClient: any,
  table: string,
  filters: Array<[string, string]>,
): Promise<boolean> {
  let query = adminClient.from(table).select("id").limit(1);
  for (const [column, value] of filters) {
    query = query.eq(column, value);
  }

  const { data, error } = await query.maybeSingle();
  if (error) {
    return false;
  }
  return data != null;
}

async function insertAuditLog(
  adminClient: any,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string;
    metadata: Record<string, unknown>;
    requestId: string;
  },
): Promise<void> {
  const { error } = await adminClient.from("audit_logs").insert({
    entity_type: args.entityType,
    entity_id: args.entityId,
    action: args.action,
    performed_by: args.performedBy,
    metadata: args.metadata,
  });

  if (error) {
    console.error("delete_account audit insert failed", {
      request_id: args.requestId,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

function extractStoragePath(
  rawUrl: string | null | undefined,
  bucketId: string,
): string | null {
  const normalized = rawUrl?.trim();
  if (normalized == null || normalized.length === 0) return null;

  if (normalized.startsWith(`${bucketId}/`)) {
    return normalized.substring(bucketId.length + 1);
  }

  if (normalized.startsWith(`/${bucketId}/`)) {
    return normalized.substring(bucketId.length + 2);
  }

  let pathname: string;
  try {
    pathname = new URL(normalized).pathname;
  } catch {
    return null;
  }

  const segments = pathname.split("/").filter((segment) => segment.length > 0);
  const bucketIndex = segments.indexOf(bucketId);
  if (bucketIndex === -1 || bucketIndex >= segments.length - 1) {
    return null;
  }

  return segments.slice(bucketIndex + 1).join("/");
}

function successResponse(status: DeleteAccountOutcome, requestId: string): Response {
  return jsonResponse(
    {
      success: true,
      status,
      request_id: requestId,
    },
    200,
  );
}

function errorResponse(
  error: DeleteAccountErrorCode,
  message: string,
  status: number,
  requestId: string,
): Response {
  return jsonResponse(
    {
      error,
      message,
      request_id: requestId,
    },
    status,
  );
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

function readErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string") return value;
  }
  return "";
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") return value.toLowerCase();
  }
  return "";
}
