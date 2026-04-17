import { createClient } from "@supabase/supabase-js";

import {
  createStripeConnectGateway,
  createSupabaseSellerStripeStore,
  handleCreateSellerStripeAccountLink,
  handleRefreshSellerStripeStatus,
} from "../_shared/stripe_connect.ts";

type UserRow = {
  id: string;
  country_code: string | null;
  region: string | null;
  stripe_account_id: string | null;
  stripe_details_submitted: boolean;
  stripe_charges_enabled: boolean;
  stripe_payouts_enabled: boolean;
  stripe_requirements_pending: boolean;
  stripe_onboarding_completed_at: string | null;
  stripe_ready_at: string | null;
  role: string;
  seller_status: string;
  is_active: boolean;
};

type ValidationSummary = {
  setup: {
    supabaseUrl: string;
    createLinkUrl: string;
    refreshStatusUrl: string;
    publishTruffleUrl: string | null;
    sellerCreateId: string;
    sellerBlockedId: string;
  };
  case1: Record<string, unknown>;
  case2: Record<string, unknown>;
  case3: Record<string, unknown>;
  case4: Record<string, unknown>;
};

const supabaseUrl = Deno.env.get("LOCAL_SUPABASE_URL") ?? "http://127.0.0.1:54321";
const supabaseAnonKey = requiredEnv("LOCAL_SUPABASE_ANON_KEY");
const supabaseServiceRoleKey = requiredEnv("LOCAL_SUPABASE_SERVICE_ROLE_KEY");
const stripeSecretKey = requiredEnv("LOCAL_STRIPE_SECRET_KEY");
const stripeConnectReturnUrl =
  Deno.env.get("LOCAL_STRIPE_CONNECT_RETURN_URL") ??
  "https://example.com/truffly/stripe-connect-return";
const stripeConnectRefreshUrl =
  Deno.env.get("LOCAL_STRIPE_CONNECT_REFRESH_URL") ??
  "https://example.com/truffly/stripe-connect-refresh";
const publishTruffleUrl = normalizeUrl(
  Deno.env.get("LOCAL_PUBLISH_TRUFFLE_URL"),
);
const readyStripeAccountIdOverride = normalizeOptionalString(
  Deno.env.get("LOCAL_READY_STRIPE_ACCOUNT_ID"),
);

const sellerCreate = {
  id: "22222222-2222-2222-2222-222222222222",
  email: "seller1@test.com",
  password: "DevPass123!",
};
const sellerBlocked = {
  id: "33333333-3333-3333-3333-333333333333",
  email: "seller2@test.com",
  password: "DevPass123!",
};

const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey, {
  auth: { persistSession: false },
});
const sellerStripeStore = createSupabaseSellerStripeStore(adminClient);
const stripeGateway = createStripeConnectGateway(fetch, stripeSecretKey);

async function main() {
  const originalCreateSeller = await fetchUser(sellerCreate.id);
  const originalBlockedSeller = await fetchUser(sellerBlocked.id);

  if (originalCreateSeller == null || originalBlockedSeller == null) {
    throw new Error("Seeded sellers required for Stripe Phase 2 validation were not found.");
  }

  await resetSellerStripeState({
    userId: sellerCreate.id,
    countryCode: originalCreateSeller.country_code ?? "IT",
    region: originalCreateSeller.region,
    stripeAccountId: null,
  });
  await resetSellerStripeState({
    userId: sellerBlocked.id,
    countryCode: "IT",
    region: originalBlockedSeller.region,
    stripeAccountId: null,
  });

  let createdTruffleId: string | null = null;

  try {
    const case1 = await validateCase1();
    const case2 = await validateCase2();
    const case3 = await validateCase3(case1.accountId as string);
    const case4Result = await validateCase4();
    createdTruffleId = case4Result.createdTruffleId;

    const summary: ValidationSummary = {
      setup: {
        supabaseUrl,
        createLinkUrl: stripeConnectReturnUrl,
        refreshStatusUrl: stripeConnectRefreshUrl,
        publishTruffleUrl,
        sellerCreateId: sellerCreate.id,
        sellerBlockedId: sellerBlocked.id,
      },
      case1,
      case2,
      case3,
      case4: case4Result.summary,
    };

    console.log(JSON.stringify(summary, null, 2));
  } finally {
    if (createdTruffleId != null) {
      await cleanupPublishedTruffle(createdTruffleId);
    }

    await restoreUserRow(originalCreateSeller);
    await restoreUserRow(originalBlockedSeller);
  }
}

async function validateCase1() {
  const response = await handleCreateSellerStripeAccountLink({
    request: new Request("http://localhost/create_seller_stripe_account_or_link", {
      method: "POST",
    }),
    requestId: "req-seller-phase2-case1",
    authenticatedUserId: sellerCreate.id,
    authenticatedUserEmail: sellerCreate.email,
    accountLinkReturnUrl: stripeConnectReturnUrl,
    accountLinkRefreshUrl: stripeConnectRefreshUrl,
    store: sellerStripeStore,
    stripeGateway,
  });

  const body = await response.json();
  if (response.status !== 200) {
    throw new Error(`Case 1 failed: ${JSON.stringify(body)}`);
  }
  const accountId = readRequiredString(body, "stripe_account_id");
  const account = await retrieveStripeAccount(accountId);
  const dbUser = await fetchUser(sellerCreate.id);

  return {
    status: response.status,
    accountId,
    onboardingUrl: readRequiredString(body, "onboarding_url"),
    stripeAccountDetailsSubmitted: account.details_submitted === true,
    stripeAccountChargesEnabled: account.charges_enabled === true,
    stripeAccountPayoutsEnabled: account.payouts_enabled === true,
    dbStripeAccountId: dbUser?.stripe_account_id ?? null,
    dbStripeReadyAt: dbUser?.stripe_ready_at ?? null,
  };
}

async function validateCase2() {
  const before = await fetchUser(sellerCreate.id);
  const response = await handleCreateSellerStripeAccountLink({
    request: new Request("http://localhost/create_seller_stripe_account_or_link", {
      method: "POST",
    }),
    requestId: "req-seller-phase2-case2",
    authenticatedUserId: sellerCreate.id,
    authenticatedUserEmail: sellerCreate.email,
    accountLinkReturnUrl: stripeConnectReturnUrl,
    accountLinkRefreshUrl: stripeConnectRefreshUrl,
    store: sellerStripeStore,
    stripeGateway,
  });

  const body = await response.json();
  const after = await fetchUser(sellerCreate.id);

  return {
    status: response.status,
    sameAccountIdReused:
      before?.stripe_account_id != null &&
      before.stripe_account_id == readRequiredString(body, "stripe_account_id"),
    accountId: readRequiredString(body, "stripe_account_id"),
    onboardingUrl: readRequiredString(body, "onboarding_url"),
    dbStripeAccountId: after?.stripe_account_id ?? null,
  };
}

async function validateCase3(accountId: string) {
  const targetAccountId = readyStripeAccountIdOverride ?? accountId;
  let completionAttempt: Record<string, unknown>;

  if (readyStripeAccountIdOverride != null) {
    await adminClient
      .from("users")
      .update({
        stripe_account_id: readyStripeAccountIdOverride,
      })
      .eq("id", sellerCreate.id);
    completionAttempt = {
      mode: "preexisting_ready_account",
      accountId: readyStripeAccountIdOverride,
    };
  } else {
    completionAttempt = await attemptExpressOnboardingCompletionForValidation(
      accountId,
      sellerCreate.email,
    );
  }

  const response = await handleRefreshSellerStripeStatus({
    request: new Request("http://localhost/refresh_seller_stripe_status", {
      method: "POST",
    }),
    requestId: "req-seller-phase2-case3",
    authenticatedUserId: sellerCreate.id,
    store: sellerStripeStore,
    stripeGateway,
  });

  const body = await response.json();
  const dbUser = await fetchUser(sellerCreate.id);
  const account = await retrieveStripeAccount(targetAccountId);

  return {
    status: response.status,
    completionAttempt,
    readiness: body.readiness ?? null,
    stripeAccountId: body.stripe_account_id ?? null,
    detailsSubmitted: body.details_submitted ?? null,
    chargesEnabled: body.charges_enabled ?? null,
    payoutsEnabled: body.payouts_enabled ?? null,
    requirementsPending: body.requirements_pending ?? null,
    stripeAccountDetailsSubmitted: account.details_submitted ?? null,
    stripeAccountChargesEnabled: account.charges_enabled ?? null,
    stripeAccountPayoutsEnabled: account.payouts_enabled ?? null,
    stripeAccountRequirementsPending: stripeRequirementsPending(account),
    dbStripeReadyAt: dbUser?.stripe_ready_at ?? null,
    dbStripeDetailsSubmitted: dbUser?.stripe_details_submitted ?? null,
    dbStripeChargesEnabled: dbUser?.stripe_charges_enabled ?? null,
    dbStripePayoutsEnabled: dbUser?.stripe_payouts_enabled ?? null,
    dbStripeRequirementsPending: dbUser?.stripe_requirements_pending ?? null,
  };
}

async function validateCase4(): Promise<{
  createdTruffleId: string | null;
  summary: Record<string, unknown>;
}> {
  if (publishTruffleUrl == null) {
    return {
      createdTruffleId: null,
      summary: {
        skipped: true,
        reason: "LOCAL_PUBLISH_TRUFFLE_URL not set",
      },
    };
  }

  const blockedToken = await signInSeller(sellerBlocked.email, sellerBlocked.password);
  const blockedResponse = await fetch(publishTruffleUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${blockedToken}`,
      "Content-Type": "application/json",
      "x-request-id": "req-seller-phase2-case4-blocked",
    },
    body: JSON.stringify({}),
  });
  const blockedBody = await parseJsonSafe(blockedResponse);

  const readyToken = await signInSeller(sellerCreate.email, sellerCreate.password);
  const publishRequestId = crypto.randomUUID();
  const stagedImagePath = await uploadValidationImage(readyToken, sellerCreate.id);
  const readyResponse = await fetch(publishTruffleUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${readyToken}`,
      "Content-Type": "application/json",
      "x-request-id": "req-seller-phase2-case4-ready",
    },
    body: JSON.stringify({
      publish_request_id: publishRequestId,
      truffle_type: "TUBER_AESTIVUM",
      quality: "FIRST",
      weight_grams: 120,
      price_total: 199.5,
      shipping_price_italy: 12,
      shipping_price_abroad: 25,
      region: "PIEMONTE",
      harvest_date: "2026-03-20",
      images: [{ staging_path: stagedImagePath }],
    }),
  });
  const readyBody = await parseJsonSafe(readyResponse);
  const createdTruffleId = typeof readyBody.truffle_id === "string"
    ? readyBody.truffle_id
    : null;
  const publishedTruffle = createdTruffleId == null
    ? null
    : await fetchSingle("truffles", "id,status,seller_id", { id: createdTruffleId });

  return {
    createdTruffleId,
    summary: {
      blockedStatus: blockedResponse.status,
      blockedError: blockedBody.error ?? null,
      readyStatus: readyResponse.status,
      readySuccess: readyBody.success ?? null,
      readyTruffleId: createdTruffleId,
      readyTruffleStatus: publishedTruffle?.status ?? null,
    },
  };
}

async function attemptExpressOnboardingCompletionForValidation(
  accountId: string,
  email: string,
): Promise<Record<string, unknown>> {
  const nowEpoch = Math.floor(Date.now() / 1000).toString();
  const params = new URLSearchParams({
    business_type: "individual",
    email,
    "business_profile[mcc]": "5499",
    "individual[first_name]": "Seller",
    "individual[last_name]": "Validation",
    "individual[email]": email,
    "individual[phone]": "+393331234567",
    "individual[dob][day]": "1",
    "individual[dob][month]": "1",
    "individual[dob][year]": "1902",
    "individual[address][line1]": "Via Roma 1",
    "individual[address][city]": "Alba",
    "individual[address][postal_code]": "12051",
    "individual[address][state]": "CN",
    "individual[address][country]": "IT",
    "external_account[object]": "bank_account",
    "external_account[country]": "IT",
    "external_account[currency]": "eur",
    "external_account[account_holder_name]": "Seller Validation",
    "external_account[account_holder_type]": "individual",
    "external_account[account_number]": "IT60X0542811101000000123456",
    "tos_acceptance[date]": nowEpoch,
    "tos_acceptance[ip]": "127.0.0.1",
  });

  try {
    await stripeApiRequest(`/v1/accounts/${accountId}`, {
      method: "POST",
      body: params,
    });
  } catch (error) {
    return {
      mode: "platform_api_completion_attempt",
      accountId,
      completed: false,
      limitation: "express_hosted_onboarding_requires_manual_completion",
      error: error instanceof Error ? error.message : String(error),
    };
  }

  let lastAccount: Record<string, unknown> | null = null;
  for (let attempt = 0; attempt < 8; attempt++) {
    lastAccount = await retrieveStripeAccount(accountId);
    const requirementsPending = stripeRequirementsPending(lastAccount);
    if (
      lastAccount.details_submitted === true &&
      lastAccount.payouts_enabled === true &&
      !requirementsPending
    ) {
      return {
        mode: "platform_api_completion_attempt",
        accountId,
        completed: true,
        limitation: null,
      };
    }

    await delay(1500);
  }

  return {
    mode: "platform_api_completion_attempt",
    accountId,
    completed: false,
    limitation: "account_not_ready_after_completion_attempt",
    lastAccount,
  };
}

async function signInSeller(email: string, password: string): Promise<string> {
  const client = createClient(supabaseUrl, supabaseAnonKey, {
    auth: { persistSession: false },
  });
  const { data, error } = await client.auth.signInWithPassword({
    email,
    password,
  });

  if (error != null || data.session?.access_token == null) {
    throw error ?? new Error(`Failed to sign in seller ${email}.`);
  }

  return data.session.access_token;
}

async function uploadValidationImage(
  accessToken: string,
  userId: string,
): Promise<string> {
  const client = createClient(supabaseUrl, supabaseAnonKey, {
    auth: { persistSession: false },
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  });

  const bytes = Uint8Array.from(atob(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5W6YQAAAAASUVORK5CYII=",
  ), (char) => char.charCodeAt(0));
  const stagingPath =
    `staging/${userId}/stripe-phase2-${crypto.randomUUID()}.png`;

  const { error } = await client.storage
    .from("truffle_images_staging")
    .upload(stagingPath, bytes, {
      contentType: "image/png",
      upsert: false,
    });

  if (error != null) {
    throw error;
  }

  return stagingPath;
}

async function resetSellerStripeState(args: {
  userId: string;
  countryCode: string;
  region: string | null;
  stripeAccountId: string | null;
}) {
  const { error } = await adminClient
    .from("users")
    .update({
      country_code: args.countryCode,
      region: args.region,
      stripe_account_id: args.stripeAccountId,
      stripe_details_submitted: false,
      stripe_charges_enabled: false,
      stripe_payouts_enabled: false,
      stripe_requirements_pending: true,
      stripe_onboarding_completed_at: null,
      stripe_ready_at: null,
    })
    .eq("id", args.userId);

  if (error != null) {
    throw error;
  }
}

async function restoreUserRow(row: UserRow) {
  const { error } = await adminClient
    .from("users")
    .update({
      country_code: row.country_code,
      region: row.region,
      stripe_account_id: row.stripe_account_id,
      stripe_details_submitted: row.stripe_details_submitted,
      stripe_charges_enabled: row.stripe_charges_enabled,
      stripe_payouts_enabled: row.stripe_payouts_enabled,
      stripe_requirements_pending: row.stripe_requirements_pending,
      stripe_onboarding_completed_at: row.stripe_onboarding_completed_at,
      stripe_ready_at: row.stripe_ready_at,
    })
    .eq("id", row.id);

  if (error != null) {
    throw error;
  }
}

async function fetchUser(userId: string): Promise<UserRow | null> {
  const { data, error } = await adminClient
    .from("users")
    .select(
      "id,country_code,region,stripe_account_id,stripe_details_submitted,stripe_charges_enabled,stripe_payouts_enabled,stripe_requirements_pending,stripe_onboarding_completed_at,stripe_ready_at,role,seller_status,is_active",
    )
    .eq("id", userId)
    .maybeSingle();

  if (error != null) {
    throw error;
  }

  return data as UserRow | null;
}

async function fetchSingle(
  table: string,
  columns: string,
  filters: Record<string, string>,
) {
  let query = adminClient.from(table).select(columns);
  for (const [column, value] of Object.entries(filters)) {
    query = query.eq(column, value);
  }

  const { data, error } = await query.limit(1).maybeSingle();
  if (error != null) {
    throw error;
  }
  return data as Record<string, unknown> | null;
}

async function cleanupPublishedTruffle(truffleId: string) {
  const images = (
    await adminClient
      .from("truffle_images")
      .select("image_url")
      .eq("truffle_id", truffleId)
  ).data?.map((row) => row.image_url as string).filter(Boolean) ?? [];

  if (images.length > 0) {
    await adminClient.storage.from("truffle_images").remove(images);
  }

  await adminClient.from("truffle_images").delete().eq("truffle_id", truffleId);
  await adminClient.from("truffles").delete().eq("id", truffleId);
  await adminClient.from("publish_truffle_requests").delete().eq("truffle_id", truffleId);
  await adminClient.from("audit_logs").delete().eq("entity_type", "truffle").eq("entity_id", truffleId);
}

async function retrieveStripeAccount(accountId: string): Promise<Record<string, unknown>> {
  return await stripeApiRequest(`/v1/accounts/${accountId}`, {
    method: "GET",
  });
}

async function stripeApiRequest(
  path: string,
  init: RequestInit,
): Promise<Record<string, unknown>> {
  const response = await fetch(`https://api.stripe.com${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${stripeSecretKey}`,
      ...(init.body == null ? {} : {
        "Content-Type": "application/x-www-form-urlencoded",
      }),
    },
  });

  const json = await response.json() as Record<string, unknown>;
  if (!response.ok) {
    throw new Error(`Stripe request failed (${response.status}): ${JSON.stringify(json)}`);
  }

  return json;
}

function stripeRequirementsPending(account: Record<string, unknown>): boolean {
  const requirements = account.requirements;
  if (typeof requirements !== "object" || requirements == null) {
    return true;
  }

  const current = Reflect.get(requirements, "currently_due");
  const past = Reflect.get(requirements, "past_due");
  const pending = Reflect.get(requirements, "pending_verification");
  const disabledReason = Reflect.get(requirements, "disabled_reason");

  return (Array.isArray(current) && current.length > 0) ||
    (Array.isArray(past) && past.length > 0) ||
    (Array.isArray(pending) && pending.length > 0) ||
    typeof disabledReason === "string";
}

async function parseJsonSafe(response: Response): Promise<Record<string, unknown>> {
  try {
    return await response.json() as Record<string, unknown>;
  } catch {
    return {};
  }
}

function readRequiredString(
  value: Record<string, unknown>,
  key: string,
): string {
  const raw = value[key];
  if (typeof raw !== "string" || raw.trim().length === 0) {
    throw new Error(`Missing required string field ${key}.`);
  }
  return raw.trim();
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (value == null || value.trim().length === 0) {
    throw new Error(`${name} is required.`);
  }
  return value.trim();
}

function normalizeUrl(value: string | undefined): string | null {
  if (value == null || value.trim().length === 0) {
    return null;
  }
  return value.trim();
}

function normalizeOptionalString(value: string | undefined): string | null {
  if (value == null || value.trim().length === 0) {
    return null;
  }
  return value.trim();
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

await main();
