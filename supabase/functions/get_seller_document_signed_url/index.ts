import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const DOCUMENT_SIGNED_URL_EXPIRY_SECONDS = 60;

type GetSellerDocumentSignedUrlPayload = {
  document_type: "identity_document" | "tesserino_document";
  user_id?: string;
};

class SellerDocumentAccessError extends Error {
  constructor(
    readonly appCode: string,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "SellerDocumentAccessError";
  }
}

Deno.serve(async (request) => {
  const requestId = getRequestId(request);

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    return jsonResponse({ error: "missing_runtime_configuration" }, 500, requestId);
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
    return jsonResponse({ error: "unauthorized" }, 401, requestId);
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const {
    data: currentUser,
    error: currentUserError,
  } = await adminClient
    .from("users")
    .select("id, is_active, role")
    .eq("id", user.id)
    .single();

  if (currentUserError || !currentUser) {
    return jsonResponse({ error: "user_not_found" }, 404, requestId);
  }

  if (!currentUser.is_active) {
    return jsonResponse({ error: "inactive_account" }, 403, requestId);
  }

  let payload: GetSellerDocumentSignedUrlPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_json_body" }, 400, requestId);
  }

  const validationError = validatePayload(payload);
  if (validationError != null) {
    return jsonResponse({ error: validationError }, 400, requestId);
  }

  const targetUserId = payload.user_id?.trim() || user.id;
  const isOwner = targetUserId === user.id;
  const isAdmin = currentUser.role === "admin";

  if (!isOwner && !isAdmin) {
    await insertAuditLog(adminClient, {
      entityType: "seller_document",
      entityId: targetUserId,
      action: "access_denied",
      performedBy: user.id,
      metadata: {
        action: "access_denied",
        request_id: requestId,
        result: "denied",
        document_type: payload.document_type,
        access_scope: "forbidden",
      },
      logLabel: "get_seller_document_signed_url denied audit insert failed",
      requestId,
    });
    return jsonResponse({ error: "forbidden" }, 403, requestId);
  }

  try {
    const matchingPath = await resolveLatestDocumentPath(
      adminClient,
      targetUserId,
      payload.document_type,
    );

    if (matchingPath == null) {
      await insertAuditLog(adminClient, {
        entityType: "seller_document",
        entityId: targetUserId,
        action: "access_url_missing",
        performedBy: user.id,
        metadata: {
          action: "access_url_missing",
          request_id: requestId,
          result: "not_found",
          document_type: payload.document_type,
          access_scope: isOwner ? "owner" : "admin",
        },
        logLabel: "get_seller_document_signed_url missing audit insert failed",
        requestId,
      });
      return jsonResponse({ error: "document_not_found" }, 404, requestId);
    }

    const signedUrlResult = await adminClient.storage.from("seller_documents")
      .createSignedUrl(matchingPath, DOCUMENT_SIGNED_URL_EXPIRY_SECONDS);

    if (signedUrlResult.error || !signedUrlResult.data?.signedUrl) {
      throw new SellerDocumentAccessError(
        "signed_url_generation_failed",
        500,
        "Failed to create a temporary document access URL.",
        signedUrlResult.error,
      );
    }

    await insertAuditLog(adminClient, {
      entityType: "seller_document",
      entityId: targetUserId,
      action: "access_url_issued",
      performedBy: user.id,
      metadata: {
        action: "access_url_issued",
        request_id: requestId,
        result: "succeeded",
        document_type: payload.document_type,
        access_scope: isOwner ? "owner" : "admin",
        url_ttl_seconds: DOCUMENT_SIGNED_URL_EXPIRY_SECONDS,
      },
      logLabel: "get_seller_document_signed_url audit insert failed",
      requestId,
    });

    return jsonResponse({
      signed_url: signedUrlResult.data.signedUrl,
      expires_in: DOCUMENT_SIGNED_URL_EXPIRY_SECONDS,
      request_id: requestId,
    }, 200);
  } catch (error) {
    console.error(
      "get_seller_document_signed_url failed",
      {
        request_id: requestId,
        ...normalizeErrorForLogging(error),
      },
    );
    return toErrorResponse(error, requestId);
  }
});

function validatePayload(
  payload: GetSellerDocumentSignedUrlPayload,
): string | null {
  if (!payload || typeof payload !== "object") {
    return "invalid_payload";
  }

  if (
    payload.document_type !== "identity_document" &&
    payload.document_type !== "tesserino_document"
  ) {
    return "invalid_document_type";
  }

  if (payload.user_id != null && payload.user_id.trim().length === 0) {
    return "invalid_user_id";
  }

  return null;
}

async function resolveLatestDocumentPath(
  adminClient: any,
  userId: string,
  documentType: GetSellerDocumentSignedUrlPayload["document_type"],
): Promise<string | null> {
  const listResult = await adminClient.storage.from("seller_documents").list(
    userId,
    {
      limit: 100,
      sortBy: { column: "name", order: "desc" },
    },
  );

  if (listResult.error) {
    throw new SellerDocumentAccessError(
      "seller_documents_list_failed",
      500,
      "Failed to resolve seller document metadata.",
      listResult.error,
    );
  }

  const prefix = `${documentType}_`;
  const matchingEntry = listResult.data.find((entry: { name?: string }) =>
    typeof entry.name === "string" && entry.name.startsWith(prefix)
  );

  if (!matchingEntry) {
    return null;
  }

  return `${userId}/${matchingEntry.name}`;
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
  requestId?: string,
): Response {
  const responseBody = requestId == null
    ? body
    : { ...body, request_id: requestId };

  return new Response(JSON.stringify(responseBody), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function toErrorResponse(error: unknown, requestId?: string): Response {
  if (error instanceof SellerDocumentAccessError) {
    return jsonResponse(
      {
        error: error.appCode,
        message: error.message,
        ...(requestId ? { request_id: requestId } : {}),
      },
      error.status,
    );
  }

  return jsonResponse(
    {
      error: "seller_document_access_failed",
      message: "Unexpected seller document access failure.",
      ...(requestId ? { request_id: requestId } : {}),
    },
    500,
  );
}

function normalizeErrorForLogging(error: unknown): Record<string, unknown> {
  if (error instanceof SellerDocumentAccessError) {
    return {
      appCode: error.appCode,
      status: error.status,
      message: error.message,
      cause: readErrorMessage(error.cause),
    };
  }

  return {
    message: readErrorMessage(error),
  };
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") {
      return value.toLowerCase();
    }
  }

  return "";
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
      code: readErrorCode(auditInsert.error),
      message: readErrorMessage(auditInsert.error),
    });
  }
}

function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  const normalized = normalizeOptionalString(headerValue);
  return normalized ?? crypto.randomUUID();
}

function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}
