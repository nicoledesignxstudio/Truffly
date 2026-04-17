import {
  refundOrderPayment,
  releaseFundsForCompletedOrder,
} from "../_shared/order_financials.ts";

Deno.test("release funds creates one transfer for a completed order", async () => {
  let transferCreated = false;
  let markedSucceeded = false;

  const result = await releaseFundsForCompletedOrder({
    orderId: "order-1",
    requestId: "req-transfer-1",
    triggerSource: "buyer_confirm_delivery",
    triggeredBy: "buyer-1",
    store: createNoopStore({
      getOrderForFinancialAction: async () => ({
        id: "order-1",
        buyerId: "buyer-1",
        sellerId: "seller-1",
        status: "completed",
        totalPrice: 79,
        sellerAmount: 71.1,
        stripePaymentIntentId: "pi_1",
        sellerStripeAccountId: "acct_ready",
        sellerStripeReadyAt: "2026-04-08T10:00:00.000Z",
        sellerStripePayoutsEnabled: true,
        sellerStripeRequirementsPending: false,
      }),
      beginOrReadFinancialOperation: async () => ({
        id: "fo_transfer_1",
        orderId: "order-1",
        kind: "transfer",
        logicalKey: "transfer:order_completion:order-1",
        idempotencyKey: "transfer:order_completion:order-1",
        status: "pending",
        amount: 71.1,
        currency: "EUR",
        stripePaymentIntentId: "pi_1",
        stripeRefundId: null,
        stripeTransferId: null,
        sourceChargeId: null,
        destinationAccountId: null,
        requestId: "req-transfer-1",
        triggeredBy: "buyer-1",
        triggerSource: "buyer_confirm_delivery",
        failureCode: null,
        failureMessage: null,
        metadata: {},
        processedAt: null,
      }),
      markFinancialOperationSucceeded: async () => {
        markedSucceeded = true;
      },
    }),
    stripeGateway: createNoopGateway({
      retrievePaymentIntent: async () => ({
        id: "pi_1",
        latestChargeId: "ch_1",
        status: "succeeded",
      }),
      createTransfer: async () => {
        transferCreated = true;
        return {
          id: "tr_1",
          status: "paid",
        };
      },
    }),
  });

  assertEquals(result.idempotent, false);
  assertEquals(transferCreated, true);
  assertEquals(markedSucceeded, true);
  assertEquals(result.operation.stripeTransferId, "tr_1");
});

Deno.test("release funds is idempotent when transfer already succeeded", async () => {
  let transferCreated = false;

  const result = await releaseFundsForCompletedOrder({
    orderId: "order-1",
    requestId: "req-transfer-2",
    triggerSource: "buyer_confirm_delivery",
    triggeredBy: "buyer-1",
    store: createNoopStore({
      getOrderForFinancialAction: async () => ({
        id: "order-1",
        buyerId: "buyer-1",
        sellerId: "seller-1",
        status: "completed",
        totalPrice: 79,
        sellerAmount: 71.1,
        stripePaymentIntentId: "pi_1",
        sellerStripeAccountId: "acct_ready",
        sellerStripeReadyAt: "2026-04-08T10:00:00.000Z",
        sellerStripePayoutsEnabled: true,
        sellerStripeRequirementsPending: false,
      }),
      beginOrReadFinancialOperation: async () => ({
        id: "fo_transfer_1",
        orderId: "order-1",
        kind: "transfer",
        logicalKey: "transfer:order_completion:order-1",
        idempotencyKey: "transfer:order_completion:order-1",
        status: "succeeded",
        amount: 71.1,
        currency: "EUR",
        stripePaymentIntentId: "pi_1",
        stripeRefundId: null,
        stripeTransferId: "tr_existing",
        sourceChargeId: "ch_existing",
        destinationAccountId: "acct_ready",
        requestId: "req-transfer-2",
        triggeredBy: "buyer-1",
        triggerSource: "buyer_confirm_delivery",
        failureCode: null,
        failureMessage: null,
        metadata: {},
        processedAt: "2026-04-08T10:00:00.000Z",
      }),
    }),
    stripeGateway: createNoopGateway({
      createTransfer: async () => {
        transferCreated = true;
        return { id: "tr_unexpected", status: "paid" };
      },
    }),
  });

  assertEquals(result.idempotent, true);
  assertEquals(transferCreated, false);
});

Deno.test("refund payment creates one refund for a paid order", async () => {
  let refundCreated = false;
  let markedSucceeded = false;

  const result = await refundOrderPayment({
    orderId: "order-2",
    requestId: "req-refund-1",
    triggerSource: "seller_cancel_order",
    triggeredBy: "seller-1",
    refundReason: "seller_cancelled_before_shipment",
    store: createNoopStore({
      getOrderForFinancialAction: async () => ({
        id: "order-2",
        buyerId: "buyer-1",
        sellerId: "seller-1",
        status: "paid",
        totalPrice: 79,
        sellerAmount: 71.1,
        stripePaymentIntentId: "pi_2",
        sellerStripeAccountId: "acct_ready",
        sellerStripeReadyAt: "2026-04-08T10:00:00.000Z",
        sellerStripePayoutsEnabled: true,
        sellerStripeRequirementsPending: false,
      }),
      beginOrReadFinancialOperation: async () => ({
        id: "fo_refund_1",
        orderId: "order-2",
        kind: "refund",
        logicalKey: "refund:primary:order-2",
        idempotencyKey: "refund:primary:order-2",
        status: "pending",
        amount: 79,
        currency: "EUR",
        stripePaymentIntentId: "pi_2",
        stripeRefundId: null,
        stripeTransferId: null,
        sourceChargeId: null,
        destinationAccountId: null,
        requestId: "req-refund-1",
        triggeredBy: "seller-1",
        triggerSource: "seller_cancel_order",
        failureCode: null,
        failureMessage: null,
        metadata: {},
        processedAt: null,
      }),
      markFinancialOperationSucceeded: async () => {
        markedSucceeded = true;
      },
    }),
    stripeGateway: createNoopGateway({
      createRefund: async () => {
        refundCreated = true;
        return {
          id: "re_1",
          status: "succeeded",
        };
      },
    }),
  });

  assertEquals(result.idempotent, false);
  assertEquals(refundCreated, true);
  assertEquals(markedSucceeded, true);
  assertEquals(result.operation.stripeRefundId, "re_1");
});

function createNoopStore(overrides: Record<string, unknown> = {}) {
  return {
    getOrderForFinancialAction: async () => null,
    beginOrReadFinancialOperation: async () => {
      throw new Error("beginOrReadFinancialOperation override required");
    },
    markFinancialOperationProcessing: async () => undefined,
    markFinancialOperationSucceeded: async () => undefined,
    markFinancialOperationFailed: async () => undefined,
    cancelOrderAfterRefund: async () => ({
      orderId: "order-1",
      idempotent: false,
    }),
    completeOrderSystem: async () => ({
      orderId: "order-1",
      idempotent: false,
    }),
    insertAuditLog: async () => undefined,
    ...overrides,
  } as any;
}

function createNoopGateway(overrides: Record<string, unknown> = {}) {
  return {
    retrievePaymentIntent: async () => ({
      id: "pi_default",
      latestChargeId: "ch_default",
      status: "succeeded",
    }),
    createRefund: async () => ({
      id: "re_default",
      status: "succeeded",
    }),
    createTransfer: async () => ({
      id: "tr_default",
      status: "paid",
    }),
    ...overrides,
  } as any;
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (actual !== expected) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${
        JSON.stringify(actual)
      }`,
    );
  }
}
