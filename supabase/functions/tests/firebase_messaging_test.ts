// deno-lint-ignore-file no-explicit-any

import type { SupabaseClient } from "@supabase/supabase-js";
import {
  loadFirebaseServiceAccount,
  parseFirebaseServiceAccount,
  sendFirebasePushToUser,
} from "../_shared/firebase_messaging.ts";
import {
  buildItalianPushContent,
  buildNotificationEnvelope,
  buildPushData,
  isHighImportanceNotification,
} from "../_shared/notification_catalog.ts";

Deno.test("notification catalog builds Italian push content and string data", () => {
  const envelope = buildNotificationEnvelope({
    type: "order_confirmed",
    metadata: {
      order_id: "order-1",
      truffle_name: "Tartufo bianco",
      paid: true,
      nested: { ignored: true },
    },
  });
  const content = buildItalianPushContent({
    type: envelope.type,
    metadata: envelope.metadata,
  });
  const data = buildPushData(envelope);

  assertEquals(isHighImportanceNotification("order_confirmed"), true);
  assertEquals(isHighImportanceNotification("profile_updated"), false);
  assertEquals(content.title, "Ordine confermato");
  assertEquals(
    content.body,
    'Il tuo ordine per "Tartufo bianco" è stato confermato. Il venditore ha 48 ore per spedirlo.',
  );
  assertEquals(data.type, "order_confirmed");
  assertEquals(data.order_id, "order-1");
  assertEquals(data.paid, "true");
  assertEquals(data.nested, undefined);
});

Deno.test("notification catalog uses truffle type and weight in push content", () => {
  const envelope = buildNotificationEnvelope({
    type: "seller_new_order",
    metadata: {
      order_id: "order-1",
      truffle_type: "TUBER_MELANOSPORUM",
      weight_grams: 500,
    },
  });
  const content = buildItalianPushContent({
    type: envelope.type,
    metadata: envelope.metadata,
  });
  const data = buildPushData(envelope);

  assertEquals(
    content.body,
    'Hai ricevuto un nuovo ordine per "Nero pregiato 500g". Spediscilo entro 48 ore.',
  );
  assertEquals(data.weight_grams, "500");
});

Deno.test("Firebase service account parser accepts raw JSON string", () => {
  const account = createServiceAccount();
  const parsed = parseFirebaseServiceAccount(JSON.stringify(account));

  assertEquals(parsed.project_id, account.project_id);
  assertEquals(parsed.client_email, account.client_email);
  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase service account parser accepts escaped JSON string", () => {
  const account = createServiceAccount();
  const parsed = parseFirebaseServiceAccount(JSON.stringify(
    JSON.stringify(account),
  ));

  assertEquals(parsed.project_id, account.project_id);
  assertEquals(parsed.client_email, account.client_email);
  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase service account parser accepts accidental quoted JSON", () => {
  const account = createServiceAccount();
  const parsed = parseFirebaseServiceAccount(`'${JSON.stringify(account)}'`);

  assertEquals(parsed.project_id, account.project_id);
  assertEquals(parsed.client_email, account.client_email);
  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader accepts split credentials", () => {
  const parsed = loadFirebaseServiceAccount({
    serviceAccountJson: "",
    projectId: "truffly-split",
    clientEmail: "firebase-split@example.com",
    privateKey: createPrivateKeyEscapedNewlines(),
  });

  assertEquals(parsed.project_id, "truffly-split");
  assertEquals(parsed.client_email, "firebase-split@example.com");
  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader falls back to split credentials when JSON is invalid", () => {
  const parsed = loadFirebaseServiceAccount({
    serviceAccountJson: "{invalid",
    projectId: "truffly-fallback",
    clientEmail: "firebase-fallback@example.com",
    privateKey: createPrivateKeyEscapedNewlines(),
  });

  assertEquals(parsed.project_id, "truffly-fallback");
  assertEquals(parsed.client_email, "firebase-fallback@example.com");
  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader supports private key with escaped newlines", () => {
  const parsed = loadFirebaseServiceAccount({
    serviceAccountJson: "",
    projectId: "truffly-test",
    clientEmail: "firebase@example.com",
    privateKey: createPrivateKeyEscapedNewlines(),
  });

  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader supports private key with real newlines", () => {
  const parsed = loadFirebaseServiceAccount({
    serviceAccountJson: "",
    projectId: "truffly-test",
    clientEmail: "firebase@example.com",
    privateKey: createPrivateKeyRealNewlines(),
  });

  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader supports base64 private key", () => {
  const parsed = loadFirebaseServiceAccount({
    serviceAccountJson: "",
    projectId: "truffly-test",
    clientEmail: "firebase@example.com",
    privateKeyBase64: btoa(createPrivateKeyRealNewlines()),
    privateKey: "not-used-when-base64-exists",
  });

  assertEquals(parsed.private_key, createPrivateKeyRealNewlines());
});

Deno.test("Firebase credential loader rejects malformed base64 private key", () => {
  assertThrows(
    () =>
      loadFirebaseServiceAccount({
        serviceAccountJson: "",
        projectId: "truffly-test",
        clientEmail: "firebase@example.com",
        privateKeyBase64: "not valid base64!",
      }),
    "invalid private key format",
  );
});

Deno.test("Firebase credential loader rejects decoded key without PEM markers", () => {
  assertThrows(
    () =>
      loadFirebaseServiceAccount({
        serviceAccountJson: "",
        projectId: "truffly-test",
        clientEmail: "firebase@example.com",
        privateKeyBase64: btoa("not a pem key"),
      }),
    "invalid private key format",
  );
});

Deno.test("Firebase credential loader validates missing split fields", () => {
  assertThrows(
    () =>
      loadFirebaseServiceAccount({
        serviceAccountJson: "",
        projectId: "",
        clientEmail: "firebase@example.com",
        privateKey: createPrivateKeyEscapedNewlines(),
      }),
    "missing project_id",
  );
  assertThrows(
    () =>
      loadFirebaseServiceAccount({
        serviceAccountJson: "",
        projectId: "truffly-test",
        clientEmail: "",
        privateKey: createPrivateKeyEscapedNewlines(),
      }),
    "missing client_email",
  );
  assertThrows(
    () =>
      loadFirebaseServiceAccount({
        serviceAccountJson: "",
        projectId: "truffly-test",
        clientEmail: "firebase@example.com",
        privateKey: "",
      }),
    "missing private_key",
  );
});

Deno.test("Firebase service account parser rejects invalid JSON safely", () => {
  assertThrows(
    () => parseFirebaseServiceAccount("{invalid"),
    "invalid service account JSON",
  );
});

Deno.test("Firebase service account parser validates required fields", () => {
  assertThrows(
    () =>
      parseFirebaseServiceAccount(JSON.stringify({
        client_email: "firebase@example.com",
        private_key: createPrivateKeyEscapedNewlines(),
      })),
    "missing project_id",
  );
  assertThrows(
    () =>
      parseFirebaseServiceAccount(JSON.stringify({
        project_id: "truffly-test",
        private_key: createPrivateKeyEscapedNewlines(),
      })),
    "missing client_email",
  );
  assertThrows(
    () =>
      parseFirebaseServiceAccount(JSON.stringify({
        project_id: "truffly-test",
        client_email: "firebase@example.com",
      })),
    "missing private_key",
  );
});

Deno.test("FCM skips users without enabled tokens", async () => {
  const adminClient = createFakeAdminClient({
    tokens: [],
  });

  const result = await sendFirebasePushToUser({
    adminClient: adminClient as unknown as SupabaseClient,
    userId: "user-1",
    message: {
      title: "Test",
      body: "Body",
      data: { type: "test_push" },
    },
    requestId: "req-no-tokens",
  });

  assertEquals(result, {
    status: "skipped",
    attempted: 0,
    sent: 0,
    failed: 0,
  });
});

Deno.test("FCM sends Italian accented title and body as UTF-8 JSON", async () => {
  const adminClient = createFakeAdminClient({
    tokens: [{ token: "valid-token-123", platform: "android" }],
  });
  let capturedInit: RequestInit | undefined;

  const result = await sendFirebasePushToUser({
    adminClient: adminClient as unknown as SupabaseClient,
    userId: "user-1",
    message: {
      title: "Questa è una notifica",
      body: "L’ordine è stato spedito",
      data: { type: "test_push" },
    },
    requestId: "req-utf8-payload",
    config: {
      accessToken: "test-access-token",
      serviceAccountJson: JSON.stringify(createServiceAccount()),
      fetchImpl: (_input, init) => {
        capturedInit = init;
        return Promise.resolve(new Response("{}", { status: 200 }));
      },
    },
  });

  assertEquals(result.status, "sent");
  assertEquals(
    readHeader(capturedInit?.headers, "Content-Type"),
    "application/json; charset=utf-8",
  );

  const requestBody = await readRequestBody(capturedInit?.body);
  const payload = JSON.parse(requestBody);
  assertEquals(payload.message.notification.title, "Questa è una notifica");
  assertEquals(payload.message.notification.body, "L’ordine è stato spedito");
});

Deno.test("FCM disables an unregistered token", async () => {
  const adminClient = createFakeAdminClient({
    tokens: [{ token: "invalid-token-123", platform: "android" }],
  });

  const result = await sendFirebasePushToUser({
    adminClient: adminClient as unknown as SupabaseClient,
    userId: "user-1",
    message: {
      title: "Test",
      body: "Body",
      data: { type: "test_push" },
    },
    requestId: "req-invalid-token",
    config: {
      accessToken: "test-access-token",
      serviceAccountJson: JSON.stringify({
        client_email: "firebase@example.com",
        private_key: createPrivateKeyEscapedNewlines(),
        project_id: "truffly-test",
      }),
      fetchImpl: () =>
        Promise.resolve(
          new Response(
            JSON.stringify({
              error: {
                status: "NOT_FOUND",
                details: [{ errorCode: "UNREGISTERED" }],
              },
            }),
            { status: 404 },
          ),
        ),
    },
  });

  assertEquals(result.status, "failed");
  assertEquals(adminClient.disabledTokens, ["invalid-token-123"]);
});

function createFakeAdminClient(args: {
  tokens: Array<{ token: string; platform: string }>;
}) {
  const disabledTokens: string[] = [];

  return {
    disabledTokens,
    from(table: string) {
      if (table !== "user_push_tokens") {
        throw new Error(`Unexpected table ${table}`);
      }

      const builder: any = {
        select() {
          return builder;
        },
        update() {
          return builder;
        },
        eq(column: string, value: unknown) {
          if (column === "token" && typeof value === "string") {
            disabledTokens.push(value);
          }
          return builder;
        },
        then(onFulfilled: any, onRejected: any) {
          return Promise.resolve({
            data: args.tokens,
            error: null,
          }).then(onFulfilled, onRejected);
        },
      };
      return builder;
    },
  };
}

function createServiceAccount() {
  return {
    type: "service_account",
    project_id: "truffly-test",
    client_email: "firebase@example.com",
    private_key: createPrivateKeyEscapedNewlines(),
  };
}

function createPrivateKeyEscapedNewlines(): string {
  return "-----BEGIN PRIVATE KEY-----\\ntest\\n-----END PRIVATE KEY-----\\n";
}

function createPrivateKeyRealNewlines(): string {
  return "-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----";
}

async function readRequestBody(
  body: BodyInit | null | undefined,
): Promise<string> {
  if (body instanceof Uint8Array) {
    return new TextDecoder("utf-8", { fatal: true }).decode(body);
  }
  if (typeof body === "string") {
    return body;
  }
  if (body instanceof ReadableStream) {
    return await new Response(body).text();
  }
  throw new Error("Unsupported request body type");
}

function readHeader(
  headers: HeadersInit | undefined,
  name: string,
): string | null {
  if (!headers) return null;
  if (headers instanceof Headers) return headers.get(name);
  if (Array.isArray(headers)) {
    const entry = headers.find(([key]) =>
      key.toLowerCase() === name.toLowerCase()
    );
    return entry?.[1] ?? null;
  }
  const headerRecord = headers as Record<string, string>;
  const value = headerRecord[name] ?? headerRecord[name.toLowerCase()];
  return typeof value === "string" ? value : null;
}

function assertThrows(fn: () => unknown, expectedMessage: string): void {
  try {
    fn();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (message !== expectedMessage) {
      throw new Error(
        `Expected error ${JSON.stringify(expectedMessage)}, received ${
          JSON.stringify(message)
        }`,
      );
    }
    return;
  }

  throw new Error(`Expected error ${JSON.stringify(expectedMessage)}`);
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
