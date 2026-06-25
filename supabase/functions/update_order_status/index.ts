import { createClient } from "@supabase/supabase-js";
import {
  createStripeOrderFinancialGateway,
  createSupabaseOrderFinancialStore,
  OrderFinancialActionError,
  refundOrderPayment,
  releaseFundsForCompletedOrder,
} from "../_shared/order_financials.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type OrderAction = "confirm_receipt" | "mark_shipped" | "cancel_order";
type OrderStatus = "paid" | "shipped" | "completed" | "cancelled";

type UpdateOrderPayload = {
  action?: OrderAction;
  order_id?: string;
  tracking_code?: string;
};

type UpdateOrderRpcResult = {
  order_id: string;
  resulting_status: OrderStatus;
  idempotent: boolean;
};

const maxTrackingCodeLength = 120;

type UpdateOrderErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "invalid_json_body"
  | "invalid_action"
  | "invalid_order_id"
  | "invalid_tracking_code"
  | "order_not_found"
  | "order_not_accessible"
  | "invalid_order_transition"
  | "shipping_window_expired"
  | "order_auto_cancel_pending"
  | "missing_runtime_secret"
  | "refund_failed"
  | "internal_error";

class UpdateOrderFlowError extends Error {
  constructor(
    readonly code: UpdateOrderErrorCode,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "UpdateOrderFlowError";
  }
}

Deno.serve(async (request) => {
  const requestId = getRequestId(request);
  let step = "init";
  let authUserId: string | null = null;
  let orderId: string | null = null;
  let action: OrderAction | null = null;
  let targetStatus: OrderStatus | null = null;
  let trackingPresent = false;
  let payloadSummary: Record<string, unknown> = {};

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    step = "validate_method";
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      requestId,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const authHeader = request.headers.get("Authorization");
  step = "parse_request";

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    const missing = [
      !supabaseUrl ? "SUPABASE_URL" : null,
      !supabaseAnonKey ? "SUPABASE_ANON_KEY" : null,
      !supabaseServiceRoleKey ? "SUPABASE_SERVICE_ROLE_KEY" : null,
      !authHeader ? "Authorization header" : null,
    ].filter((value): value is string => value !== null);
    console.error("update_order_status missing runtime config", {
      request_id: requestId,
      missing,
    });
    return errorResponse(
      "missing_runtime_secret",
      `Missing runtime configuration: ${missing.join(", ")}.`,
      500,
      requestId,
    );
  }

  const authClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: authHeader },
    },
  });

  const {
    data: { user },
    error: authError,
  } = await authClient.auth.getUser();
  step = "load_user";

  if (authError || !user) {
    return errorResponse(
      "unauthorized",
      "Authentication is required.",
      401,
      requestId,
    );
  }
  authUserId = user.id;

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
  const financialStore = createSupabaseOrderFinancialStore(adminClient);
  const financialGateway = stripeSecretKey == null
    ? null
    : createStripeOrderFinancialGateway(fetch, stripeSecretKey);

  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, is_active")
    .eq("id", user.id)
    .single();

  if (currentUserError || !currentUser) {
    return errorResponse(
      "user_not_found",
      "Authenticated user profile was not found.",
      404,
      requestId,
    );
  }

  if (!currentUser.is_active) {
    return errorResponse(
      "inactive_account",
      "The authenticated account is inactive.",
      403,
      requestId,
    );
  }

  let payload: UpdateOrderPayload;
  try {
    step = "parse_payload";
    payload = await request.json();
  } catch {
    return errorResponse(
      "invalid_json_body",
      "Request body must be valid JSON.",
      400,
      requestId,
    );
  }

  action = normalizeAction(payload.action);
  payloadSummary = summarizePayload(payload);
  orderId = normalizeRequiredString(payload.order_id);
  trackingPresent = normalizeOptionalString(payload.tracking_code) != null;
  targetStatus = action == null ? null : actionToTargetStatus(action);
  step = "validate_payload";
  if (action == null) {
    return errorResponse(
      "invalid_action",
      "A valid action is required.",
      400,
      requestId,
    );
  }

  if (orderId == null) {
    return errorResponse(
      "invalid_order_id",
      "A valid order id is required.",
      400,
      requestId,
    );
  }

  const trackingCode = normalizeOptionalString(payload.tracking_code);
  trackingPresent = trackingCode != null;
  if (action === "mark_shipped" && trackingCode == null) {
    return errorResponse(
      "invalid_tracking_code",
      "Tracking code is required when marking an order as shipped.",
      400,
      requestId,
    );
  }
  if (trackingCode != null && trackingCode.length > maxTrackingCodeLength) {
    return errorResponse(
      "invalid_tracking_code",
      "Tracking code is too long.",
      400,
      requestId,
    );
  }

  try {
    if (action === "mark_shipped") {
      step = "load_order";
      const existingOrder = await getOrderStatusForMutation(
        adminClient,
        orderId,
      );
      if (existingOrder == null) {
        throw new UpdateOrderFlowError(
          "order_not_found",
          404,
          "The requested order was not found.",
        );
      }
      if (existingOrder.sellerId !== user.id) {
        throw new UpdateOrderFlowError(
          "order_not_accessible",
          403,
          "You cannot update this order.",
        );
      }

      step = "shipping_deadline_check";
      if (
        existingOrder.status === "paid" &&
        isShippingDeadlineElapsed(existingOrder.createdAt)
      ) {
        const latestRefundOperation = await getLatestRefundOperation(
          adminClient,
          orderId,
        );
        if (
          latestRefundOperation?.status === "pending" ||
          latestRefundOperation?.status === "processing"
        ) {
          throw new UpdateOrderFlowError(
            "order_auto_cancel_pending",
            409,
            "An automatic cancel/refund is already in progress for this order.",
          );
        }

        throw new UpdateOrderFlowError(
          "shipping_window_expired",
          409,
          "This order can no longer be marked as shipped because the 48-hour shipping window has expired.",
        );
      }
    }

    if (action === "cancel_order") {
      step = "load_order";
      const existingOrder = await financialStore.getOrderForFinancialAction(
        orderId,
      );
      if (existingOrder == null) {
        throw new UpdateOrderFlowError(
          "order_not_found",
          404,
          "The requested order was not found.",
        );
      }
      if (existingOrder.sellerId !== user.id) {
        throw new UpdateOrderFlowError(
          "order_not_accessible",
          403,
          "You cannot update this order.",
        );
      }

      if (existingOrder.status === "cancelled") {
        return jsonResponse({
          success: true,
          order_id: existingOrder.id,
          action,
          status: "cancelled",
          idempotent: true,
          payout_status: "not_applicable",
          request_id: requestId,
        }, 200);
      }

      if (existingOrder.status !== "paid") {
        throw new UpdateOrderFlowError(
          "invalid_order_transition",
          409,
          "Only paid orders can be refunded before cancellation.",
        );
      }

      if (financialGateway == null) {
        throw new UpdateOrderFlowError(
          "internal_error",
          500,
          "Missing Stripe runtime configuration for refunds.",
        );
      }

      await refundOrderPayment({
        orderId,
        requestId,
        triggerSource: "seller_cancel_order",
        triggeredBy: user.id,
        refundReason: "seller_cancelled_before_shipment",
        store: financialStore,
        stripeGateway: financialGateway,
      });
    }

    step = "run_rpc";
    const { data, error } = await adminClient.rpc(
      "update_order_status_atomic",
      {
        p_order_id: orderId,
        p_actor_user_id: user.id,
        p_action: action,
        p_tracking_code: trackingCode,
        p_request_id: requestId,
      },
    ).single();

    if (error) {
      throw mapRpcError(error);
    }

    const result = data as UpdateOrderRpcResult | null;
    if (!result) {
      throw new UpdateOrderFlowError(
        "internal_error",
        500,
        "The order update did not return a result.",
      );
    }

    let payoutStatus: "not_applicable" | "released" | "retry_required" =
      "not_applicable";

    if (
      action === "confirm_receipt" &&
      result.resulting_status === "completed"
    ) {
      if (financialGateway == null) {
        payoutStatus = "retry_required";
      } else {
        try {
          const payoutResult = await releaseFundsForCompletedOrder({
            orderId: result.order_id,
            requestId,
            triggerSource: "buyer_confirm_delivery",
            triggeredBy: user.id,
            store: financialStore,
            stripeGateway: financialGateway,
          });
          payoutStatus = payoutResult.idempotent ? "released" : "released";
        } catch (error) {
          payoutStatus = "retry_required";
          console.error("update_order_status payout release failed", {
            request_id: requestId,
            order_id: result.order_id,
            message: readErrorMessage(error),
            code: readErrorCode(error),
          });
        }
      }
    }

    return jsonResponse({
      success: true,
      order_id: result.order_id,
      action,
      status: result.resulting_status,
      idempotent: result.idempotent,
      payout_status: payoutStatus,
      request_id: requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeUnhandledError(error);
    const errorDetails = describeError(error);
    const debugMessage = buildDebugMessage(step, errorDetails);
    console.error("update_order_status failed", {
      request_id: requestId,
      step,
      order_id: orderId,
      target_status: targetStatus,
      auth_user_id: authUserId,
      tracking_present: trackingPresent,
      payload: payloadSummary,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
      error_message: errorDetails.message,
      error_code: errorDetails.code,
      error_name: errorDetails.name,
      error_stack: errorDetails.stack,
      cause_message: errorDetails.cause?.message ?? null,
      cause_code: errorDetails.cause?.code ?? null,
      cause_stack: errorDetails.cause?.stack ?? null,
    });
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
      debugMessage,
    );
  }
});

function normalizeAction(value: unknown): OrderAction | null {
  if (
    value === "confirm_receipt" ||
    value === "mark_shipped" ||
    value === "cancel_order"
  ) {
    return value;
  }
  return null;
}

function normalizeRequiredString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function normalizeUnhandledError(error: unknown): UpdateOrderFlowError {
  if (error instanceof UpdateOrderFlowError) {
    return error;
  }

  if (error instanceof OrderFinancialActionError) {
    if (error.code === "order_not_found") {
      return new UpdateOrderFlowError(
        "order_not_found",
        404,
        "The requested order was not found.",
        error,
      );
    }

    if (error.code === "order_not_paid") {
      return new UpdateOrderFlowError(
        "invalid_order_transition",
        409,
        "Only paid orders can be refunded in the current state.",
        error,
      );
    }

    return new UpdateOrderFlowError(
      "refund_failed",
      503,
      error.message,
      error,
    );
  }

  return new UpdateOrderFlowError(
    "internal_error",
    500,
    "An unexpected error occurred while updating the order.",
    error,
  );
}

function mapRpcError(error: unknown): UpdateOrderFlowError {
  if (isOrderStateInvariantViolation(error)) {
    return new UpdateOrderFlowError(
      "invalid_order_transition",
      409,
      "The requested order transition violates database invariants.",
      error,
    );
  }

  const message = readErrorMessage(error);
  switch (message) {
    case "order_not_found":
      return new UpdateOrderFlowError(
        "order_not_found",
        404,
        "The requested order was not found.",
        error,
      );
    case "order_not_accessible":
      return new UpdateOrderFlowError(
        "order_not_accessible",
        403,
        "You cannot update this order.",
        error,
      );
    case "invalid_order_transition":
      return new UpdateOrderFlowError(
        "invalid_order_transition",
        409,
        "The requested transition is not valid for the current order state.",
        error,
      );
    case "invalid_tracking_code":
      return new UpdateOrderFlowError(
        "invalid_tracking_code",
        400,
        "Tracking code is invalid.",
        error,
      );
    case "shipping_window_expired":
    case "shipping_deadline_elapsed":
      return new UpdateOrderFlowError(
        "shipping_window_expired",
        409,
        "This order can no longer be marked as shipped because the 48-hour shipping window has expired.",
        error,
      );
    case "order_auto_cancel_pending":
      return new UpdateOrderFlowError(
        "order_auto_cancel_pending",
        409,
        "An automatic cancel/refund is already in progress for this order.",
        error,
      );
    case "missing_runtime_secret":
      return new UpdateOrderFlowError(
        "missing_runtime_secret",
        500,
        "Missing runtime configuration.",
        error,
      );
    default:
      return new UpdateOrderFlowError(
        "internal_error",
        500,
        "Failed to update the order.",
        error,
      );
  }
}

async function getOrderStatusForMutation(
  adminClient: any,
  orderId: string,
): Promise<
  {
    id: string;
    sellerId: string;
    status: OrderStatus;
    createdAt: string;
  } | null
> {
  const { data, error } = await adminClient
    .from("orders")
    .select("id, seller_id, status, created_at")
    .eq("id", orderId)
    .maybeSingle();

  if (error != null) {
    throw error;
  }
  const row = data as Record<string, unknown> | null;
  if (row == null) return null;

  return {
    id: row.id as string,
    sellerId: row.seller_id as string,
    status: row.status as OrderStatus,
    createdAt: row.created_at as string,
  };
}

async function getLatestRefundOperation(
  adminClient: any,
  orderId: string,
): Promise<
  {
    id: string;
    status: string;
    failureCode: string | null;
    failureMessage: string | null;
    metadata: Record<string, unknown> | null;
  } | null
> {
  const { data, error } = await adminClient
    .from("order_financial_operations")
    .select("id, status, failure_code, failure_message, metadata, created_at")
    .eq("order_id", orderId)
    .eq("kind", "refund")
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error != null) {
    throw error;
  }

  const row = data as Record<string, unknown> | null;
  if (row == null) return null;

  return {
    id: row.id as string,
    status: row.status as string,
    failureCode: (row.failure_code as string | null) ?? null,
    failureMessage: (row.failure_message as string | null) ?? null,
    metadata: (row.metadata as Record<string, unknown> | null) ?? null,
  };
}

function isShippingDeadlineElapsed(createdAt: string): boolean {
  const createdAtMs = Date.parse(createdAt);
  if (!Number.isFinite(createdAtMs)) return false;
  return createdAtMs <= Date.now() - 48 * 60 * 60 * 1000;
}

function isOrderStateInvariantViolation(error: unknown): boolean {
  const code = readErrorCode(error);
  return code === "23505" || code === "23514";
}

function readErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function readErrorStack(error: unknown): string {
  if (typeof error === "object" && error !== null && "stack" in error) {
    const value = Reflect.get(error, "stack");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function readErrorName(error: unknown): string {
  if (typeof error === "object" && error !== null && "name" in error) {
    const value = Reflect.get(error, "name");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function readErrorCause(
  error: unknown,
): { message: string; code: string; stack: string } | null {
  if (typeof error !== "object" || error === null || !("cause" in error)) {
    return null;
  }

  const cause = Reflect.get(error, "cause");
  if (typeof cause !== "object" || cause === null) return null;

  return {
    message: readErrorMessage(cause),
    code: readErrorCode(cause),
    stack: readErrorStack(cause),
  };
}

function describeError(error: unknown): {
  message: string;
  code: string;
  name: string;
  stack: string;
  cause: { message: string; code: string; stack: string } | null;
} {
  return {
    message: readErrorMessage(error),
    code: readErrorCode(error),
    name: readErrorName(error),
    stack: readErrorStack(error),
    cause: readErrorCause(error),
  };
}

function buildDebugMessage(
  step: string,
  errorDetails: ReturnType<typeof describeError>,
): string {
  const parts = [
    `step=${step}`,
    errorDetails.code ? `code=${errorDetails.code}` : null,
    errorDetails.message ? `message=${errorDetails.message}` : null,
  ].filter((value): value is string => value !== null);
  return parts.join(" | ");
}

function summarizePayload(
  payload: UpdateOrderPayload,
): Record<string, unknown> {
  const trackingCode = normalizeOptionalString(payload.tracking_code);
  return {
    action: payload.action ?? null,
    order_id_present: normalizeRequiredString(payload.order_id) != null,
    tracking_present: trackingCode != null,
    tracking_length: trackingCode?.length ?? 0,
  };
}

function actionToTargetStatus(action: OrderAction): OrderStatus {
  switch (action) {
    case "confirm_receipt":
      return "completed";
    case "mark_shipped":
      return "shipped";
    case "cancel_order":
      return "cancelled";
  }
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

function errorResponse(
  error: UpdateOrderErrorCode,
  message: string,
  status: number,
  requestId?: string,
  debugMessage?: string,
): Response {
  const body: Record<string, unknown> = { error, message };
  if (requestId) {
    body.request_id = requestId;
  }
  if (debugMessage) {
    body.debug_message = debugMessage;
  }
  return jsonResponse(body, status);
}

function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  const normalized = normalizeOptionalString(headerValue);
  return normalized ?? crypto.randomUUID();
}
