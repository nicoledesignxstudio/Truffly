import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const stagingBucket = "truffle_images_staging";
const finalImagesBucket = "truffle_images";
const maxImageBytes = 1500000;
const maxPublishRequestIdLength = 128;

type PublishTruffleImagePayload = {
  staging_path: string;
};

type PublishTrufflePayload = {
  publish_request_id: string;
  truffle_type: string;
  quality: string;
  weight_grams: number;
  price_total: number;
  shipping_price_italy: number;
  shipping_price_abroad: number;
  region: string;
  harvest_date: string;
  images: PublishTruffleImagePayload[];
};

type ValidatedImage = {
  stagingPath: string;
  bytes: Uint8Array;
  extension: ".jpg" | ".png";
  contentType: "image/jpeg" | "image/png";
};

type PublishAllowedValues = {
  truffleTypes: Set<string>;
  qualities: Set<string>;
  regions: Set<string>;
};

type StorageDownloadResult = {
  data: Blob | null;
  error: unknown;
};

type PublishRequestStatus = "processing" | "succeeded" | "failed";

type PublishRequestRow = {
  request_id: string;
  request_status: PublishRequestStatus;
  request_fingerprint: string;
  truffle_id: string | null;
  failure_code: string | null;
  failure_message: string | null;
  failure_http_status: number | null;
};

type PublishErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "seller_not_allowed"
  | "invalid_json_body"
  | "invalid_payload"
  | "missing_publish_request_id"
  | "publish_request_payload_mismatch"
  | "publish_request_in_progress"
  | "publish_request_failed"
  | "invalid_truffle_type"
  | "invalid_quality"
  | "invalid_weight_grams"
  | "invalid_price_total"
  | "invalid_shipping_price_italy"
  | "invalid_shipping_price_abroad"
  | "missing_region"
  | "invalid_region"
  | "missing_harvest_date"
  | "invalid_harvest_date"
  | "harvest_date_in_future"
  | "missing_images"
  | "too_many_images"
  | "invalid_image_payload"
  | "invalid_image_type"
  | "invalid_image_encoding"
  | "invalid_image_size"
  | "publish_validation_failed"
  | "publish_image_upload_failed"
  | "publish_image_cleanup_failed"
  | "publish_unknown_error";

class PublishFlowError extends Error {
  constructor(
    readonly code: PublishErrorCode,
    readonly status: number,
    message: string,
    readonly cause?: unknown,
  ) {
    super(message);
    this.name = "PublishFlowError";
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
      "publish_unknown_error",
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
    return errorResponse(
      "unauthorized",
      "Authentication is required.",
      401,
    );
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, role, seller_status, stripe_account_id, is_active")
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

  if (
    currentUser.role !== "seller" ||
    currentUser.seller_status !== "approved" ||
    currentUser.stripe_account_id == null ||
    `${currentUser.stripe_account_id}`.trim() === ""
  ) {
    return errorResponse(
      "seller_not_allowed",
      "Only approved sellers with Stripe onboarding completed can publish truffles.",
      403,
    );
  }

  let payload: PublishTrufflePayload;
  try {
    payload = await request.json();
  } catch {
    return errorResponse(
      "invalid_json_body",
      "Request body must be valid JSON.",
      400,
    );
  }

  const publishRequestId = normalizePublishRequestId(payload.publish_request_id);
  if (publishRequestId == null) {
    return errorResponse(
      "missing_publish_request_id",
      "Publish request id is required.",
      400,
    );
  }

  const requestFingerprint = buildRequestFingerprint(payload, publishRequestId);
  const requestRegistration = await beginOrReadPublishRequest({
    adminClient,
    userId: user.id,
    requestId: publishRequestId,
    requestFingerprint,
  });

  if (!requestRegistration.isNew) {
    return resolveExistingRequest(requestRegistration.row, requestFingerprint);
  }

  const stagedPathsForCleanup = collectStagedPaths(payload);
  let truffleId: string | null = null;
  const finalizedPaths: string[] = [];
  const remainingStagedPaths = new Set<string>(stagedPathsForCleanup);

  try {
    const allowedValues = await loadPublishAllowedValues(adminClient);
    const validationError = validatePayload(payload, allowedValues);
    if (validationError != null) {
      throw new PublishFlowError(
        validationError,
        400,
        validationMessage(validationError),
      );
    }

    const validatedImages: ValidatedImage[] = [];
    for (const image of payload.images) {
      validatedImages.push(
        await validateStagedImage({
          adminClient,
          image,
          userId: user.id,
        }),
      );
    }

    const normalizedRegion = payload.region.trim().toUpperCase();
    const normalizedHarvestDate = normalizeDate(payload.harvest_date);
    if (normalizedHarvestDate == null) {
      throw new PublishFlowError(
        "invalid_harvest_date",
        400,
        validationMessage("invalid_harvest_date"),
      );
    }

    const insertResult = await adminClient
      .from("truffles")
      .insert({
        seller_id: user.id,
        truffle_type: payload.truffle_type.trim().toUpperCase(),
        quality: payload.quality.trim().toUpperCase(),
        weight_grams: payload.weight_grams,
        price_total: payload.price_total,
        shipping_price_italy: payload.shipping_price_italy,
        shipping_price_abroad: payload.shipping_price_abroad,
        region: normalizedRegion,
        harvest_date: normalizedHarvestDate,
        status: "publishing",
      })
      .select("id")
      .single();

    if (insertResult.error) {
      throw mapDatabaseError(
        insertResult.error,
        "Failed to create the truffle draft.",
      );
    }

    if (!insertResult.data?.id) {
      throw new PublishFlowError(
        "publish_unknown_error",
        500,
        "Failed to create the truffle draft.",
      );
    }

    truffleId = insertResult.data.id;

    const imageRows = [];
    for (let index = 0; index < validatedImages.length; index++) {
      const image = validatedImages[index];
      const orderIndex = index + 1;
      const storagePath = buildStoragePath(truffleId, orderIndex, image.extension);

      const uploadResult = await adminClient.storage.from(finalImagesBucket).upload(
        storagePath,
        image.bytes,
        {
          contentType: image.contentType,
          upsert: false,
        },
      );

      if (uploadResult.error) {
        throw new PublishFlowError(
          "publish_image_upload_failed",
          500,
          "Failed to upload one or more images.",
          uploadResult.error,
        );
      }

      finalizedPaths.push(storagePath);
      imageRows.push({
        truffle_id: truffleId,
        image_url: storagePath,
        order_index: orderIndex,
      });
    }

    const imageInsert = await adminClient.from("truffle_images").insert(imageRows);
    if (imageInsert.error) {
      throw mapDatabaseError(
        imageInsert.error,
        "Failed to persist truffle images.",
      );
    }

    const activationUpdate = await adminClient
      .from("truffles")
      .update({ status: "active" })
      .eq("id", truffleId)
      .eq("status", "publishing");

    if (activationUpdate.error) {
      throw mapDatabaseError(
        activationUpdate.error,
        "Failed to activate the published truffle.",
      );
    }

    const auditInsert = await adminClient.from("audit_logs").insert({
      entity_type: "truffle",
      entity_id: truffleId,
      action: "published",
      performed_by: user.id,
      metadata: {
        image_count: validatedImages.length,
        storage_bucket: finalImagesBucket,
        publish_request_id: publishRequestId,
      },
    });

    if (auditInsert.error) {
      console.error("publish_truffle audit insert failed", auditInsert.error);
    }

    await markPublishRequestSucceeded({
      adminClient,
      userId: user.id,
      requestId: publishRequestId,
      truffleId,
    });

    if (remainingStagedPaths.size > 0) {
      const stagingCleanup = await adminClient.storage.from(stagingBucket).remove(
        [...remainingStagedPaths],
      );
      if (stagingCleanup.error) {
        console.error(
          "publish_truffle success-path staged cleanup failed",
          stagingCleanup.error,
        );
      }
    }

    return jsonResponse({
      success: true,
      truffle_id: truffleId,
      status: "active",
    }, 200);
  } catch (error) {
    let cleanupFailed = false;

    if (finalizedPaths.length > 0) {
      const finalizedCleanup = await adminClient.storage.from(finalImagesBucket).remove(
        finalizedPaths,
      );
      if (finalizedCleanup.error) {
        console.error(
          "publish_truffle cleanup finalized images failed",
          finalizedCleanup.error,
        );
        cleanupFailed = true;
      }
    }

    if (remainingStagedPaths.size > 0) {
      const stagingCleanup = await adminClient.storage.from(stagingBucket).remove(
        [...remainingStagedPaths],
      );
      if (stagingCleanup.error) {
        console.error(
          "publish_truffle cleanup staged images failed",
          stagingCleanup.error,
        );
        cleanupFailed = true;
      }
    }

    if (truffleId != null) {
      const deleteResult = await adminClient.from("truffles").delete().eq(
        "id",
        truffleId,
      );
      if (deleteResult.error) {
        console.error(
          "publish_truffle cleanup truffle delete failed",
          deleteResult.error,
        );
        cleanupFailed = true;
      }
    }

    console.error("publish_truffle failed", error);

    const normalizedError = normalizeUnhandledError(error);
    const finalError = cleanupFailed
      ? new PublishFlowError(
        "publish_image_cleanup_failed",
        500,
        "Publish failed and cleanup could not be completed safely.",
        error,
      )
      : normalizedError;

    await markPublishRequestFailed({
      adminClient,
      userId: user.id,
      requestId: publishRequestId,
      error: finalError,
    });

    return errorResponse(finalError.code, finalError.message, finalError.status);
  }
});

function validatePayload(
  payload: PublishTrufflePayload,
  allowedValues: PublishAllowedValues,
): PublishErrorCode | null {
  if (!payload || typeof payload !== "object") {
    return "invalid_payload";
  }

  const truffleType = payload.truffle_type?.trim().toUpperCase();
  if (!truffleType || !allowedValues.truffleTypes.has(truffleType)) {
    return "invalid_truffle_type";
  }

  const quality = payload.quality?.trim().toUpperCase();
  if (!quality || !allowedValues.qualities.has(quality)) {
    return "invalid_quality";
  }

  if (!Number.isInteger(payload.weight_grams) || payload.weight_grams <= 0) {
    return "invalid_weight_grams";
  }

  if (!isPositiveNumber(payload.price_total)) {
    return "invalid_price_total";
  }

  if (!isNonNegativeNumber(payload.shipping_price_italy)) {
    return "invalid_shipping_price_italy";
  }

  if (!isNonNegativeNumber(payload.shipping_price_abroad)) {
    return "invalid_shipping_price_abroad";
  }

  const region = payload.region?.trim().toUpperCase();
  if (!region) {
    return "missing_region";
  }
  if (!allowedValues.regions.has(region)) {
    return "invalid_region";
  }

  if (!isNonEmptyString(payload.harvest_date)) {
    return "missing_harvest_date";
  }

  const normalizedHarvestDate = normalizeDate(payload.harvest_date);
  if (normalizedHarvestDate == null) {
    return "invalid_harvest_date";
  }
  if (isFutureDate(normalizedHarvestDate)) {
    return "harvest_date_in_future";
  }

  if (!Array.isArray(payload.images) || payload.images.length == 0) {
    return "missing_images";
  }
  if (payload.images.length > 3) {
    return "too_many_images";
  }

  for (const image of payload.images) {
    if (!image || typeof image !== "object") {
      return "invalid_image_payload";
    }
    if (!isNonEmptyString(image.staging_path)) {
      return "invalid_image_payload";
    }
  }

  return null;
}

async function loadPublishAllowedValues(
  adminClient: ReturnType<typeof createClient>,
): Promise<PublishAllowedValues> {
  const [truffleTypes, qualities, regions] = await Promise.all([
    loadEnumValues(adminClient, "truffle_type_enum"),
    loadEnumValues(adminClient, "truffle_quality_enum"),
    loadEnumValues(adminClient, "region_enum"),
  ]);

  return {
    truffleTypes,
    qualities,
    regions,
  };
}

async function loadEnumValues(
  adminClient: ReturnType<typeof createClient>,
  enumName: "truffle_type_enum" | "truffle_quality_enum" | "region_enum",
): Promise<Set<string>> {
  const { data, error } = await adminClient.rpc("get_enum_values", {
    p_enum_name: enumName,
  });

  if (error) {
    throw error;
  }

  if (!Array.isArray(data) || data.length === 0) {
    throw new Error(`Enum ${enumName} returned no values.`);
  }

  return new Set(
    data
      .filter((value): value is string => typeof value === "string")
      .map((value) => value.trim().toUpperCase())
      .filter((value) => value.length > 0),
  );
}

async function validateStagedImage({
  adminClient,
  image,
  userId,
}: {
  adminClient: ReturnType<typeof createClient>;
  image: PublishTruffleImagePayload;
  userId: string;
}): Promise<ValidatedImage> {
  const normalizedPath = image.staging_path.trim();
  if (!isOwnedStagingPath(normalizedPath, userId)) {
    throw new PublishFlowError(
      "invalid_image_payload",
      400,
      validationMessage("invalid_image_payload"),
    );
  }

  let downloadResult: StorageDownloadResult;
  try {
    downloadResult = await adminClient.storage.from(stagingBucket).download(
      normalizedPath,
    );
  } catch (error) {
    throw new PublishFlowError(
      "invalid_image_payload",
      400,
      validationMessage("invalid_image_payload"),
      error,
    );
  }

  if (downloadResult.error || !downloadResult.data) {
    throw new PublishFlowError(
      "invalid_image_payload",
      400,
      validationMessage("invalid_image_payload"),
      downloadResult.error,
    );
  }

  const bytes = new Uint8Array(await downloadResult.data.arrayBuffer());
  if (bytes.length === 0) {
    throw new PublishFlowError(
      "invalid_image_encoding",
      400,
      validationMessage("invalid_image_encoding"),
    );
  }

  if (bytes.length > maxImageBytes) {
    throw new PublishFlowError(
      "invalid_image_size",
      400,
      validationMessage("invalid_image_size"),
    );
  }

  if (isJpeg(bytes)) {
    return {
      stagingPath: normalizedPath,
      bytes,
      extension: ".jpg",
      contentType: "image/jpeg",
    };
  }

  if (isPng(bytes)) {
    return {
      stagingPath: normalizedPath,
      bytes,
      extension: ".png",
      contentType: "image/png",
    };
  }

  throw new PublishFlowError(
    "invalid_image_type",
    400,
    validationMessage("invalid_image_type"),
  );
}

async function beginOrReadPublishRequest({
  adminClient,
  userId,
  requestId,
  requestFingerprint,
}: {
  adminClient: ReturnType<typeof createClient>;
  userId: string;
  requestId: string;
  requestFingerprint: string;
}): Promise<{ row: PublishRequestRow; isNew: boolean }> {
  const insertResult = await adminClient
    .from("publish_truffle_requests")
    .insert({
      user_id: userId,
      request_id: requestId,
      request_status: "processing",
      request_fingerprint: requestFingerprint,
    })
    .select(
      "request_id, request_status, request_fingerprint, truffle_id, failure_code, failure_message, failure_http_status",
    )
    .single();

  if (!insertResult.error && insertResult.data) {
    return {
      row: insertResult.data as PublishRequestRow,
      isNew: true,
    };
  }

  if (insertResult.error?.code !== "23505") {
    throw new PublishFlowError(
      "publish_unknown_error",
      500,
      "Failed to register the publish request.",
      insertResult.error,
    );
  }

  const existingResult = await adminClient
    .from("publish_truffle_requests")
    .select(
      "request_id, request_status, request_fingerprint, truffle_id, failure_code, failure_message, failure_http_status",
    )
    .eq("user_id", userId)
    .eq("request_id", requestId)
    .single();

  if (existingResult.error || !existingResult.data) {
    throw new PublishFlowError(
      "publish_unknown_error",
      500,
      "Failed to load the existing publish request.",
      existingResult.error,
    );
  }

  return {
    row: existingResult.data as PublishRequestRow,
    isNew: false,
  };
}

function resolveExistingRequest(
  row: PublishRequestRow,
  requestFingerprint: string,
): Response {
  if (row.request_fingerprint !== requestFingerprint) {
    return errorResponse(
      "publish_request_payload_mismatch",
      "This publish request id was already used with a different payload.",
      409,
    );
  }

  if (row.request_status === "succeeded" && row.truffle_id != null) {
    return jsonResponse({
      success: true,
      truffle_id: row.truffle_id,
      status: "active",
    }, 200);
  }

  if (row.request_status === "processing") {
    return errorResponse(
      "publish_request_in_progress",
      "This publish request is still being processed.",
      409,
    );
  }

  if (row.request_status === "failed") {
    const errorCode = normalizeStoredErrorCode(row.failure_code);
    return errorResponse(
      errorCode,
      row.failure_message ?? errorMessage(errorCode),
      row.failure_http_status ?? errorStatus(errorCode),
    );
  }

  return errorResponse(
    "publish_request_failed",
    "This publish request cannot be retried safely.",
    409,
  );
}

async function markPublishRequestSucceeded({
  adminClient,
  userId,
  requestId,
  truffleId,
}: {
  adminClient: ReturnType<typeof createClient>;
  userId: string;
  requestId: string;
  truffleId: string;
}): Promise<void> {
  const updateResult = await adminClient
    .from("publish_truffle_requests")
    .update({
      request_status: "succeeded",
      truffle_id: truffleId,
      failure_code: null,
      failure_message: null,
      failure_http_status: null,
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", userId)
    .eq("request_id", requestId)
    .eq("request_status", "processing");

  if (updateResult.error) {
    throw new PublishFlowError(
      "publish_unknown_error",
      500,
      "Failed to finalize the publish request state.",
      updateResult.error,
    );
  }
}

async function markPublishRequestFailed({
  adminClient,
  userId,
  requestId,
  error,
}: {
  adminClient: ReturnType<typeof createClient>;
  userId: string;
  requestId: string;
  error: PublishFlowError;
}): Promise<void> {
  const updateResult = await adminClient
    .from("publish_truffle_requests")
    .update({
      request_status: "failed",
      truffle_id: null,
      failure_code: error.code,
      failure_message: error.message,
      failure_http_status: error.status,
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", userId)
    .eq("request_id", requestId);

  if (updateResult.error) {
    console.error(
      "publish_truffle request state update failed",
      updateResult.error,
    );
  }
}

function normalizePublishRequestId(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (trimmed.length === 0 || trimmed.length > maxPublishRequestIdLength) {
    return null;
  }

  return trimmed;
}

function buildRequestFingerprint(
  payload: PublishTrufflePayload,
  publishRequestId: string,
): string {
  return JSON.stringify({
    publish_request_id: publishRequestId,
    truffle_type: payload.truffle_type?.trim().toUpperCase() ?? "",
    quality: payload.quality?.trim().toUpperCase() ?? "",
    weight_grams: payload.weight_grams,
    price_total: payload.price_total,
    shipping_price_italy: payload.shipping_price_italy,
    shipping_price_abroad: payload.shipping_price_abroad,
    region: payload.region?.trim().toUpperCase() ?? "",
    harvest_date: payload.harvest_date?.trim() ?? "",
    images: Array.isArray(payload.images)
      ? payload.images.map((image) => image?.staging_path?.trim() ?? "")
      : [],
  });
}

function normalizeUnhandledError(error: unknown): PublishFlowError {
  if (error instanceof PublishFlowError) {
    return error;
  }

  return new PublishFlowError(
    "publish_unknown_error",
    500,
    "An unexpected error occurred while publishing the truffle.",
    error,
  );
}

function normalizeStoredErrorCode(code: string | null): PublishErrorCode {
  if (code != null && isPublishErrorCode(code)) {
    return code;
  }

  return "publish_request_failed";
}

function isPublishErrorCode(code: string): code is PublishErrorCode {
  return [
    "method_not_allowed",
    "unauthorized",
    "user_not_found",
    "inactive_account",
    "seller_not_allowed",
    "invalid_json_body",
    "invalid_payload",
    "missing_publish_request_id",
    "publish_request_payload_mismatch",
    "publish_request_in_progress",
    "publish_request_failed",
    "invalid_truffle_type",
    "invalid_quality",
    "invalid_weight_grams",
    "invalid_price_total",
    "invalid_shipping_price_italy",
    "invalid_shipping_price_abroad",
    "missing_region",
    "invalid_region",
    "missing_harvest_date",
    "invalid_harvest_date",
    "harvest_date_in_future",
    "missing_images",
    "too_many_images",
    "invalid_image_payload",
    "invalid_image_type",
    "invalid_image_encoding",
    "invalid_image_size",
    "publish_validation_failed",
    "publish_image_upload_failed",
    "publish_image_cleanup_failed",
    "publish_unknown_error",
  ].includes(code);
}

function isPositiveNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && value > 0;
}

function isNonNegativeNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && value >= 0;
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function normalizeDate(value: string): string | null {
  const trimmed = value.trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) {
    return null;
  }

  const date = new Date(`${trimmed}T00:00:00Z`);
  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return trimmed;
}

function isFutureDate(value: string): boolean {
  const today = new Date();
  const normalizedToday = new Date(Date.UTC(
    today.getUTCFullYear(),
    today.getUTCMonth(),
    today.getUTCDate(),
  ));
  const date = new Date(`${value}T00:00:00Z`);
  return date.getTime() > normalizedToday.getTime();
}

function collectStagedPaths(payload: PublishTrufflePayload): string[] {
  if (!Array.isArray(payload.images)) {
    return [];
  }

  return payload.images
    .map((image) => image.staging_path?.trim() ?? "")
    .filter((path) => path.length > 0);
}

function isOwnedStagingPath(path: string, userId: string): boolean {
  const expectedPrefix = `staging/${userId}/`;
  if (!path.startsWith(expectedPrefix)) {
    return false;
  }

  const remainder = path.slice(expectedPrefix.length);
  return remainder.length > 0 && !remainder.includes("..");
}

function isJpeg(bytes: Uint8Array): boolean {
  return bytes.length >= 3 &&
    bytes[0] === 0xFF &&
    bytes[1] === 0xD8 &&
    bytes[2] === 0xFF;
}

function isPng(bytes: Uint8Array): boolean {
  const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (bytes.length < pngSignature.length) {
    return false;
  }

  for (let index = 0; index < pngSignature.length; index++) {
    if (bytes[index] !== pngSignature[index]) {
      return false;
    }
  }

  return true;
}

function buildStoragePath(
  truffleId: string,
  orderIndex: number,
  extension: ".jpg" | ".png",
): string {
  const fileName = orderIndex === 1
    ? `cover${extension}`
    : `image_${orderIndex}${extension}`;
  return `${truffleId}/${fileName}`;
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
  error: PublishErrorCode,
  message: string,
  status: number,
): Response {
  return jsonResponse({ error, message }, status);
}

function mapDatabaseError(
  error: unknown,
  fallbackMessage: string,
): PublishFlowError {
  if (isDatabaseValidationError(error)) {
    return new PublishFlowError(
      "publish_validation_failed",
      400,
      "The publish payload failed backend validation.",
      error,
    );
  }

  return new PublishFlowError(
    "publish_unknown_error",
    500,
    fallbackMessage,
    error,
  );
}

function isDatabaseValidationError(error: unknown): boolean {
  if (typeof error !== "object" || error === null) {
    return false;
  }

  const code = "code" in error ? Reflect.get(error, "code") : null;
  if (code === "22P02" || code === "23514" || code === "23505") {
    return true;
  }

  const constraint = "constraint" in error
    ? Reflect.get(error, "constraint")
    : null;
  return constraint === "truffle_images_truffle_id_order_index_key";
}

function validationMessage(errorCode: PublishErrorCode): string {
  switch (errorCode) {
    case "invalid_payload":
      return "Publish payload is invalid.";
    case "invalid_json_body":
      return "Request body must be valid JSON.";
    case "missing_publish_request_id":
      return "Publish request id is required.";
    case "invalid_truffle_type":
      return "Truffle type is invalid.";
    case "invalid_quality":
      return "Truffle quality is invalid.";
    case "invalid_weight_grams":
      return "Weight must be greater than zero.";
    case "invalid_price_total":
      return "Total price must be greater than zero.";
    case "invalid_shipping_price_italy":
      return "Italy shipping price must be zero or greater.";
    case "invalid_shipping_price_abroad":
      return "Abroad shipping price must be zero or greater.";
    case "missing_region":
      return "Harvest region is required.";
    case "invalid_region":
      return "Harvest region is invalid.";
    case "missing_harvest_date":
      return "Harvest date is required.";
    case "invalid_harvest_date":
      return "Harvest date is invalid.";
    case "harvest_date_in_future":
      return "Harvest date cannot be in the future.";
    case "missing_images":
      return "At least one image is required.";
    case "too_many_images":
      return "At most three images are allowed.";
    case "invalid_image_payload":
      return "Image payload is invalid.";
    case "invalid_image_type":
      return "Image type is invalid.";
    case "invalid_image_encoding":
      return "Image encoding is invalid.";
    case "invalid_image_size":
      return "Image size exceeds the allowed limit.";
    case "publish_validation_failed":
      return "The publish payload failed backend validation.";
    default:
      return "Publish validation failed.";
  }
}

function errorStatus(errorCode: PublishErrorCode): number {
  switch (errorCode) {
    case "unauthorized":
      return 401;
    case "inactive_account":
    case "seller_not_allowed":
      return 403;
    case "user_not_found":
      return 404;
    case "publish_request_in_progress":
    case "publish_request_payload_mismatch":
    case "publish_request_failed":
      return 409;
    case "method_not_allowed":
      return 405;
    case "invalid_json_body":
    case "invalid_payload":
    case "missing_publish_request_id":
    case "invalid_truffle_type":
    case "invalid_quality":
    case "invalid_weight_grams":
    case "invalid_price_total":
    case "invalid_shipping_price_italy":
    case "invalid_shipping_price_abroad":
    case "missing_region":
    case "invalid_region":
    case "missing_harvest_date":
    case "invalid_harvest_date":
    case "harvest_date_in_future":
    case "missing_images":
    case "too_many_images":
    case "invalid_image_payload":
    case "invalid_image_type":
    case "invalid_image_encoding":
    case "invalid_image_size":
    case "publish_validation_failed":
      return 400;
    case "publish_image_upload_failed":
    case "publish_image_cleanup_failed":
    case "publish_unknown_error":
      return 500;
  }
}

function errorMessage(errorCode: PublishErrorCode): string {
  switch (errorCode) {
    case "publish_request_payload_mismatch":
      return "This publish request id was already used with a different payload.";
    case "publish_request_in_progress":
      return "This publish request is still being processed.";
    case "publish_request_failed":
      return "This publish request cannot be retried safely.";
    case "publish_image_upload_failed":
      return "Failed to upload one or more images.";
    case "publish_image_cleanup_failed":
      return "Publish failed and cleanup could not be completed safely.";
    case "publish_unknown_error":
      return "An unexpected error occurred while publishing the truffle.";
    default:
      return validationMessage(errorCode);
  }
}
