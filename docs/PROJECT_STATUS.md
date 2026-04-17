# Project Status - Truffly

Current phase: Core marketplace backend materially hardened, seller flows integrated, security phases 1-8 largely completed, Stripe integration not started yet
Goal: Build MVP truffle marketplace with production-grade backend foundations before enabling real payments

---

# Executive Summary

Truffly is no longer in an early MVP-backend state.

The project now has:

* authenticated Flutter app structure with onboarding, marketplace, seller publish flow and seller-managed listings
* Supabase schema with RLS, constrained write paths and service-owned flows
* hardened seller document storage and signed URL access
* robust DB invariants for orders and truffle availability
* atomic/idempotent order status transitions through SQL RPC + Edge Function
* audit/observability improvements with `request_id`
* first lifecycle/privacy controls for seller documents, notifications and audit minimization

Main strategic conclusion:

* backend security posture is good enough to begin Stripe integration in test mode
* backend is not yet ready for live money without a dedicated payment hardening phase

---

# Completed

## Project Setup

* Git repository initialized
* GitHub repository created
* Flutter project created
* Initial Flutter app runs successfully

## Supabase Setup

* Supabase project created
* Supabase CLI installed
* Supabase initialized locally
* Local Supabase stack configured for development

## Database Schema

Schema is materially established and no longer just a draft MVP schema.

Current main entities:

* `users`
* `shipping_addresses`
* `truffles`
* `truffle_images`
* `publish_truffle_requests`
* `orders`
* `reviews`
* `favorites`
* `notifications`
* `seller_documents`
* `audit_logs`

Current schema capabilities include:

* ENUM types for user/seller/truffle/order domains
* constraints and indexes for integrity/performance
* RLS enabled on protected tables
* storage buckets and policies for private assets
* RPCs for shipping addresses and other constrained operations
* security comments and lifecycle markers for future anonymization work

## Seed Data

* `seed.sql` aligned to current DB invariants
* local reset/seed supports users, truffles, orders and reviews under current constraints
* seller/truffle/order seed transitions were updated to comply with new status invariants

## Flutter + Supabase Integration

Implemented and working:

* `.env.local` loading in Flutter bootstrap
* environment validation for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
* Supabase initialization in app startup
* Riverpod application shell
* route-aware auth/bootstrap flow

## Flutter Project Architecture

Feature-first architecture remains in place in `app/truffly_app/lib`.

Main areas already structured:

* `core/`
* `features/auth/`
* `features/onboarding/`
* `features/home/`
* `features/marketplace/`
* `features/truffle/`
* `features/orders/`
* `features/account/`

Main framework choices currently in use:

* Riverpod
* go_router
* Supabase Auth
* Supabase Postgres + RLS
* Supabase Edge Functions

## Bootstrap + Routing Foundation

Implemented and integrated:

* typed bootstrap state machine
* startup loading / error screens
* route-driven app entry
* bootstrap/auth redirect orchestration
* onboarding gating based on `public.users.onboarding_completed`
* auth state evaluation after bootstrap and auth events

## Auth Feature

Implemented:

* login
* signup
* verify email
* forgot password
* reset password
* session restore
* onboarding gating
* password recovery support
* sign out / session refresh handling

Security hardening already completed at repo level:

* fail-closed account/session handling
* hardened callback/deep-link behavior
* safer routing around auth state transitions

## Onboarding Feature

Buyer and seller onboarding are implemented with dedicated domain/application/data/presentation layers.

Implemented:

* role-based onboarding paths
* buyer onboarding persistence to `public.users`
* seller onboarding submit through Edge Function
* seller document capture and validation
* localized onboarding flow
* notifications step fallback flow

## Seller Document Flow

Seller document handling is materially implemented and hardened.

Current behavior:

* documents uploaded only through backend-controlled seller submit flow
* private `seller_documents` bucket
* owner/admin gated access
* signed URL access through dedicated Edge Function
* document access events now auditable
* lifecycle markers added for review outcome / retention / purge readiness

Privacy/lifecycle improvements now present:

* `seller_documents.review_outcome`
* `seller_documents.reviewed_at`
* `seller_documents.documents_retention_expires_at`
* `seller_documents.documents_purged_at`
* duplicated `tesserino_number` in `seller_documents` minimized after approval/rejection

## Marketplace Listing

Marketplace is implemented beyond placeholder state.

Current surface includes:

* authenticated listing page
* debounced search
* type quick filters
* filter sheet for quality/price/weight/harvest date/region
* pagination/load more
* loading skeletons
* empty/error/retry states
* favorite toggle wiring
* seller publish CTA gating

## Truffle Detail / Images

Current behavior:

* private storage image resolution through signed URLs
* storage path normalization
* Android emulator URL normalization where needed

## Seller Publish Flow

Seller publish is materially wired end-to-end.

Implemented:

* publish form page
* image picking and validation
* quality/type/pricing/shipping/region/harvest date inputs
* confirmation dialog
* Edge Function-backed publish flow
* publish request idempotency via `publish_truffle_requests`

Seller publish access model:

* only approved sellers
* Stripe account presence required at publish gate
* service-owned backend mutation path

## Seller Managed Truffles

Seller listing management is aligned to the new truffle status model.

Current seller-visible statuses:

* `publishing`
* `active`
* `reserved`
* `sold`
* `expired`

Implemented:

* seller client support for `reserved`
* clear seller distinction between `reserved` and `sold`
* fail-closed handling for unknown statuses
* seller tabs/cards updated
* localization for `publishing` and `reserved`
* basic widget/domain test coverage for seller status presentation

## Orders Domain And Status Handling

This area is now one of the strongest parts of the backend.

Implemented:

* DB invariants between `orders` and `truffles`
* `reserved` introduced in `truffle_status_enum`
* partial unique indexes to enforce one open/completed order shape per truffle
* triggers to keep truffle state derived from domain facts
* DB enforcement of allowed order status transitions
* atomic SQL RPC for `update_order_status`
* idempotent replay handling
* race/conflict protection via locked/current-state evaluation

Supported order transitions at DB level:

* `paid -> shipped`
* `paid -> cancelled`
* `shipped -> completed`

## Shipping Addresses

Shipping address management is implemented through SQL RPCs.

Current capabilities:

* save/update/delete through constrained backend logic
* one default address per user
* RLS ownership enforcement
* addresses ready for future checkout flow

## Views / RPC / SQL Exposure Hardening

Security hardening phases already completed:

* exposed views moved to `security_invoker = true` where needed
* execute privileges tightened on SQL functions / RPC / helpers
* helper and trigger functions reduced to intended callers
* sensitive views and RPC surfaces reviewed for RLS consistency

## Audit / Observability

Audit quality is materially improved.

Implemented:

* `request_id` propagation across main Edge Functions
* normalized audit metadata with `request_id`, `result`, `action`
* order transition audits including idempotent replays
* document access auditing
* seller application auditing
* truffle delete auditing
* audit index on `metadata->>'request_id'`

Console logging has been hardened to reduce sensitive output:

* no signed URL logging
* no document base64 logging
* no full payload logging in sensitive paths
* errors normalized toward request id / code / message patterns

## Privacy / Retention / Lifecycle

Initial privacy/lifecycle phase is implemented.

Now present:

* seller document lifecycle markers
* minimization of duplicated PII in seller document metadata
* notification purge helper
* minimized order audit tracking metadata
* schema comments clarifying anonymization direction for accounts

Important current design note:

* `users.deleted_at` is only a soft-delete marker
* historical user-linked data means future account deletion will require anonymization flows rather than hard deletes

## Localization

Localization coverage includes:

* auth
* onboarding
* marketplace
* publish flow
* shipping addresses
* seller managed truffle statuses including `publishing` and `reserved`

## Local Runtime / Development Hardening

Implemented:

* Android emulator host normalization
* local Supabase URL validation in sensitive functions
* reduced risk of starting Edge Functions with incorrect Flutter app env assumptions

---

# Security Posture Summary

## Current Security Assessment

Current backend/app security posture is **good for pre-production integration work**.

Approximate expert assessment:

* Auth / session handling: strong
* RLS / authorization model: strong
* Storage / seller document protection: strong
* DB integrity / order concurrency safety: very strong
* Audit / observability: good
* Privacy / retention / lifecycle: good but not complete
* Payment security readiness: not yet complete

## Current Recommendation On Stripe

It is now reasonable to proceed with:

* Stripe integration in test mode
* payment architecture work
* checkout / PaymentIntent / webhook implementation phase

It is **not yet recommended** to enable live money in production without a dedicated payment hardening phase covering:

* Stripe webhooks
* signature verification
* payment event idempotency
* reconciliation tooling
* refund/dispute operational paths
* payment-specific observability and runbooks

---

# Current Validation / Verification Status

Verified at code/repo level:

* security migrations through Phase 8 are present in repo
* main sensitive Edge Functions have been hardened and aligned on `request_id`
* seller and order domain logic is materially stronger than earlier project phases

Still recommended:

* re-run full local DB reset after the latest migration sequence changes
* run targeted end-to-end manual verification for:
  * seller onboarding submit
  * document signed URL access
  * publish truffle flow
  * delete truffle flow
  * update order status flow

Automated coverage still remains lighter than desired for backend-sensitive flows.

---

# Remaining Gaps / Known Limitations

The following items are still incomplete or intentionally deferred:

* no production-ready Stripe payment flow yet
* no Stripe webhook implementation yet
* no reconciliation/admin tooling for payments yet
* no full account anonymization flow yet
* no storage purge job yet for seller documents after retention expiry
* no formalized retention policy for `audit_logs`
* no advanced alerting/dashboard layer beyond current audit trail
* automated tests are still thinner than ideal for:
  * onboarding submit backend path
  * publish flow backend path
  * seller document access flow
  * order status RPC edge cases

---

# Current Task Direction

## Recommended Next Phase

The most sensible next phase is:

* start Stripe integration in test mode
* keep security standards already established
* add payment-specific hardening before any live rollout

Recommended concrete next tasks:

* implement Stripe PaymentIntent creation flow
* implement verified/idempotent Stripe webhook handling
* define payment-to-order reconciliation logic
* add payment incident runbooks and observability hooks
* add backend-focused tests around payment + order interaction
* implement seller document storage purge job
* plan account anonymization workflow
