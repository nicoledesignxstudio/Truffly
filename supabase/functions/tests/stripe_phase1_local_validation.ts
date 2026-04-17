import { createClient } from "@supabase/supabase-js";

import {
  createSupabasePaymentStore,
  handleCreatePaymentIntent,
  handleStripeWebhook,
} from "../_shared/stripe_payments.ts";

type ValidationSummary = {
  setup: {
    supabaseUrl: string;
    buyerId: string;
    shippingAddressId: string;
    successTruffleId: string;
    failedTruffleId: string;
    concurrentTruffleId: string;
  };
  caseA: Record<string, unknown>;
  caseB: Record<string, unknown>;
  caseC: Record<string, unknown>;
  caseD: Record<string, unknown>;
  caseE: Record<string, unknown>;
};

const localSupabaseUrl = Deno.env.get("LOCAL_SUPABASE_URL") ??
  "http://127.0.0.1:54321";
const serviceRoleKey = Deno.env.get("LOCAL_SUPABASE_SERVICE_ROLE_KEY");
const webhookSecret = Deno.env.get("LOCAL_STRIPE_WEBHOOK_SECRET") ??
  "whsec_local_validation";
const buyerId = "11111111-1111-1111-1111-111111111111";

if (!serviceRoleKey) {
  throw new Error(
    "LOCAL_SUPABASE_SERVICE_ROLE_KEY is required to run local Stripe validation.",
  );
}

const adminClient = createClient(localSupabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});
const store = createSupabasePaymentStore(adminClient);

const ids = {
  successAttemptId: "70000000-0000-4000-8000-000000000001",
  failedAttemptId: "70000000-0000-4000-8000-000000000002",
  concurrentAttemptIdA: "70000000-0000-4000-8000-000000000003",
  concurrentAttemptIdB: "70000000-0000-4000-8000-000000000004",
  successStripeIntentId: "pi_validation_success_001",
  failedStripeIntentId: "pi_validation_failed_001",
  concurrentStripeIntentId: "pi_validation_concurrent_001",
  successEventId: "evt_validation_success_001",
  failedEventId: "evt_validation_failed_001",
};

const stripeCalls: Array<Record<string, unknown>> = [];

const fakeStripeGateway = {
  async createPaymentIntent(args: {
    amountCents: number;
    currency: "eur";
    metadata: Record<string, string>;
    idempotencyKey: string;
  }) {
    const paymentAttemptId = args.metadata.payment_attempt_id;
    let id = ids.successStripeIntentId;
    if (paymentAttemptId === ids.failedAttemptId) {
      id = ids.failedStripeIntentId;
    } else if (paymentAttemptId === ids.concurrentAttemptIdA) {
      id = ids.concurrentStripeIntentId;
    }

    stripeCalls.push({
      kind: "create_payment_intent",
      payment_attempt_id: paymentAttemptId,
      amount_cents: args.amountCents,
      currency: args.currency,
      metadata: args.metadata,
      idempotency_key: args.idempotencyKey,
      stripe_payment_intent_id: id,
    });

    return {
      id,
      clientSecret: `${id}_secret_validation`,
      status: "requires_payment_method",
    };
  },
  async retrievePaymentIntent(paymentIntentId: string) {
    return {
      id: paymentIntentId,
      clientSecret: `${paymentIntentId}_secret_validation`,
      status: "requires_payment_method",
    };
  },
};

async function main() {
  const setup = await resolveSetup();
  await cleanupValidationArtifacts(setup.truffleIds);

  const summary: ValidationSummary = {
    setup: {
      supabaseUrl: localSupabaseUrl,
      buyerId,
      shippingAddressId: setup.shippingAddress.id,
      successTruffleId: setup.truffleIds[0].id,
      failedTruffleId: setup.truffleIds[1].id,
      concurrentTruffleId: setup.truffleIds[2].id,
    },
    caseA: await validateCaseA(
      setup.shippingAddress.id,
      setup.truffleIds[0].id,
    ),
    caseB: await validateCaseB(),
    caseC: await validateCaseC(),
    caseD: await validateCaseD(
      setup.shippingAddress.id,
      setup.truffleIds[1].id,
    ),
    caseE: await validateCaseE(
      setup.shippingAddress.id,
      setup.truffleIds[2].id,
    ),
  };

  console.log(JSON.stringify(summary, null, 2));
}

async function resolveSetup() {
  const firstShippingAddress = await fetchSingle(
    "shipping_addresses",
    "id",
    { user_id: buyerId },
    { order: "created_at.asc" },
  );
  if (firstShippingAddress == null) {
    throw new Error("No shipping address found for seeded buyer.");
  }

  const shippingAddress = await store.getShippingAddress(
    buyerId,
    firstShippingAddress.id as string,
  );

  if (!shippingAddress) {
    throw new Error("No shipping address found for seeded buyer.");
  }

  const { data: truffles, error } = await adminClient
    .from("truffles")
    .select("id, seller_id, status")
    .eq("status", "active")
    .neq("seller_id", buyerId)
    .order("created_at", { ascending: true })
    .limit(3);

  if (error) {
    throw error;
  }

  if (!truffles || truffles.length < 3) {
    throw new Error(
      "At least three active truffles are required for Stripe Phase 1 validation.",
    );
  }

  return {
    shippingAddress,
    truffleIds: truffles.map((row) => ({
      id: row.id as string,
      sellerId: row.seller_id as string,
    })),
  };
}

async function validateCaseA(shippingAddressId: string, truffleId: string) {
  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: ids.successAttemptId,
        truffle_id: truffleId,
        shipping_address_id: shippingAddressId,
      }),
    }),
    requestId: "req-validation-a",
    authenticatedUserId: buyerId,
    store,
    stripeGateway: fakeStripeGateway,
  });

  const body = await response.json();
  const attempt = await store.getPaymentAttemptById(ids.successAttemptId);

  return {
    status: response.status,
    response_body_keys: Object.keys(body).sort(),
    response_body: body,
    attempt_status: attempt?.status ?? null,
    attempt_stripe_payment_intent_id: attempt?.stripePaymentIntentId ?? null,
    stripe_call:
      stripeCalls.find((call) =>
        call.payment_attempt_id === ids.successAttemptId
      ) ?? null,
  };
}

async function validateCaseB() {
  const response = await sendWebhook({
    eventId: ids.successEventId,
    eventType: "payment_intent.succeeded",
    paymentIntentId: ids.successStripeIntentId,
    paymentAttemptId: ids.successAttemptId,
  });

  const attempt = await store.getPaymentAttemptById(ids.successAttemptId);
  const order = attempt?.orderId
    ? await fetchSingle("orders", "*", { id: attempt.orderId })
    : null;
  const truffle = await fetchSingle(
    "truffles",
    "id,status",
    { id: attempt?.truffleId ?? "" },
  );

  return {
    status: response.status,
    body: await response.json(),
    payment_attempt_status: attempt?.status ?? null,
    order_id: attempt?.orderId ?? null,
    order_status: order?.status ?? null,
    order_stripe_payment_intent_id: order?.stripe_payment_intent_id ?? null,
    truffle_status: truffle?.status ?? null,
  };
}

async function validateCaseC() {
  const response = await sendWebhook({
    eventId: ids.successEventId,
    eventType: "payment_intent.succeeded",
    paymentIntentId: ids.successStripeIntentId,
    paymentAttemptId: ids.successAttemptId,
  });

  const orderCount = await countRows("orders", {
    stripe_payment_intent_id: ids.successStripeIntentId,
  });

  return {
    status: response.status,
    body: await response.json(),
    order_count_for_payment_intent: orderCount,
  };
}

async function validateCaseD(shippingAddressId: string, truffleId: string) {
  const createResponse = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: ids.failedAttemptId,
        truffle_id: truffleId,
        shipping_address_id: shippingAddressId,
      }),
    }),
    requestId: "req-validation-d-create",
    authenticatedUserId: buyerId,
    store,
    stripeGateway: fakeStripeGateway,
  });

  const createBody = await createResponse.json();
  const webhookResponse = await sendWebhook({
    eventId: ids.failedEventId,
    eventType: "payment_intent.payment_failed",
    paymentIntentId: ids.failedStripeIntentId,
    paymentAttemptId: ids.failedAttemptId,
    lastPaymentError: {
      code: "card_declined",
      message: "Validation decline",
    },
  });

  const attempt = await store.getPaymentAttemptById(ids.failedAttemptId);
  const orderCount = await countRows("orders", {
    stripe_payment_intent_id: ids.failedStripeIntentId,
  });

  return {
    create_status: createResponse.status,
    create_body: createBody,
    webhook_status: webhookResponse.status,
    webhook_body: await webhookResponse.json(),
    payment_attempt_status: attempt?.status ?? null,
    failure_code: await fetchColumn(
      "payment_attempts",
      "failure_code",
      { id: ids.failedAttemptId },
    ),
    order_count_for_payment_intent: orderCount,
  };
}

async function validateCaseE(shippingAddressId: string, truffleId: string) {
  const firstResponse = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: ids.concurrentAttemptIdA,
        truffle_id: truffleId,
        shipping_address_id: shippingAddressId,
      }),
    }),
    requestId: "req-validation-e-first",
    authenticatedUserId: buyerId,
    store,
    stripeGateway: fakeStripeGateway,
  });

  const secondResponse = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: ids.concurrentAttemptIdB,
        truffle_id: truffleId,
        shipping_address_id: shippingAddressId,
      }),
    }),
    requestId: "req-validation-e-second",
    authenticatedUserId: buyerId,
    store,
    stripeGateway: fakeStripeGateway,
  });

  const openAttemptCount = await countOpenAttemptsForTruffle(truffleId);

  return {
    first_status: firstResponse.status,
    first_body: await firstResponse.json(),
    second_status: secondResponse.status,
    second_body: await secondResponse.json(),
    open_requires_payment_method_attempts: openAttemptCount,
  };
}

async function sendWebhook(args: {
  eventId: string;
  eventType: "payment_intent.succeeded" | "payment_intent.payment_failed";
  paymentIntentId: string;
  paymentAttemptId: string;
  lastPaymentError?: {
    code?: string;
    message?: string;
  };
}) {
  const payload = JSON.stringify({
    id: args.eventId,
    type: args.eventType,
    data: {
      object: {
        id: args.paymentIntentId,
        object: "payment_intent",
        metadata: {
          payment_attempt_id: args.paymentAttemptId,
        },
        last_payment_error: args.lastPaymentError,
      },
    },
  });
  const timestamp = 1710000000;
  const signature = await signStripeWebhookPayload({
    secret: webhookSecret,
    payload,
    timestamp,
  });

  return await handleStripeWebhook({
    request: new Request("http://localhost/stripe_webhook", {
      method: "POST",
      headers: { "stripe-signature": signature },
      body: payload,
    }),
    requestId: `req-${args.eventId}`,
    webhookSecret,
    now: () => new Date("2024-03-09T16:00:00.000Z"),
    store,
  });
}

async function signStripeWebhookPayload(args: {
  secret: string;
  payload: string;
  timestamp: number;
}) {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(args.secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signed = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(`${args.timestamp}.${args.payload}`),
  );

  return `t=${args.timestamp},v1=${toHex(signed)}`;
}

function toHex(input: ArrayBuffer): string {
  return Array.from(new Uint8Array(input))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function cleanupValidationArtifacts(
  truffles: Array<{ id: string }>,
) {
  const orderIds = (
    await adminClient
      .from("orders")
      .select("id")
      .in("stripe_payment_intent_id", [
        ids.successStripeIntentId,
        ids.failedStripeIntentId,
        ids.concurrentStripeIntentId,
      ])
  ).data?.map((row) => row.id as string) ?? [];

  if (orderIds.length > 0) {
    const { error } = await adminClient
      .from("orders")
      .delete()
      .in("id", orderIds);
    if (error) {
      throw error;
    }
  }

  const { error: paymentAttemptDeleteError } = await adminClient
    .from("payment_attempts")
    .delete()
    .in("id", [
      ids.successAttemptId,
      ids.failedAttemptId,
      ids.concurrentAttemptIdA,
      ids.concurrentAttemptIdB,
    ]);
  if (paymentAttemptDeleteError) {
    throw paymentAttemptDeleteError;
  }

  const { error: webhookDeleteError } = await adminClient
    .from("stripe_webhook_events")
    .delete()
    .in("stripe_event_id", [ids.successEventId, ids.failedEventId]);
  if (webhookDeleteError) {
    throw webhookDeleteError;
  }

  for (const truffle of truffles) {
    await adminClient.rpc("sync_truffle_status_from_orders", {
      p_truffle_id: truffle.id,
    });
  }
}

async function fetchSingle(
  table: string,
  columns: string,
  filters: Record<string, string>,
  options?: { order?: string },
) {
  let query = adminClient.from(table).select(columns);
  for (const [column, value] of Object.entries(filters)) {
    query = query.eq(column, value);
  }
  if (options?.order) {
    const [column, direction] = options.order.split(".");
    query = query.order(column, { ascending: direction !== "desc" });
  }

  const { data, error } = await query.limit(1).maybeSingle();
  if (error) {
    throw error;
  }
  return data as Record<string, unknown> | null;
}

async function fetchColumn(
  table: string,
  column: string,
  filters: Record<string, string>,
) {
  const row = await fetchSingle(table, column, filters);
  return row?.[column] ?? null;
}

async function countRows(table: string, filters: Record<string, string>) {
  let query = adminClient
    .from(table)
    .select("*", { count: "exact", head: true });
  for (const [column, value] of Object.entries(filters)) {
    query = query.eq(column, value);
  }
  const { count, error } = await query;
  if (error) {
    throw error;
  }
  return count ?? 0;
}

async function countOpenAttemptsForTruffle(truffleId: string) {
  const { count, error } = await adminClient
    .from("payment_attempts")
    .select("*", { count: "exact", head: true })
    .eq("truffle_id", truffleId)
    .eq("status", "requires_payment_method");
  if (error) {
    throw error;
  }
  return count ?? 0;
}

await main();
