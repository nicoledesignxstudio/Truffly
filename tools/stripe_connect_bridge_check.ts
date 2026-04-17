const bridgeBaseUrl = normalizeBaseUrl(
  Deno.env.get("STRIPE_CONNECT_BRIDGE_BASE_URL") ?? "http://127.0.0.1:8788",
);

type HealthResponse = {
  ok: boolean;
  app_return_url: string;
  app_refresh_url: string;
};

async function main() {
  const health = await fetchJson<HealthResponse>(`${bridgeBaseUrl}/healthz`);
  const returnCheck = await checkRedirect("return");
  const refreshCheck = await checkRedirect("refresh");

  console.log(JSON.stringify({
    bridge_base_url: bridgeBaseUrl,
    health,
    return_check: returnCheck,
    refresh_check: refreshCheck,
  }, null, 2));
}

async function checkRedirect(mode: "return" | "refresh") {
  const response = await fetch(
    `${bridgeBaseUrl}/stripe/connect-${mode}?account=acct_test_validation&error=none`,
    {
      method: "GET",
      redirect: "manual",
    },
  );

  const location = response.headers.get("location");
  const parsedLocation = location == null ? null : new URL(location);

  return {
    status: response.status,
    location,
    stripe_param: parsedLocation?.searchParams.get("stripe") ?? null,
    account_param: parsedLocation?.searchParams.get("account") ?? null,
    error_param: parsedLocation?.searchParams.get("error") ?? null,
    path: parsedLocation?.pathname ?? null,
  };
}

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request failed for ${url}: ${response.status}`);
  }
  return await response.json() as T;
}

function normalizeBaseUrl(value: string): string {
  const parsed = new URL(value.trim());
  const pathname = parsed.pathname.replace(/\/+$/, "");
  parsed.pathname = pathname === "" ? "/" : pathname;
  return parsed.toString().replace(/\/$/, "");
}

if (import.meta.main) {
  await main();
}
