import { createClient } from "@supabase/supabase-js";

import {
  createSupabasePaymentStore,
  getRequestId,
  handleStripeWebhook,
  validateRuntimeSupabaseUrl,
} from "../_shared/stripe_payments.ts";

Deno.serve(async (request) => {
  const requestId = getRequestId(request);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeWebhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");

  if (!supabaseUrl || !supabaseServiceRoleKey || !stripeWebhookSecret) {
    return new Response(
      JSON.stringify({
        error: "webhook_unknown_error",
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
        error: "webhook_unknown_error",
        message: supabaseUrlValidationError,
        request_id: requestId,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  return await handleStripeWebhook({
    request,
    requestId,
    store: createSupabasePaymentStore(adminClient),
    webhookSecret: stripeWebhookSecret,
  });
});
