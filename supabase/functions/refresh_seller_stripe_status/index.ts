import { createClient } from "@supabase/supabase-js";

import {
  getRequestId,
  validateRuntimeSupabaseUrl,
} from "../_shared/stripe_payments.ts";
import {
  createStripeConnectGateway,
  createSupabaseSellerStripeStore,
  handleRefreshSellerStripeStatus,
  resolveAuthenticatedUser,
} from "../_shared/stripe_connect.ts";

Deno.serve(async (request) => {
  const requestId = getRequestId(request);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const authHeader = request.headers.get("Authorization");

  if (
    !supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey ||
    !stripeSecretKey
  ) {
    return new Response(
      JSON.stringify({
        error: "seller_stripe_runtime_error",
        message: "Missing runtime configuration.",
        request_id: requestId,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  const supabaseUrlValidationError = validateRuntimeSupabaseUrl(supabaseUrl);
  if (supabaseUrlValidationError != null) {
    return new Response(
      JSON.stringify({
        error: "seller_stripe_runtime_error",
        message: supabaseUrlValidationError,
        request_id: requestId,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  const authenticatedUser = await resolveAuthenticatedUser({
    supabaseUrl,
    supabaseAnonKey,
    authHeader,
  });

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  return await handleRefreshSellerStripeStatus({
    request,
    requestId,
    authenticatedUserId: authenticatedUser.id,
    store: createSupabaseSellerStripeStore(adminClient),
    stripeGateway: createStripeConnectGateway(fetch, stripeSecretKey),
  });
});
