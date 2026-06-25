import { createBusinessNotificationAndPush } from "../_shared/business_notifications.ts";
import { handleAutoCreateMissingReviews } from "../auto_create_missing_reviews/index.ts";
import { handleCreateReview } from "../create_review/index.ts";

type ResponseTuple = {
  data?: unknown;
  error?: unknown;
};

type TableSpec = {
  selectResponse?:
    | ResponseTuple
    | (() => ResponseTuple | Promise<ResponseTuple>);
  singleResponse?:
    | ResponseTuple
    | (() => ResponseTuple | Promise<ResponseTuple>);
  maybeSingleResponse?:
    | ResponseTuple
    | (() => ResponseTuple | Promise<ResponseTuple>);
  insertResponse?:
    | ResponseTuple
    | ((payload?: unknown) => ResponseTuple | Promise<ResponseTuple>);
  insertSelectResponse?:
    | ResponseTuple
    | ((payload: unknown) => ResponseTuple | Promise<ResponseTuple>);
  updateResponse?:
    | ResponseTuple
    | ((payload: unknown) => ResponseTuple | Promise<ResponseTuple>);
  insertedPayloads?: unknown[];
};

type FakeClientSpec = {
  authUserResponse?: ResponseTuple;
  tables: Record<string, TableSpec>;
};

Deno.test("create_review blocks ownership violations", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      orders: {
        singleResponse: {
          data: {
            id: "order-1",
            buyer_id: "buyer-2",
            seller_id: "seller-1",
            status: "completed",
            completed_at: new Date(Date.now() - 24 * 60 * 60 * 1000)
              .toISOString(),
          },
          error: null,
        },
      },
      reviews: {
        maybeSingleResponse: { data: null, error: null },
        insertedPayloads: [],
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: null,
      },
      authHeader: true,
      requestId: "req-review-ownership",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-ownership",
    },
  );

  assertEquals(response.status, 403);
  assertEquals(await jsonBody(response), {
    error: "forbidden",
    request_id: "req-review-ownership",
  });
  assertEquals(adminClient.calls.reviews?.length ?? 0, 0);
});

Deno.test("create_review blocks duplicate reviews", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      orders: {
        singleResponse: {
          data: {
            id: "order-1",
            buyer_id: "u1",
            seller_id: "seller-1",
            status: "completed",
            completed_at: new Date(Date.now() - 24 * 60 * 60 * 1000)
              .toISOString(),
          },
          error: null,
        },
      },
      reviews: {
        maybeSingleResponse: {
          data: { id: "review-1" },
          error: null,
        },
        insertedPayloads: [],
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: "Great",
      },
      authHeader: true,
      requestId: "req-review-duplicate",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-duplicate",
    },
  );

  assertEquals(response.status, 409);
  assertEquals(await jsonBody(response), {
    error: "review_already_exists",
    request_id: "req-review-duplicate",
  });
  assertEquals(adminClient.calls.reviews.length, 0);
});

Deno.test("create_review creates a manual review within 48 hours", async () => {
  const reviewsSpec: TableSpec = {
    maybeSingleResponse: { data: null, error: null },
    insertSelectResponse: {
      data: {
        id: "review-1",
        order_id: "order-1",
        rating: 5,
        comment: "Perfetto",
        created_at: "2026-06-09T09:00:00.000Z",
        is_auto: false,
        auto_created_at: null,
      },
      error: null,
    },
    insertedPayloads: [],
  };
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      orders: {
        singleResponse: {
          data: {
            id: "order-1",
            buyer_id: "u1",
            seller_id: "seller-1",
            status: "completed",
            completed_at: new Date(Date.now() - 47 * 60 * 60 * 1000)
              .toISOString(),
          },
          error: null,
        },
      },
      reviews: reviewsSpec,
      notifications: {
        insertResponse: { data: null, error: null },
        insertSelectResponse: {
          data: { id: "notification-review-created" },
          error: null,
        },
      },
      notification_push_outbox: {
        updateResponse: { data: null, error: null },
      },
      user_push_tokens: {
        selectResponse: { data: [], error: null },
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: "Perfetto",
      },
      authHeader: true,
      requestId: "req-review-created",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-created",
    },
  );

  assertEquals(response.status, 200);
  assertEquals(await jsonBody(response), {
    success: true,
    request_id: "req-review-created",
  });
  assertEquals(reviewsSpec.insertedPayloads?.length, 1);
});

Deno.test("create_review blocks expired review window", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      orders: {
        singleResponse: {
          data: {
            id: "order-1",
            buyer_id: "u1",
            seller_id: "seller-1",
            status: "completed",
            completed_at: new Date(Date.now() - 49 * 60 * 60 * 1000)
              .toISOString(),
          },
          error: null,
        },
      },
      reviews: {
        maybeSingleResponse: { data: null, error: null },
        insertedPayloads: [],
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: null,
      },
      authHeader: true,
      requestId: "req-review-expired",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-expired",
    },
  );

  assertEquals(response.status, 409);
  assertEquals(await jsonBody(response), {
    error: "review_window_expired",
    request_id: "req-review-expired",
  });
  assertEquals(adminClient.calls.reviews?.length ?? 0, 0);
});

Deno.test("create_review blocks non-completed orders", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      orders: {
        singleResponse: {
          data: {
            id: "order-1",
            buyer_id: "u1",
            seller_id: "seller-1",
            status: "shipped",
            completed_at: null,
          },
          error: null,
        },
      },
      reviews: {
        maybeSingleResponse: { data: null, error: null },
        insertedPayloads: [],
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: null,
      },
      authHeader: true,
      requestId: "req-review-not-completed",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-not-completed",
    },
  );

  assertEquals(response.status, 409);
  assertEquals(await jsonBody(response), {
    error: "order_not_completed",
    request_id: "req-review-not-completed",
  });
});

Deno.test("create_review rejects invalid rating input", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 6,
        comment: null,
      },
      authHeader: true,
      requestId: "req-review-invalid-rating",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-invalid-rating",
    },
  );

  assertEquals(response.status, 400);
  assertEquals(await jsonBody(response), {
    error: "invalid_input",
    request_id: "req-review-invalid-rating",
  });
});

Deno.test("create_review rejects comments longer than 300 chars", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        singleResponse: {
          data: { id: "u1", is_active: true },
          error: null,
        },
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleCreateReview(
    requestWithBody({
      path: "http://localhost/create_review",
      body: {
        order_id: "order-1",
        rating: 5,
        comment: "a".repeat(301),
      },
      authHeader: true,
      requestId: "req-review-long-comment",
    }),
    {
      authClient: createFakeAuthClient("u1"),
      adminClient,
      requestId: "req-review-long-comment",
    },
  );

  assertEquals(response.status, 400);
  assertEquals(await jsonBody(response), {
    error: "invalid_input",
    request_id: "req-review-long-comment",
  });
});

Deno.test("auto_create_missing_reviews creates 5-star reviews once", async () => {
  let reviewExists = false;
  const reviewsSpec: TableSpec = {
    maybeSingleResponse: () =>
      reviewExists
        ? { data: { id: "review-1" }, error: null }
        : { data: null, error: null },
    insertResponse: (payload) => {
      reviewExists = true;
      return {
        data: null,
        error: null,
      };
    },
    insertSelectResponse: (payload) => {
      return {
        data: {
          id: "review-1",
          order_id: (payload as { order_id: string }).order_id,
          rating: 5,
          comment: null,
          is_auto: true,
        },
        error: null,
      };
    },
    insertedPayloads: [],
  };

  const adminClient = createFakeSupabaseClient({
    tables: {
      orders: {
        selectResponse: {
          data: [
            {
              id: "order-1",
              seller_id: "seller-1",
              buyer_id: "buyer-1",
            },
          ],
          error: null,
        },
      },
      reviews: reviewsSpec,
      notifications: {
        insertResponse: { data: null, error: null },
        insertSelectResponse: {
          data: { id: "notification-auto-review" },
          error: null,
        },
      },
      notification_push_outbox: {
        updateResponse: { data: null, error: null },
      },
      user_push_tokens: {
        selectResponse: { data: [], error: null },
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const firstResponse = await handleAutoCreateMissingReviews(
    new Request("http://localhost/auto_create_missing_reviews", {
      method: "POST",
      headers: { Authorization: "Bearer cron-secret" },
    }),
    {
      adminClient,
      cronSecret: "cron-secret",
      requestId: "req-auto-review-1",
    },
  );

  assertEquals(firstResponse.status, 200);
  assertEquals(await jsonBody(firstResponse), {
    success: true,
    request_id: "req-auto-review-1",
    scanned: 1,
    created: 1,
    failures: [],
  });
  assertEquals(reviewsSpec.insertedPayloads?.length, 1);
  assertEquals(
    (reviewsSpec.insertedPayloads?.[0] as { rating?: number }).rating,
    5,
  );

  const secondResponse = await handleAutoCreateMissingReviews(
    new Request("http://localhost/auto_create_missing_reviews", {
      method: "POST",
      headers: { Authorization: "Bearer cron-secret" },
    }),
    {
      adminClient,
      cronSecret: "cron-secret",
      requestId: "req-auto-review-2",
    },
  );

  assertEquals(secondResponse.status, 200);
  assertEquals(await jsonBody(secondResponse), {
    success: true,
    request_id: "req-auto-review-2",
    scanned: 1,
    created: 0,
    failures: [],
  });
  assertEquals(reviewsSpec.insertedPayloads?.length, 1);
});

Deno.test("auto_create_missing_reviews skips when no completed orders are eligible", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      orders: {
        selectResponse: { data: [], error: null },
      },
      reviews: {
        maybeSingleResponse: { data: null, error: null },
        insertedPayloads: [],
      },
      notifications: {
        insertResponse: { data: null, error: null },
      },
      user_push_tokens: {
        selectResponse: { data: [], error: null },
      },
      audit_logs: {
        insertResponse: { data: null, error: null },
      },
    },
  });

  const response = await handleAutoCreateMissingReviews(
    new Request("http://localhost/auto_create_missing_reviews", {
      method: "POST",
      headers: { Authorization: "Bearer cron-secret" },
    }),
    {
      adminClient,
      cronSecret: "cron-secret",
      requestId: "req-auto-review-empty",
    },
  );

  assertEquals(response.status, 200);
  assertEquals(await jsonBody(response), {
    success: true,
    request_id: "req-auto-review-empty",
    scanned: 0,
    created: 0,
    failures: [],
  });
});

Deno.test("push failure does not block notification creation", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      notifications: {
        insertResponse: { data: null, error: null },
        insertedPayloads: [],
        insertSelectResponse: {
          data: { id: "notification-push-fail" },
          error: null,
        },
      },
      user_push_tokens: {
        selectResponse: {
          data: [{ token: "token-123", platform: "ios" }],
          error: null,
        },
      },
      notification_push_outbox: {
        updateResponse: { data: null, error: null },
      },
    },
  });

  await createBusinessNotificationAndPush({
    adminClient: adminClient as any,
    userId: "seller-1",
    type: "order_confirmed",
    message: "Your order has been confirmed.",
    metadata: { order_id: "order-1" },
    requestId: "req-push-fail-soft",
    pushConfig: {
      projectId: "truffly-test",
      serviceAccountJson:
        '{"client_email":"bot@example.com","private_key":"not-used-in-test"}',
      accessToken: "test-access-token",
      fetchImpl: async () => {
        throw new Error("fcm unavailable");
      },
    },
  });

  assertEquals(adminClient.calls.notifications.length, 1);
  assertEquals(
    adminClient.calls.notifications[0],
    {
      user_id: "seller-1",
      type: "order_confirmed",
      message: "Your order has been confirmed.",
      target_route: "/orders/order-1",
      target_id: "order-1",
      metadata: { order_id: "order-1" },
    },
  );
});

function createFakeAuthClient(userId: string) {
  return {
    auth: {
      getUser: async () => ({
        data: { user: { id: userId } },
        error: null,
      }),
    },
  };
}

function createFakeSupabaseClient(spec: FakeClientSpec) {
  const calls: Record<string, unknown[]> = {};

  return {
    auth: {
      getUser: async () =>
        spec.authUserResponse ?? {
          data: { user: null },
          error: null,
        },
    },
    calls,
    from(table: string) {
      calls[table] ??= [];
      const tableSpec = spec.tables[table] ?? {};
      const builder: any = {
        select() {
          return builder;
        },
        eq() {
          return builder;
        },
        lte() {
          return builder;
        },
        maybeSingle: async () => resolveResponse(tableSpec.maybeSingleResponse),
        single: async () => resolveResponse(tableSpec.singleResponse),
        insert(payload: unknown) {
          calls[table].push(payload);
          tableSpec.insertedPayloads?.push(payload);
          const chain: any = {
            select() {
              return {
                single: async () =>
                  resolveResponse(
                    tableSpec.insertSelectResponse,
                    payload,
                  ),
              };
            },
            then(onFulfilled: any, onRejected: any) {
              return Promise.resolve(
                resolveResponse(tableSpec.insertResponse, payload),
              ).then(onFulfilled, onRejected);
            },
          };
          return chain;
        },
        update(payload: unknown) {
          calls[table].push(payload);
          const chain: any = {
            eq() {
              return chain;
            },
            then(onFulfilled: any, onRejected: any) {
              return Promise.resolve(
                resolveResponse(tableSpec.updateResponse, payload),
              ).then(onFulfilled, onRejected);
            },
          };
          return chain;
        },
        then(onFulfilled: any, onRejected: any) {
          return Promise.resolve(resolveResponse(tableSpec.selectResponse))
            .then(
              onFulfilled,
              onRejected,
            );
        },
      };
      return builder;
    },
  };
}

async function resolveResponse(
  response?:
    | ResponseTuple
    | ((payload?: unknown) => ResponseTuple | Promise<ResponseTuple>),
  payload?: unknown,
): Promise<ResponseTuple> {
  if (typeof response === "function") {
    return await response(payload);
  }
  return response ?? { data: null, error: null };
}

async function jsonBody(response: Response): Promise<Record<string, unknown>> {
  return await response.json() as Record<string, unknown>;
}

function requestWithBody(args: {
  path: string;
  body: Record<string, unknown>;
  authHeader: boolean;
  requestId: string;
}): Request {
  return new Request(args.path, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(args.authHeader ? { Authorization: "Bearer test-token" } : {}),
      "x-request-id": args.requestId,
    },
    body: JSON.stringify(args.body),
  });
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${
        JSON.stringify(actual)
      }`,
    );
  }
}
