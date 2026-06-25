import { createClient } from "@supabase/supabase-js";
import { createBusinessNotificationAndPush } from "../_shared/business_notifications.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

type EligibleOrderRow = {
  id: string;
  seller_id: string;
  buyer_id: string;
};

const reviewWindowMs = 48 * 60 * 60 * 1000;

export async function handleAutoCreateMissingReviews(
  request: Request,
  deps: {
    adminClient?: any;
    requestId?: string;
    cronSecret?: string;
  } = {},
): Promise<Response> {
  const requestId = deps.requestId ?? getRequestId(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  const cronSecret = deps.cronSecret ?? Deno.env.get("CRON_SECRET");
  const authHeader = request.headers.get("Authorization");
  if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }

  const adminClient = deps.adminClient ?? createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  const cutoffIso = new Date(Date.now() - reviewWindowMs).toISOString();

  const { data, error } = await adminClient
    .from("orders")
    .select("id, seller_id, buyer_id")
    .eq("status", "completed")
    .lte("completed_at", cutoffIso);

  if (error) {
    return jsonResponse({ error: "query_failed" }, 500, requestId);
  }

  const orders = (data ?? []) as EligibleOrderRow[];
  let created = 0;
  const failures: Array<Record<string, string>> = [];

  for (const order of orders) {
    const { data: existingReview, error: existingReviewError } = await adminClient
      .from("reviews")
      .select("id")
      .eq("order_id", order.id)
      .maybeSingle();

    if (existingReviewError) {
      failures.push({
        order_id: order.id,
        message: "review_lookup_failed",
      });
      continue;
    }

    if (existingReview) {
      continue;
    }

    const insertResult = await adminClient.from("reviews").insert({
      order_id: order.id,
      rating: 5,
      comment: "Automatic review: order completed successfully.",
      is_auto: true,
      auto_created_at: new Date().toISOString(),
    });

    if (insertResult.error) {
      failures.push({
        order_id: order.id,
        message: insertResult.error.message,
      });
      continue;
    }

    created += 1;

    await createBusinessNotificationAndPush({
      adminClient,
      userId: order.seller_id,
      type: "seller_auto_review_received",
      message: "An automatic review was added for one of your orders.",
      metadata: { order_id: order.id },
      requestId,
    });

    await insertAuditLog(adminClient, {
      entityType: "review",
      entityId: order.id,
      action: "auto_created",
      performedBy: order.buyer_id,
      metadata: {
        action: "auto_created",
        request_id: requestId,
        result: "succeeded",
        order_id: order.id,
        rating: 5,
        is_auto: true,
      },
      requestId,
    });
  }

  return jsonResponse({
    success: true,
    request_id: requestId,
    scanned: orders.length,
    created,
    failures,
  }, 200);
}

if (import.meta.main) {
  Deno.serve((request) => handleAutoCreateMissingReviews(request));
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
