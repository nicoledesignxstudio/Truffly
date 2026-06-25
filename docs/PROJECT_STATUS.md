# Project Status - Truffly

Snapshot date: 2026-05-09
Environment analyzed: local repo (`Flutter app + Supabase local stack + Stripe test integration code`)

---

# Executive Summary

Truffly is no longer just an MVP skeleton.

Today the repository already contains:

* a structured Flutter app with auth, onboarding, home, marketplace, seller area, checkout, orders, guides and account pages
* a substantial Supabase backend with migrations, RLS, protected views, RPCs and Edge Functions
* an end-to-end Stripe test-mode architecture for buyer payments and seller Connect onboarding
* financial/order lifecycle automation for refunds, payouts, auto-completion and retry flows

Main conclusion:

* the product is materially ahead of the previous project status document
* Stripe integration is already started and broadly wired in both Flutter and Supabase
* the project is still not production-ready because several UX/product surfaces remain incomplete and the whole stack is still configured around local/provisional operation

---

# Current State

## Flutter App

Implemented in app code:

* email/password signup, login, verify email, forgot password, reset password, session restore and sign out
* startup/bootstrap gate with route-aware auth redirection
* buyer and seller onboarding flows
* home screen with buyer/seller variants
* marketplace listing with search, filters, pagination and favorites
* truffle detail page with seller preview and checkout entry
* checkout page with shipping address selection and Stripe Payment Sheet
* orders list/detail with buyer and seller actions
* seller publish flow
* seller managed truffles page
* sellers directory
* seller public profile page
* truffle guides listing and detail pages
* account details, favorites, shipping addresses, support, settings, privacy policy and terms pages
* Italian/English localization across the main flows

Known incomplete or placeholder Flutter surfaces:

* Google sign-in is hidden/not wired in the current auth flow
* account payments page is still a placeholder
* notification permission request in onboarding is still a fallback/mock implementation, not a real platform integration
* push notification delivery still needs real Firebase/staging validation

Implemented but worth validating in staging:

* notifications inbox is implemented and reachable from account/home flows
* buyer review creation after completed orders is implemented
* profile image upload is implemented against Supabase Storage
* account deletion/anonymization is implemented through an authenticated Edge Function

## Supabase Backend

Implemented in backend code and migrations:

* local Supabase stack configuration
* full schema for users, shipping addresses, truffles, truffle images, publish requests, orders, reviews, favorites, notifications, seller documents, audit logs, payment attempts, webhook events and financial operations
* RLS policies on protected tables
* protected/public-safe views for marketplace, seller cards, seller profile and current-user order details
* RPCs for enum access, shipping addresses, order transitions and payment-attempt-to-order creation
* audit logging with `request_id`
* privacy/lifecycle helpers for notifications and seller documents
* seller document storage protection with signed URL retrieval through an Edge Function
* publish flow with staging bucket, validation, idempotency and cleanup paths
* order invariants and atomic status transitions
* Stripe readiness gating on marketplace visibility and seller publishing

## Stripe Integration

Stripe is already materially integrated.

Implemented:

* `flutter_stripe` initialized in app startup
* Stripe Payment Sheet in checkout
* Edge Function `create_payment_intent`
* Edge Function `finalize_payment_attempt`
* Stripe webhook endpoint with signature verification
* payment attempt persistence and idempotency
* order creation from successful payment attempts
* seller Stripe Connect Express onboarding
* seller Stripe status refresh and readiness mirroring on `users`
* payout release flow via Stripe transfers
* refund flow via Stripe refunds
* retry flow for failed financial operations
* scheduled job SQL for:
  * auto-complete shipped orders
  * auto-cancel unshipped paid orders
  * retry failed financial operations

Important nuance:

* the codebase is designed around Stripe test/integration readiness, but production operations still need real secrets, hosted callbacks, webhook setup, cron installation and rollout hardening

## Orders / Financial Lifecycle

Implemented:

* buyer can confirm receipt
* seller can mark as shipped with tracking code
* seller can cancel a paid order before shipment
* successful completion can trigger seller payout release
* cancellation can trigger refund processing
* cron-style functions handle:
  * refund + cancel after 48h if seller does not ship
  * reminder after 7 days from shipment
  * auto-complete after reminder window
  * payout release after auto-completion

## Tests / Verification

Present in repo:

* Flutter tests for auth, startup, routing, account details, shipping addresses, home, marketplace filters, guides, orders and seller status presentation
* Deno tests for Stripe payments, Stripe Connect and order financial flows
* local validation scripts for Stripe phases

Current limitation:

* coverage exists, but it is still not broad enough to treat the app as production-hardened end to end

---

# Important Gaps

## Product / UX Gaps

The main product-level gaps still visible in the codebase are:

* no real Google authentication flow
* no real push notification delivery validation on staging/production
* no real payment methods management page in account
* no in-app admin/reviewer tooling for seller approval and seller document review

## Legacy Placeholder Routes Audit

The following placeholder pages are present in the tree but are not reachable from the current router/UI:

* `seller_profile_placeholder_page`
* `account_destination_placeholder_page`
* `truffle_guide_placeholder_page`

Why they remain:

* `app_router.dart` routes to the real pages instead of these placeholders
* the account guide destination redirects to the real guides route
* there are no current UI entry points that reference the placeholder widgets
* they are safe legacy artifacts and can be removed in a later cleanup pass if desired

## Technical / Operational Gaps

The main technical gaps before production are:

* current workflow is still centered on local Supabase and local env files
* production Stripe callback URLs and secrets are still example/provisional in repo templates
* scheduled Edge jobs are prepared via SQL script but not guaranteed installed in a real hosted environment
* push notification config still needs real Firebase/staging validation
* there is no evidence of CI/CD, release pipeline, staging environment discipline or production observability setup
* legal/compliance/ops flows are still mostly represented as static pages or comments rather than complete operational systems

---

# Deployment Readiness

## What Looks Ready Enough For The Next Phase

The following areas look solid enough to continue building on:

* auth and route gating foundation
* marketplace read models
* seller onboarding submission backend
* seller Stripe onboarding base flow
* checkout + payment intent orchestration
* order/refund/payout domain modeling
* Supabase security baseline

## What Prevents A Safe Production Launch Today

The following areas still block a confident public launch:

* incomplete user-facing features in account/auth/notifications/reviews
* missing real production infrastructure and environment rollout
* missing admin/reviewer operational tooling
* incomplete production observability and incident procedures
* incomplete account/privacy lifecycle implementation
* insufficient evidence of full end-to-end production validation on hosted Supabase + Stripe

---

# TODO - Missing Product Work

* wire Google authentication or keep it hidden until it is ready
* validate push notification permissions and delivery integration on staging
* replace the account payments placeholder with a real payments area
* add admin/reviewer tooling for seller application approval/rejection and seller document review
* add explicit surfaces for seller payout/refund visibility if needed in the account/order UX
* review whether buyer-facing support, dispute and refund communication pages need dedicated product flows instead of static destinations

# TODO - Work Needed To Bring The App Online

* provision a hosted Supabase project and migrate the full local schema there
* configure production environment variables for Flutter and all Edge Functions
* configure real Stripe test/live projects, keys, webhook secret and callback URLs
* deploy all required Edge Functions:
  * `create_payment_intent`
  * `finalize_payment_attempt`
  * `stripe_webhook`
  * `create_seller_stripe_account_or_link`
  * `refresh_seller_stripe_status`
  * `update_order_status`
  * `publish_truffle`
  * `submit_seller_application`
  * `auto_complete_orders`
  * `cancel_unshipped_orders`
  * `retry_financial_operations`
* install scheduled jobs from `supabase/scripts/install_scheduled_edge_jobs.sql` in the hosted environment
* verify Storage buckets, policies and signed URL flows on hosted Supabase
* replace all local/dev redirect assumptions with production app/web deep links
* prepare Android/iOS production configuration for Stripe, package ids, merchant identifiers and release signing
* define a staging environment and run full hosted end-to-end tests for auth, onboarding, publish, checkout, webhook, refund and payout flows
* add production monitoring/alerting for Edge Functions, Stripe webhooks, failed financial operations and cron jobs
* define manual operations and incident runbooks for seller approval, refunds, payout failures and webhook failures
* complete legal/compliance readiness:
  * privacy policy and terms final review
  * seller verification operational policy
  * retention/anonymization policy
  * payment/refund support process
* set up CI/CD or at least a repeatable release/deploy checklist
* execute a production-readiness pass on security, secrets handling and rollback procedures
