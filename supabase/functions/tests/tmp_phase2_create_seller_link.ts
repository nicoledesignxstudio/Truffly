import { createClient } from "@supabase/supabase-js";
import {
  createStripeConnectGateway,
  createSupabaseSellerStripeStore,
  handleCreateSellerStripeAccountLink,
} from "../_shared/stripe_connect.ts";

const supabaseUrl =
  Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
const stripeSecretKey = requiredEnv("STRIPE_SECRET_KEY");
const sellerId = Deno.env.get("SELLER_ID")?.trim() ??
  "22222222-2222-2222-2222-222222222222";
const sellerEmail = Deno.env.get("SELLER_EMAIL")?.trim() ?? "seller1@test.com";
const returnUrl = Deno.env.get("STRIPE_CONNECT_RETURN_URL")?.trim() ??
  "https://wise-regions-beg.loca.lt/stripe/connect-return";
const refreshUrl = Deno.env.get("STRIPE_CONNECT_REFRESH_URL")?.trim() ??
  "https://wise-regions-beg.loca.lt/stripe/connect-refresh";

const admin = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

const { error: resetError } = await admin.from("users").update({
  stripe_account_id: null,
  stripe_details_submitted: false,
  stripe_charges_enabled: false,
  stripe_payouts_enabled: false,
  stripe_requirements_pending: true,
  stripe_onboarding_completed_at: null,
  stripe_ready_at: null,
}).eq("id", sellerId);

if (resetError) throw resetError;

const store = createSupabaseSellerStripeStore(admin);
const gateway = createStripeConnectGateway(fetch, stripeSecretKey);
const response = await handleCreateSellerStripeAccountLink({
  request: new Request("http://localhost/create_seller_stripe_account_or_link", {
    method: "POST",
  }),
  requestId: "req-phase2-playwright-link",
  authenticatedUserId: sellerId,
  authenticatedUserEmail: sellerEmail,
  accountLinkReturnUrl: returnUrl,
  accountLinkRefreshUrl: refreshUrl,
  store,
  stripeGateway: gateway,
});

console.log(await response.text());

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`${name} is required.`);
  }
  return value;
}
