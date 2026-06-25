import { createClient } from "@supabase/supabase-js";

import {
  createStripeOrderFinancialGateway,
  createSupabaseOrderFinancialStore,
  type FinancialOperationKind,
  refundOrderPayment,
  releaseFundsForCompletedOrder,
} from "../_shared/order_financials.ts";
import {
  corsHeaders,
  getRequestId,
  validateRuntimeSupabaseUrl,
} from "../_shared/stripe_payments.ts";

type RetryPayload = {
  order_id?: string;
  kind?: FinancialOperationKind;
  limit?: number;
};

Deno.serve(async (request) => {
  const requestId = getRequestId(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({
      error: "method_not_allowed",
      message: "Only POST requests are supported.",
      request_id: requestId,
    }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const cronSecret = Deno.env.get("CRON_SECRET");

  if (
    !supabaseUrl || !supabaseServiceRoleKey || !stripeSecretKey || !cronSecret
  ) {
    return jsonResponse({
      error: "retry_financial_operations_runtime_error",
      message: "Missing runtime configuration.",
      request_id: requestId,
    }, 500);
  }

  const supabaseUrlValidationError = validateRuntimeSupabaseUrl(supabaseUrl);
  if (supabaseUrlValidationError != null) {
    return jsonResponse({
      error: "retry_financial_operations_runtime_error",
      message: supabaseUrlValidationError,
      request_id: requestId,
    }, 500);
  }

  if (request.headers.get("Authorization") !== `Bearer ${cronSecret}`) {
    return jsonResponse({
      error: "unauthorized",
      message: "A valid cron secret is required.",
      request_id: requestId,
    }, 401);
  }

  let payload: RetryPayload = {};
  try {
    const parsed = await request.json();
    if (parsed != null && typeof parsed === "object") {
      payload = parsed as RetryPayload;
    }
  } catch {
    payload = {};
  }

  const kind = payload.kind === "refund" || payload.kind === "transfer"
    ? payload.kind
    : null;
  const limit = clampRetryLimit(payload.limit);

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
  const store = createSupabaseOrderFinancialStore(adminClient);
  const stripeGateway = createStripeOrderFinancialGateway(
    fetch,
    stripeSecretKey,
  );

  let query = adminClient
    .from("order_financial_operations")
    .select("id, order_id, kind, metadata")
    .eq("status", "failed")
    .in("kind", kind == null ? ["refund", "transfer"] : [kind])
    .order("updated_at", { ascending: true })
    .limit(limit);

  if (typeof payload.order_id === "string" && payload.order_id.trim() !== "") {
    query = query.eq("order_id", payload.order_id.trim());
  }

  const { data, error } = await query;
  if (error != null) {
    return jsonResponse({
      error: "retry_financial_operations_query_failed",
      message: error.message,
      request_id: requestId,
    }, 500);
  }

  const operations = Array.isArray(data) ? data : [];
  const results = [];

  for (const operation of operations) {
    const orderId = `${operation.order_id ?? ""}`.trim();
    const operationKind = `${operation.kind ?? ""}`.trim();
    const refundReason = readString(operation.metadata, "refund_reason");
    try {
      if (operationKind === "refund") {
        await refundOrderPayment({
          orderId,
          requestId,
          triggerSource: "retry_financial_operations",
          triggeredBy: null,
          refundReason: "retry_failed_refund",
          store,
          stripeGateway,
        });
        await store.cancelOrderAfterRefund({
          orderId,
          requestId,
          actorUserId: null,
          reason:
            refundReason === "seller_did_not_ship_within_48h"
              ? "auto_cancel_unshipped_48h"
              : "retry_refund_processed",
        });
      } else if (operationKind === "transfer") {
        await releaseFundsForCompletedOrder({
          orderId,
          requestId,
          triggerSource: "retry_financial_operations",
          triggeredBy: null,
          store,
          stripeGateway,
        });
      }

      results.push({
        operation_id: operation.id,
        order_id: orderId,
        kind: operationKind,
        status: "succeeded",
      });
    } catch (retryError) {
      results.push({
        operation_id: operation.id,
        order_id: orderId,
        kind: operationKind,
        status: "failed",
        error: readErrorMessage(retryError),
      });
    }
  }

  return jsonResponse({
    request_id: requestId,
    attempted: results.length,
    succeeded: results.filter((result) => result.status === "succeeded").length,
    failed: results.filter((result) => result.status === "failed").length,
    results,
  }, 200);
});

function readString(
  value: unknown,
  key: string,
): string | null {
  if (typeof value !== "object" || value === null) return null;
  const record = value as Record<string, unknown>;
  const raw = record[key];
  return typeof raw === "string" ? raw : null;
}

function clampRetryLimit(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return 10;
  return Math.min(Math.max(Math.trunc(value), 1), 50);
}

function readErrorMessage(error: unknown): string {
  if (error instanceof Error && error.message.trim() !== "") {
    return error.message;
  }
  return "Unknown retry error.";
}

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
