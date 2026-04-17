import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const finalImagesBucket = "truffle_images";

type DeleteTrufflePayload = {
  truffle_id: string;
};

type DeleteTruffleErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "seller_not_allowed"
  | "invalid_json_body"
  | "invalid_truffle_id"
  | "truffle_not_found"
  | "truffle_not_owned"
  | "truffle_not_active"
  | "truffle_has_orders"
  | "delete_truffle_unknown_error";

class DeleteTruffleFlowError extends Error {
  constructor(
    readonly code: DeleteTruffleErrorCode,
    readonly status: number,
    message: string,
    readonly cause?: unknown,
  ) {
    super(message);
    this.name = "DeleteTruffleFlowError";
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
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    return errorResponse(
      "delete_truffle_unknown_error",
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
    return errorResponse("unauthorized", "Authentication is required.", 401, requestId);
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, role, is_active")
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

  if (currentUser.role !== "seller") {
    return errorResponse(
      "seller_not_allowed",
      "Only sellers can delete active truffles.",
      403,
      requestId,
    );
  }

  let payload: DeleteTrufflePayload;
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

  const truffleId = normalizeTruffleId(payload?.truffle_id);
  if (truffleId == null) {
    return errorResponse(
      "invalid_truffle_id",
      "A valid truffle id is required.",
      400,
      requestId,
    );
  }

  try {
    const { data: truffle, error: truffleError } = await adminClient
      .from("truffles")
      .select("id, seller_id, status")
      .eq("id", truffleId)
      .maybeSingle();

    if (truffleError) {
      throw new DeleteTruffleFlowError(
        "delete_truffle_unknown_error",
        500,
        "Failed to load the truffle.",
        truffleError,
      );
    }

    if (!truffle) {
      throw new DeleteTruffleFlowError(
        "truffle_not_found",
        404,
        "The requested truffle was not found.",
      );
    }

    if (truffle.seller_id !== user.id) {
      throw new DeleteTruffleFlowError(
        "truffle_not_owned",
        403,
        "You can only delete your own truffles.",
      );
    }

    if (truffle.status !== "active") {
      throw new DeleteTruffleFlowError(
        "truffle_not_active",
        409,
        "Only active truffles can be deleted.",
      );
    }

    const [
      { data: orders, error: ordersError },
      { data: favoriteRows, error: favoritesError },
      { data: imageRows, error: imageRowsError },
    ] = await Promise.all([
      adminClient
        .from("orders")
        .select("id")
        .eq("truffle_id", truffleId)
        .limit(1),
      adminClient
        .from("favorites")
        .select("user_id")
        .eq("truffle_id", truffleId),
      adminClient
        .from("truffle_images")
        .select("image_url")
        .eq("truffle_id", truffleId),
    ]);

    if (ordersError) {
      throw new DeleteTruffleFlowError(
        "delete_truffle_unknown_error",
        500,
        "Failed to validate linked orders.",
        ordersError,
      );
    }

    if (favoritesError) {
      throw new DeleteTruffleFlowError(
        "delete_truffle_unknown_error",
        500,
        "Failed to load favorite references.",
        favoritesError,
      );
    }

    if (imageRowsError) {
      throw new DeleteTruffleFlowError(
        "delete_truffle_unknown_error",
        500,
        "Failed to load truffle image references.",
        imageRowsError,
      );
    }

    if ((orders ?? []).length > 0) {
      await insertAuditLog(adminClient, {
        entityType: "truffle",
        entityId: truffleId,
        action: "delete_denied",
        performedBy: user.id,
        metadata: {
          action: "delete_denied",
          request_id: requestId,
          result: "denied",
          reason: "linked_orders",
        },
        logLabel: "delete_truffle denied audit insert failed",
        requestId,
      });
      throw new DeleteTruffleFlowError(
        "truffle_has_orders",
        409,
        "Sold truffles or truffles with linked orders cannot be deleted.",
      );
    }

    const favoriteUserIds = (favoriteRows ?? [])
      .map((row) => row.user_id as string)
      .filter((value) => value.trim().length > 0);

    const storagePaths = (imageRows ?? [])
      .map((row) => normalizeStoragePath(row.image_url))
      .filter((path): path is string => path != null);

    if (storagePaths.length > 0) {
      // Keep deterministic remove payload and avoid duplicates.
      const deduped = [...new Set(storagePaths)];
      const deleteResult = await adminClient.from("truffles").delete().eq("id", truffleId);
      if (deleteResult.error) {
        throw new DeleteTruffleFlowError(
          "delete_truffle_unknown_error",
          500,
          "Failed to delete the truffle record.",
          deleteResult.error,
        );
      }

      const storageRemoval = await adminClient.storage.from(finalImagesBucket).remove(
        deduped,
      );
      if (storageRemoval.error) {
        console.error("delete_truffle storage cleanup failed", {
          request_id: requestId,
          bucket: finalImagesBucket,
          paths_count: deduped.length,
          error_code: readErrorCode(storageRemoval.error),
          error_message: readErrorMessage(storageRemoval.error),
        });
      }
    } else {
      const deleteResult = await adminClient.from("truffles").delete().eq("id", truffleId);
      if (deleteResult.error) {
        throw new DeleteTruffleFlowError(
          "delete_truffle_unknown_error",
          500,
          "Failed to delete the truffle record.",
          deleteResult.error,
        );
      }
    }

    if (favoriteUserIds.length > 0) {
      const notifications = favoriteUserIds.map((userId) => ({
        user_id: userId,
        type: "favorite_truffle_deleted",
        message: "A truffle you saved is no longer available.",
      }));

      const notificationInsert = await adminClient
        .from("notifications")
        .insert(notifications);

      if (notificationInsert.error) {
        console.error("delete_truffle notification insert failed", {
          request_id: requestId,
          error_code: readErrorCode(notificationInsert.error),
          error_message: readErrorMessage(notificationInsert.error),
        });
      }
    }

    await insertAuditLog(adminClient, {
      entityType: "truffle",
      entityId: truffleId,
      action: "deleted",
      performedBy: user.id,
      metadata: {
        action: "deleted",
        request_id: requestId,
        result: "succeeded",
        favorite_user_count: favoriteUserIds.length,
        storage_bucket: finalImagesBucket,
        image_count: storagePaths.length,
      },
      logLabel: "delete_truffle audit insert failed",
      requestId,
    });

    return jsonResponse({
      success: true,
      truffle_id: truffleId,
      request_id: requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeUnhandledError(error);
    console.error("delete_truffle failed", {
      request_id: requestId,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
      cause_code: readErrorCode(normalizedError.cause),
      cause_message: readErrorMessage(normalizedError.cause),
    });
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
    );
  }
});

function normalizeTruffleId(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (trimmed.length === 0) {
    return null;
  }

  return trimmed;
}

function normalizeStoragePath(rawValue: unknown): string | null {
  if (typeof rawValue !== "string") {
    return null;
  }

  const trimmed = rawValue.trim();
  if (trimmed.length === 0) {
    return null;
  }

  if (trimmed.startsWith(`${finalImagesBucket}/`)) {
    return trimmed.slice(finalImagesBucket.length + 1);
  }
  if (trimmed.startsWith(`/${finalImagesBucket}/`)) {
    return trimmed.slice(finalImagesBucket.length + 2);
  }
  if (!trimmed.startsWith("http://") && !trimmed.startsWith("https://")) {
    return trimmed;
  }

  try {
    const parsed = new URL(trimmed);
    const bucketIndex = parsed.pathname.split("/").indexOf(finalImagesBucket);
    if (bucketIndex === -1) return null;
    const segments = parsed.pathname.split("/").slice(bucketIndex + 1).filter(Boolean);
    if (segments.length === 0) return null;
    return decodeURIComponent(segments.join("/"));
  } catch {
    return null;
  }
}

function normalizeUnhandledError(error: unknown): DeleteTruffleFlowError {
  if (error instanceof DeleteTruffleFlowError) {
    return error;
  }

  return new DeleteTruffleFlowError(
    "delete_truffle_unknown_error",
    500,
    "An unexpected error occurred while deleting the truffle.",
    error,
  );
}

async function insertAuditLog(
  adminClient: any,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string;
    metadata: Record<string, unknown>;
    logLabel: string;
    requestId?: string;
  },
): Promise<void> {
  const auditInsert = await adminClient.from("audit_logs").insert({
    entity_type: args.entityType,
    entity_id: args.entityId,
    action: args.action,
    performed_by: args.performedBy,
    metadata: args.metadata,
  });

  if (auditInsert.error) {
    console.error(args.logLabel, {
      request_id: args.requestId,
      error_code: readErrorCode(auditInsert.error),
      error_message: readErrorMessage(auditInsert.error),
    });
  }
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

function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  const normalized = normalizeTruffleId(headerValue);
  return normalized ?? crypto.randomUUID();
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
  error: DeleteTruffleErrorCode,
  message: string,
  status: number,
  requestId?: string,
): Response {
  return jsonResponse(
    requestId ? { error, message, request_id: requestId } : { error, message },
    status,
  );
}
