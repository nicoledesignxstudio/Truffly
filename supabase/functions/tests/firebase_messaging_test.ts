// deno-lint-ignore-file no-explicit-any

import type { SupabaseClient } from "@supabase/supabase-js";
import { sendFirebasePushToUser } from "../_shared/firebase_messaging.ts";
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
        private_key: "unused-in-test",
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

function assertEquals(actual: unknown, expected: unknown): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, received ${
        JSON.stringify(actual)
      }`,
    );
  }
}
