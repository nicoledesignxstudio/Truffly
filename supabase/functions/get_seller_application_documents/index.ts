import {
  adminCorsHeaders,
  DOCUMENT_SIGNED_URL_EXPIRY_SECONDS,
  getRequestId,
  jsonResponse,
  readJsonPayload,
  requireAdminContext,
  requirePendingSeller,
  resolveLatestDocumentPath,
  toErrorResponse,
  validateUuid,
} from "../_shared/admin_seller_applications.ts";

type Payload = { user_id?: string };

Deno.serve(async (request) => {
  const requestId = getRequestId(request);
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: adminCorsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  try {
    const { adminClient } = await requireAdminContext(request, requestId);
    const payload = await readJsonPayload<Payload>(request);
    const userId = validateUuid(payload.user_id);
    await requirePendingSeller(adminClient, userId);

    const identityPath = await resolveLatestDocumentPath(
      adminClient,
      userId,
      "identity_document",
    );
    const tesserinoPath = await resolveLatestDocumentPath(
      adminClient,
      userId,
      "tesserino_document",
    );
    if (identityPath == null || tesserinoPath == null) {
      return jsonResponse({ error: "document_not_found" }, 404, requestId);
    }

    const identity = await adminClient.storage.from("seller_documents")
      .createSignedUrl(identityPath, DOCUMENT_SIGNED_URL_EXPIRY_SECONDS);
    const tesserino = await adminClient.storage.from("seller_documents")
      .createSignedUrl(tesserinoPath, DOCUMENT_SIGNED_URL_EXPIRY_SECONDS);

    if (
      identity.error || tesserino.error || !identity.data?.signedUrl ||
      !tesserino.data?.signedUrl
    ) {
      return jsonResponse(
        { error: "signed_url_generation_failed" },
        500,
        requestId,
      );
    }

    return jsonResponse(
      {
        identity_document_url: identity.data.signedUrl,
        tesserino_document_url: tesserino.data.signedUrl,
        expires_in: DOCUMENT_SIGNED_URL_EXPIRY_SECONDS,
      },
      200,
      requestId,
    );
  } catch (error) {
    return toErrorResponse(error, requestId);
  }
});
