import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type OrderAction = "confirm_receipt" | "mark_shipped" | "cancel_order";

type UpdateOrderPayload = {
  action?: OrderAction;
  order_id?: string;
  tracking_code?: string;
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
  | "update_order_unknown_error";

class UpdateOrderFlowError extends Error {
  constructor(
    readonly code: UpdateOrderErrorCode,
    readonly status: number,
    message: string,
    readonly cause?: unknown,
  ) {
    super(message);
    this.name = "UpdateOrderFlowError";
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    return errorResponse(
      "update_order_unknown_error",
      "Missing runtime configuration.",
      500,
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
    return errorResponse("unauthorized", "Authentication is required.", 401);
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

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
    );
  }

  if (!currentUser.is_active) {
    return errorResponse(
      "inactive_account",
      "The authenticated account is inactive.",
      403,
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
    );
  }

  const action = normalizeAction(payload.action);
  if (action == null) {
    return errorResponse("invalid_action", "A valid action is required.", 400);
  }

  const orderId = normalizeRequiredString(payload.order_id);
  if (orderId == null) {
    return errorResponse("invalid_order_id", "A valid order id is required.", 400);
  }

  const trackingCode = normalizeOptionalString(payload.tracking_code);
  if (action === "mark_shipped" && trackingCode == null) {
    return errorResponse(
      "invalid_tracking_code",
      "Tracking code is required when marking an order as shipped.",
      400,
    );
  }
  if (trackingCode != null && trackingCode.length > maxTrackingCodeLength) {
    return errorResponse(
      "invalid_tracking_code",
      "Tracking code is too long.",
      400,
    );
  }

  try {
    const { data: order, error: orderError } = await adminClient
      .from("orders")
      .select("id, truffle_id, buyer_id, seller_id, status")
      .eq("id", orderId)
      .maybeSingle();

    if (orderError) {
      throw new UpdateOrderFlowError(
        "update_order_unknown_error",
        500,
        "Failed to load the order.",
        orderError,
      );
    }

    if (!order) {
      throw new UpdateOrderFlowError(
        "order_not_found",
        404,
        "The requested order was not found.",
      );
    }

    const isBuyer = order.buyer_id === user.id;
    const isSeller = order.seller_id === user.id;

    if (!isBuyer && !isSeller) {
      throw new UpdateOrderFlowError(
        "order_not_accessible",
        403,
        "You cannot update this order.",
      );
    }

    const updatePayload: Record<string, unknown> = {};
    let expectedStatus = "";
    let ownershipColumn: "buyer_id" | "seller_id" = "seller_id";
    let notificationUserId: string | null = null;
    let notificationType = "";
    let notificationMessage = "";
    let auditAction = "";

    switch (action) {
      case "confirm_receipt":
        if (!isBuyer || order.status !== "shipped") {
          throw new UpdateOrderFlowError(
            "invalid_order_transition",
            409,
            "Only the buyer can confirm receipt for a shipped order.",
          );
        }
        expectedStatus = "shipped";
        ownershipColumn = "buyer_id";
        updatePayload.status = "completed";
        notificationUserId = order.seller_id;
        notificationType = "order_completed";
        notificationMessage = "A buyer confirmed receipt for one of your orders.";
        auditAction = "completed";
        break;
      case "mark_shipped":
        if (!isSeller || order.status !== "paid") {
          throw new UpdateOrderFlowError(
            "invalid_order_transition",
            409,
            "Only the seller can mark a paid order as shipped.",
          );
        }
        expectedStatus = "paid";
        ownershipColumn = "seller_id";
        updatePayload.status = "shipped";
        updatePayload.tracking_code = trackingCode;
        notificationUserId = order.buyer_id;
        notificationType = "order_shipped";
        notificationMessage = "Your order has been marked as shipped.";
        auditAction = "shipped";
        break;
      case "cancel_order":
        if (!isSeller || order.status !== "paid") {
          throw new UpdateOrderFlowError(
            "invalid_order_transition",
            409,
            "Only the seller can cancel a paid order.",
          );
        }
        expectedStatus = "paid";
        ownershipColumn = "seller_id";
        updatePayload.status = "cancelled";
        notificationUserId = order.buyer_id;
        notificationType = "order_cancelled";
        notificationMessage = "Your order has been cancelled.";
        auditAction = "cancelled";
        break;
    }

    const updateQuery = adminClient
      .from("orders")
      .update(updatePayload)
      .eq("id", orderId)
      .eq("status", expectedStatus)
      .eq(ownershipColumn, user.id)
      .select("id")
      .maybeSingle();

    const { data: updatedOrder, error: updateError } = await updateQuery;

    if (updateError) {
      throw new UpdateOrderFlowError(
        "update_order_unknown_error",
        500,
        "Failed to update the order.",
        updateError,
      );
    }

    if (!updatedOrder) {
      throw new UpdateOrderFlowError(
        "invalid_order_transition",
        409,
        "The order state changed before this action could be applied.",
      );
    }

    if (action === "cancel_order") {
      const { error: truffleUpdateError } = await adminClient
        .from("truffles")
        .update({ status: "active" })
        .eq("id", order.truffle_id);

      if (truffleUpdateError) {
        await adminClient
          .from("orders")
          .update({ status: "paid" })
          .eq("id", orderId)
          .eq("seller_id", user.id)
          .eq("status", "cancelled");
        throw new UpdateOrderFlowError(
          "update_order_unknown_error",
          500,
          "Failed to reactivate the linked truffle.",
          truffleUpdateError,
        );
      }
    }

    if (notificationUserId) {
      const { error: notificationError } = await adminClient
        .from("notifications")
        .insert({
          user_id: notificationUserId,
          type: notificationType,
          message: notificationMessage,
        });

      if (notificationError) {
        console.error("update_order_status notification insert failed", notificationError);
      }
    }

    const { error: auditError } = await adminClient.from("audit_logs").insert({
      entity_type: "order",
      entity_id: orderId,
      action: auditAction,
      performed_by: user.id,
      metadata: {
        order_id: orderId,
        action,
      },
    });

    if (auditError) {
      console.error("update_order_status audit insert failed", auditError);
    }

    return jsonResponse({ success: true, order_id: orderId, action }, 200);
  } catch (error) {
    const normalizedError = normalizeUnhandledError(error);
    console.error("update_order_status failed", error);
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
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

  return new UpdateOrderFlowError(
    "update_order_unknown_error",
    500,
    "An unexpected error occurred while updating the order.",
    error,
  );
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
): Response {
  return jsonResponse({ error, message }, status);
}
