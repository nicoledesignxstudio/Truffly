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

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    return jsonResponse({ error: "missing_runtime_configuration" }, 500);
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
    return jsonResponse({ error: "unauthorized" }, 401);
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
    return jsonResponse({ error: "user_not_found" }, 404);
  }

  if (!currentUser.is_active) {
    return jsonResponse({ error: "inactive_account" }, 403);
  }

  if (currentUser.onboarding_completed === true) {
    return jsonResponse({ error: "onboarding_already_completed" }, 409);
  }

  if (
    currentUser.seller_status !== "not_requested" &&
    currentUser.seller_status !== "rejected"
  ) {
    return jsonResponse({ error: "seller_application_not_allowed" }, 409);
  }

  let payload: SubmitSellerApplicationPayload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_json_body" }, 400);
  }

  const validationError = validatePayload(payload);
  if (validationError != null) {
    return jsonResponse({ error: validationError }, 400);
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
    return jsonResponse({ error: "seller_documents_lookup_failed" }, 500);
  }

  const identityBytes = decodeBase64(payload.identity_document.content_base64);
  const tesserinoBytes = decodeBase64(
    payload.tesserino_document.content_base64,
  );

  if (identityBytes == null || tesserinoBytes == null) {
    return jsonResponse({ error: "invalid_document_encoding" }, 400);
  }

  const identityPath = buildStoragePath(
    user.id,
    "identity_document",
    payload.identity_document.file_name,
  );
  const tesserinoPath = buildStoragePath(
    user.id,
    "tesserino_document",
    payload.tesserino_document.file_name,
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
        contentType: payload.identity_document.content_type,
        upsert: false,
      });
    if (identityUpload.error) {
      throw identityUpload.error;
    }
    uploadedPaths.push(identityPath);

    const tesserinoUpload = await adminClient.storage.from("seller_documents")
      .upload(tesserinoPath, tesserinoBytes, {
        contentType: payload.tesserino_document.content_type,
        upsert: false,
      });
    if (tesserinoUpload.error) {
      throw tesserinoUpload.error;
    }
    uploadedPaths.push(tesserinoPath);

    const sellerDocumentsUpsert = await adminClient
      .from("seller_documents")
      .upsert({
        user_id: user.id,
        tesserino_number: payload.tesserino_number.trim(),
      }, { onConflict: "user_id" });
    if (sellerDocumentsUpsert.error) {
      throw sellerDocumentsUpsert.error;
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
      throw userUpdate.error;
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
      console.error(
        "submit_seller_application notification insert failed",
        notificationInsert.error,
      );
    }

    const auditInsert = await adminClient.from("audit_logs").insert({
      entity_type: "seller_application",
      entity_id: user.id,
      action: "submitted",
      performed_by: user.id,
      metadata: {
        seller_status: "pending",
        storage_bucket: "seller_documents",
        identity_document_path: identityPath,
        tesserino_document_path: tesserinoPath,
      },
    });
    if (auditInsert.error) {
      console.error(
        "submit_seller_application audit insert failed",
        auditInsert.error,
      );
    }

    return jsonResponse({
      success: true,
      seller_status: "pending",
      onboarding_completed: true,
      country_code: "IT",
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

    console.error("submit_seller_application failed", error);
    return toErrorResponse(error);
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

  return null;
}

function isValidDocumentPayload(payload: SellerDocumentPayload): boolean {
  return !!payload &&
    isNonEmptyString(payload.file_name) &&
    isNonEmptyString(payload.content_base64) &&
    isNonEmptyString(payload.content_type);
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

function buildStoragePath(
  userId: string,
  documentPrefix: string,
  fileName: string,
): string {
  const extension = extractExtension(fileName);
  return `${userId}/${documentPrefix}_${Date.now()}${extension}`;
}

function extractExtension(fileName: string): string {
  const sanitized = fileName.trim().toLowerCase();
  if (sanitized.endsWith(".pdf")) return ".pdf";
  if (sanitized.endsWith(".png")) return ".png";
  if (sanitized.endsWith(".jpg")) return ".jpg";
  if (sanitized.endsWith(".jpeg")) return ".jpeg";
  return ".bin";
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

function toErrorResponse(error: unknown): Response {
  const code = readErrorCode(error);
  const message = readErrorMessage(error);

  if (code === "23505" && message.includes("tesserino_number")) {
    return jsonResponse({ error: "duplicate_tesserino_number" }, 409);
  }

  if (
    code === "22P02" ||
    code === "23514" ||
    message.includes("region_enum") ||
    message.includes("users_country_region_chk")
  ) {
    return jsonResponse({ error: "invalid_region" }, 400);
  }

  return jsonResponse({ error: "seller_submit_failed" }, 500);
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
