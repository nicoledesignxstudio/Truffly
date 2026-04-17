import { createClient } from "@supabase/supabase-js";

import {
  createStripeGateway,
  createSupabasePaymentStore,
  getRequestId,
  handleCreatePaymentIntent,
  validateRuntimeSupabaseUrl,
} from "../_shared/stripe_payments.ts";

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
        error: "payment_unknown_error",
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
        error: "payment_unknown_error",
        message: supabaseUrlValidationError,
        request_id: requestId,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  let authenticatedUserId: string | null = null;
  if (authHeader != null) {
    const authClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: { Authorization: authHeader },
      },
    });

    const {
      data: { user },
    } = await authClient.auth.getUser();
    authenticatedUserId = user?.id ?? null;
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  return await handleCreatePaymentIntent({
    request,
    requestId,
    authenticatedUserId,
    store: createSupabasePaymentStore(adminClient),
    stripeGateway: createStripeGateway(fetch, stripeSecretKey),
  });
});
