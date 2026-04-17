import type { SupabaseClient } from "@supabase/supabase-js";

type JsonPrimitive = string | number | boolean | null;
type JsonValue = JsonPrimitive | JsonObject | JsonValue[];
type JsonObject = { [key: string]: JsonValue };

const stripeApiBaseUrl = "https://api.stripe.com/v1";

export type FinancialOperationKind = "payment" | "refund" | "transfer";
export type FinancialOperationStatus =
  | "pending"
  | "processing"
  | "succeeded"
  | "failed";

export type OrderFinancialActionErrorCode =
  | "order_not_found"
  | "order_not_completed"
  | "order_not_paid"
  | "seller_not_stripe_ready"
  | "order_payment_not_captured"
  | "financial_operation_failed"
  | "stripe_api_error";

export class OrderFinancialActionError extends Error {
  constructor(
    readonly code: OrderFinancialActionErrorCode,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "OrderFinancialActionError";
  }
}

export type FinancialOrderRecord = {
  id: string;
  buyerId: string;
  sellerId: string;
  status: string;
  totalPrice: number;
  sellerAmount: number;
  stripePaymentIntentId: string;
  sellerStripeAccountId: string | null;
  sellerStripeReadyAt: string | null;
  sellerStripePayoutsEnabled: boolean;
  sellerStripeRequirementsPending: boolean;
};

export type FinancialOperationRecord = {
  id: string;
  orderId: string;
  kind: FinancialOperationKind;
  logicalKey: string;
  idempotencyKey: string;
  status: FinancialOperationStatus;
  amount: number;
  currency: string;
  stripePaymentIntentId: string | null;
  stripeRefundId: string | null;
  stripeTransferId: string | null;
  sourceChargeId: string | null;
  destinationAccountId: string | null;
  requestId: string | null;
  triggeredBy: string | null;
  triggerSource: string;
  failureCode: string | null;
  failureMessage: string | null;
  metadata: JsonObject;
  processedAt: string | null;
};

export type BeginFinancialOperationArgs = {
  orderId: string;
  kind: FinancialOperationKind;
  logicalKey: string;
  idempotencyKey: string;
  amount: number;
  currency: string;
  stripePaymentIntentId: string | null;
  triggerSource: string;
  triggeredBy: string | null;
  requestId: string | null;
  metadata: JsonObject;
};

export type OrderFinancialStore = {
  getOrderForFinancialAction(
    orderId: string,
  ): Promise<FinancialOrderRecord | null>;
  beginOrReadFinancialOperation(
    args: BeginFinancialOperationArgs,
  ): Promise<FinancialOperationRecord>;
  markFinancialOperationProcessing(operationId: string): Promise<void>;
  markFinancialOperationSucceeded(args: {
    operationId: string;
    stripeRefundId?: string | null;
    stripeTransferId?: string | null;
    sourceChargeId?: string | null;
    destinationAccountId?: string | null;
    metadata: JsonObject;
    processedAt: string;
  }): Promise<void>;
  markFinancialOperationFailed(args: {
    operationId: string;
    failureCode: string;
    failureMessage: string;
    metadata: JsonObject;
  }): Promise<void>;
  cancelOrderAfterRefund(args: {
    orderId: string;
    requestId: string | null;
    actorUserId: string | null;
    reason: string;
  }): Promise<{ orderId: string; idempotent: boolean }>;
  completeOrderSystem(args: {
    orderId: string;
    requestId: string | null;
    reason: string;
  }): Promise<{ orderId: string; idempotent: boolean }>;
  insertAuditLog(args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string | null;
    metadata: JsonObject;
  }): Promise<void>;
};

export type RetrievedPaymentIntent = {
  id: string;
  latestChargeId: string | null;
  status: string | null;
};

export type CreatedRefund = {
  id: string;
  status: string | null;
};

export type CreatedTransfer = {
  id: string;
  status: string | null;
};

export type OrderFinancialGateway = {
  retrievePaymentIntent(
    paymentIntentId: string,
  ): Promise<RetrievedPaymentIntent>;
  createRefund(args: {
    paymentIntentId: string;
    idempotencyKey: string;
    metadata: Record<string, string>;
  }): Promise<CreatedRefund>;
  createTransfer(args: {
    amountCents: number;
    destinationAccountId: string;
    sourceChargeId: string;
    idempotencyKey: string;
    metadata: Record<string, string>;
  }): Promise<CreatedTransfer>;
};

export async function releaseFundsForCompletedOrder(args: {
  orderId: string;
  requestId: string | null;
  triggerSource: string;
  triggeredBy: string | null;
  now?: () => Date;
  store: OrderFinancialStore;
  stripeGateway: OrderFinancialGateway;
}): Promise<{ idempotent: boolean; operation: FinancialOperationRecord }> {
  const now = args.now ?? (() => new Date());
  const order = await args.store.getOrderForFinancialAction(args.orderId);
  if (order == null) {
    throw new OrderFinancialActionError(
      "order_not_found",
      "The requested order was not found for payout processing.",
    );
  }

  if (order.status !== "completed") {
    throw new OrderFinancialActionError(
      "order_not_completed",
      "Funds can only be released after the order is completed.",
    );
  }

  if (
    order.sellerStripeAccountId == null ||
    order.sellerStripeAccountId.trim() === "" ||
    order.sellerStripeReadyAt == null ||
    order.sellerStripePayoutsEnabled !== true ||
    order.sellerStripeRequirementsPending !== false
  ) {
    throw new OrderFinancialActionError(
      "seller_not_stripe_ready",
      "Seller Stripe readiness could not be confirmed for payout.",
    );
  }

  const operation = await args.store.beginOrReadFinancialOperation({
    orderId: order.id,
    kind: "transfer",
    logicalKey: `transfer:order_completion:${order.id}`,
    idempotencyKey: `transfer:order_completion:${order.id}`,
    amount: roundMoney(order.sellerAmount),
    currency: "EUR",
    stripePaymentIntentId: order.stripePaymentIntentId,
    triggerSource: args.triggerSource,
    triggeredBy: args.triggeredBy,
    requestId: args.requestId,
    metadata: {
      order_id: order.id,
      stripe_payment_intent_id: order.stripePaymentIntentId,
    },
  });

  if (operation.status === "succeeded") {
    return { idempotent: true, operation };
  }

  await args.store.markFinancialOperationProcessing(operation.id);

  try {
    const paymentIntent = await args.stripeGateway.retrievePaymentIntent(
      order.stripePaymentIntentId,
    );
    if (
      paymentIntent.latestChargeId == null ||
      paymentIntent.latestChargeId.trim() === ""
    ) {
      throw new OrderFinancialActionError(
        "order_payment_not_captured",
        "The captured payment charge could not be resolved for payout.",
      );
    }

    const transfer = await args.stripeGateway.createTransfer({
      amountCents: toStripeAmountCents(order.sellerAmount),
      destinationAccountId: order.sellerStripeAccountId,
      sourceChargeId: paymentIntent.latestChargeId,
      idempotencyKey: operation.idempotencyKey,
      metadata: {
        order_id: order.id,
        stripe_payment_intent_id: order.stripePaymentIntentId,
        trigger_source: args.triggerSource,
      },
    });

    await args.store.markFinancialOperationSucceeded({
      operationId: operation.id,
      stripeTransferId: transfer.id,
      sourceChargeId: paymentIntent.latestChargeId,
      destinationAccountId: order.sellerStripeAccountId,
      processedAt: now().toISOString(),
      metadata: {
        stripe_status: transfer.status,
        source_charge_id: paymentIntent.latestChargeId,
      },
    });

    await args.store.insertAuditLog({
      entityType: "order",
      entityId: order.id,
      action: "seller_payout_released",
      performedBy: args.triggeredBy,
      metadata: {
        order_id: order.id,
        financial_operation_id: operation.id,
        stripe_transfer_id: transfer.id,
        trigger_source: args.triggerSource,
        request_id: args.requestId,
      },
    });

    return {
      idempotent: false,
      operation: {
        ...operation,
        status: "succeeded",
        stripeTransferId: transfer.id,
        sourceChargeId: paymentIntent.latestChargeId,
        destinationAccountId: order.sellerStripeAccountId,
        processedAt: now().toISOString(),
      },
    };
  } catch (error) {
    const normalized = normalizeFinancialFailure(error);
    await args.store.markFinancialOperationFailed({
      operationId: operation.id,
      failureCode: normalized.code,
      failureMessage: normalized.message,
      metadata: {
        trigger_source: args.triggerSource,
        request_id: args.requestId,
      },
    });
    throw normalized;
  }
}

export async function refundOrderPayment(args: {
  orderId: string;
  requestId: string | null;
  triggerSource: string;
  triggeredBy: string | null;
  refundReason: string;
  now?: () => Date;
  store: OrderFinancialStore;
  stripeGateway: OrderFinancialGateway;
}): Promise<{ idempotent: boolean; operation: FinancialOperationRecord }> {
  const now = args.now ?? (() => new Date());
  const order = await args.store.getOrderForFinancialAction(args.orderId);
  if (order == null) {
    throw new OrderFinancialActionError(
      "order_not_found",
      "The requested order was not found for refund processing.",
    );
  }

  if (order.status !== "paid") {
    throw new OrderFinancialActionError(
      "order_not_paid",
      "Only paid orders can be refunded in the MVP flows.",
    );
  }

  const operation = await args.store.beginOrReadFinancialOperation({
    orderId: order.id,
    kind: "refund",
    logicalKey: `refund:primary:${order.id}`,
    idempotencyKey: `refund:primary:${order.id}`,
    amount: roundMoney(order.totalPrice),
    currency: "EUR",
    stripePaymentIntentId: order.stripePaymentIntentId,
    triggerSource: args.triggerSource,
    triggeredBy: args.triggeredBy,
    requestId: args.requestId,
    metadata: {
      order_id: order.id,
      stripe_payment_intent_id: order.stripePaymentIntentId,
      refund_reason: args.refundReason,
    },
  });

  if (operation.status === "succeeded") {
    return { idempotent: true, operation };
  }

  await args.store.markFinancialOperationProcessing(operation.id);

  try {
    const refund = await args.stripeGateway.createRefund({
      paymentIntentId: order.stripePaymentIntentId,
      idempotencyKey: operation.idempotencyKey,
      metadata: {
        order_id: order.id,
        stripe_payment_intent_id: order.stripePaymentIntentId,
        refund_reason: args.refundReason,
        trigger_source: args.triggerSource,
      },
    });

    await args.store.markFinancialOperationSucceeded({
      operationId: operation.id,
      stripeRefundId: refund.id,
      processedAt: now().toISOString(),
      metadata: {
        stripe_status: refund.status,
        refund_reason: args.refundReason,
      },
    });

    await args.store.insertAuditLog({
      entityType: "order",
      entityId: order.id,
      action: "buyer_refund_processed",
      performedBy: args.triggeredBy,
      metadata: {
        order_id: order.id,
        financial_operation_id: operation.id,
        stripe_refund_id: refund.id,
        trigger_source: args.triggerSource,
        request_id: args.requestId,
        refund_reason: args.refundReason,
      },
    });

    return {
      idempotent: false,
      operation: {
        ...operation,
        status: "succeeded",
        stripeRefundId: refund.id,
        processedAt: now().toISOString(),
      },
    };
  } catch (error) {
    const normalized = normalizeFinancialFailure(error);
    await args.store.markFinancialOperationFailed({
      operationId: operation.id,
      failureCode: normalized.code,
      failureMessage: normalized.message,
      metadata: {
        trigger_source: args.triggerSource,
        request_id: args.requestId,
        refund_reason: args.refundReason,
      },
    });
    throw normalized;
  }
}

export function createStripeOrderFinancialGateway(
  fetchFn: typeof fetch,
  secretKey: string,
): OrderFinancialGateway {
  return {
    async retrievePaymentIntent(paymentIntentId: string) {
      const response = await stripeRequest(fetchFn, secretKey, {
        method: "GET",
        path: `/payment_intents/${encodeURIComponent(paymentIntentId)}`,
      });

      return {
        id: readString(response, "id") ?? paymentIntentId,
        latestChargeId: readString(response, "latest_charge"),
        status: readString(response, "status"),
      };
    },

    async createRefund(args) {
      const body = new URLSearchParams({
        payment_intent: args.paymentIntentId,
      });
      appendMetadata(body, args.metadata);

      const response = await stripeRequest(fetchFn, secretKey, {
        method: "POST",
        path: "/refunds",
        body,
        idempotencyKey: args.idempotencyKey,
      });

      return {
        id: readRequiredString(response, "id"),
        status: readString(response, "status"),
      };
    },

    async createTransfer(args) {
      const body = new URLSearchParams({
        amount: `${args.amountCents}`,
        currency: "eur",
        destination: args.destinationAccountId,
        source_transaction: args.sourceChargeId,
      });
      appendMetadata(body, args.metadata);

      const response = await stripeRequest(fetchFn, secretKey, {
        method: "POST",
        path: "/transfers",
        body,
        idempotencyKey: args.idempotencyKey,
      });

      return {
        id: readRequiredString(response, "id"),
        status: readString(response, "status"),
      };
    },
  };
}

export function createSupabaseOrderFinancialStore(
  adminClient: SupabaseClient,
): OrderFinancialStore {
  return {
    async getOrderForFinancialAction(orderId) {
      const { data, error } = await adminClient
        .from("orders")
        .select(
          "id, buyer_id, seller_id, status, total_price, seller_amount, stripe_payment_intent_id, seller:users!orders_seller_id_fkey(stripe_account_id, stripe_ready_at, stripe_payouts_enabled, stripe_requirements_pending)",
        )
        .eq("id", orderId)
        .maybeSingle();

      if (error != null) {
        throw error;
      }
      if (data == null) return null;

      const seller = Array.isArray(data.seller) ? data.seller[0] : data.seller;

      return {
        id: data.id as string,
        buyerId: data.buyer_id as string,
        sellerId: data.seller_id as string,
        status: data.status as string,
        totalPrice: toNumber(data.total_price),
        sellerAmount: toNumber(data.seller_amount),
        stripePaymentIntentId: data.stripe_payment_intent_id as string,
        sellerStripeAccountId: readString(seller, "stripe_account_id"),
        sellerStripeReadyAt: readString(seller, "stripe_ready_at"),
        sellerStripePayoutsEnabled:
          readBoolean(seller, "stripe_payouts_enabled") === true,
        sellerStripeRequirementsPending:
          readBoolean(seller, "stripe_requirements_pending") !== false,
      };
    },

    async beginOrReadFinancialOperation(args) {
      const payload = {
        order_id: args.orderId,
        kind: args.kind,
        logical_key: args.logicalKey,
        idempotency_key: args.idempotencyKey,
        amount: roundMoney(args.amount),
        currency: args.currency.toUpperCase(),
        stripe_payment_intent_id: args.stripePaymentIntentId,
        trigger_source: args.triggerSource,
        triggered_by: args.triggeredBy,
        request_id: args.requestId,
        metadata: args.metadata,
      };

      const { error: insertError } = await adminClient
        .from("order_financial_operations")
        .insert(payload)
        .select("id")
        .single();

      if (insertError != null && insertError.code !== "23505") {
        throw insertError;
      }

      const { data, error } = await adminClient
        .from("order_financial_operations")
        .select(
          "id, order_id, kind, logical_key, idempotency_key, status, amount, currency, stripe_payment_intent_id, stripe_refund_id, stripe_transfer_id, source_charge_id, destination_account_id, request_id, triggered_by, trigger_source, failure_code, failure_message, metadata, processed_at",
        )
        .eq("logical_key", args.logicalKey)
        .single();

      if (error != null || data == null) {
        throw error ?? new Error("Financial operation could not be loaded.");
      }

      return mapFinancialOperationRow(data);
    },

    async markFinancialOperationProcessing(operationId) {
      const { error } = await adminClient
        .from("order_financial_operations")
        .update({
          status: "processing",
          failure_code: null,
          failure_message: null,
        })
        .eq("id", operationId);

      if (error != null) {
        throw error;
      }
    },

    async markFinancialOperationSucceeded(args) {
      const { error } = await adminClient
        .from("order_financial_operations")
        .update({
          status: "succeeded",
          stripe_refund_id: args.stripeRefundId ?? undefined,
          stripe_transfer_id: args.stripeTransferId ?? undefined,
          source_charge_id: args.sourceChargeId ?? undefined,
          destination_account_id: args.destinationAccountId ?? undefined,
          failure_code: null,
          failure_message: null,
          metadata: args.metadata,
          processed_at: args.processedAt,
        })
        .eq("id", args.operationId);

      if (error != null) {
        throw error;
      }
    },

    async markFinancialOperationFailed(args) {
      const { error } = await adminClient
        .from("order_financial_operations")
        .update({
          status: "failed",
          failure_code: args.failureCode,
          failure_message: args.failureMessage,
          metadata: args.metadata,
        })
        .eq("id", args.operationId);

      if (error != null) {
        throw error;
      }
    },

    async cancelOrderAfterRefund(args) {
      const { data, error } = await adminClient
        .rpc("cancel_order_after_refund", {
          p_order_id: args.orderId,
          p_request_id: args.requestId,
          p_actor_user_id: args.actorUserId,
          p_reason: args.reason,
        })
        .single();

      if (error != null || data == null) {
        throw error ?? new Error("cancel_order_after_refund did not return data.");
      }

      const result = data as Record<string, unknown>;

      return {
        orderId: result.order_id as string,
        idempotent: result.idempotent === true,
      };
    },

    async completeOrderSystem(args) {
      const { data, error } = await adminClient
        .rpc("complete_order_system", {
          p_order_id: args.orderId,
          p_request_id: args.requestId,
          p_reason: args.reason,
        })
        .single();

      if (error != null || data == null) {
        throw error ?? new Error("complete_order_system did not return data.");
      }

      const result = data as Record<string, unknown>;

      return {
        orderId: result.order_id as string,
        idempotent: result.idempotent === true,
      };
    },

    async insertAuditLog(args) {
      const { error } = await adminClient.from("audit_logs").insert({
        entity_type: args.entityType,
        entity_id: args.entityId,
        action: args.action,
        performed_by: args.performedBy,
        metadata: args.metadata,
      });

      if (error != null) {
        throw error;
      }
    },
  };
}

function mapFinancialOperationRow(row: Record<string, unknown>): FinancialOperationRecord {
  return {
    id: readRequiredString(row, "id"),
    orderId: readRequiredString(row, "order_id"),
    kind: readRequiredString(row, "kind") as FinancialOperationKind,
    logicalKey: readRequiredString(row, "logical_key"),
    idempotencyKey: readRequiredString(row, "idempotency_key"),
    status: readRequiredString(row, "status") as FinancialOperationStatus,
    amount: toNumber(row.amount),
    currency: readRequiredString(row, "currency"),
    stripePaymentIntentId: readString(row, "stripe_payment_intent_id"),
    stripeRefundId: readString(row, "stripe_refund_id"),
    stripeTransferId: readString(row, "stripe_transfer_id"),
    sourceChargeId: readString(row, "source_charge_id"),
    destinationAccountId: readString(row, "destination_account_id"),
    requestId: readString(row, "request_id"),
    triggeredBy: readString(row, "triggered_by"),
    triggerSource: readRequiredString(row, "trigger_source"),
    failureCode: readString(row, "failure_code"),
    failureMessage: readString(row, "failure_message"),
    metadata: readJsonObject(row, "metadata"),
    processedAt: readString(row, "processed_at"),
  };
}

async function stripeRequest(
  fetchFn: typeof fetch,
  secretKey: string,
  args: {
    method: "GET" | "POST";
    path: string;
    body?: URLSearchParams;
    idempotencyKey?: string;
  },
): Promise<Record<string, unknown>> {
  const response = await fetchFn(`${stripeApiBaseUrl}${args.path}`, {
    method: args.method,
    headers: {
      Authorization: `Bearer ${secretKey}`,
      ...(args.body == null
        ? {}
        : { "Content-Type": "application/x-www-form-urlencoded" }),
      ...(args.idempotencyKey == null
        ? {}
        : { "Idempotency-Key": args.idempotencyKey }),
    },
    body: args.body,
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new OrderFinancialActionError(
      "stripe_api_error",
      readStripeErrorMessage(body) ??
        `Stripe API request failed with status ${response.status}.`,
      { status: response.status, body },
    );
  }

  return isRecord(body) ? body : {};
}

function appendMetadata(
  params: URLSearchParams,
  metadata: Record<string, string>,
) {
  for (const [key, value] of Object.entries(metadata)) {
    params.set(`metadata[${key}]`, value);
  }
}

function normalizeFinancialFailure(error: unknown): OrderFinancialActionError {
  if (error instanceof OrderFinancialActionError) {
    return error;
  }

  const message = error instanceof Error ? error.message : String(error);
  return new OrderFinancialActionError(
    "financial_operation_failed",
    message,
    error,
  );
}

function readStripeErrorMessage(body: unknown): string | null {
  if (!isRecord(body)) return null;
  const error = body.error;
  if (!isRecord(error)) return null;
  const message = error.message;
  return typeof message === "string" && message.trim() !== ""
    ? message
    : null;
}

function readRequiredString(record: Record<string, unknown>, key: string): string {
  const value = readString(record, key);
  if (value == null) {
    throw new Error(`Expected string field ${key}.`);
  }
  return value;
}

function readString(
  record: unknown,
  key: string,
): string | null {
  if (!isRecord(record)) return null;
  const value = record[key];
  return typeof value === "string" && value.trim() !== "" ? value : null;
}

function readBoolean(record: unknown, key: string): boolean | null {
  if (!isRecord(record)) return null;
  const value = record[key];
  return typeof value === "boolean" ? value : null;
}

function readJsonObject(record: Record<string, unknown>, key: string): JsonObject {
  const value = record[key];
  return isRecord(value) ? value as JsonObject : {};
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function toNumber(value: unknown): number {
  if (typeof value === "number") return value;
  return Number.parseFloat(`${value}`);
}

function roundMoney(amount: number): number {
  return Math.round(amount * 100) / 100;
}

function toStripeAmountCents(amount: number): number {
  return Math.round(roundMoney(amount) * 100);
}
