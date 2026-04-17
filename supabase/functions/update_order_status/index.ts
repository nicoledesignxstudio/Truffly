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
  | "refund_failed"
  | "update_order_unknown_error";

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

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
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

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    return errorResponse(
      "update_order_unknown_error",
      "Missing runtime configuration.",
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

  if (authError || !user) {
    return errorResponse(
      "unauthorized",
      "Authentication is required.",
      401,
      requestId,
    );
  }

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
    payload = await request.json();
  } catch {
    return errorResponse(
      "invalid_json_body",
      "Request body must be valid JSON.",
      400,
      requestId,
    );
  }

  const action = normalizeAction(payload.action);
  if (action == null) {
    return errorResponse(
      "invalid_action",
      "A valid action is required.",
      400,
      requestId,
    );
  }

  const orderId = normalizeRequiredString(payload.order_id);
  if (orderId == null) {
    return errorResponse(
      "invalid_order_id",
      "A valid order id is required.",
      400,
      requestId,
    );
  }

  const trackingCode = normalizeOptionalString(payload.tracking_code);
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
    if (action === "cancel_order") {
      const existingOrder = await financialStore.getOrderForFinancialAction(
        orderId,
      );
      if (financialGateway == null) {
        throw new UpdateOrderFlowError(
          "update_order_unknown_error",
          500,
          "Missing Stripe runtime configuration for refunds.",
        );
      }

      if (existingOrder?.status !== "cancelled") {
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
    }

    const { data, error } = await adminClient.rpc("update_order_status_atomic", {
      p_order_id: orderId,
      p_actor_user_id: user.id,
      p_action: action,
      p_tracking_code: trackingCode,
      p_request_id: requestId,
    }).single();

    if (error) {
      throw mapRpcError(error);
    }

    const result = data as UpdateOrderRpcResult | null;
    if (!result) {
      throw new UpdateOrderFlowError(
        "update_order_unknown_error",
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
    console.error("update_order_status failed", {
      request_id: requestId,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
    });
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
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
    "update_order_unknown_error",
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
    default:
      return new UpdateOrderFlowError(
        "update_order_unknown_error",
        500,
        "Failed to update the order.",
        error,
      );
  }
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
): Response {
  return jsonResponse(
    requestId ? { error, message, request_id: requestId } : { error, message },
    status,
  );
}

function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  const normalized = normalizeOptionalString(headerValue);
  return normalized ?? crypto.randomUUID();
}
