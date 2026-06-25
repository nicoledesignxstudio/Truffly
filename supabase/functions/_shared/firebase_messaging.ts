import type { SupabaseClient } from "@supabase/supabase-js";

export type FirebasePushMessage = {
  title: string;
  body: string;
  data: Record<string, string>;
};

export type FirebasePushConfig = {
  serviceAccountJson?: string;
  projectId?: string;
  fetchImpl?: typeof fetch;
  now?: () => Date;
  accessToken?: string;
};

export type FirebasePushResult = {
  status: "sent" | "skipped" | "failed";
  attempted: number;
  sent: number;
  failed: number;
};

type PushTokenRow = {
  token: string;
  platform: string;
};

type FirebaseServiceAccount = {
  client_email?: string;
  private_key?: string;
  project_id?: string;
  token_uri?: string;
};

const firebaseMessagingScope =
  "https://www.googleapis.com/auth/firebase.messaging";

export async function sendFirebasePushToUser(args: {
  adminClient: SupabaseClient;
  userId: string;
  message: FirebasePushMessage;
  requestId: string;
  config?: FirebasePushConfig;
}): Promise<FirebasePushResult> {
  console.info("FCM push send started", {
    request_id: args.requestId,
    user_id: args.userId,
  });

  try {
    const tokensResult = await args.adminClient
      .from("user_push_tokens")
      .select("token, platform")
      .eq("user_id", args.userId)
      .eq("enabled", true);

    if (tokensResult.error) {
      throw tokensResult.error;
    }

    const tokens = (tokensResult.data ?? []) as PushTokenRow[];
    if (tokens.length === 0) {
      console.info("FCM push skipped: no enabled tokens", {
        request_id: args.requestId,
        user_id: args.userId,
      });
      return { status: "skipped", attempted: 0, sent: 0, failed: 0 };
    }

    const serviceAccountJson = args.config?.serviceAccountJson?.trim() ??
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")?.trim();
    if (!serviceAccountJson) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON is not configured.");
    }

    const serviceAccount = parseServiceAccount(serviceAccountJson);
    const projectId = args.config?.projectId?.trim() ||
      serviceAccount.project_id?.trim();
    if (!projectId) {
      throw new Error("Firebase service account JSON is missing project_id.");
    }
    const accessToken = args.config?.accessToken?.trim() ||
      await obtainAccessToken(
        serviceAccount,
        args.config?.fetchImpl ?? fetch,
        args.config?.now ?? (() => new Date()),
      );
    const endpoint = `https://fcm.googleapis.com/v1/projects/${
      encodeURIComponent(projectId)
    }/messages:send`;

    let sent = 0;
    let failed = 0;

    for (const tokenRow of tokens) {
      const response = await (args.config?.fetchImpl ?? fetch)(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: tokenRow.token,
            notification: {
              title: args.message.title,
              body: args.message.body,
            },
            data: args.message.data,
            android: {
              priority: "high",
            },
          },
        }),
      });

      if (response.ok) {
        sent += 1;
        console.info("FCM push sent successfully", {
          request_id: args.requestId,
          user_id: args.userId,
          token_prefix: tokenRow.token.slice(0, 8),
          platform: tokenRow.platform,
        });
        continue;
      }

      failed += 1;
      const responseBody = await readResponseBody(response);
      if (isInvalidRegistrationToken(response.status, responseBody)) {
        await disableInvalidToken({
          adminClient: args.adminClient,
          token: tokenRow.token,
          requestId: args.requestId,
        });
      }

      console.error("FCM push failed", {
        request_id: args.requestId,
        user_id: args.userId,
        status: response.status,
        token_prefix: tokenRow.token.slice(0, 8),
        fcm_status: readFcmStatus(responseBody),
      });
    }

    return {
      status: failed === 0 ? "sent" : "failed",
      attempted: tokens.length,
      sent,
      failed,
    };
  } catch (error) {
    console.error("FCM push failed", {
      request_id: args.requestId,
      user_id: args.userId,
      message: readErrorMessage(error),
    });
    return { status: "failed", attempted: 0, sent: 0, failed: 1 };
  }
}

function parseServiceAccount(value: string): FirebaseServiceAccount {
  const account = JSON.parse(value) as FirebaseServiceAccount;
  if (
    !account.client_email?.trim() ||
    !account.private_key?.trim()
  ) {
    throw new Error(
      "Firebase service account JSON is missing client_email or private_key.",
    );
  }
  return account;
}

async function obtainAccessToken(
  account: FirebaseServiceAccount,
  fetchImpl: typeof fetch,
  now: () => Date,
): Promise<string> {
  const tokenUri = account.token_uri?.trim() ||
    "https://oauth2.googleapis.com/token";
  const issuedAt = Math.floor(now().getTime() / 1000);
  const encodedHeader = base64UrlEncode(JSON.stringify({
    alg: "RS256",
    typ: "JWT",
  }));
  const encodedClaim = base64UrlEncode(JSON.stringify({
    iss: account.client_email,
    scope: firebaseMessagingScope,
    aud: tokenUri,
    iat: issuedAt,
    exp: issuedAt + 3600,
  }));
  const signingInput = `${encodedHeader}.${encodedClaim}`;
  const privateKey = await importPrivateKey(account.private_key!);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(signingInput),
  );
  const assertion = `${signingInput}.${
    base64UrlEncodeBytes(new Uint8Array(signature))
  }`;

  const response = await fetchImpl(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const responseBody = await readResponseBody(response);

  if (!response.ok) {
    throw new Error(
      `Firebase OAuth token request failed with status ${response.status}.`,
    );
  }

  const accessToken = isRecord(responseBody)
    ? readString(responseBody, "access_token")
    : null;
  if (!accessToken) {
    throw new Error("Firebase OAuth response did not include an access token.");
  }
  return accessToken;
}

async function disableInvalidToken(args: {
  adminClient: SupabaseClient;
  token: string;
  requestId: string;
}): Promise<void> {
  const nowIso = new Date().toISOString();
  const result = await args.adminClient
    .from("user_push_tokens")
    .update({
      enabled: false,
      updated_at: nowIso,
      last_seen_at: nowIso,
    })
    .eq("token", args.token);

  if (result.error) {
    console.error("FCM push failed", {
      request_id: args.requestId,
      message: "Unable to disable invalid FCM token.",
    });
    return;
  }

  console.info("FCM token disabled because invalid", {
    request_id: args.requestId,
    token_prefix: args.token.slice(0, 8),
  });
}

function isInvalidRegistrationToken(
  status: number,
  body: unknown,
): boolean {
  if (status !== 400 && status !== 404) return false;
  const fcmStatus = readFcmStatus(body);
  if (fcmStatus === "UNREGISTERED") return true;

  const message = isRecord(body) && isRecord(body.error)
    ? readString(body.error, "message")?.toLowerCase() ?? ""
    : "";
  return message.includes("registration-token-not-registered") ||
    message.includes("requested entity was not found") ||
    message.includes("invalid registration token");
}

function readFcmStatus(body: unknown): string | null {
  if (!isRecord(body) || !isRecord(body.error)) return null;
  const details = body.error.details;
  if (!Array.isArray(details)) return readString(body.error, "status");

  for (const detail of details) {
    if (!isRecord(detail)) continue;
    const errorCode = readString(detail, "errorCode");
    if (errorCode) return errorCode;
  }
  return readString(body.error, "status");
}

async function readResponseBody(response: Response): Promise<unknown> {
  const text = await response.text();
  if (!text.trim()) return {};
  try {
    return JSON.parse(text);
  } catch {
    return { message: text.slice(0, 500) };
  }
}

function importPrivateKey(pem: string): Promise<CryptoKey> {
  const normalizedPem = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(normalizedPem);
  const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));

  return crypto.subtle.importKey(
    "pkcs8",
    bytes.buffer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );
}

function base64UrlEncode(value: string): string {
  return base64UrlEncodeBytes(new TextEncoder().encode(value));
}

function base64UrlEncodeBytes(value: Uint8Array): string {
  let binary = "";
  for (const byte of value) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function readErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function readString(
  value: Record<string, unknown>,
  key: string,
): string | null {
  const candidate = value[key];
  return typeof candidate === "string" && candidate.trim()
    ? candidate.trim()
    : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
