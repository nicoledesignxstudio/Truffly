# Supabase Production Runbook

This runbook prepares a new Supabase production project without reusing staging
state and without committing secrets.

## Current Inventory

- Supabase local config: `supabase/config.toml` is local-dev oriented. It has
  `project_id = "Truffly"`, local ports, local auth URLs, and `db.seed.enabled = true`.
  Do not use `supabase db reset` against production.
- Migrations: production schema, RLS, storage buckets, functions/RPCs, views,
  Stripe payment tables, order lifecycle helpers, push outbox, reviews, privacy
  helpers, and seller/admin approval support live under `supabase/migrations`.
- Seed data: `supabase/seed.sql` and `supabase/seeds/truffle_guides.sql` contain
  test users, test Stripe account IDs, sample truffles, orders, reviews, and guides.
  Do not apply seed data to production. The guide rows are also covered by a
  migration, so production does not need seeds.
- Storage buckets are created by migrations:
  `truffle_images` public, `truffle_images_staging` private,
  `seller_documents` private, and `profile_images` public.
- RLS/policies are migration-managed for application tables and storage objects.
- Flutter runtime config uses `--dart-define` through `Env` and `RuntimeConfig`.
  There is no runtime Supabase project ref hardcoded in the Flutter app.
- Edge Function secrets are read from Supabase function secrets. No real secrets
  should be committed.

## Production Project Setup

1. Create a new Supabase project in the Dashboard.
2. Record the project ref as `<PROD_PROJECT_REF>`.
3. Record API values as `<PROD_SUPABASE_URL>`,
   `<PROD_SUPABASE_ANON_KEY>`, and `<PROD_SERVICE_ROLE_KEY>`.
4. Configure Auth URL settings before app smoke tests.
5. Link the local repo to production only when ready to deploy production.
6. Push migrations, never seed data.
7. Set Edge Function secrets.
8. Deploy Edge Functions.
9. Configure Stripe webhook endpoint against production.
10. Install scheduled jobs with replaced placeholders.

## Supabase CLI Commands

Login:

```bash
npx supabase login
```

Link production:

```bash
npx supabase link --project-ref <PROD_PROJECT_REF>
```

Confirm the link before pushing:

```bash
npx supabase projects list
npx supabase migration list
```

Push database migrations:

```bash
npx supabase db push
```

Do not run:

```bash
npx supabase db reset
```

Set production Edge Function secrets:

```bash
npx supabase secrets set \
  SUPABASE_URL=<PROD_SUPABASE_URL> \
  SUPABASE_ANON_KEY=<PROD_SUPABASE_ANON_KEY> \
  SUPABASE_SERVICE_ROLE_KEY=<PROD_SERVICE_ROLE_KEY> \
  STRIPE_SECRET_KEY=<PROD_STRIPE_SECRET_KEY> \
  STRIPE_WEBHOOK_SECRET=<PROD_STRIPE_WEBHOOK_SECRET> \
  CRON_SECRET=<PROD_CRON_SECRET> \
  FIREBASE_SERVICE_ACCOUNT_JSON='<PROD_FIREBASE_SERVICE_ACCOUNT_JSON>'
```

Set production Connect callback config when the URLs are final:

```bash
npx supabase secrets set \
  STRIPE_CONNECT_RETURN_URL=https://example.com/truffly/stripe/connect-return \
  STRIPE_CONNECT_REFRESH_URL=https://example.com/truffly/stripe/connect-refresh
```

List secrets without revealing values:

```bash
npx supabase secrets list
```

Deploy authenticated app/admin functions:

```bash
npx supabase functions deploy approve_seller
npx supabase functions deploy create_payment_intent
npx supabase functions deploy create_review
npx supabase functions deploy create_seller_stripe_account_or_link
npx supabase functions deploy delete_account
npx supabase functions deploy delete_truffle
npx supabase functions deploy finalize_payment_attempt
npx supabase functions deploy get_seller_application_documents
npx supabase functions deploy get_seller_document_signed_url
npx supabase functions deploy list_seller_applications
npx supabase functions deploy publish_truffle
npx supabase functions deploy refresh_seller_stripe_status
npx supabase functions deploy reject_seller
npx supabase functions deploy submit_seller_application
npx supabase functions deploy update_order_status
```

Deploy Stripe webhook and cron functions with JWT verification disabled:

```bash
npx supabase functions deploy stripe_webhook --no-verify-jwt
npx supabase functions deploy auto_complete_orders --no-verify-jwt
npx supabase functions deploy auto_create_missing_reviews --no-verify-jwt
npx supabase functions deploy cancel_unshipped_orders --no-verify-jwt
npx supabase functions deploy cleanup_unverified_accounts --no-verify-jwt
npx supabase functions deploy dispatch_notification_pushes --no-verify-jwt
npx supabase functions deploy retry_financial_operations --no-verify-jwt
```

Deploy `send_test_push` only for staging/manual diagnostics. Avoid deploying it
to production unless there is an explicit operational need:

```bash
npx supabase functions deploy send_test_push --no-verify-jwt
```

## Stripe Webhook

Create a Stripe webhook endpoint:

```text
<PROD_SUPABASE_URL>/functions/v1/stripe_webhook
```

Set the resulting signing secret as `<PROD_STRIPE_WEBHOOK_SECRET>`.

Enable these Stripe events for the production endpoint:

- `payment_intent.succeeded`
- `payment_intent.payment_failed`
- `payment_intent.canceled`
- `account.updated`

The current handler ignores unsupported event types.

## Cron Jobs

Install cron from `supabase/scripts/install_scheduled_edge_jobs.sql` in the
production SQL editor only after replacing:

- `<PROD_PROJECT_REF>`
- `<PROD_CRON_SECRET>`

Installed jobs:

- `truffly-dispatch-notification-pushes`: every minute.
- `truffly-auto-complete-orders`: every 30 minutes.
- `truffly-cancel-unshipped-orders`: every 30 minutes.
- `truffly-retry-financial-operations`: every 15 minutes.
- `truffly-auto-create-missing-reviews`: daily at 03:00 UTC.
- `truffly-cleanup-unverified-accounts`: daily at 03:30 UTC.

After installation, run `supabase/scripts/diagnose_order_lifecycle_cloud.sql`
in the SQL editor to verify job definitions and recent HTTP responses.

## Supabase Dashboard Checklist

- API: production URL and anon key match Flutter `--dart-define` values.
- Auth URL Configuration: Site URL and redirect allow-list include the final
  web fallback and `truffly://**`; no localhost remains.
- Auth email: production SMTP/provider and confirmation templates are configured.
- Database: all migrations show applied; `seed.sql` was not executed.
- Storage: buckets exist with expected visibility:
  `truffle_images` public, `profile_images` public,
  `truffle_images_staging` private, `seller_documents` private.
- Storage policies: owner/admin/service policies exist for private buckets.
- Edge Functions: all required functions are deployed.
- Edge Function secrets: required names exist for production.
- Cron: pg_cron jobs exist, active, and point to `<PROD_PROJECT_REF>`.
- Logs: no repeated 401, 404, or missing-secret errors.
- Stripe: webhook endpoint points to production Supabase and uses live mode
  when production payments are enabled.
- Firebase: service account JSON belongs to the production Firebase project.

## Production-Safe Smoke Tests

- Auth: sign up, email verification, login, logout, password reset deep link.
- Buyer onboarding: complete profile and region/country flow.
- Seller onboarding: submit seller application with safe test documents.
- Admin approval: approve and reject separate test seller applications.
- Stripe onboarding: use test mode first, then live mode only with a real
  controlled seller account when ready.
- Publish truffle: publish a low-risk listing from an approved seller.
- Checkout: create payment intent and complete a controlled purchase.
- Webhook: verify payment webhook creates/updates order and records event id.
- Mark shipped: seller adds tracking and order becomes shipped.
- Confirm delivery: buyer completes order and review flow becomes available.
- Refund: test a controlled refund/cancel path before any real customer traffic.
- Payout/transfer: verify financial operation rows and retry path; confirm
  Stripe transfer/payout state in Dashboard.
- Push notification: register device token and trigger a real order notification.
- Account deletion/deactivation: delete/deactivate a test buyer and seller, then
  verify anonymization/retention behavior.

## Residual Risks Before Internal Testing

- `supabase/config.toml` contains local auth URLs and seed config; this is safe
  for local development but production settings must be applied in Dashboard.
- `seed.sql` contains test accounts, sample orders, and `acct_test_*` values.
  Running it in production would pollute live data.
- `send_test_push` has `verify_jwt = false` with internal auth paths. Keep it
  staging-only unless explicitly needed in production.
- Live Stripe Connect requires real account/onboarding readiness. Test-mode
  success does not prove live payout eligibility.
- Auth email deliverability and deep links must be verified on installed builds,
  not only emulator/dev runs.
- Cron functions depend on `<PROD_CRON_SECRET>` matching both Supabase secrets
  and SQL job headers.
- Firebase push depends on the service account matching the app package and
  uploaded production build credentials.
