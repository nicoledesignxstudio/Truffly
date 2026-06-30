import {
  adminCorsHeaders,
  createSellerReviewNotification,
  deleteSellerDocuments,
  getRequestId,
  insertAuditLog,
  jsonResponse,
  readJsonPayload,
  requireAdminContext,
  requirePendingSeller,
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
    const { adminClient, user } = await requireAdminContext(request, requestId);
    const payload = await readJsonPayload<Payload>(request);
    const userId = validateUuid(payload.user_id);
    await requirePendingSeller(adminClient, userId);

    const updateResult = await adminClient.from("users")
      .update({ seller_status: "approved", role: "seller" })
      .eq("id", userId)
      .eq("seller_status", "pending")
      .select("id")
      .single();
    if (updateResult.error || !updateResult.data) {
      return jsonResponse({ error: "seller_approval_failed" }, 409, requestId);
    }

    const deletedDocuments = await deleteSellerDocuments(adminClient, userId);
    await createSellerReviewNotification({
      adminClient,
      userId,
      approved: true,
      requestId,
    });
    await insertAuditLog(adminClient, {
      entityType: "seller_application",
      entityId: userId,
      action: "approved",
      performedBy: user.id,
      requestId,
      metadata: {
        result: "succeeded",
        seller_status: "approved",
        deleted_documents: deletedDocuments,
      },
    });

    return jsonResponse({ success: true }, 200, requestId);
  } catch (error) {
    return toErrorResponse(error, requestId);
  }
});
