import { handleDeleteAccount } from "../delete_account/index.ts";

type ResponseTuple = {
  data?: unknown;
  error?: unknown;
};

type TableSpec = {
  maybeSingleResponses?: ResponseTuple[];
  selectResponses?: ResponseTuple[];
  updateResponses?: ResponseTuple[];
  deleteResponses?: ResponseTuple[];
  insertResponses?: ResponseTuple[];
};

type FakeClientSpec = {
  authUserId?: string | null;
  tables: Record<string, TableSpec>;
  authDeleteResponse?: ResponseTuple;
};

Deno.test("delete_account requires authentication", async () => {
  const adminClient = createFakeSupabaseClient({
    tables: {
      users: {
        maybeSingleResponses: [
          { data: { id: "u1", is_active: true }, error: null },
        ],
      },
    },
  });

  const response = await handleDeleteAccount(
    new Request("http://localhost/delete_account", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    }),
    {
      adminClient,
      requestId: "req-unauth",
    },
  );

  assertEquals(response.status, 401);
  assertEquals(await jsonBody(response), {
    error: "unauthorized",
    message: "Authentication is required.",
    request_id: "req-unauth",
  });
});

Deno.test("delete_account ignores client-provided user_id and hard-deletes inactive-free accounts", async () => {
  const adminClient = createFakeSupabaseClient({
    authUserId: "u1",
    tables: {
      users: {
        maybeSingleResponses: [
          { data: { id: "u1", is_active: true }, error: null },
        ],
        updateResponses: [{ data: null, error: null }],
      },
      orders: {
        maybeSingleResponses: [
          { data: null, error: null },
          { data: null, error: null },
        ],
      },
      truffles: {
        maybeSingleResponses: [
          { data: null, error: null },
          { data: null, error: null },
        ],
        selectResponses: [
          { data: [], error: null },
        ],
        deleteResponses: [{ data: null, error: null }],
      },
      shipping_addresses: {
        deleteResponses: [{ data: null, error: null }],
      },
      favorites: {
        deleteResponses: [{ data: null, error: null }],
      },
      notifications: {
        deleteResponses: [{ data: null, error: null }],
      },
      seller_documents: {
        deleteResponses: [{ data: null, error: null }],
      },
      truffle_images: {
        selectResponses: [{ data: [], error: null }],
      },
      audit_logs: {
        insertResponses: [{ data: null, error: null }],
      },
    },
    authDeleteResponse: { data: { user: { id: "u1" } }, error: null },
  });

  const response = await handleDeleteAccount(
    requestWithBody({
      body: { user_id: "u2" },
      authHeader: true,
      requestId: "req-hard-delete",
    }),
    {
      adminClient,
      authClient: createFakeAuthClient("u1"),
      requestId: "req-hard-delete",
    },
  );

  assertEquals(response.status, 200);
  assertEquals(await jsonBody(response), {
    success: true,
    status: "deleted",
    request_id: "req-hard-delete",
  });
  assertEquals(adminClient.authDeleteCalls, ["u1"]);
  assertEquals(
    adminClient.calls.users?.some((call) => call.kind === "update" &&
      JSON.stringify(call.payload).includes("\"is_active\":false")),
    false,
  );
});

Deno.test("delete_account deactivates accounts with historical activity", async () => {
  const adminClient = createFakeSupabaseClient({
    authUserId: "u1",
    tables: {
      users: {
        maybeSingleResponses: [
          { data: { id: "u1", is_active: true }, error: null },
        ],
        updateResponses: [{ data: null, error: null }],
      },
      orders: {
        maybeSingleResponses: [
          { data: { id: "order-1" }, error: null },
        ],
      },
      truffles: {
        maybeSingleResponses: [
          { data: null, error: null },
        ],
        selectResponses: [
          { data: [{ id: "truffle-1" }], error: null },
        ],
        deleteResponses: [{ data: null, error: null }],
      },
      shipping_addresses: {
        deleteResponses: [{ data: null, error: null }],
      },
      favorites: {
        deleteResponses: [{ data: null, error: null }],
      },
      notifications: {
        deleteResponses: [{ data: null, error: null }],
      },
      seller_documents: {
        deleteResponses: [{ data: null, error: null }],
      },
      truffle_images: {
        selectResponses: [{ data: [{ id: "img-1", image_url: "profile_images/u1/avatar.png" }], error: null }],
        deleteResponses: [{ data: null, error: null }],
      },
      audit_logs: {
        insertResponses: [{ data: null, error: null }],
      },
    },
    authDeleteResponse: { data: null, error: { message: "not called" } },
  });

  const response = await handleDeleteAccount(
    requestWithBody({
      body: {},
      authHeader: true,
      requestId: "req-deactivate",
    }),
    {
      adminClient,
      authClient: createFakeAuthClient("u1"),
      requestId: "req-deactivate",
    },
  );

  assertEquals(response.status, 200);
  assertEquals(await jsonBody(response), {
    success: true,
    status: "deactivated",
    request_id: "req-deactivate",
  });
  assertEquals(adminClient.authDeleteCalls.length, 0);
  const userUpdate = adminClient.calls.users?.find((call) =>
    call.kind === "update" && call.payload?.is_active === false
  );
  assertEquals(Boolean(userUpdate), true);
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
  const calls: Record<string, any[]> = {};
  const authDeleteCalls: string[] = [];

  const client = {
    authDeleteCalls,
    auth: {
      getUser: async () => ({
        data: { user: spec.authUserId == null ? null : { id: spec.authUserId } },
        error: null,
      }),
      admin: {
        deleteUser: async (userId: string) => {
          authDeleteCalls.push(userId);
          return spec.authDeleteResponse ?? { data: { user: { id: userId } }, error: null };
        },
      },
    },
    storage: {
      from(bucketId: string) {
        return {
          remove: async (paths: string[]) => {
            calls[bucketId] ??= [];
            calls[bucketId].push({ kind: "remove", paths });
            return [];
          },
        };
      },
    },
    calls,
    from(table: string) {
      calls[table] ??= [];
      const tableSpec = spec.tables[table] ?? {};
      let mode: "select" | "update" | "delete" | "insert" = "select";
      let payload: unknown;

      const builder: any = {
        select() {
          mode = "select";
          return builder;
        },
        eq(column: string, value: string) {
          calls[table].push({ kind: "eq", column, value });
          return builder;
        },
        in(column: string, values: string[]) {
          calls[table].push({ kind: "in", column, values });
          return builder;
        },
        limit(value: number) {
          calls[table].push({ kind: "limit", value });
          return builder;
        },
        maybeSingle: async () => resolveResponse(
          shiftResponse(tableSpec.maybeSingleResponses),
        ),
        update(nextPayload: unknown) {
          mode = "update";
          payload = nextPayload;
          calls[table].push({ kind: "update", payload: nextPayload });
          return builder;
        },
        delete() {
          mode = "delete";
          calls[table].push({ kind: "delete" });
          return builder;
        },
        insert(nextPayload: unknown) {
          mode = "insert";
          payload = nextPayload;
          calls[table].push({ kind: "insert", payload: nextPayload });
          return builder;
        },
        then(onFulfilled: any, onRejected: any) {
          let response: ResponseTuple | undefined;
          if (mode === "update") {
            response = shiftResponse(tableSpec.updateResponses);
          } else if (mode === "delete") {
            response = shiftResponse(tableSpec.deleteResponses);
          } else if (mode === "insert") {
            response = shiftResponse(tableSpec.insertResponses);
          } else {
            response = shiftResponse(tableSpec.selectResponses);
          }
          return Promise.resolve(resolveResponse(response, payload)).then(
            onFulfilled,
            onRejected,
          );
        },
      };

      return builder;
    },
  };

  return client;
}

function shiftResponse(
  responses?: ResponseTuple[],
): ResponseTuple | undefined {
  return responses?.shift();
}

async function resolveResponse(
  response?: ResponseTuple,
  _payload?: unknown,
): Promise<ResponseTuple> {
  return response ?? { data: null, error: null };
}

function requestWithBody(args: {
  body: Record<string, unknown>;
  authHeader: boolean;
  requestId: string;
}): Request {
  return new Request("http://localhost/delete_account", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(args.authHeader ? { Authorization: "Bearer test-token" } : {}),
      "x-request-id": args.requestId,
    },
    body: JSON.stringify(args.body),
  });
}

async function jsonBody(response: Response): Promise<Record<string, unknown>> {
  return await response.json() as Record<string, unknown>;
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}`,
    );
  }
}
