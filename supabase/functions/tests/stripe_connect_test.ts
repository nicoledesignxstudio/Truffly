import {
  handleCreateSellerStripeAccountLink,
  handleRefreshSellerStripeStatus,
  isSellerStripeReady,
  mapStripeAccountToSellerStripeStatus,
  type SellerStripeStatusSnapshot,
} from "../_shared/stripe_connect.ts";

Deno.test("seller onboarding blocks non approved sellers", async () => {
  const response = await handleCreateSellerStripeAccountLink({
    request: new Request(
      "http://localhost/create_seller_stripe_account_or_link",
      {
        method: "POST",
      },
    ),
    requestId: "req-seller-not-approved",
    authenticatedUserId: "seller-1",
    authenticatedUserEmail: "seller@example.com",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => ({
        ...approvedSeller(),
        sellerStatus: "pending",
      }),
    }),
    stripeGateway: createNoopStripeConnectGateway(),
  });

  assertEquals(response.status, 403);
  assertMatch(await response.json(), { error: "seller_not_approved" });
});

Deno.test("seller onboarding blocks inactive sellers", async () => {
  const response = await handleCreateSellerStripeAccountLink({
    request: new Request(
      "http://localhost/create_seller_stripe_account_or_link",
      {
        method: "POST",
      },
    ),
    requestId: "req-seller-inactive",
    authenticatedUserId: "seller-1",
    authenticatedUserEmail: "seller@example.com",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => ({
        ...approvedSeller(),
        isActive: false,
      }),
    }),
    stripeGateway: createNoopStripeConnectGateway(),
  });

  assertEquals(response.status, 403);
  assertMatch(await response.json(), { error: "inactive_account" });
});

Deno.test("seller onboarding creates connected account when missing", async () => {
  let createdAccountId: string | null = null;
  let savedAccountId: string | null = null;
  let receivedFirstName: string | null = null;
  let receivedLastName: string | null = null;
  let receivedEmail: string | null = null;

  const response = await handleCreateSellerStripeAccountLink({
    request: new Request(
      "http://localhost/create_seller_stripe_account_or_link",
      {
        method: "POST",
      },
    ),
    requestId: "req-create-account",
    authenticatedUserId: "seller-1",
    authenticatedUserEmail: "seller@example.com",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => approvedSeller(),
      saveSellerStripeAccountId: async (
        _userId: string,
        accountId: string,
      ) => {
        savedAccountId = accountId;
      },
    }),
    stripeGateway: createNoopStripeConnectGateway({
      createExpressAccount: async (args: {
        email: string | null;
        firstName: string | null;
        lastName: string | null;
      }) => {
        createdAccountId = "acct_created";
        receivedEmail = args.email;
        receivedFirstName = args.firstName;
        receivedLastName = args.lastName;
        return {
          id: "acct_created",
          detailsSubmitted: false,
          chargesEnabled: false,
          payoutsEnabled: false,
          requirements: { currently_due: ["business_profile.url"] },
        };
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createdAccountId, "acct_created");
  assertEquals(savedAccountId, "acct_created");
  assertEquals(receivedEmail, "seller@example.com");
  assertEquals(receivedFirstName, "Seller");
  assertEquals(receivedLastName, "Example");
  assertMatch(await response.json(), {
    stripe_account_id: "acct_created",
  });
});

Deno.test("seller onboarding reuses existing account", async () => {
  let createAccountCalled = false;
  let createdAccountLinkFor: string | null = null;

  const response = await handleCreateSellerStripeAccountLink({
    request: new Request(
      "http://localhost/create_seller_stripe_account_or_link",
      {
        method: "POST",
      },
    ),
    requestId: "req-reuse-account",
    authenticatedUserId: "seller-1",
    authenticatedUserEmail: "seller@example.com",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => ({
        ...approvedSeller(),
        stripeAccountId: "acct_existing",
      }),
    }),
    stripeGateway: createNoopStripeConnectGateway({
      createExpressAccount: async () => {
        createAccountCalled = true;
        return {
          id: "acct_unexpected",
          detailsSubmitted: false,
          chargesEnabled: false,
          payoutsEnabled: false,
          requirements: null,
        };
      },
      createAccountLink: async (args: { accountId: string }) => {
        createdAccountLinkFor = args.accountId;
        return {
          url: "https://connect.stripe.test/onboarding/acct_existing",
          expiresAt: null,
        };
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createAccountCalled, false);
  assertEquals(createdAccountLinkFor, "acct_existing");
  assertMatch(await response.json(), {
    onboarding_url: "https://connect.stripe.test/onboarding/acct_existing",
    stripe_account_id: "acct_existing",
  });
});

Deno.test("seller onboarding uses configured return and refresh URLs", async () => {
  let receivedReturnUrl: string | null = null;
  let receivedRefreshUrl: string | null = null;

  const response = await handleCreateSellerStripeAccountLink({
    request: new Request(
      "http://localhost/create_seller_stripe_account_or_link",
      {
        method: "POST",
      },
    ),
    requestId: "req-configured-urls",
    authenticatedUserId: "seller-1",
    authenticatedUserEmail: "seller@example.com",
    accountLinkReturnUrl: "https://example.com/truffly/stripe-connect-return",
    accountLinkRefreshUrl: "https://example.com/truffly/stripe-connect-refresh",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => approvedSeller(),
    }),
    stripeGateway: createNoopStripeConnectGateway({
      createAccountLink: async (args: {
        accountId: string;
        returnUrl: string;
        refreshUrl: string;
      }) => {
        receivedReturnUrl = args.returnUrl;
        receivedRefreshUrl = args.refreshUrl;
        return {
          url: "https://connect.stripe.test/onboarding/acct_default",
          expiresAt: null,
        };
      },
    }),
  });

  const body = await response.json();

  assertEquals(response.status, 200);
  assertEquals(
    receivedReturnUrl,
    "https://example.com/truffly/stripe-connect-return",
  );
  assertEquals(
    receivedRefreshUrl,
    "https://example.com/truffly/stripe-connect-refresh",
  );
  assertEquals("return_url" in body, false);
  assertEquals("refresh_url" in body, false);
});

Deno.test("refresh seller status updates readiness to ready", async () => {
  let persistedReadiness: SellerStripeStatusSnapshot["readiness"] | null = null;

  const response = await handleRefreshSellerStripeStatus({
    request: new Request("http://localhost/refresh_seller_stripe_status", {
      method: "POST",
    }),
    requestId: "req-refresh-ready",
    authenticatedUserId: "seller-1",
    store: createNoopSellerStripeStore({
      getSellerStripeUser: async () => ({
        ...approvedSeller(),
        stripeAccountId: "acct_ready",
      }),
      updateSellerStripeStatus: async (
        _userId: string,
        status: SellerStripeStatusSnapshot,
      ) => {
        persistedReadiness = status.readiness;
      },
    }),
    stripeGateway: createNoopStripeConnectGateway({
      retrieveAccount: async () => ({
        id: "acct_ready",
        detailsSubmitted: true,
        chargesEnabled: false,
        payoutsEnabled: true,
        requirements: {
          currently_due: [],
          past_due: [],
          pending_verification: [],
          disabled_reason: null,
        },
      }),
    }),
    now: () => new Date("2026-03-29T10:00:00.000Z"),
  });

  assertEquals(response.status, 200);
  assertMatch(await response.json(), {
    readiness: "ready",
    stripe_account_id: "acct_ready",
    charges_enabled: false,
    payouts_enabled: true,
    requirements_pending: false,
  });
  assertEquals(persistedReadiness, "ready");
});

Deno.test("publish gate helper blocks not ready sellers", () => {
  assertEquals(
    isSellerStripeReady({
      accountId: "acct_test",
      detailsSubmitted: true,
      chargesEnabled: false,
      payoutsEnabled: false,
      requirementsPending: false,
      readyAt: null,
    }),
    false,
  );
});

Deno.test("publish gate helper allows ready sellers", () => {
  assertEquals(
    isSellerStripeReady({
      accountId: "acct_test",
      detailsSubmitted: true,
      chargesEnabled: false,
      payoutsEnabled: true,
      requirementsPending: false,
      readyAt: "2026-03-29T10:00:00.000Z",
    }),
    true,
  );
});

Deno.test("status mapper derives verification pending after details submitted", () => {
  const status = mapStripeAccountToSellerStripeStatus({
    account: {
      id: "acct_verifying",
      detailsSubmitted: true,
      chargesEnabled: false,
      payoutsEnabled: false,
      requirements: {
        currently_due: [],
        past_due: [],
        pending_verification: ["representative.verification.document"],
        disabled_reason: null,
      },
    },
    existingUser: {
      stripeOnboardingCompletedAt: null,
      stripeReadyAt: null,
    },
    now: new Date("2026-03-29T10:00:00.000Z"),
  });

  assertEquals(status.readiness, "verification_pending");
  assertEquals(status.onboardingCompletedAt, "2026-03-29T10:00:00.000Z");
  assertEquals(status.readyAt, null);
});

function approvedSeller() {
  return {
    id: "seller-1",
    role: "seller",
    sellerStatus: "approved",
    isActive: true,
    firstName: "Seller",
    lastName: "Example",
    stripeAccountId: null,
    stripeDetailsSubmitted: false,
    stripeChargesEnabled: false,
    stripePayoutsEnabled: false,
    stripeRequirementsPending: true,
    stripeOnboardingCompletedAt: null,
    stripeReadyAt: null,
    countryCode: "IT",
  };
}

function createNoopSellerStripeStore(overrides: Record<string, unknown> = {}) {
  return {
    getSellerStripeUser: async () => null,
    updateSellerStripeStatus: async () => undefined,
    saveSellerStripeAccountId: async () => undefined,
    insertAuditLog: async () => undefined,
    ...overrides,
  } as any;
}

function createNoopStripeConnectGateway(
  overrides: Record<string, unknown> = {},
) {
  return {
    createExpressAccount: async () => ({
      id: "acct_default",
      detailsSubmitted: false,
      chargesEnabled: false,
      payoutsEnabled: false,
      requirements: { currently_due: ["business_profile.url"] },
    }),
    createAccountLink: async () => ({
      url: "https://connect.stripe.test/onboarding/acct_default",
      expiresAt: null,
    }),
    retrieveAccount: async () => ({
      id: "acct_default",
      detailsSubmitted: false,
      chargesEnabled: false,
      payoutsEnabled: false,
      requirements: { currently_due: ["business_profile.url"] },
    }),
    ...overrides,
  } as any;
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (actual !== expected) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function assertMatch(
  actual: Record<string, unknown>,
  expected: Record<string, unknown>,
): void {
  for (const [key, value] of Object.entries(expected)) {
    if (actual[key] !== value) {
      throw new Error(
        `Expected property ${key}=${JSON.stringify(value)}, received ${
          JSON.stringify(actual[key])
        }`,
      );
    }
  }
}
