import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type SellerDocumentPayload = {
  file_name: string;
  content_base64: string;
  content_type: string;
};

type SubmitSellerApplicationPayload = {
  first_name: string;
  last_name: string;
  country_code: string;
  region: string;
  tesserino_number: string;
  identity_document: SellerDocumentPayload;
  tesserino_document: SellerDocumentPayload;
};

type AllowedDocumentType = {
  extension: ".pdf" | ".png" | ".jpg" | ".jpeg";
  mimeType: "application/pdf" | "image/png" | "image/jpeg";
  detectedType: "pdf" | "png" | "jpeg";
};

const MAX_DOCUMENT_BYTES = 5 * 1024 * 1024;
const MAX_REQUEST_BYTES = 15 * 1024 * 1024;
const MAX_SUBMISSION_ATTEMPTS_PER_WINDOW = 5;
const SUBMISSION_RATE_WINDOW_MINUTES = 15;
const DOCUMENT_SIGNED_URL_EXPIRY_SECONDS = 60;

class SubmitSellerApplicationError extends Error {
  constructor(
    readonly appCode: string,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "SubmitSellerApplicationError";
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

  const contentLength = parseContentLength(request.headers.get("content-length"));
  if (contentLength != null && contentLength > MAX_REQUEST_BYTES) {
    return jsonResponse({ error: "request_payload_too_large" }, 413, requestId);
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

  const runtimeUrlValidationError = validateRuntimeSupabaseUrl(supabaseUrl);
  if (runtimeUrlValidationError != null) {
    return jsonResponse(runtimeUrlValidationError, 500, requestId);
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
    .select(
      "id, is_active, seller_status, onboarding_completed, first_name, last_name, country_code, region, tesserino_number",
    )
    .eq("id", user.id)
    .single();

  if (currentUserError || !currentUser) {
    return jsonResponse({ error: "user_not_found" }, 404, requestId);
  }

  if (!currentUser.is_active) {
    return jsonResponse({ error: "inactive_account" }, 403, requestId);
  }

  if (currentUser.onboarding_completed === true) {
    return jsonResponse({ error: "onboarding_already_completed" }, 409, requestId);
  }

  if (
    currentUser.seller_status !== "not_requested" &&
    currentUser.seller_status !== "rejected"
  ) {
    return jsonResponse({ error: "seller_application_not_allowed" }, 409, requestId);
  }

  let payload: SubmitSellerApplicationPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_json_body" }, 400, requestId);
  }

  const validationError = validatePayload(payload);
  if (validationError != null) {
    return jsonResponse({ error: validationError }, 400, requestId);
  }

  const submissionRateLimitError = await enforceSubmissionRateLimit(
    adminClient,
    user.id,
    requestId,
  );
  if (submissionRateLimitError != null) {
    return jsonResponse({ error: submissionRateLimitError }, 429, requestId);
  }

  const {
    data: previousSellerDocuments,
    error: previousSellerDocumentsError,
  } = await adminClient
    .from("seller_documents")
    .select("user_id, tesserino_number")
    .eq("user_id", user.id)
    .maybeSingle();

  if (previousSellerDocumentsError) {
    return jsonResponse({ error: "seller_documents_lookup_failed" }, 500, requestId);
  }

  const identityBytes = decodeBase64(payload.identity_document.content_base64);
  const tesserinoBytes = decodeBase64(
    payload.tesserino_document.content_base64,
  );

  if (identityBytes == null || tesserinoBytes == null) {
    return jsonResponse({ error: "invalid_document_encoding" }, 400, requestId);
  }

  const identityValidationError = validateDecodedDocument(
    payload.identity_document,
    identityBytes,
  );
  if (identityValidationError != null) {
    return jsonResponse({ error: identityValidationError }, 400, requestId);
  }

  const tesserinoValidationError = validateDecodedDocument(
    payload.tesserino_document,
    tesserinoBytes,
  );
  if (tesserinoValidationError != null) {
    return jsonResponse({ error: tesserinoValidationError }, 400, requestId);
  }

  const identityDocumentType = resolveAllowedDocumentType(
    payload.identity_document.file_name,
    payload.identity_document.content_type,
    identityBytes,
  );
  const tesserinoDocumentType = resolveAllowedDocumentType(
    payload.tesserino_document.file_name,
    payload.tesserino_document.content_type,
    tesserinoBytes,
  );

  if (identityDocumentType == null || tesserinoDocumentType == null) {
    return jsonResponse({ error: "document_type_mismatch" }, 400, requestId);
  }

  const identityPath = buildStoragePath(
    user.id,
    "identity_document",
    identityDocumentType.extension,
  );
  const tesserinoPath = buildStoragePath(
    user.id,
    "tesserino_document",
    tesserinoDocumentType.extension,
  );

  const uploadedPaths: string[] = [];
  let metadataWritten = false;
  let userUpdated = false;

  try {
    // The repo contract stores seller verification files in the private
    // `seller_documents` bucket while retaining `tesserino_number` in both
    // `users` and `seller_documents` metadata.
    const identityUpload = await adminClient.storage.from("seller_documents")
      .upload(identityPath, identityBytes, {
        contentType: identityDocumentType.mimeType,
        upsert: false,
      });
    if (identityUpload.error) {
      throw new SubmitSellerApplicationError(
        "seller_documents_identity_upload_failed",
        500,
        "Failed to upload identity document.",
        identityUpload.error,
      );
    }
    uploadedPaths.push(identityPath);

    const tesserinoUpload = await adminClient.storage.from("seller_documents")
      .upload(tesserinoPath, tesserinoBytes, {
        contentType: tesserinoDocumentType.mimeType,
        upsert: false,
      });
    if (tesserinoUpload.error) {
      throw new SubmitSellerApplicationError(
        "seller_documents_tesserino_upload_failed",
        500,
        "Failed to upload tesserino document.",
        tesserinoUpload.error,
      );
    }
    uploadedPaths.push(tesserinoPath);

    const sellerDocumentsUpsert = await adminClient
      .from("seller_documents")
      .upsert({
        user_id: user.id,
        tesserino_number: payload.tesserino_number.trim(),
      }, { onConflict: "user_id" });
    if (sellerDocumentsUpsert.error) {
      throw new SubmitSellerApplicationError(
        "seller_documents_upsert_failed",
        500,
        "Failed to persist seller document metadata.",
        sellerDocumentsUpsert.error,
      );
    }
    metadataWritten = true;

    const userUpdate = await adminClient
      .from("users")
      .update({
        first_name: payload.first_name.trim(),
        last_name: payload.last_name.trim(),
        country_code: "IT",
        region: payload.region.trim().toUpperCase(),
        tesserino_number: payload.tesserino_number.trim(),
        seller_status: "pending",
        onboarding_completed: true,
      })
      .eq("id", user.id);

    if (userUpdate.error) {
      throw new SubmitSellerApplicationError(
        "seller_user_update_failed",
        500,
        "Failed to update seller onboarding profile.",
        userUpdate.error,
      );
    }
    userUpdated = true;

    // The repo does not constrain notifications.type with an enum; the column
    // is free text. Keep a descriptive event key while still avoiding any
    // invented admin-recipient contract in the notifications table.
    const notificationInsert = await adminClient
      .from("notifications")
      .insert({
        user_id: user.id,
        type: "seller_application_submitted",
        message: "Your seller application has been submitted and is pending review.",
      });
    if (notificationInsert.error) {
      console.error("submit_seller_application notification insert failed", {
        request_id: requestId,
        code: readErrorCode(notificationInsert.error),
        message: readErrorMessage(notificationInsert.error),
      });
    }

    await insertAuditLog(adminClient, {
      entityType: "seller_application",
      entityId: user.id,
      action: "submitted",
      performedBy: user.id,
      metadata: {
        action: "submitted",
        request_id: requestId,
        result: "succeeded",
        seller_status: "pending",
        storage_bucket: "seller_documents",
        document_access_mode: "signed_url_only",
        document_url_ttl_seconds: DOCUMENT_SIGNED_URL_EXPIRY_SECONDS,
      },
      logLabel: "submit_seller_application audit insert failed",
      requestId,
    });

    return jsonResponse({
      success: true,
      seller_status: "pending",
      onboarding_completed: true,
      country_code: "IT",
      request_id: requestId,
    }, 200);
  } catch (error) {
    if (userUpdated) {
      await adminClient
        .from("users")
        .update({
          first_name: currentUser.first_name,
          last_name: currentUser.last_name,
          country_code: currentUser.country_code,
          region: currentUser.region,
          tesserino_number: currentUser.tesserino_number,
          seller_status: currentUser.seller_status,
          onboarding_completed: currentUser.onboarding_completed,
        })
        .eq("id", user.id);
    }

    if (metadataWritten) {
      if (previousSellerDocuments != null) {
        await adminClient
          .from("seller_documents")
          .upsert(previousSellerDocuments, { onConflict: "user_id" });
      } else {
        await adminClient.from("seller_documents").delete().eq("user_id", user.id);
      }
    }

    if (uploadedPaths.length > 0) {
      await adminClient.storage.from("seller_documents").remove(uploadedPaths);
    }

    await insertAuditLog(adminClient, {
      entityType: "seller_application",
      entityId: user.id,
      action: "submit_failed",
      performedBy: user.id,
      metadata: {
        action: "submit_failed",
        request_id: requestId,
        result: "failed",
        error_code: resolveAuditFailureCode(error),
      },
      logLabel: "submit_seller_application failure audit insert failed",
      requestId,
    });

    console.error("submit_seller_application failed", {
      request_id: requestId,
      ...normalizeErrorForLogging(error),
    });
    return toErrorResponse(error, requestId);
  }
});

function validatePayload(payload: SubmitSellerApplicationPayload): string | null {
  if (!payload || typeof payload !== "object") {
    return "invalid_payload";
  }

  if (!isNonEmptyString(payload.first_name)) {
    return "missing_first_name";
  }
  if (!isNonEmptyString(payload.last_name)) {
    return "missing_last_name";
  }
  if (payload.country_code?.trim().toUpperCase() !== "IT") {
    return "invalid_country_code";
  }
  if (!isNonEmptyString(payload.region)) {
    return "missing_region";
  }
  if (!isNonEmptyString(payload.tesserino_number)) {
    return "missing_tesserino_number";
  }
  if (!isValidDocumentPayload(payload.identity_document)) {
    return "invalid_identity_document";
  }
  if (!isValidDocumentPayload(payload.tesserino_document)) {
    return "invalid_tesserino_document";
  }
  if (
    estimatedDecodedBytes(payload.identity_document.content_base64) >
      MAX_DOCUMENT_BYTES ||
    estimatedDecodedBytes(payload.tesserino_document.content_base64) >
      MAX_DOCUMENT_BYTES
  ) {
    return "document_too_large";
  }
  if (
    estimatedDecodedBytes(payload.identity_document.content_base64) +
        estimatedDecodedBytes(payload.tesserino_document.content_base64) >
      MAX_REQUEST_BYTES
  ) {
    return "request_payload_too_large";
  }

  return null;
}

function isValidDocumentPayload(payload: SellerDocumentPayload): boolean {
  return !!payload &&
    isNonEmptyString(payload.file_name) &&
    isNonEmptyString(payload.content_base64) &&
    isNonEmptyString(payload.content_type);
}

async function enforceSubmissionRateLimit(
  adminClient: any,
  userId: string,
  requestId: string,
): Promise<string | null> {
  const windowStart = new Date(
    Date.now() - SUBMISSION_RATE_WINDOW_MINUTES * 60 * 1000,
  ).toISOString();

  const attemptsLookup = await adminClient
    .from("audit_logs")
    .select("id", { count: "exact", head: true })
    .eq("entity_type", "seller_application")
    .eq("entity_id", userId)
    .eq("action", "submit_attempt")
    .gte("created_at", windowStart);

  if (attemptsLookup.error) {
    console.error(
      "submit_seller_application rate limit lookup failed",
      attemptsLookup.error,
    );
    return "seller_submission_rate_limit_lookup_failed";
  }

  const attemptsInWindow = attemptsLookup.count ?? 0;
  if (attemptsInWindow >= MAX_SUBMISSION_ATTEMPTS_PER_WINDOW) {
    await insertAuditLog(adminClient, {
      entityType: "seller_application",
      entityId: userId,
      action: "submit_rejected",
      performedBy: userId,
      metadata: {
        action: "submit_rejected",
        request_id: requestId,
        result: "rate_limited",
        rate_window_minutes: SUBMISSION_RATE_WINDOW_MINUTES,
      },
      logLabel: "submit_seller_application rate limit reject audit insert failed",
      requestId,
    });
    return "seller_submission_rate_limited";
  }

  const auditInsertError = await insertAuditLog(adminClient, {
    entityType: "seller_application",
    entityId: userId,
    action: "submit_attempt",
    performedBy: userId,
    metadata: {
      action: "submit_attempt",
      request_id: requestId,
      result: "attempted",
      rate_window_minutes: SUBMISSION_RATE_WINDOW_MINUTES,
    },
    logLabel: "submit_seller_application rate limit audit insert failed",
    swallowError: true,
    requestId,
  });

  if (auditInsertError) {
    return "seller_submission_rate_limit_audit_failed";
  }

  return null;
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function decodeBase64(value: string): Uint8Array | null {
  try {
    const binary = atob(value);
    const bytes = new Uint8Array(binary.length);
    for (let index = 0; index < binary.length; index++) {
      bytes[index] = binary.charCodeAt(index);
    }
    return bytes;
  } catch {
    return null;
  }
}

function estimatedDecodedBytes(base64Value: string): number {
  const normalized = base64Value.replace(/\s/g, "");
  if (normalized.length === 0) {
    return 0;
  }

  let padding = 0;
  if (normalized.endsWith("==")) {
    padding = 2;
  } else if (normalized.endsWith("=")) {
    padding = 1;
  }

  return Math.floor((normalized.length * 3) / 4) - padding;
}

function buildStoragePath(
  userId: string,
  documentPrefix: string,
  extension: AllowedDocumentType["extension"],
): string {
  return `${userId}/${documentPrefix}_${Date.now()}_${crypto.randomUUID()}${extension}`;
}

function extractExtension(
  fileName: string,
): AllowedDocumentType["extension"] | null {
  const sanitized = fileName.trim().toLowerCase();
  if (sanitized.endsWith(".pdf")) return ".pdf";
  if (sanitized.endsWith(".png")) return ".png";
  if (sanitized.endsWith(".jpg")) return ".jpg";
  if (sanitized.endsWith(".jpeg")) return ".jpeg";
  return null;
}

function normalizeContentType(contentType: string): string {
  return contentType.trim().toLowerCase().split(";")[0] ?? "";
}

function validateDecodedDocument(
  payload: SellerDocumentPayload,
  bytes: Uint8Array,
): string | null {
  if (bytes.length === 0) {
    return "invalid_document_content";
  }

  if (bytes.length > MAX_DOCUMENT_BYTES) {
    return "document_too_large";
  }

  const documentType = resolveAllowedDocumentType(
    payload.file_name,
    payload.content_type,
    bytes,
  );

  if (documentType == null) {
    return "document_type_mismatch";
  }

  return null;
}

function resolveAllowedDocumentType(
  fileName: string,
  contentType: string,
  bytes: Uint8Array,
): AllowedDocumentType | null {
  const extension = extractExtension(fileName);
  if (extension == null) {
    return null;
  }

  const normalizedContentType = normalizeContentType(contentType);
  const detectedType = detectDocumentType(bytes);
  if (detectedType == null) {
    return null;
  }

  return allowedDocumentTypes.find((documentType) =>
    documentType.extension === extension &&
    documentType.mimeType === normalizedContentType &&
    documentType.detectedType === detectedType
  ) ?? null;
}

function detectDocumentType(
  bytes: Uint8Array,
): AllowedDocumentType["detectedType"] | null {
  if (
    bytes.length >= 5 &&
    bytes[0] === 0x25 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x44 &&
    bytes[3] === 0x46 &&
    bytes[4] === 0x2D
  ) {
    return "pdf";
  }

  if (
    bytes.length >= 8 &&
    bytes[0] === 0x89 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x4E &&
    bytes[3] === 0x47 &&
    bytes[4] === 0x0D &&
    bytes[5] === 0x0A &&
    bytes[6] === 0x1A &&
    bytes[7] === 0x0A
  ) {
    return "png";
  }

  if (
    bytes.length >= 3 &&
    bytes[0] === 0xFF &&
    bytes[1] === 0xD8 &&
    bytes[2] === 0xFF
  ) {
    return "jpeg";
  }

  return null;
}

function parseContentLength(headerValue: string | null): number | null {
  if (headerValue == null || headerValue.trim().length === 0) {
    return null;
  }

  const parsed = Number.parseInt(headerValue, 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : null;
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
  if (error instanceof SubmitSellerApplicationError) {
    return jsonResponse(
      {
        error: error.appCode,
        message: error.message,
        ...(requestId ? { request_id: requestId } : {}),
      },
      error.status,
    );
  }

  const code = readErrorCode(error);
  const message = readErrorMessage(error);

  if (code === "23505" && message.includes("tesserino_number")) {
    return jsonResponse({ error: "duplicate_tesserino_number" }, 409, requestId);
  }

  if (
    code === "22P02" ||
    code === "23514" ||
    message.includes("region_enum") ||
    message.includes("users_country_region_chk")
  ) {
    return jsonResponse({ error: "invalid_region" }, 400, requestId);
  }

  return jsonResponse(
    {
      error: "seller_submit_failed",
      message: "Unexpected seller onboarding failure.",
      ...(requestId ? { request_id: requestId } : {}),
    },
    500,
  );
}

function normalizeErrorForLogging(error: unknown): Record<string, unknown> {
  if (error instanceof SubmitSellerApplicationError) {
    return {
      appCode: error.appCode,
      status: error.status,
      message: error.message,
      causeCode: readErrorCode(error.cause),
      causeMessage: readErrorMessage(error.cause),
    };
  }

  return {
    code: readErrorCode(error),
    message: readErrorMessage(error),
  };
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
      return value.toLowerCase();
    }
  }

  return "";
}

function validateRuntimeSupabaseUrl(
  supabaseUrl: string,
): Record<string, unknown> | null {
  let parsedUrl: URL;
  try {
    parsedUrl = new URL(supabaseUrl);
  } catch {
    return {
      error: "invalid_runtime_supabase_url",
      message: "SUPABASE_URL is not a valid URL for the seller onboarding function.",
    };
  }

  if (parsedUrl.hostname === "10.0.2.2") {
    return {
      error: "invalid_runtime_supabase_url",
      message:
        "SUPABASE_URL points to the Android emulator loopback. Edge Functions must not be started with the Flutter app env file.",
    };
  }

  return null;
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
    swallowError?: boolean;
    requestId?: string;
  },
): Promise<unknown | null> {
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
    return auditInsert.error;
  }

  return null;
}

function resolveAuditFailureCode(error: unknown): string {
  if (error instanceof SubmitSellerApplicationError) {
    return error.appCode;
  }

  return readErrorCode(error) || "seller_submit_failed";
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

const allowedDocumentTypes: AllowedDocumentType[] = [
  {
    extension: ".pdf",
    mimeType: "application/pdf",
    detectedType: "pdf",
  },
  {
    extension: ".png",
    mimeType: "image/png",
    detectedType: "png",
  },
  {
    extension: ".jpg",
    mimeType: "image/jpeg",
    detectedType: "jpeg",
  },
  {
    extension: ".jpeg",
    mimeType: "image/jpeg",
    detectedType: "jpeg",
  },
];
