import {
  adminCorsHeaders,
  getRequestId,
  jsonResponse,
  requireAdminContext,
  toErrorResponse,
} from "../_shared/admin_seller_applications.ts";

Deno.serve(async (request) => {
  const requestId = getRequestId(request);
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: adminCorsHeaders });
  }
  if (request.method !== "GET" && request.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405, requestId);
  }

  try {
    const { adminClient } = await requireAdminContext(request, requestId);
    const { data, error } = await adminClient
      .from("seller_documents")
      .select(
        "user_id, tesserino_number, uploaded_at, users!inner(id, first_name, last_name, country_code, region, seller_status, is_active)",
      )
      .eq("users.seller_status", "pending")
      .eq("users.is_active", true)
      .order("uploaded_at", { ascending: true });

    if (error) {
      throw error;
    }

    return jsonResponse(
      {
        applications: (data ?? []).map((row: any) => ({
          id: row.user_id,
          user_id: row.user_id,
          first_name: row.users?.first_name ?? null,
          last_name: row.users?.last_name ?? null,
          email: null,
          region: row.users?.region ?? null,
          seller_status: row.users?.seller_status ?? "pending",
          tesserino_number: row.tesserino_number ?? null,
          uploaded_at: row.uploaded_at ?? null,
        })),
      },
      200,
      requestId,
    );
  } catch (error) {
    return toErrorResponse(error, requestId);
  }
});
