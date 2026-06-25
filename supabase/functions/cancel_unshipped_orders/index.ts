import { createClient } from "@supabase/supabase-js";
import {
  createStripeOrderFinancialGateway,
  createSupabaseOrderFinancialStore,
  refundOrderPayment,
} from "../_shared/order_financials.ts";

type EligibleOrderRow = {
  id: string;
  truffleId: string | null;
};

type CancelUnshippedOrdersDependencies = {
  adminClient?: ReturnType<typeof createClient>;
  financialStore?: ReturnType<typeof createSupabaseOrderFinancialStore>;
  financialGateway?: ReturnType<typeof createStripeOrderFinancialGateway>;
  cronSecret?: string | null;
  now?: () => Date;
};

export async function handleCancelUnshippedOrders(
  request: Request,
  dependencies: CancelUnshippedOrdersDependencies = {},
): Promise<Response> {
  const requestId = request.headers.get("x-request-id")?.trim() ||
    crypto.randomUUID();

  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method_not_allowed", request_id: requestId },
      405,
    );
  }

  const cronSecret = dependencies.cronSecret ?? Deno.env.get("CRON_SECRET");
  const authHeader = request.headers.get("Authorization");
  if (
    !cronSecret || authHeader !== `Bearer ${cronSecret}`
  ) {
    console.warn("cancel_unshipped_orders unauthorized", {
      request_id: requestId,
      has_cron_secret: Boolean(cronSecret),
      auth_header_present: authHeader != null,
    });
    return jsonResponse(
      { error: "unauthorized", request_id: requestId },
      401,
    );
  }

  const supabaseUrl = dependencies.adminClient
    ? null
    : Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = dependencies.adminClient
    ? null
    : Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecretKey = dependencies.financialGateway
    ? null
    : Deno.env.get("STRIPE_SECRET_KEY");
  if (
    (!dependencies.adminClient && (!supabaseUrl || !serviceRoleKey)) ||
    (!dependencies.financialGateway && !stripeSecretKey)
  ) {
    const missing = [
      !dependencies.adminClient && !supabaseUrl ? "SUPABASE_URL" : null,
      !dependencies.adminClient && !serviceRoleKey
        ? "SUPABASE_SERVICE_ROLE_KEY"
        : null,
      !dependencies.financialGateway && !stripeSecretKey
        ? "STRIPE_SECRET_KEY"
        : null,
    ].filter((value): value is string => value !== null);
    console.error("cancel_unshipped_orders missing runtime config", {
      request_id: requestId,
      missing,
    });
    return jsonResponse(
      {
        error: "missing_runtime_secret",
        message: `Missing runtime configuration: ${missing.join(", ")}.`,
        request_id: requestId,
      },
      500,
    );
  }

  const adminClient = dependencies.adminClient ??
    createClient(supabaseUrl!, serviceRoleKey!);
  const financialStore = dependencies.financialStore ??
    createSupabaseOrderFinancialStore(adminClient);
  const financialGateway = dependencies.financialGateway ??
    createStripeOrderFinancialGateway(fetch, stripeSecretKey!);

  const now = dependencies.now ?? (() => new Date());
  const cutoffIso = new Date(now().getTime() - 48 * 60 * 60 * 1000)
    .toISOString();
  const { data, error } = await adminClient
    .from("orders")
    .select("id, truffleId:truffle_id")
    .eq("status", "paid")
    .lte("created_at", cutoffIso)
    .order("created_at", { ascending: true });

  if (error != null) {
    console.error("cancel_unshipped_orders query failed", {
      request_id: requestId,
      message: error.message,
    });
    return jsonResponse(
      { error: "query_failed", message: error.message, request_id: requestId },
      500,
    );
  }

  const orders = (data ?? []) as EligibleOrderRow[];
  let refunded = 0;
  let cancelled = 0;
  const failures: Array<Record<string, unknown>> = [];

  for (const order of orders) {
    let step = "start";
    try {
      console.info("cancel_unshipped_orders order processing start", {
        request_id: requestId,
        order_id: order.id,
      });

      step = "refund_start";
      console.info("cancel_unshipped_orders refund step start", {
        request_id: requestId,
        order_id: order.id,
      });
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
      console.info("cancel_unshipped_orders refund step success", {
        request_id: requestId,
        order_id: order.id,
        idempotent: refundResult.idempotent,
      });

      step = "cancel_start";
      console.info("cancel_unshipped_orders cancel step start", {
        request_id: requestId,
        order_id: order.id,
      });
      const cancelResult = await financialStore.cancelOrderAfterRefund({
        orderId: order.id,
        requestId,
        actorUserId: null,
        reason: "auto_cancel_unshipped_48h",
      });
      if (!cancelResult.idempotent) {
        cancelled += 1;
      }
      console.info("cancel_unshipped_orders cancel step success", {
        request_id: requestId,
        order_id: order.id,
        idempotent: cancelResult.idempotent,
      });

      step = "review_verify_start";
      console.info("cancel_unshipped_orders auto review verify start", {
        request_id: requestId,
        order_id: order.id,
      });
      const { data: reviewRows, error: reviewError } = await adminClient
        .from("reviews")
        .select("id, is_auto, auto_created_at, created_at")
        .eq("order_id", order.id)
        .order("created_at", { ascending: false });
      if (reviewError != null) {
        throw reviewError;
      }
      const normalizedReviewRows = (reviewRows ?? []) as Array<
        Record<string, unknown>
      >;
      const autoReview = normalizedReviewRows.find((review) =>
        review.is_auto === true
      );
      console.info("cancel_unshipped_orders auto review verify success", {
        request_id: requestId,
        order_id: order.id,
        auto_review_present: autoReview != null,
        auto_review_id: autoReview?.id ?? null,
      });

      step = "truffle_verify_start";
      console.info("cancel_unshipped_orders truffle state verify start", {
        request_id: requestId,
        order_id: order.id,
        truffle_id: order.truffleId,
      });
      if (order.truffleId != null) {
        const { data: truffleRow, error: truffleError } = await adminClient
          .from("truffles")
          .select("id, status, expires_at")
          .eq("id", order.truffleId)
          .maybeSingle();
        if (truffleError != null) {
          throw truffleError;
        }
        const normalizedTruffleRow = truffleRow as
          | Record<string, unknown>
          | null;
        console.info("cancel_unshipped_orders truffle state verify success", {
          request_id: requestId,
          order_id: order.id,
          truffle_id: order.truffleId,
          truffle_status: normalizedTruffleRow?.status ?? null,
          truffle_expires_at: normalizedTruffleRow?.expires_at ?? null,
        });
      } else {
        console.info("cancel_unshipped_orders truffle state verify skipped", {
          request_id: requestId,
          order_id: order.id,
        });
      }

      step = "post_cancel_state";
      const postCancelState = await financialStore.getOrderForFinancialAction(
        order.id,
      );
      console.info("cancel_unshipped_orders post cancel state", {
        request_id: requestId,
        order_id: order.id,
        order_status: postCancelState?.status ?? null,
      });
    } catch (error) {
      const serialized = serializeUnknownError(error);
      failures.push({
        order_id: order.id,
        step,
        error_message: readUnknownErrorMessage(serialized),
        error_code: readUnknownErrorCode(serialized),
        error_details: serialized,
      });
      console.error("cancel_unshipped_orders order failed", {
        request_id: requestId,
        order_id: order.id,
        step,
        error: serialized,
      });
    }
  }

  console.info("cancel_unshipped_orders completed", {
    request_id: requestId,
    cutoff: cutoffIso,
    scanned: orders.length,
    refunded,
    cancelled,
    failures: failures.length,
  });

  return jsonResponse({
    success: true,
    request_id: requestId,
    scanned: orders.length,
    refunded,
    cancelled,
    failures,
  }, 200);
}

if (import.meta.main) {
  Deno.serve((request) => handleCancelUnshippedOrders(request));
}

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function serializeUnknownError(error: unknown): Record<string, unknown> {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: readErrorCode(error),
      details: readErrorDetails(error),
      cause: serializeUnknownError(error.cause),
    };
  }

  if (typeof error === "object" && error !== null) {
    try {
      return JSON.parse(JSON.stringify(error)) as Record<string, unknown>;
    } catch {
      return {
        message: String(error),
      };
    }
  }

  return {
    message: String(error),
  };
}

function readErrorCode(error: unknown): string | null {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string" && value.trim() !== "") {
      return value;
    }
  }
  return null;
}

function readErrorDetails(error: unknown): unknown {
  if (typeof error === "object" && error !== null && "details" in error) {
    return Reflect.get(error, "details");
  }
  return null;
}

function readUnknownErrorMessage(error: Record<string, unknown>): string {
  const message = error.message;
  if (typeof message === "string" && message.trim() !== "") {
    return message;
  }

  const detailsMessage = error.details;
  if (typeof detailsMessage === "string" && detailsMessage.trim() !== "") {
    return detailsMessage;
  }

  return "Unknown error.";
}

function readUnknownErrorCode(error: Record<string, unknown>): string | null {
  const code = error.code;
  if (typeof code === "string" && code.trim() !== "") {
    return code;
  }
  return null;
}
