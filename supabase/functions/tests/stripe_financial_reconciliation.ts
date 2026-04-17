import { createClient } from "@supabase/supabase-js";

const supabaseUrl = Deno.env.get("LOCAL_SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requiredEnv("LOCAL_SUPABASE_SERVICE_ROLE_KEY");

const adminClient = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

async function main() {
  const { data: orders, error: orderError } = await adminClient
    .from("orders")
    .select(
      "id,status,paid_at,shipped_at,completed_at,cancelled_at,stripe_payment_intent_id",
    )
    .order("created_at", { ascending: false })
    .limit(200);

  if (orderError != null) {
    throw orderError;
  }

  const { data: operations, error: operationError } = await adminClient
    .from("order_financial_operations")
    .select(
      "order_id,kind,status,stripe_refund_id,stripe_transfer_id,stripe_payment_intent_id,logical_key,processed_at,created_at",
    )
    .order("created_at", { ascending: false })
    .limit(500);

  if (operationError != null) {
    throw operationError;
  }

  const grouped = new Map<string, Array<Record<string, unknown>>>();
  for (const operation of operations ?? []) {
    const orderId = operation.order_id as string;
    const bucket = grouped.get(orderId) ?? [];
    bucket.push(operation as Record<string, unknown>);
    grouped.set(orderId, bucket);
  }

  const mismatches: Array<Record<string, unknown>> = [];

  for (const order of orders ?? []) {
    const ops = grouped.get(order.id as string) ?? [];
    const payment = ops.find((entry) => entry.kind === "payment");
    const refund = ops.find((entry) => entry.kind === "refund");
    const transfer = ops.find((entry) => entry.kind === "transfer");
    const status = order.status as string;

    if (payment == null) {
      mismatches.push({
        order_id: order.id,
        issue: "missing_payment_operation",
      });
    }

    if (status === "completed" && transfer == null) {
      mismatches.push({
        order_id: order.id,
        issue: "completed_without_transfer_operation",
      });
    }

    if (status === "cancelled" && refund == null) {
      mismatches.push({
        order_id: order.id,
        issue: "cancelled_without_refund_operation",
      });
    }

    if (status === "paid" && refund != null && refund.status === "succeeded") {
      mismatches.push({
        order_id: order.id,
        issue: "paid_with_succeeded_refund",
      });
    }
  }

  console.log(JSON.stringify({
    scanned_orders: (orders ?? []).length,
    scanned_operations: (operations ?? []).length,
    mismatches,
  }, null, 2));
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`${name} is required.`);
  }
  return value;
}

if (import.meta.main) {
  await main();
}
