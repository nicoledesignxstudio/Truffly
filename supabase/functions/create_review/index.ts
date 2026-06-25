import { createClient } from "@supabase/supabase-js";
import { createBusinessNotificationAndPush } from "../_shared/business_notifications.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

type CreateReviewPayload = {
  order_id?: string;
  rating?: number;
  comment?: string | null;
};

const reviewWindowMs = 48 * 60 * 60 * 1000;

export async function handleCreateReview(
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
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  const authHeader = request.headers.get("Authorization");
  const authClient = deps.authClient ?? createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    {
      global: { headers: { Authorization: authHeader ?? "" } },
    },
  );
  const adminClient = deps.adminClient ?? createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  if (!authHeader) {
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }

  const { data: authData, error: authError } = await authClient.auth.getUser();
  if (authError || !authData.user) {
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }
  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, is_active")
    .eq("id", authData.user.id)
    .single();

  if (currentUserError || !currentUser) {
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }

  if (!currentUser.is_active) {
    return jsonResponse({ error: "forbidden" }, 403, requestId);
  }

  let payload: CreateReviewPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_input" }, 400, requestId);
  }

  const orderId = normalizeString(payload.order_id);
  const rating = normalizeRating(payload.rating);
  const normalizedComment = normalizeComment(payload.comment);
  const comment = normalizedComment.value;
  if (!orderId || rating == null) {
    return jsonResponse({ error: "invalid_input" }, 400, requestId);
  }
  if (!normalizedComment.isValid) {
    return jsonResponse({ error: "invalid_input" }, 400, requestId);
  }

  const { data: order, error: orderError } = await adminClient
    .from("orders")
    .select("id, buyer_id, seller_id, status, completed_at")
    .eq("id", orderId)
    .single();

  if (orderError || !order) {
    return jsonResponse({ error: "order_not_found" }, 404, requestId);
  }

  if (order.buyer_id !== authData.user.id) {
    return jsonResponse({ error: "forbidden" }, 403, requestId);
  }

  if (order.status !== "completed") {
    return jsonResponse({ error: "order_not_completed" }, 409, requestId);
  }

  const completedAt = parseCompletedAt(order.completed_at);
  if (completedAt == null || Date.now() >= completedAt.getTime() + reviewWindowMs) {
    return jsonResponse({ error: "review_window_expired" }, 409, requestId);
  }

  const { data: existingReview, error: existingReviewError } = await adminClient
    .from("reviews")
    .select("id")
    .eq("order_id", order.id)
    .maybeSingle();

  if (existingReviewError) {
    return jsonResponse({ error: "internal_error" }, 500, requestId);
  }

  if (existingReview) {
    return jsonResponse({ error: "review_already_exists" }, 409, requestId);
  }

  const insertResult = await adminClient.from("reviews").insert({
    order_id: order.id,
    rating,
    comment,
    is_auto: false,
    auto_created_at: null,
  }).select("id, order_id, rating, comment, created_at, is_auto, auto_created_at").single();

  if (insertResult.error || !insertResult.data) {
    return jsonResponse({ error: "internal_error" }, 500, requestId);
  }

  await createBusinessNotificationAndPush({
    adminClient,
    userId: order.seller_id,
    type: "seller_new_review",
    message: "You received a new review for your truffle.",
    metadata: { order_id: order.id },
    requestId,
  });

  await insertAuditLog(adminClient, {
    entityType: "review",
    entityId: insertResult.data.id,
    action: "created",
    performedBy: authData.user.id,
    metadata: {
      action: "created",
      request_id: requestId,
      result: "succeeded",
      order_id: order.id,
      is_auto: false,
    },
    requestId,
  });

  return jsonResponse({ success: true, request_id: requestId }, 200);
}

if (import.meta.main) {
  Deno.serve((request) => handleCreateReview(request));
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
  await adminClient.from("audit_logs").insert({
    entity_type: args.entityType,
    entity_id: args.entityId,
    action: args.action,
    performed_by: args.performedBy,
    metadata: args.metadata,
  });
}

function normalizeString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function normalizeComment(value: unknown): { isValid: boolean; value: string | null } {
  if (value == null) {
    return { isValid: true, value: null };
  }
  if (typeof value !== "string") {
    return { isValid: false, value: null };
  }
  const trimmed = value.trim();
  if (trimmed.length > 300) {
    return { isValid: false, value: null };
  }
  return { isValid: true, value: trimmed.length > 0 ? trimmed : null };
}

function normalizeRating(value: unknown): number | null {
  if (typeof value !== "number") return null;
  if (!Number.isInteger(value)) return null;
  if (value < 1 || value > 5) return null;
  return value;
}

function parseCompletedAt(value: unknown): Date | null {
  if (typeof value !== "string" || value.trim().length === 0) {
    return null;
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
  requestId?: string,
): Response {
  return new Response(JSON.stringify(requestId ? { ...body, request_id: requestId } : body), {
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
