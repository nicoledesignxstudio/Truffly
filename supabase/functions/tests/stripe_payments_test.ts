import {
  handleCreatePaymentIntent,
  handleFinalizePaymentAttempt,
  handleStripeWebhook,
  type PaymentStore,
  type StripeGateway,
  verifyStripeWebhookSignature,
} from "../_shared/stripe_payments.ts";

Deno.test("create payment intent rejects unauthenticated buyers", async () => {
  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: "123e4567-e89b-42d3-a456-426614174001",
        shipping_address_id: "123e4567-e89b-42d3-a456-426614174002",
      }),
    }),
    requestId: "req-1",
    authenticatedUserId: null,
    store: createNoopStore(),
    stripeGateway: createNoopStripeGateway(),
  });

  assertEquals(response.status, 401);
  assertMatch(await response.json(), { error: "unauthorized" });
});

Deno.test("create payment intent blocks self purchase", async () => {
  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "buyer-1",
      status: "active",
      priceTotal: 79,
    }),
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: "123e4567-e89b-42d3-a456-426614174001",
        shipping_address_id: "123e4567-e89b-42d3-a456-426614174002",
      }),
    }),
    requestId: "req-2",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway(),
  });

  assertEquals(response.status, 403);
  assertMatch(await response.json(), { error: "self_purchase_forbidden" });
});

Deno.test("create payment intent blocks unavailable truffles", async () => {
  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "reserved",
      priceTotal: 79,
    }),
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: "123e4567-e89b-42d3-a456-426614174001",
        shipping_address_id: "123e4567-e89b-42d3-a456-426614174002",
      }),
    }),
    requestId: "req-3",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway(),
  });

  assertEquals(response.status, 409);
  assertMatch(await response.json(), { error: "truffle_not_available" });
});

Deno.test("create payment intent creates attempt and payment intent", async () => {
  let createdStripeIntent = false;
  let attachedIntentId: string | null = null;

  const attempt = {
    id: "123e4567-e89b-42d3-a456-426614174000",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: null,
    totalPrice: 79,
    commissionAmount: 7.9,
    sellerAmount: 71.1,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date().toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
      shippingPriceItaly: 10.99,
      shippingPriceAbroad: 25,
    }),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt,
      isNew: true,
      conflict: null,
    }),
    attachStripePaymentIntent: (
      _attemptId: string,
      stripePaymentIntentId: string,
    ) => {
      attachedIntentId = stripePaymentIntentId;
      return Promise.resolve();
    },
  });

  const stripeGateway = createNoopStripeGateway({
    createPaymentIntent: ({ amountCents }) => {
      createdStripeIntent = true;
      assertEquals(amountCents, 8999);
      return Promise.resolve({
        id: "pi_test_1",
        clientSecret: "pi_test_1_secret_123",
        status: "requires_payment_method",
      });
    },
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: attempt.id,
        truffle_id: attempt.truffleId,
        shipping_address_id: attempt.shippingAddressId,
      }),
    }),
    requestId: "req-4",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway,
  });

  assertEquals(response.status, 200);
  assertEquals(createdStripeIntent, true);
  assertEquals(attachedIntentId, "pi_test_1");
  assertMatch(await response.json(), {
    payment_attempt_id: attempt.id,
    stripe_payment_intent_id: "pi_test_1",
    client_secret: "pi_test_1_secret_123",
  });
});

Deno.test("create payment intent reuses an open attempt and existing payment intent", async () => {
  let createdStripeIntent = false;
  let retrievedStripeIntent = false;

  const openAttempt = {
    id: "123e4567-e89b-42d3-a456-426614174099",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_existing_open",
    totalPrice: 89.99,
    commissionAmount: 9,
    sellerAmount: 80.99,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date().toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
      shippingPriceItaly: 10.99,
      shippingPriceAbroad: 25,
    }),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt: openAttempt,
      isNew: false,
      conflict: null,
    }),
    attachStripePaymentIntent: () => Promise.resolve(),
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: openAttempt.truffleId,
        shipping_address_id: openAttempt.shippingAddressId,
      }),
    }),
    requestId: "req-reuse-open-attempt",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway({
      createPaymentIntent: () => {
        createdStripeIntent = true;
        return Promise.resolve({
          id: "pi_should_not_be_created",
          clientSecret: "pi_should_not_be_created_secret",
          status: "requires_payment_method",
        });
      },
      retrievePaymentIntent: (paymentIntentId: string) => {
        retrievedStripeIntent = true;
        assertEquals(paymentIntentId, "pi_existing_open");
        return Promise.resolve({
          id: "pi_existing_open",
          clientSecret: "pi_existing_open_secret",
          status: "requires_payment_method",
        });
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createdStripeIntent, false);
  assertEquals(retrievedStripeIntent, true);
  assertMatch(await response.json(), {
    payment_attempt_id: openAttempt.id,
    stripe_payment_intent_id: "pi_existing_open",
    client_secret: "pi_existing_open_secret",
  });
});

Deno.test("create payment intent refreshes a legacy payment intent that is not card-only", async () => {
  let createdStripeIntent = false;
  let retrievedStripeIntent = false;
  let attachedIntentId: string | null = null;

  const openAttempt = {
    id: "123e4567-e89b-42d3-a456-426614174199",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_legacy_link",
    totalPrice: 89.99,
    commissionAmount: 9,
    sellerAmount: 80.99,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date().toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
      shippingPriceItaly: 10.99,
      shippingPriceAbroad: 25,
    }),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt: openAttempt,
      isNew: false,
      conflict: null,
    }),
    attachStripePaymentIntent: (_attemptId: string, stripePaymentIntentId: string) => {
      attachedIntentId = stripePaymentIntentId;
      return Promise.resolve();
    },
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: openAttempt.truffleId,
        shipping_address_id: openAttempt.shippingAddressId,
      }),
    }),
    requestId: "req-repair-legacy-intent",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway({
      retrievePaymentIntent: (paymentIntentId: string) => {
        retrievedStripeIntent = true;
        assertEquals(paymentIntentId, "pi_legacy_link");
        return Promise.resolve({
          id: "pi_legacy_link",
          clientSecret: "pi_legacy_link_secret",
          status: "requires_payment_method",
          paymentMethodTypes: ["card", "link"],
        });
      },
      createPaymentIntent: (args: { amountCents: number }) => {
        createdStripeIntent = true;
        assertEquals(args.amountCents, 8999);
        return Promise.resolve({
          id: "pi_card_only_repaired",
          clientSecret: "pi_card_only_repaired_secret",
          status: "requires_payment_method",
        });
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(retrievedStripeIntent, true);
  assertEquals(createdStripeIntent, true);
  assertMatch(await response.json(), {
    payment_attempt_id: openAttempt.id,
    stripe_payment_intent_id: "pi_card_only_repaired",
    client_secret: "pi_card_only_repaired_secret",
  });
  assertEquals(attachedIntentId, "pi_card_only_repaired");
});

Deno.test("finalize payment attempt creates the order immediately when Stripe succeeded", async () => {
  let createOrderCalled = false;

  const attempt = {
    id: "123e4567-e89b-42d3-a456-426614174010",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_finalized_1",
    totalPrice: 89.99,
    commissionAmount: 9,
    sellerAmount: 80.99,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date().toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getPaymentAttemptById: () => Promise.resolve(attempt),
    createOrderFromPaymentAttempt: () => {
      createOrderCalled = true;
      return Promise.resolve({
        orderId: "223e4567-e89b-42d3-a456-426614174010",
        created: true,
        paymentAttemptStatus: "succeeded" as const,
      });
    },
  });

  const response = await handleFinalizePaymentAttempt({
    request: new Request("http://localhost/finalize_payment_attempt", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: attempt.id,
        stripe_payment_intent_id: attempt.stripePaymentIntentId,
      }),
    }),
    requestId: "req-finalize-success",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway({
      retrievePaymentIntent: () => Promise.resolve({
        id: attempt.stripePaymentIntentId,
        clientSecret: "pi_finalized_1_secret",
        status: "succeeded",
        metadata: {
          payment_attempt_id: attempt.id,
        },
      }),
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createOrderCalled, true);
  assertMatch(await response.json(), {
    payment_attempt_id: attempt.id,
    stripe_payment_intent_id: attempt.stripePaymentIntentId,
    order_id: "223e4567-e89b-42d3-a456-426614174010",
    created: true,
    finalized: true,
  });
});

Deno.test("finalize payment attempt stays pending when Stripe has not succeeded yet", async () => {
  let createOrderCalled = false;

  const attempt = {
    id: "123e4567-e89b-42d3-a456-426614174011",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_finalized_2",
    totalPrice: 89.99,
    commissionAmount: 9,
    sellerAmount: 80.99,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date().toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getPaymentAttemptById: () => Promise.resolve(attempt),
    createOrderFromPaymentAttempt: () => {
      createOrderCalled = true;
      return Promise.resolve({
        orderId: "unexpected",
        created: false,
        paymentAttemptStatus: "succeeded" as const,
      });
    },
  });

  const response = await handleFinalizePaymentAttempt({
    request: new Request("http://localhost/finalize_payment_attempt", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: attempt.id,
        stripe_payment_intent_id: attempt.stripePaymentIntentId,
      }),
    }),
    requestId: "req-finalize-pending",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway({
      retrievePaymentIntent: () => Promise.resolve({
        id: attempt.stripePaymentIntentId,
        clientSecret: "pi_finalized_2_secret",
        status: "processing",
        metadata: {
          payment_attempt_id: attempt.id,
        },
      }),
    }),
  });

  assertEquals(response.status, 202);
  assertEquals(createOrderCalled, false);
  assertMatch(await response.json(), {
    payment_attempt_id: attempt.id,
    stripe_payment_intent_id: attempt.stripePaymentIntentId,
    payment_intent_status: "processing",
    finalized: false,
  });
});

Deno.test("create payment intent rejects temporally expired attempts", async () => {
  let retrieveCalled = false;
  const expiredAttempt = {
    id: "123e4567-e89b-42d3-a456-426614174000",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_existing",
    totalPrice: 79,
    commissionAmount: 7.9,
    sellerAmount: 71.1,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: "2024-03-09T15:59:59.000Z",
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
      shippingPriceItaly: 10.99,
      shippingPriceAbroad: 25,
    }),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt: expiredAttempt,
      isNew: false,
      conflict: null,
    }),
  });

  const stripeGateway = createNoopStripeGateway({
    retrievePaymentIntent: () => {
      retrieveCalled = true;
      return Promise.resolve({
        id: "pi_existing",
        clientSecret: "pi_existing_secret",
        status: "requires_payment_method",
      });
    },
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: expiredAttempt.id,
        truffle_id: expiredAttempt.truffleId,
        shipping_address_id: expiredAttempt.shippingAddressId,
      }),
    }),
    requestId: "req-expired-attempt",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway,
    now: () => new Date("2024-03-09T16:00:00.000Z"),
  });

  assertEquals(response.status, 409);
  assertEquals(retrieveCalled, false);
  assertMatch(await response.json(), { error: "payment_attempt_expired" });
});

Deno.test("create payment intent normalizes shipping country code before insert", async () => {
  let insertedCountryCode: string | null = null;

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "it",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
    }),
    beginOrReadPaymentAttempt: (
      args: { shippingCountryCode: string },
    ) => {
      insertedCountryCode = args.shippingCountryCode;
      return Promise.resolve({
        attempt: {
          id: "123e4567-e89b-42d3-a456-426614174000",
          buyerId: "buyer-1",
          sellerId: "seller-1",
          truffleId: "123e4567-e89b-42d3-a456-426614174001",
          shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
          status: "requires_payment_method" as const,
          requestFingerprint:
            '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
          stripePaymentIntentId: null,
          totalPrice: 79,
          commissionAmount: 7.9,
          sellerAmount: 71.1,
          shippingFullName: "Buyer One",
          shippingStreet: "Via Roma 1",
          shippingCity: "Roma",
          shippingPostalCode: "00100",
          shippingCountryCode: "IT",
          shippingPhone: "3331111111",
          orderId: null,
          expiresAt: new Date().toISOString(),
        },
        isNew: true,
        conflict: null,
      });
    },
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        truffle_id: "123e4567-e89b-42d3-a456-426614174001",
        shipping_address_id: "123e4567-e89b-42d3-a456-426614174002",
      }),
    }),
    requestId: "req-country-normalization",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway(),
  });

  assertEquals(response.status, 200);
  assertEquals(insertedCountryCode, "IT");
});

Deno.test("create payment intent blocks reuse of succeeded payment intents", async () => {
  const attempt = {
    id: "123e4567-e89b-42d3-a456-426614174000",
    buyerId: "buyer-1",
    sellerId: "seller-1",
    truffleId: "123e4567-e89b-42d3-a456-426614174001",
    shippingAddressId: "123e4567-e89b-42d3-a456-426614174002",
    status: "requires_payment_method" as const,
    requestFingerprint:
      '{"truffle_id":"123e4567-e89b-42d3-a456-426614174001","shipping_address_id":"123e4567-e89b-42d3-a456-426614174002"}',
    stripePaymentIntentId: "pi_succeeded",
    totalPrice: 79,
    commissionAmount: 7.9,
    sellerAmount: 71.1,
    shippingFullName: "Buyer One",
    shippingStreet: "Via Roma 1",
    shippingCity: "Roma",
    shippingPostalCode: "00100",
    shippingCountryCode: "IT",
    shippingPhone: "3331111111",
    orderId: null,
    expiresAt: new Date("2024-03-09T16:30:00.000Z").toISOString(),
  };

  const store = createNoopStore({
    getCurrentUser: () => Promise.resolve({ id: "buyer-1", isActive: true }),
    getShippingAddress: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174002",
      userId: "buyer-1",
      fullName: "Buyer One",
      street: "Via Roma 1",
      city: "Roma",
      postalCode: "00100",
      countryCode: "IT",
      phone: "3331111111",
    }),
    getTruffleForPurchase: () => Promise.resolve({
      id: "123e4567-e89b-42d3-a456-426614174001",
      sellerId: "seller-1",
      status: "active",
      priceTotal: 79,
    }),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt,
      isNew: false,
      conflict: null,
    }),
  });

  const response = await handleCreatePaymentIntent({
    request: new Request("http://localhost/create_payment_intent", {
      method: "POST",
      body: JSON.stringify({
        payment_attempt_id: attempt.id,
        truffle_id: attempt.truffleId,
        shipping_address_id: attempt.shippingAddressId,
      }),
    }),
    requestId: "req-succeeded-pi",
    authenticatedUserId: "buyer-1",
    store,
    stripeGateway: createNoopStripeGateway({
      retrievePaymentIntent: () => Promise.resolve({
        id: "pi_succeeded",
        clientSecret: "pi_succeeded_secret",
        status: "succeeded",
      }),
    }),
    now: () => new Date("2024-03-09T16:00:00.000Z"),
  });

  assertEquals(response.status, 409);
  assertMatch(await response.json(), {
    error: "payment_attempt_already_succeeded",
  });
});

Deno.test("webhook signature verification rejects invalid signatures", async () => {
  const verification = await verifyStripeWebhookSignature({
    payload: '{"id":"evt_test"}',
    signatureHeader: "t=1710000000,v1=deadbeef",
    secret: "whsec_test",
    now: () => new Date("2024-03-09T16:00:00.000Z"),
  });

  assertEquals(verification.ok, false);
});

Deno.test("webhook replay does not reprocess duplicate events", async () => {
  let createOrderCalled = false;
  const payload = JSON.stringify({
    id: "evt_duplicate",
    type: "payment_intent.succeeded",
    data: {
      object: {
        id: "pi_test_1",
        object: "payment_intent",
        metadata: {
          payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        },
      },
    },
  });
  const signature = await makeStripeSignature(
    "whsec_test",
    payload,
    1710000000,
  );

  const response = await handleStripeWebhook({
    request: new Request("http://localhost/stripe_webhook", {
      method: "POST",
      headers: { "stripe-signature": signature },
      body: payload,
    }),
    requestId: "req-5",
    webhookSecret: "whsec_test",
    now: () => new Date("2024-03-09T16:00:00.000Z"),
    store: createNoopStore({
      registerWebhookEvent: () => Promise.resolve({ isDuplicate: true }),
      createOrderFromPaymentAttempt: () => {
        createOrderCalled = true;
        return Promise.resolve({
          orderId: "unexpected",
          created: false,
          paymentAttemptStatus: "succeeded",
        });
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createOrderCalled, false);
  assertMatch(await response.json(), { duplicate: true });
});

Deno.test("payment_intent.succeeded creates one order", async () => {
  let createOrderCalled = false;
  const payload = JSON.stringify({
    id: "evt_success",
    type: "payment_intent.succeeded",
    data: {
      object: {
        id: "pi_test_success",
        object: "payment_intent",
        metadata: {
          payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        },
      },
    },
  });
  const signature = await makeStripeSignature(
    "whsec_test",
    payload,
    1710000000,
  );

  const response = await handleStripeWebhook({
    request: new Request("http://localhost/stripe_webhook", {
      method: "POST",
      headers: { "stripe-signature": signature },
      body: payload,
    }),
    requestId: "req-6",
    webhookSecret: "whsec_test",
    now: () => new Date("2024-03-09T16:00:00.000Z"),
    store: createNoopStore({
      registerWebhookEvent: () => Promise.resolve({ isDuplicate: false }),
      getPaymentAttemptById: () => Promise.resolve({
        id: "123e4567-e89b-42d3-a456-426614174000",
        buyerId: "buyer-1",
        sellerId: "seller-1",
        truffleId: "truffle-1",
        shippingAddressId: "shipping-1",
        status: "requires_payment_method",
        requestFingerprint: "fp",
        stripePaymentIntentId: "pi_test_success",
        totalPrice: 79,
        commissionAmount: 7.9,
        sellerAmount: 71.1,
        shippingFullName: "Buyer One",
        shippingStreet: "Via Roma 1",
        shippingCity: "Roma",
        shippingPostalCode: "00100",
        shippingCountryCode: "IT",
        shippingPhone: "3331111111",
        orderId: null,
        expiresAt: new Date().toISOString(),
      }),
      createOrderFromPaymentAttempt: () => {
        createOrderCalled = true;
        return Promise.resolve({
          orderId: "223e4567-e89b-42d3-a456-426614174000",
          created: true,
          paymentAttemptStatus: "succeeded",
        });
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(createOrderCalled, true);
  assertMatch(await response.json(), { processed: true });
});

Deno.test("payment_intent.payment_failed does not create orders", async () => {
  let createOrderCalled = false;
  let markedFailed = false;
  const payload = JSON.stringify({
    id: "evt_failed",
    type: "payment_intent.payment_failed",
    data: {
      object: {
        id: "pi_test_failed",
        object: "payment_intent",
        metadata: {
          payment_attempt_id: "123e4567-e89b-42d3-a456-426614174000",
        },
        last_payment_error: {
          code: "card_declined",
          message: "Card was declined",
        },
      },
    },
  });
  const signature = await makeStripeSignature(
    "whsec_test",
    payload,
    1710000000,
  );

  const response = await handleStripeWebhook({
    request: new Request("http://localhost/stripe_webhook", {
      method: "POST",
      headers: { "stripe-signature": signature },
      body: payload,
    }),
    requestId: "req-7",
    webhookSecret: "whsec_test",
    now: () => new Date("2024-03-09T16:00:00.000Z"),
    store: createNoopStore({
      registerWebhookEvent: () => Promise.resolve({ isDuplicate: false }),
      getPaymentAttemptById: () => Promise.resolve({
        id: "123e4567-e89b-42d3-a456-426614174000",
        buyerId: "buyer-1",
        sellerId: "seller-1",
        truffleId: "truffle-1",
        shippingAddressId: "shipping-1",
        status: "requires_payment_method",
        requestFingerprint: "fp",
        stripePaymentIntentId: "pi_test_failed",
        totalPrice: 79,
        commissionAmount: 7.9,
        sellerAmount: 71.1,
        shippingFullName: "Buyer One",
        shippingStreet: "Via Roma 1",
        shippingCity: "Roma",
        shippingPostalCode: "00100",
        shippingCountryCode: "IT",
        shippingPhone: "3331111111",
        orderId: null,
        expiresAt: new Date().toISOString(),
      }),
      markPaymentAttemptFailed: () => {
        markedFailed = true;
        return Promise.resolve({
          idempotent: false,
          status: "failed",
        });
      },
      createOrderFromPaymentAttempt: () => {
        createOrderCalled = true;
        return Promise.resolve({
          orderId: "unexpected",
          created: false,
          paymentAttemptStatus: "failed",
        });
      },
    }),
  });

  assertEquals(response.status, 200);
  assertEquals(markedFailed, true);
  assertEquals(createOrderCalled, false);
});

function createNoopStore(overrides: Partial<PaymentStore> = {}): PaymentStore {
  return {
    getCurrentUser: () => Promise.resolve(null),
    getTruffleForPurchase: () => Promise.resolve(null),
    getShippingAddress: () => Promise.resolve(null),
    expireStalePaymentAttempts: () => Promise.resolve(),
    beginOrReadPaymentAttempt: () => Promise.resolve({
      attempt: null,
      isNew: false,
      conflict: null,
    }),
    attachStripePaymentIntent: () => Promise.resolve(),
    getPaymentAttemptById: () => Promise.resolve(null),
    getPaymentAttemptByStripeIntentId: () => Promise.resolve(null),
    markPaymentAttemptFailed: () => Promise.resolve({
      idempotent: false,
      status: "failed" as const,
    }),
    registerWebhookEvent: () => Promise.resolve({ isDuplicate: false }),
    completeWebhookEvent: () => Promise.resolve(),
    failWebhookEvent: () => Promise.resolve(),
    createOrderFromPaymentAttempt: () => Promise.resolve({
      orderId: "223e4567-e89b-42d3-a456-426614174000",
      created: false,
      paymentAttemptStatus: "succeeded" as const,
    }),
    insertAuditLog: () => Promise.resolve(),
    ...overrides,
  };
}

function createNoopStripeGateway(
  overrides: Partial<StripeGateway> = {},
): StripeGateway {
  return {
    createPaymentIntent: () => Promise.resolve({
      id: "pi_default",
      clientSecret: "pi_default_secret",
      status: "requires_payment_method" as const,
    }),
    retrievePaymentIntent: () => Promise.resolve({
      id: "pi_default",
      clientSecret: "pi_default_secret",
      status: "requires_payment_method" as const,
    }),
    ...overrides,
  };
}

async function makeStripeSignature(
  secret: string,
  payload: string,
  timestamp: number,
): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signedPayload = `${timestamp}.${payload}`;
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(signedPayload),
  );
  const hex = Array.from(new Uint8Array(signature))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
  return `t=${timestamp},v1=${hex}`;
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
