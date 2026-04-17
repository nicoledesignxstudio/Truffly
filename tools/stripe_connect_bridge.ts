const bridgePort = parsePort(Deno.env.get("STRIPE_CONNECT_BRIDGE_PORT")) ?? 8788;
const appReturnUrl = requiredAbsoluteUrl(
  Deno.env.get("TRUFFLY_APP_RETURN_URL"),
  "TRUFFLY_APP_RETURN_URL",
);
const appRefreshUrl = requiredAbsoluteUrl(
  Deno.env.get("TRUFFLY_APP_REFRESH_URL"),
  "TRUFFLY_APP_REFRESH_URL",
);

type BridgeMode = "return" | "refresh";

Deno.serve({ port: bridgePort }, (request) => {
  const url = new URL(request.url);

  if (request.method === "GET" && url.pathname === "/healthz") {
    return new Response(
      JSON.stringify({
        ok: true,
        app_return_url: appReturnUrl,
        app_refresh_url: appRefreshUrl,
      }),
      {
        status: 200,
        headers: { "content-type": "application/json; charset=utf-8" },
      },
    );
  }

  if (request.method === "GET" && url.pathname === "/stripe/connect-return") {
    return redirectToApp({
      targetUrl: appReturnUrl,
      mode: "return",
      sourceUrl: url,
    });
  }

  if (request.method === "GET" && url.pathname === "/stripe/connect-refresh") {
    return redirectToApp({
      targetUrl: appRefreshUrl,
      mode: "refresh",
      sourceUrl: url,
    });
  }

  return new Response("Not found", { status: 404 });
});

function redirectToApp(args: {
  targetUrl: string;
  mode: BridgeMode;
  sourceUrl: URL;
}): Response {
  const target = new URL(args.targetUrl);
  const sourceParams = args.sourceUrl.searchParams;

  target.searchParams.set("stripe", args.mode);
  if (sourceParams.has("account")) {
    target.searchParams.set("account", sourceParams.get("account") ?? "");
  }
  if (sourceParams.has("error")) {
    target.searchParams.set("error", sourceParams.get("error") ?? "");
  }

  const escapedTarget = escapeHtml(target.toString());
  const title = args.mode === "return"
    ? "Returning to Truffly"
    : "Refreshing Stripe onboarding";
  const body = args.mode === "return"
    ? "Returning to Truffly so the app can verify your Stripe status."
    : "Reopening Truffly so a fresh Stripe onboarding link can be issued.";

  return new Response(
    `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${escapeHtml(title)}</title>
    <meta http-equiv="refresh" content="0;url=${escapedTarget}" />
  </head>
  <body>
    <p>${escapeHtml(body)}</p>
    <p><a href="${escapedTarget}">Open Truffly</a></p>
    <script>
      window.location.replace(${JSON.stringify(target.toString())});
    </script>
  </body>
</html>`,
    {
      status: 302,
      headers: {
        location: target.toString(),
        "content-type": "text/html; charset=utf-8",
        "cache-control": "no-store",
      },
    },
  );
}

function requiredAbsoluteUrl(value: string | undefined, envName: string): string {
  const normalized = value?.trim();
  if (!normalized) {
    throw new Error(`${envName} is required.`);
  }

  const parsed = new URL(normalized);
  if (
    parsed.protocol !== "https:" && parsed.protocol !== "http:" &&
    parsed.protocol !== "truffly:"
  ) {
    throw new Error(`${envName} must use https, http, or truffly scheme.`);
  }

  return parsed.toString();
}

function parsePort(value: string | undefined): number | null {
  const normalized = value?.trim();
  if (!normalized) return null;
  const parsed = Number.parseInt(normalized, 10);
  if (!Number.isFinite(parsed) || parsed < 1 || parsed > 65535) {
    throw new Error("STRIPE_CONNECT_BRIDGE_PORT must be a valid TCP port.");
  }
  return parsed;
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll("\"", "&quot;")
    .replaceAll("'", "&#39;");
}
