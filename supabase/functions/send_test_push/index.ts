import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { sendNotificationPush } from "../_shared/business_notifications.ts";

type TestPushPayload = {
  user_id?: string;
  title?: string;
  body?: string;
  target_route?: string;
  type?: string;
};

export async function handleSendTestPush(
  request: Request,
  deps: {
    authClient?: SupabaseClient;
    adminClient?: SupabaseClient;
    devSecret?: string;
    requestId?: string;
  } = {},
): Promise<Response> {
  const requestId = deps.requestId ??
    request.headers.get("x-request-id")?.trim() ??
    crypto.randomUUID();

  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  let payload: TestPushPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_json_body" }, 400, requestId);
  }

  const userId = normalizedString(payload.user_id);
  if (!userId) {
    return jsonResponse({ error: "invalid_user_id" }, 400, requestId);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const adminClient = deps.adminClient ?? createClient(
    supabaseUrl,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const authHeader = request.headers.get("Authorization");
  const authClient = deps.authClient ?? createClient(
    supabaseUrl,
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader ?? "" } } },
  );
  const devSecret = deps.devSecret ?? Deno.env.get("PUSH_TEST_SECRET");
  const suppliedDevSecret = request.headers.get("x-push-test-secret");
  const devAuthorized = Boolean(
    devSecret && suppliedDevSecret && suppliedDevSecret === devSecret,
  );

  const { data: authData } = authHeader
    ? await authClient.auth.getUser()
    : { data: { user: null } };
  const authUser = authData.user;
  const isAdmin = authUser?.app_metadata?.role === "admin";
  const isSelf = authUser?.id === userId;

  if (!devAuthorized && !isAdmin && !isSelf) {
    return jsonResponse({ error: "forbidden" }, 403, requestId);
  }

  const type = normalizedString(payload.type) ?? "test_push";
  const targetRoute = normalizedString(payload.target_route) ??
    "/notifications";
  const result = await sendNotificationPush({
    adminClient,
    notificationId: `test-${crypto.randomUUID()}`,
    userId,
    type,
    targetRoute,
    targetId: null,
    metadata: {},
    title: normalizedString(payload.title) ?? "Test Truffly",
    body: normalizedString(payload.body) ?? "Questa è una notifica di test",
    requestId,
    bypassImportanceFilter: true,
  });

  return jsonResponse(
    {
      success: result.status !== "failed",
      status: result.status,
      attempted: result.attempted,
      sent: result.sent,
      failed: result.failed,
    },
    result.status === "failed" ? 502 : 200,
    requestId,
  );
}

if (import.meta.main) {
  Deno.serve((request) => handleSendTestPush(request));
}

function normalizedString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
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
