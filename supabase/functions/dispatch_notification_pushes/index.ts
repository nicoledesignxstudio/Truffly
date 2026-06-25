import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { sendNotificationPush } from "../_shared/business_notifications.ts";

type ClaimedPushRow = {
  outbox_id: string;
  notification_id: string;
  user_id: string;
  type: string;
  target_route: string | null;
  target_id: string | null;
  metadata: Record<string, unknown> | null;
  attempts: number;
};

export async function handleDispatchNotificationPushes(
  request: Request,
  deps: {
    adminClient?: SupabaseClient;
    cronSecret?: string;
    requestId?: string;
  } = {},
): Promise<Response> {
  const requestId = deps.requestId ??
    request.headers.get("x-request-id")?.trim() ??
    crypto.randomUUID();

  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  const cronSecret = deps.cronSecret ?? Deno.env.get("CRON_SECRET");
  if (
    !cronSecret ||
    request.headers.get("Authorization") !== `Bearer ${cronSecret}`
  ) {
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }

  const adminClient = deps.adminClient ?? createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const { data, error } = await adminClient.rpc(
    "claim_notification_push_outbox",
    { p_limit: 25 },
  );

  if (error) {
    console.error("FCM push failed", {
      request_id: requestId,
      message: error.message,
    });
    return jsonResponse({ error: "outbox_claim_failed" }, 500, requestId);
  }

  const rows = (data ?? []) as ClaimedPushRow[];
  let sent = 0;
  let skipped = 0;
  let failed = 0;

  for (const row of rows) {
    const result = await sendNotificationPush({
      adminClient,
      notificationId: row.notification_id,
      userId: row.user_id,
      type: row.type,
      targetRoute: row.target_route,
      targetId: row.target_id,
      metadata: row.metadata ?? {},
      requestId,
    });

    if (result.status === "failed") {
      failed += 1;
      await adminClient
        .from("notification_push_outbox")
        .update({
          status: "pending",
          locked_at: null,
          next_attempt_at: nextRetryAt(row.attempts),
          last_error: "fcm_send_failed",
          updated_at: new Date().toISOString(),
        })
        .eq("id", row.outbox_id);
      continue;
    }

    if (result.status === "sent") {
      sent += 1;
    } else {
      skipped += 1;
    }
    await adminClient
      .from("notification_push_outbox")
      .update({
        status: "sent",
        locked_at: null,
        processed_at: new Date().toISOString(),
        last_error: null,
        updated_at: new Date().toISOString(),
      })
      .eq("id", row.outbox_id);
  }

  return jsonResponse(
    {
      success: true,
      claimed: rows.length,
      sent,
      skipped,
      failed,
    },
    200,
    requestId,
  );
}

if (import.meta.main) {
  Deno.serve((request) => handleDispatchNotificationPushes(request));
}

function nextRetryAt(attempts: number): string {
  const delayMinutes = Math.min(60, 2 ** Math.max(0, attempts - 1));
  return new Date(Date.now() + delayMinutes * 60 * 1000).toISOString();
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
  requestId: string,
): Response {
  return new Response(JSON.stringify({ ...body, request_id: requestId }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
