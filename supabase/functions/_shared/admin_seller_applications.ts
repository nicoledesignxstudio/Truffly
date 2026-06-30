import {
  createClient,
  type SupabaseClient,
  type User,
} from "@supabase/supabase-js";
import { createBusinessNotificationAndPush } from "./business_notifications.ts";

export const adminCorsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

export const DOCUMENT_SIGNED_URL_EXPIRY_SECONDS = 300;

export type AdminContext = {
  adminClient: SupabaseClient;
  user: User;
  requestId: string;
};

export class AdminSellerApplicationError extends Error {
  constructor(
    readonly appCode: string,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "AdminSellerApplicationError";
  }
}

export async function requireAdminContext(
  request: Request,
  requestId: string,
): Promise<AdminContext> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey || !authHeader
  ) {
    throw new AdminSellerApplicationError(
      "missing_runtime_configuration",
      500,
      "Missing runtime configuration.",
    );
  }

  const authClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error } = await authClient.auth.getUser();
  if (error || !user) {
    throw new AdminSellerApplicationError("unauthorized", 401, "Unauthorized.");
  }

  if (user.app_metadata?.role !== "admin") {
    throw new AdminSellerApplicationError("forbidden", 403, "Forbidden.");
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
  const { data: currentUser, error: currentUserError } = await adminClient
    .from("users")
    .select("id, is_active")
    .eq("id", user.id)
    .single();
  if (currentUserError || !currentUser) {
    throw new AdminSellerApplicationError(
      "user_not_found",
      404,
      "User not found.",
    );
  }
  if (currentUser.is_active !== true) {
    throw new AdminSellerApplicationError(
      "inactive_account",
      403,
      "Inactive account.",
    );
  }

  return { adminClient, user, requestId };
}

export async function readJsonPayload<T>(request: Request): Promise<T> {
  try {
    return await request.json() as T;
  } catch {
    throw new AdminSellerApplicationError(
      "invalid_json_body",
      400,
      "Invalid JSON body.",
    );
  }
}

export function validateUuid(value: unknown, fieldName = "user_id"): string {
  if (typeof value !== "string" || !isUuid(value.trim())) {
    throw new AdminSellerApplicationError(
      `invalid_${fieldName}`,
      400,
      "Invalid UUID.",
    );
  }
  return value.trim();
}

export async function requirePendingSeller(
  adminClient: SupabaseClient,
  userId: string,
) {
  const { data: seller, error } = await adminClient
    .from("users")
    .select(
      "id, first_name, last_name, country_code, region, role, seller_status, tesserino_number, is_active",
    )
    .eq("id", userId)
    .maybeSingle();

  if (error) {
    throw new AdminSellerApplicationError(
      "seller_lookup_failed",
      500,
      "Unable to load seller application.",
      error,
    );
  }
  if (
    !seller || seller.is_active !== true || seller.seller_status !== "pending"
  ) {
    throw new AdminSellerApplicationError(
      "seller_application_not_pending",
      404,
      "Seller application not found.",
    );
  }

  return seller;
}

export async function resolveLatestDocumentPath(
  adminClient: SupabaseClient,
  userId: string,
  documentType: "identity_document" | "tesserino_document",
): Promise<string | null> {
  const listResult = await adminClient.storage.from("seller_documents").list(
    userId,
    { limit: 100, sortBy: { column: "name", order: "desc" } },
  );
  if (listResult.error) {
    throw new AdminSellerApplicationError(
      "seller_documents_list_failed",
      500,
      "Unable to list seller documents.",
      listResult.error,
    );
  }

  const prefix = `${documentType}_`;
  const entry = listResult.data.find((item: { name?: string }) =>
    typeof item.name === "string" && item.name.startsWith(prefix)
  );
  return entry?.name ? `${userId}/${entry.name}` : null;
}

export async function resolveSellerDocumentPaths(
  adminClient: SupabaseClient,
  userId: string,
): Promise<string[]> {
  const listResult = await adminClient.storage.from("seller_documents").list(
    userId,
    { limit: 100 },
  );
  if (listResult.error) {
    throw new AdminSellerApplicationError(
      "seller_documents_list_failed",
      500,
      "Unable to list seller documents.",
      listResult.error,
    );
  }
  return listResult.data
    .filter((item: { name?: string }) => typeof item.name === "string")
    .map((item: { name: string }) => `${userId}/${item.name}`);
}

export async function deleteSellerDocuments(
  adminClient: SupabaseClient,
  userId: string,
): Promise<number> {
  const paths = await resolveSellerDocumentPaths(adminClient, userId);
  if (paths.length === 0) return 0;

  const removeResult = await adminClient.storage.from("seller_documents")
    .remove(paths);
  if (removeResult.error) {
    throw new AdminSellerApplicationError(
      "seller_documents_delete_failed",
      500,
      "Unable to delete seller documents.",
      removeResult.error,
    );
  }

  const purgeResult = await adminClient.rpc("mark_seller_documents_purged", {
    p_user_id: userId,
  });
  if (purgeResult.error) {
    throw new AdminSellerApplicationError(
      "seller_documents_purge_mark_failed",
      500,
      "Unable to mark seller documents purged.",
      purgeResult.error,
    );
  }

  return paths.length;
}

export async function createSellerReviewNotification(args: {
  adminClient: SupabaseClient;
  userId: string;
  approved: boolean;
  reason?: string | null;
  requestId: string;
}): Promise<void> {
  const reason = normalizeOptionalString(args.reason);
  await createBusinessNotificationAndPush({
    adminClient: args.adminClient,
    userId: args.userId,
    type: args.approved ? "seller_approved" : "seller_rejected",
    message: args.approved
      ? "You have been approved as a seller. Complete Stripe to start publishing truffles."
      : reason == null
      ? "Your seller request was not approved. Check the details or contact support."
      : `Your seller request was not approved. Reason: ${reason}`,
    metadata: reason == null ? undefined : { reason },
    requestId: args.requestId,
  });
}

export async function insertAuditLog(
  adminClient: SupabaseClient,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string;
    metadata: Record<string, unknown>;
    requestId: string;
  },
): Promise<void> {
  const result = await adminClient.from("audit_logs").insert({
    entity_type: args.entityType,
    entity_id: args.entityId,
    action: args.action,
    performed_by: args.performedBy,
    metadata: { ...args.metadata, request_id: args.requestId },
  });
  if (result.error) {
    console.error("admin seller audit insert failed", {
      request_id: args.requestId,
      code: readErrorCode(result.error),
      message: readErrorMessage(result.error),
    });
  }
}

export function getRequestId(request: Request): string {
  const value = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  return normalizeOptionalString(value) ?? crypto.randomUUID();
}

export function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
  requestId?: string,
): Response {
  return new Response(
    JSON.stringify(requestId ? { ...body, request_id: requestId } : body),
    {
      status,
      headers: { ...adminCorsHeaders, "Content-Type": "application/json" },
    },
  );
}

export function toErrorResponse(error: unknown, requestId: string): Response {
  if (error instanceof AdminSellerApplicationError) {
    return jsonResponse({ error: error.appCode }, error.status, requestId);
  }

  console.error("admin seller application unexpected failure", {
    request_id: requestId,
    code: readErrorCode(error),
    message: readErrorMessage(error),
  });
  return jsonResponse(
    { error: "admin_seller_application_failed" },
    500,
    requestId,
  );
}

export function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

function readErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string") return value;
  }
  return "";
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") return value;
  }
  return "";
}
