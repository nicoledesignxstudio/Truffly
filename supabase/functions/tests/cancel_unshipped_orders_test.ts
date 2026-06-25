import { handleCancelUnshippedOrders } from "../cancel_unshipped_orders/index.ts";

Deno.test("cancel_unshipped_orders queries paid orders older than 48 hours by created_at", async () => {
  const calls: Array<{ name: string; args: unknown[] }> = [];
  const processedOrders: string[] = [];
  const now = new Date("2026-05-26T12:00:00.000Z");

  const adminClient = {
    from(table: string) {
      calls.push({ name: "from", args: [table] });
      const builder = {
        select(...args: unknown[]) {
          calls.push({ name: "select", args });
          return builder;
        },
        eq(...args: unknown[]) {
          calls.push({ name: "eq", args });
          return builder;
        },
        lte(...args: unknown[]) {
          calls.push({ name: "lte", args });
          return builder;
        },
        order(...args: unknown[]) {
          calls.push({ name: "order", args });
          if (table === "orders") {
            return Promise.resolve({
              data: [{ id: "order-old-paid", truffleId: "truffle-1" }],
              error: null,
            });
          }
          if (table === "reviews") {
            return Promise.resolve({
              data: [],
              error: null,
            });
          }
          return Promise.resolve({
            data: [],
            error: null,
          });
        },
        maybeSingle() {
          calls.push({ name: "maybeSingle", args: [] });
          if (table === "truffles") {
            return Promise.resolve({
              data: {
                id: "truffle-1",
                status: "active",
                expires_at: "2026-06-01T00:00:00.000Z",
              },
              error: null,
            });
          }
          return Promise.resolve({
            data: null,
            error: null,
          });
        },
      };
      return builder;
    },
  };

  const financialStore = {
    getOrderForFinancialAction: async (orderId: string) => ({
      id: orderId,
      buyerId: "buyer-1",
      sellerId: "seller-1",
      truffleId: "truffle-1",
      status: "paid",
      totalPrice: 100,
      sellerAmount: 90,
      stripePaymentIntentId: "pi_1",
      sellerStripeAccountId: "acct_1",
      sellerStripeReadyAt: "2026-05-26T10:00:00.000Z",
      sellerStripePayoutsEnabled: true,
      sellerStripeRequirementsPending: false,
    }),
    beginOrReadFinancialOperation: async () => ({
      id: "fo_refund_1",
      orderId: "order-old-paid",
      kind: "refund",
      logicalKey: "refund:primary:order-old-paid",
      idempotencyKey: "refund:primary:order-old-paid",
      status: "pending",
      amount: 100,
      currency: "EUR",
      stripePaymentIntentId: "pi_1",
      stripeRefundId: null,
      stripeTransferId: null,
      sourceChargeId: null,
      destinationAccountId: null,
      requestId: "req-cancel",
      triggeredBy: null,
      triggerSource: "auto_cancel_unshipped_48h",
      failureCode: null,
      failureMessage: null,
      metadata: {},
      processedAt: null,
    }),
    markFinancialOperationProcessing: async () => undefined,
    markFinancialOperationSucceeded: async () => undefined,
    markFinancialOperationFailed: async () => undefined,
    cancelOrderAfterRefund: async (args: { orderId: string }) => {
      processedOrders.push(args.orderId);
      return { orderId: args.orderId, idempotent: false };
    },
    insertAuditLog: async () => undefined,
  };

  const financialGateway = {
    retrievePaymentIntent: async () => ({
      id: "pi_1",
      latestChargeId: "ch_1",
      status: "succeeded",
    }),
    createRefund: async () => ({ id: "re_1", status: "succeeded" }),
    createTransfer: async () => ({ id: "tr_1", status: "paid" }),
  };

  const response = await handleCancelUnshippedOrders(
    new Request("http://localhost/cancel_unshipped_orders", {
      method: "POST",
      headers: {
        Authorization: "Bearer cron-secret",
        "x-request-id": "req-cancel",
      },
    }),
    {
      adminClient: adminClient as any,
      financialStore: financialStore as any,
      financialGateway: financialGateway as any,
      cronSecret: "cron-secret",
      now: () => now,
    },
  );

  assertEquals(response.status, 200);
  assertEquals(await response.json(), {
    success: true,
    request_id: "req-cancel",
    scanned: 1,
    refunded: 1,
    cancelled: 1,
    failures: [],
  });
  assertEquals(processedOrders, ["order-old-paid"]);
  assertEquals(
    calls.some((call) =>
      call.name === "eq" &&
      call.args[0] === "status" &&
      call.args[1] === "paid"
    ),
    true,
  );
  assertEquals(
    calls.some((call) =>
      call.name === "lte" &&
      call.args[0] === "created_at" &&
      call.args[1] === "2026-05-24T12:00:00.000Z"
    ),
    true,
  );
  assertEquals(
    calls.some((call) => call.name === "from" && call.args[0] === "reviews"),
    true,
  );
  assertEquals(
    calls.some((call) => call.name === "from" && call.args[0] === "truffles"),
    true,
  );
});

Deno.test("cancel_unshipped_orders serializes unknown order failures", async () => {
  const adminClient = {
    from(table: string) {
      const builder = {
        select() {
          return builder;
        },
        eq() {
          return builder;
        },
        lte() {
          return builder;
        },
        order() {
          if (table === "orders") {
            return Promise.resolve({
              data: [{ id: "order-bad", truffleId: null }],
              error: null,
            });
          }
          if (table === "reviews") {
            return Promise.resolve({
              data: [],
              error: null,
            });
          }
          return Promise.resolve({
            data: [],
            error: null,
          });
        },
        maybeSingle() {
          if (table === "truffles") {
            return Promise.resolve({
              data: {
                id: "truffle-1",
                status: "active",
                expires_at: "2026-06-01T00:00:00.000Z",
              },
              error: null,
            });
          }
          return Promise.resolve({
            data: null,
            error: null,
          });
        },
      };
      return builder;
    },
  };

  const financialStore = {
    getOrderForFinancialAction: async () => ({
      id: "order-bad",
      buyerId: "buyer-1",
      sellerId: "seller-1",
      truffleId: null,
      status: "paid",
      totalPrice: 100,
      sellerAmount: 90,
      stripePaymentIntentId: "pi_1",
      sellerStripeAccountId: "acct_1",
      sellerStripeReadyAt: "2026-05-26T10:00:00.000Z",
      sellerStripePayoutsEnabled: true,
      sellerStripeRequirementsPending: false,
    }),
    beginOrReadFinancialOperation: async () => ({
      id: "fo_refund_1",
      orderId: "order-bad",
      kind: "refund",
      logicalKey: "refund:primary:order-bad",
      idempotencyKey: "refund:primary:order-bad",
      status: "pending",
      amount: 100,
      currency: "EUR",
      stripePaymentIntentId: "pi_1",
      stripeRefundId: null,
      stripeTransferId: null,
      sourceChargeId: null,
      destinationAccountId: null,
      requestId: "req-cancel",
      triggeredBy: null,
      triggerSource: "auto_cancel_unshipped_48h",
      failureCode: null,
      failureMessage: null,
      metadata: {},
      processedAt: null,
    }),
    markFinancialOperationProcessing: async () => undefined,
    markFinancialOperationSucceeded: async () => undefined,
    markFinancialOperationFailed: async () => undefined,
    cancelOrderAfterRefund: async () => {
      throw {
        code: "rpc_failed",
        message: "Refund RPC failed",
        details: { retryable: false, source: "stripe" },
      };
    },
    insertAuditLog: async () => undefined,
  };

  const financialGateway = {
    retrievePaymentIntent: async () => ({
      id: "pi_1",
      latestChargeId: "ch_1",
      status: "succeeded",
    }),
    createRefund: async () => ({ id: "re_1", status: "succeeded" }),
    createTransfer: async () => ({ id: "tr_1", status: "paid" }),
  };

  const response = await handleCancelUnshippedOrders(
    new Request("http://localhost/cancel_unshipped_orders", {
      method: "POST",
      headers: {
        Authorization: "Bearer cron-secret",
        "x-request-id": "req-cancel",
      },
    }),
    {
      adminClient: adminClient as any,
      financialStore: financialStore as any,
      financialGateway: financialGateway as any,
      cronSecret: "cron-secret",
      now: () => new Date("2026-05-26T12:00:00.000Z"),
    },
  );

  assertEquals(response.status, 200);
  const body = await response.json() as Record<string, unknown>;
  const failures = body.failures as Array<Record<string, unknown>>;
  assertEquals(failures.length, 1);
  assertEquals(failures[0].order_id, "order-bad");
  assertEquals(failures[0].error_code, "rpc_failed");
  assertEquals(failures[0].error_message, "Refund RPC failed");
  const errorDetails = failures[0].error_details as Record<string, unknown>;
  assertEquals(errorDetails.code, "rpc_failed");
  assertEquals(errorDetails.message, "Refund RPC failed");
});

Deno.test("cancel_unshipped_orders serializes refund step failures", async () => {
  const adminClient = {
    from(table: string) {
      const builder = {
        select() {
          return builder;
        },
        eq() {
          return builder;
        },
        lte() {
          return builder;
        },
        order() {
          if (table === "orders") {
            return Promise.resolve({
              data: [{ id: "order-refund-bad", truffleId: null }],
              error: null,
            });
          }
          if (table === "reviews") {
            return Promise.resolve({
              data: [],
              error: null,
            });
          }
          return Promise.resolve({
            data: [],
            error: null,
          });
        },
        maybeSingle() {
          return Promise.resolve({
            data: null,
            error: null,
          });
        },
      };
      return builder;
    },
  };

  const financialStore = {
    getOrderForFinancialAction: async () => ({
      id: "order-refund-bad",
      buyerId: "buyer-1",
      sellerId: "seller-1",
      truffleId: null,
      status: "paid",
      totalPrice: 100,
      sellerAmount: 90,
      stripePaymentIntentId: "pi_1",
      sellerStripeAccountId: "acct_1",
      sellerStripeReadyAt: "2026-05-26T10:00:00.000Z",
      sellerStripePayoutsEnabled: true,
      sellerStripeRequirementsPending: false,
    }),
    beginOrReadFinancialOperation: async () => ({
      id: "fo_refund_2",
      orderId: "order-refund-bad",
      kind: "refund",
      logicalKey: "refund:primary:order-refund-bad",
      idempotencyKey: "refund:primary:order-refund-bad",
      status: "pending",
      amount: 100,
      currency: "EUR",
      stripePaymentIntentId: "pi_1",
      stripeRefundId: null,
      stripeTransferId: null,
      sourceChargeId: null,
      destinationAccountId: null,
      requestId: "req-cancel",
      triggeredBy: null,
      triggerSource: "auto_cancel_unshipped_48h",
      failureCode: null,
      failureMessage: null,
      metadata: {},
      processedAt: null,
    }),
    markFinancialOperationProcessing: async () => undefined,
    markFinancialOperationSucceeded: async () => undefined,
    markFinancialOperationFailed: async () => undefined,
    cancelOrderAfterRefund: async () => {
      throw new Error("should not reach cancel step");
    },
    insertAuditLog: async () => undefined,
  };

  const financialGateway = {
    retrievePaymentIntent: async () => ({
      id: "pi_1",
      latestChargeId: "ch_1",
      status: "succeeded",
    }),
    createRefund: async () => {
      throw {
        code: "stripe_refund_failed",
        message: "Stripe refund request failed",
        details: { http_status: 402 },
      };
    },
    createTransfer: async () => ({ id: "tr_1", status: "paid" }),
  };

  const response = await handleCancelUnshippedOrders(
    new Request("http://localhost/cancel_unshipped_orders", {
      method: "POST",
      headers: {
        Authorization: "Bearer cron-secret",
        "x-request-id": "req-cancel",
      },
    }),
    {
      adminClient: adminClient as any,
      financialStore: financialStore as any,
      financialGateway: financialGateway as any,
      cronSecret: "cron-secret",
      now: () => new Date("2026-05-26T12:00:00.000Z"),
    },
  );

  assertEquals(response.status, 200);
  const body = await response.json() as Record<string, unknown>;
  const failures = body.failures as Array<Record<string, unknown>>;
  assertEquals(failures.length, 1);
  assertEquals(failures[0].step, "refund_start");
  assertEquals(failures[0].error_code, "financial_operation_failed");
  assertEquals(failures[0].error_message, "Stripe refund request failed");
  const errorDetails = failures[0].error_details as Record<string, unknown>;
  assertEquals(errorDetails.code, "financial_operation_failed");
  assertEquals(errorDetails.message, "Stripe refund request failed");
});

function assertEquals(actual: unknown, expected: unknown): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${
        JSON.stringify(actual)
      }`,
    );
  }
}
