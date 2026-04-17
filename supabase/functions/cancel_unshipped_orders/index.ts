import { createClient } from "@supabase/supabase-js";
import {
  createStripeOrderFinancialGateway,
  createSupabaseOrderFinancialStore,
  refundOrderPayment,
} from "../_shared/order_financials.ts";

type EligibleOrderRow = {
  id: string;
};

Deno.serve(async (request) => {
  const requestId = request.headers.get("x-request-id")?.trim() ||
    crypto.randomUUID();

  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method_not_allowed", request_id: requestId },
      405,
    );
  }

  const cronSecret = Deno.env.get("CRON_SECRET");
  const authHeader = request.headers.get("Authorization");
  if (
    !cronSecret || authHeader !== `Bearer ${cronSecret}`
  ) {
    return jsonResponse(
      { error: "unauthorized", request_id: requestId },
      401,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!supabaseUrl || !serviceRoleKey || !stripeSecretKey) {
    return jsonResponse(
      { error: "runtime_error", request_id: requestId },
      500,
    );
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey);
  const financialStore = createSupabaseOrderFinancialStore(adminClient);
  const financialGateway = createStripeOrderFinancialGateway(
    fetch,
    stripeSecretKey,
  );

  const cutoffIso = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();
  const { data, error } = await adminClient
    .from("orders")
    .select("id")
    .eq("status", "paid")
    .lte("paid_at", cutoffIso)
    .order("paid_at", { ascending: true });

  if (error != null) {
    return jsonResponse(
      { error: "query_failed", message: error.message, request_id: requestId },
      500,
    );
  }

  const orders = (data ?? []) as EligibleOrderRow[];
  let refunded = 0;
  let cancelled = 0;
  const failures: Array<Record<string, string>> = [];

  for (const order of orders) {
    try {
      const refundResult = await refundOrderPayment({
        orderId: order.id,
        requestId,
        triggerSource: "auto_cancel_unshipped_48h",
        triggeredBy: null,
        refundReason: "seller_did_not_ship_within_48h",
        store: financialStore,
        stripeGateway: financialGateway,
      });
      if (!refundResult.idempotent) {
        refunded += 1;
      }

      const cancelResult = await financialStore.cancelOrderAfterRefund({
        orderId: order.id,
        requestId,
        actorUserId: null,
        reason: "auto_cancel_unshipped_48h",
      });
      if (!cancelResult.idempotent) {
        cancelled += 1;
      }
    } catch (error) {
      failures.push({
        order_id: order.id,
        message: error instanceof Error ? error.message : String(error),
      });
    }
  }

  return jsonResponse({
    success: true,
    request_id: requestId,
    scanned: orders.length,
    refunded,
    cancelled,
    failures,
  }, 200);
});

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
