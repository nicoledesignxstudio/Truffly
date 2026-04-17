import { createClient, type SupabaseClient } from "@supabase/supabase-js";

export type SellerStripeReadiness =
  | "not_connected"
  | "onboarding_in_progress"
  | "verification_pending"
  | "ready";

export type SellerStripeUser = {
  id: string;
  role: string;
  sellerStatus: string;
  isActive: boolean;
  firstName: string | null;
  lastName: string | null;
  stripeAccountId: string | null;
  stripeDetailsSubmitted: boolean;
  stripeChargesEnabled: boolean;
  stripePayoutsEnabled: boolean;
  stripeRequirementsPending: boolean;
  stripeOnboardingCompletedAt: string | null;
  stripeReadyAt: string | null;
  countryCode: string | null;
};

export type SellerStripeStatusSnapshot = {
  accountId: string | null;
  readiness: SellerStripeReadiness;
  detailsSubmitted: boolean;
  chargesEnabled: boolean;
  payoutsEnabled: boolean;
  requirementsPending: boolean;
  onboardingCompletedAt: string | null;
  readyAt: string | null;
};

type StripeAccountRequirements = {
  disabled_reason?: string | null;
  currently_due?: unknown;
  past_due?: unknown;
  pending_verification?: unknown;
};

export type StripeConnectAccount = {
  id: string;
  detailsSubmitted: boolean;
  chargesEnabled: boolean;
  payoutsEnabled: boolean;
  requirements: StripeAccountRequirements | null;
};

export type StripeAccountLink = {
  url: string;
  expiresAt: number | null;
};

export type SellerStripeStore = {
  getSellerStripeUser(userId: string): Promise<SellerStripeUser | null>;
  updateSellerStripeStatus(
    userId: string,
    status: SellerStripeStatusSnapshot,
  ): Promise<void>;
  saveSellerStripeAccountId(
    userId: string,
    accountId: string,
  ): Promise<void>;
  insertAuditLog(args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string;
    metadata: Record<string, unknown>;
  }): Promise<void>;
};

export type StripeConnectGateway = {
  createExpressAccount(args: {
    email: string | null;
    country: string;
    firstName: string | null;
    lastName: string | null;
    metadata: Record<string, string>;
  }): Promise<StripeConnectAccount>;
  createAccountLink(args: {
    accountId: string;
    refreshUrl: string;
    returnUrl: string;
  }): Promise<StripeAccountLink>;
  retrieveAccount(accountId: string): Promise<StripeConnectAccount>;
};

type SellerStripeErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "seller_not_allowed"
  | "seller_not_approved"
  | "seller_stripe_account_missing"
  | "seller_stripe_runtime_error"
  | "seller_stripe_account_error"
  | "seller_stripe_link_error"
  | "seller_stripe_unknown_error";

class SellerStripeError extends Error {
  constructor(
    readonly code: SellerStripeErrorCode,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "SellerStripeError";
  }
}

type CreateSellerStripeAccountLinkDeps = {
  request: Request;
  requestId: string;
  authenticatedUserId: string | null;
  authenticatedUserEmail: string | null;
  store: SellerStripeStore;
  stripeGateway: StripeConnectGateway;
  accountLinkReturnUrl?: string | null;
  accountLinkRefreshUrl?: string | null;
  now?: () => Date;
};

type RefreshSellerStripeStatusDeps = {
  request: Request;
  requestId: string;
  authenticatedUserId: string | null;
  store: SellerStripeStore;
  stripeGateway: StripeConnectGateway;
  now?: () => Date;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-request-id, x-correlation-id",
};

const defaultStripeConnectReturnUrl =
  "https://example.com/truffly/stripe-connect-return";
const defaultStripeConnectRefreshUrl =
  "https://example.com/truffly/stripe-connect-refresh";

export async function handleCreateSellerStripeAccountLink(
  deps: CreateSellerStripeAccountLinkDeps,
): Promise<Response> {
  if (deps.request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (deps.request.method !== "POST") {
    return createSellerStripeErrorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      deps.requestId,
    );
  }

  try {
    const user = await loadSellerStripeUserOrThrow({
      store: deps.store,
      authenticatedUserId: deps.authenticatedUserId,
    });
    const accountLinkReturnUrl = normalizeAbsoluteUrl(
      deps.accountLinkReturnUrl,
    ) ?? defaultStripeConnectReturnUrl;
    const accountLinkRefreshUrl = normalizeAbsoluteUrl(
      deps.accountLinkRefreshUrl,
    ) ?? defaultStripeConnectRefreshUrl;

    let accountId = normalizeOptionalString(user.stripeAccountId);
    if (accountId == null) {
      const createdAccount = await deps.stripeGateway.createExpressAccount({
        email: normalizeOptionalString(deps.authenticatedUserEmail),
        country: normalizeCountryCode(user.countryCode),
        firstName: normalizeOptionalString(user.firstName),
        lastName: normalizeOptionalString(user.lastName),
        metadata: {
          user_id: user.id,
        },
      });

      accountId = createdAccount.id;
      const createdStatus = mapStripeAccountToSellerStripeStatus({
        account: createdAccount,
        existingUser: user,
        now: (deps.now ?? (() => new Date()))(),
      });

      await deps.store.saveSellerStripeAccountId(user.id, createdAccount.id);
      await deps.store.updateSellerStripeStatus(user.id, createdStatus);
      await insertAuditLogSafe(deps.store, {
        entityType: "user",
        entityId: user.id,
        action: "stripe_account_created",
        performedBy: user.id,
        metadata: {
          request_id: deps.requestId,
          result: "succeeded",
          stripe_account_id: createdAccount.id,
        },
      });
    }

    const accountLink = await deps.stripeGateway.createAccountLink({
      accountId,
      refreshUrl: accountLinkRefreshUrl,
      returnUrl: accountLinkReturnUrl,
    });

    await insertAuditLogSafe(deps.store, {
      entityType: "user",
      entityId: user.id,
      action: "seller_onboarding_link_issued",
      performedBy: user.id,
      metadata: {
        request_id: deps.requestId,
        result: "succeeded",
        stripe_account_id: accountId,
      },
    });

    return createSellerStripeJsonResponse({
      success: true,
      onboarding_url: accountLink.url,
      stripe_account_id: accountId,
      request_id: deps.requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeSellerStripeError(error);
    return createSellerStripeErrorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      deps.requestId,
    );
  }
}

export async function handleRefreshSellerStripeStatus(
  deps: RefreshSellerStripeStatusDeps,
): Promise<Response> {
  if (deps.request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (deps.request.method !== "POST") {
    return createSellerStripeErrorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      deps.requestId,
    );
  }

  try {
    const user = await loadSellerStripeUserOrThrow({
      store: deps.store,
      authenticatedUserId: deps.authenticatedUserId,
    });

    const accountId = normalizeOptionalString(user.stripeAccountId);
    if (accountId == null) {
      const notConnectedStatus: SellerStripeStatusSnapshot = {
        accountId: null,
        readiness: "not_connected",
        detailsSubmitted: false,
        chargesEnabled: false,
        payoutsEnabled: false,
        requirementsPending: true,
        onboardingCompletedAt: null,
        readyAt: null,
      };

      await deps.store.updateSellerStripeStatus(user.id, notConnectedStatus);
      await insertAuditLogSafe(deps.store, {
        entityType: "user",
        entityId: user.id,
        action: "seller_onboarding_status_refreshed",
        performedBy: user.id,
        metadata: {
          request_id: deps.requestId,
          result: "succeeded",
          readiness: notConnectedStatus.readiness,
        },
      });

      return createSellerStripeJsonResponse({
        success: true,
        readiness: notConnectedStatus.readiness,
        stripe_account_id: null,
        details_submitted: false,
        charges_enabled: false,
        payouts_enabled: false,
        requirements_pending: true,
        onboarding_completed_at: null,
        ready_at: null,
        request_id: deps.requestId,
      }, 200);
    }

    const account = await deps.stripeGateway.retrieveAccount(accountId);
    const status = mapStripeAccountToSellerStripeStatus({
      account,
      existingUser: user,
      now: (deps.now ?? (() => new Date()))(),
    });

    await deps.store.updateSellerStripeStatus(user.id, status);
    await insertAuditLogSafe(deps.store, {
      entityType: "user",
      entityId: user.id,
      action: "seller_onboarding_status_refreshed",
      performedBy: user.id,
      metadata: {
        request_id: deps.requestId,
        result: "succeeded",
        readiness: status.readiness,
        stripe_account_id: account.id,
      },
    });
    await insertAuditLogSafe(deps.store, {
      entityType: "user",
      entityId: user.id,
      action: status.readiness === "ready"
        ? "seller_stripe_ready"
        : "seller_stripe_not_ready",
      performedBy: user.id,
      metadata: {
        request_id: deps.requestId,
        result: "succeeded",
        readiness: status.readiness,
        stripe_account_id: account.id,
      },
    });

    return createSellerStripeJsonResponse({
      success: true,
      readiness: status.readiness,
      stripe_account_id: status.accountId,
      details_submitted: status.detailsSubmitted,
      charges_enabled: status.chargesEnabled,
      payouts_enabled: status.payoutsEnabled,
      requirements_pending: status.requirementsPending,
      onboarding_completed_at: status.onboardingCompletedAt,
      ready_at: status.readyAt,
      request_id: deps.requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeSellerStripeError(error);
    return createSellerStripeErrorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      deps.requestId,
    );
  }
}

export function mapStripeAccountToSellerStripeStatus(args: {
  account: StripeConnectAccount;
  existingUser: Pick<
    SellerStripeUser,
    "stripeOnboardingCompletedAt" | "stripeReadyAt"
  >;
  now: Date;
}): SellerStripeStatusSnapshot {
  const detailsSubmitted = args.account.detailsSubmitted === true;
  const chargesEnabled = args.account.chargesEnabled === true;
  const payoutsEnabled = args.account.payoutsEnabled === true;
  const requirementsPending = hasPendingStripeRequirements(
    args.account.requirements,
  );

  const readiness = !detailsSubmitted
    ? "onboarding_in_progress"
    : payoutsEnabled && !requirementsPending
    ? "ready"
    : "verification_pending";

  return {
    accountId: args.account.id,
    readiness,
    detailsSubmitted,
    chargesEnabled,
    payoutsEnabled,
    requirementsPending,
    onboardingCompletedAt: detailsSubmitted
      ? args.existingUser.stripeOnboardingCompletedAt ??
        args.now.toISOString()
      : null,
    readyAt: readiness === "ready" ? args.now.toISOString() : null,
  };
}

export function isSellerStripeReady(
  status: Pick<
    SellerStripeStatusSnapshot,
    | "accountId"
    | "detailsSubmitted"
    | "chargesEnabled"
    | "payoutsEnabled"
    | "requirementsPending"
    | "readyAt"
  >,
): boolean {
  return normalizeOptionalString(status.accountId) != null &&
    status.detailsSubmitted === true &&
    status.payoutsEnabled === true &&
    status.requirementsPending === false &&
    normalizeOptionalString(status.readyAt) != null;
}

export async function refreshSellerStripeStatusForPublish(args: {
  user: SellerStripeUser;
  requestId: string;
  now: Date;
  store: SellerStripeStore;
  stripeGateway: StripeConnectGateway;
}): Promise<SellerStripeStatusSnapshot> {
  const accountId = normalizeOptionalString(args.user.stripeAccountId);
  if (accountId == null) {
    return {
      accountId: null,
      readiness: "not_connected",
      detailsSubmitted: false,
      chargesEnabled: false,
      payoutsEnabled: false,
      requirementsPending: true,
      onboardingCompletedAt: null,
      readyAt: null,
    };
  }

  const account = await args.stripeGateway.retrieveAccount(accountId);
  const status = mapStripeAccountToSellerStripeStatus({
    account,
    existingUser: args.user,
    now: args.now,
  });
  await args.store.updateSellerStripeStatus(args.user.id, status);
  return status;
}

export function createStripeConnectGateway(
  fetchImpl: typeof fetch,
  stripeSecretKey: string,
): StripeConnectGateway {
  return {
    async createExpressAccount(args) {
      const response = await fetchStripeConnect(
        fetchImpl,
        stripeSecretKey,
        "https://api.stripe.com/v1/accounts",
        {
          method: "POST",
          body: new URLSearchParams({
            type: "express",
            country: args.country,
            ...(args.email == null ? {} : { email: args.email }),
            "capabilities[transfers][requested]": "true",
            business_type: "individual",
            ...(args.firstName == null
              ? {}
              : { "individual[first_name]": args.firstName }),
            ...(args.lastName == null
              ? {}
              : { "individual[last_name]": args.lastName }),
            ...(args.email == null ? {} : { "individual[email]": args.email }),
            "business_profile[product_description]":
              "Fresh truffles sold by an approved seller through the Truffly marketplace.",
            ...flattenStripeMetadata(args.metadata),
          }),
        },
      );
      return parseStripeConnectAccount(response);
    },
    async createAccountLink(args) {
      const response = await fetchStripeConnect(
        fetchImpl,
        stripeSecretKey,
        "https://api.stripe.com/v1/account_links",
        {
          method: "POST",
          body: new URLSearchParams({
            account: args.accountId,
            refresh_url: args.refreshUrl,
            return_url: args.returnUrl,
            type: "account_onboarding",
          }),
        },
      );

      return {
        url: readRequiredStripeString(response, "url"),
        expiresAt: readOptionalStripeNumber(response, "expires_at"),
      };
    },
    async retrieveAccount(accountId) {
      const response = await fetchStripeConnect(
        fetchImpl,
        stripeSecretKey,
        `https://api.stripe.com/v1/accounts/${encodeURIComponent(accountId)}`,
        {
          method: "GET",
        },
      );
      return parseStripeConnectAccount(response);
    },
  };
}

export function createSupabaseSellerStripeStore(
  adminClient: SupabaseClient,
): SellerStripeStore {
  return {
    async getSellerStripeUser(userId) {
      const result = await adminClient
        .from("users")
        .select(
          "id, role, seller_status, is_active, first_name, last_name, stripe_account_id, stripe_details_submitted, stripe_charges_enabled, stripe_payouts_enabled, stripe_requirements_pending, stripe_onboarding_completed_at, stripe_ready_at, country_code",
        )
        .eq("id", userId)
        .maybeSingle();

      if (result.error) {
        throw new SellerStripeError(
          "seller_stripe_unknown_error",
          500,
          "Failed to load the seller profile.",
          result.error,
        );
      }

      if (result.data == null) {
        return null;
      }

      return mapSellerStripeUserRow(result.data);
    },
    async updateSellerStripeStatus(userId, status) {
      const result = await adminClient
        .from("users")
        .update({
          stripe_account_id: status.accountId,
          stripe_details_submitted: status.detailsSubmitted,
          stripe_charges_enabled: status.chargesEnabled,
          stripe_payouts_enabled: status.payoutsEnabled,
          stripe_requirements_pending: status.requirementsPending,
          stripe_onboarding_completed_at: status.onboardingCompletedAt,
          stripe_ready_at: status.readyAt,
        })
        .eq("id", userId);

      if (result.error) {
        throw new SellerStripeError(
          "seller_stripe_unknown_error",
          500,
          "Failed to persist the seller Stripe status.",
          result.error,
        );
      }
    },
    async saveSellerStripeAccountId(userId, accountId) {
      const result = await adminClient
        .from("users")
        .update({
          stripe_account_id: accountId,
        })
        .eq("id", userId);

      if (result.error) {
        throw new SellerStripeError(
          "seller_stripe_unknown_error",
          500,
          "Failed to persist the seller Stripe account id.",
          result.error,
        );
      }
    },
    async insertAuditLog(args) {
      const result = await adminClient.from("audit_logs").insert({
        entity_type: args.entityType,
        entity_id: args.entityId,
        action: args.action,
        performed_by: args.performedBy,
        metadata: args.metadata,
      });

      if (result.error) {
        throw result.error;
      }
    },
  };
}

export function getStripeConnectReturnUrl(): string {
  return defaultStripeConnectReturnUrl;
}

export function getStripeConnectRefreshUrl(): string {
  return defaultStripeConnectRefreshUrl;
}

export async function resolveAuthenticatedUser(args: {
  supabaseUrl: string;
  supabaseAnonKey: string;
  authHeader: string | null;
}): Promise<{ id: string | null; email: string | null }> {
  if (args.authHeader == null) {
    return { id: null, email: null };
  }

  const authClient = createClient(args.supabaseUrl, args.supabaseAnonKey, {
    global: {
      headers: { Authorization: args.authHeader },
    },
  });

  const {
    data: { user },
  } = await authClient.auth.getUser();

  return {
    id: user?.id ?? null,
    email: normalizeOptionalString(user?.email ?? null),
  };
}

async function loadSellerStripeUserOrThrow(args: {
  store: SellerStripeStore;
  authenticatedUserId: string | null;
}): Promise<SellerStripeUser> {
  if (args.authenticatedUserId == null) {
    throw new SellerStripeError(
      "unauthorized",
      401,
      "Authentication is required.",
    );
  }

  const user = await args.store.getSellerStripeUser(args.authenticatedUserId);
  if (user == null) {
    throw new SellerStripeError(
      "user_not_found",
      404,
      "Authenticated user profile was not found.",
    );
  }

  if (!user.isActive) {
    throw new SellerStripeError(
      "inactive_account",
      403,
      "The authenticated account is inactive.",
    );
  }

  if (user.role !== "seller") {
    throw new SellerStripeError(
      "seller_not_allowed",
      403,
      "Only sellers can access this Stripe onboarding flow.",
    );
  }

  if (user.sellerStatus !== "approved") {
    throw new SellerStripeError(
      "seller_not_approved",
      403,
      "Seller approval is required before Stripe onboarding can start.",
    );
  }

  return user;
}

async function insertAuditLogSafe(
  store: SellerStripeStore,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string;
    metadata: Record<string, unknown>;
  },
): Promise<void> {
  try {
    await store.insertAuditLog(args);
  } catch (error) {
    console.error("seller_stripe audit insert failed", {
      action: args.action,
      entity_id: args.entityId,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

function mapSellerStripeUserRow(
  row: Record<string, unknown>,
): SellerStripeUser {
  return {
    id: readRequiredString(row, "id"),
    role: normalizeOptionalString(row.role)?.toLowerCase() ?? "",
    sellerStatus: normalizeOptionalString(row.seller_status)?.toLowerCase() ??
      "",
    isActive: row.is_active === true,
    firstName: normalizeOptionalString(row.first_name),
    lastName: normalizeOptionalString(row.last_name),
    stripeAccountId: normalizeOptionalString(row.stripe_account_id),
    stripeDetailsSubmitted: row.stripe_details_submitted === true,
    stripeChargesEnabled: row.stripe_charges_enabled === true,
    stripePayoutsEnabled: row.stripe_payouts_enabled === true,
    stripeRequirementsPending: row.stripe_requirements_pending !== false,
    stripeOnboardingCompletedAt: normalizeOptionalString(
      row.stripe_onboarding_completed_at,
    ),
    stripeReadyAt: normalizeOptionalString(row.stripe_ready_at),
    countryCode: normalizeOptionalString(row.country_code)?.toUpperCase() ??
      null,
  };
}

function parseStripeConnectAccount(
  response: Record<string, unknown>,
): StripeConnectAccount {
  return {
    id: readRequiredStripeString(response, "id"),
    detailsSubmitted: response.details_submitted === true,
    chargesEnabled: response.charges_enabled === true,
    payoutsEnabled: response.payouts_enabled === true,
    requirements: typeof response.requirements === "object" &&
        response.requirements !== null
      ? response.requirements as StripeAccountRequirements
      : null,
  };
}

function hasPendingStripeRequirements(
  requirements: StripeAccountRequirements | null,
): boolean {
  if (requirements == null) {
    return true;
  }

  if (normalizeOptionalString(requirements.disabled_reason) != null) {
    return true;
  }

  return toStringArray(requirements.currently_due).length > 0 ||
    toStringArray(requirements.past_due).length > 0 ||
    toStringArray(requirements.pending_verification).length > 0;
}

async function fetchStripeConnect(
  fetchImpl: typeof fetch,
  stripeSecretKey: string,
  url: string,
  init: RequestInit,
): Promise<Record<string, unknown>> {
  let response: Response;
  try {
    response = await fetchImpl(url, {
      ...init,
      headers: {
        Authorization: `Bearer ${stripeSecretKey}`,
        ...(init.body == null ? {} : {
          "Content-Type": "application/x-www-form-urlencoded",
        }),
      },
    });
  } catch (error) {
    const runtimeMessage = readRuntimeErrorMessage(error) ??
      "Unknown network error.";
    throw new SellerStripeError(
      "seller_stripe_runtime_error",
      502,
      `Stripe API request failed: ${runtimeMessage}`,
      error,
    );
  }

  let json: Record<string, unknown>;
  try {
    json = await response.json() as Record<string, unknown>;
  } catch (error) {
    throw new SellerStripeError(
      "seller_stripe_runtime_error",
      502,
      "Stripe API returned an invalid JSON response.",
      error,
    );
  }

  if (!response.ok) {
    const message = readStripeErrorMessage(json) ??
      "Stripe API returned an error response.";
    const code = url.includes("/account_links")
      ? "seller_stripe_link_error"
      : "seller_stripe_account_error";
    throw new SellerStripeError(code, 502, message, json);
  }

  return json;
}

function readStripeErrorMessage(
  response: Record<string, unknown>,
): string | null {
  const error = response["error"];
  if (typeof error !== "object" || error === null) {
    return null;
  }

  const message = Reflect.get(error, "message");
  return normalizeOptionalString(message);
}

function flattenStripeMetadata(
  metadata: Record<string, string>,
): Record<string, string> {
  return Object.fromEntries(
    Object.entries(metadata).map(([key, value]) => [`metadata[${key}]`, value]),
  );
}

function normalizeCountryCode(value: string | null): string {
  const normalized = normalizeOptionalString(value)?.toUpperCase();
  return normalized == null || normalized.length !== 2 ? "IT" : normalized;
}

function readRequiredString(
  row: Record<string, unknown>,
  field: string,
): string {
  const value = normalizeOptionalString(row[field]);
  if (value == null) {
    throw new SellerStripeError(
      "seller_stripe_unknown_error",
      500,
      `Missing ${field} in seller profile row.`,
    );
  }
  return value;
}

function readRequiredStripeString(
  response: Record<string, unknown>,
  field: string,
): string {
  const value = normalizeOptionalString(response[field]);
  if (value == null) {
    throw new SellerStripeError(
      "seller_stripe_runtime_error",
      502,
      `Stripe response is missing ${field}.`,
    );
  }
  return value;
}

function readOptionalStripeNumber(
  response: Record<string, unknown>,
  field: string,
): number | null {
  const value = response[field];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function createSellerStripeJsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function createSellerStripeErrorResponse(
  error: SellerStripeErrorCode,
  message: string,
  status: number,
  requestId: string,
): Response {
  return createSellerStripeJsonResponse({
    error,
    message,
    request_id: requestId,
  }, status);
}

function normalizeSellerStripeError(error: unknown): SellerStripeError {
  if (error instanceof SellerStripeError) {
    return error;
  }

  return new SellerStripeError(
    "seller_stripe_unknown_error",
    500,
    "An unexpected error occurred while processing seller Stripe onboarding.",
    error,
  );
}

function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function readRuntimeErrorMessage(error: unknown): string | null {
  if (error instanceof Error) {
    const directMessage = normalizeOptionalString(error.message);
    if (directMessage != null) {
      return directMessage;
    }
  }

  if (typeof error === "object" && error !== null) {
    const nestedMessage = normalizeOptionalString(Reflect.get(error, "message"));
    if (nestedMessage != null) {
      return nestedMessage;
    }
  }

  return null;
}

function normalizeAbsoluteUrl(value: unknown): string | null {
  const normalized = normalizeOptionalString(value);
  if (normalized == null) {
    return null;
  }

  try {
    const parsed = new URL(normalized);
    if (parsed.protocol !== "https:" && parsed.protocol !== "http:") {
      return null;
    }
    return parsed.toString();
  } catch {
    return null;
  }
}

function toStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter((entry): entry is string => typeof entry === "string");
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
