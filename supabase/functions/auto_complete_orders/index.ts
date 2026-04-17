import { createClient } from "@supabase/supabase-js";
import {
  createStripeOrderFinancialGateway,
  createSupabaseOrderFinancialStore,
  releaseFundsForCompletedOrder,
} from "../_shared/order_financials.ts";

type ShippedOrderRow = {
  id: string;
  buyer_id: string;
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
  if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
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

  const reminderCutoffIso = new Date(
    Date.now() - 7 * 24 * 60 * 60 * 1000,
  ).toISOString();
  const completionCutoffIso = new Date(
    Date.now() - 9 * 24 * 60 * 60 * 1000,
  ).toISOString();

  const reminderResult = await sendDeliveryReminders({
    adminClient,
    cutoffIso: reminderCutoffIso,
  });

  const { data, error } = await adminClient
    .from("orders")
    .select("id,buyer_id")
    .eq("status", "shipped")
    .lte("shipped_at", completionCutoffIso)
    .order("shipped_at", { ascending: true });

  if (error != null) {
    return jsonResponse(
      { error: "query_failed", message: error.message, request_id: requestId },
      500,
    );
  }

  const orders = (data ?? []) as ShippedOrderRow[];
  let completed = 0;
  let payoutsReleased = 0;
  const failures: Array<Record<string, string>> = [];

  for (const order of orders) {
    try {
      const completion = await financialStore.completeOrderSystem({
        orderId: order.id,
        requestId,
        reason: "auto_complete_after_7_plus_2_days",
      });
      if (!completion.idempotent) {
        completed += 1;
      }

      const payout = await releaseFundsForCompletedOrder({
        orderId: order.id,
        requestId,
        triggerSource: "auto_complete_after_7_plus_2_days",
        triggeredBy: null,
        store: financialStore,
        stripeGateway: financialGateway,
      });
      if (!payout.idempotent) {
        payoutsReleased += 1;
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
    reminders_sent: reminderResult.sent,
    reminders_scanned: reminderResult.scanned,
    auto_completed: completed,
    payouts_released: payoutsReleased,
    failures,
  }, 200);
});

async function sendDeliveryReminders(args: {
  adminClient: any;
  cutoffIso: string;
}): Promise<{ scanned: number; sent: number }> {
  const { data, error } = await args.adminClient
    .from("orders")
    .select("id,buyer_id")
    .eq("status", "shipped")
    .is("buyer_delivery_reminder_sent_at", null)
    .lte("shipped_at", args.cutoffIso);

  if (error != null) {
    throw error;
  }

  const orders = (data ?? []) as ShippedOrderRow[];
  let sent = 0;

  for (const order of orders) {
    const nowIso = new Date().toISOString();
    const { data: updatedRows, error: updateError } = await args.adminClient
      .from("orders")
      .update({
        buyer_delivery_reminder_sent_at: nowIso,
      })
      .eq("id", order.id)
      .is("buyer_delivery_reminder_sent_at", null)
      .eq("status", "shipped")
      .select("id");

    if (updateError != null) {
      throw updateError;
    }

    if ((updatedRows ?? []).length === 0) {
      continue;
    }

    const { error: notificationError } = await args.adminClient
      .from("notifications")
      .insert({
        user_id: order.buyer_id,
        type: "order_delivery_confirmation_reminder",
        message:
          "Please confirm delivery within 48 hours or the order will be auto-completed.",
      });

    if (notificationError != null) {
      throw notificationError;
    }

    sent += 1;
  }

  return { scanned: orders.length, sent };
}

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
