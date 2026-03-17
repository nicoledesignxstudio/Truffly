# Project Status - Truffly

Current phase: Flutter auth + onboarding implementation completed, marketplace/product areas still pending
Goal: Build MVP marketplace for truffles

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

## Database

* Migration file created for initial MVP schema
* PostgreSQL schema includes:
  * ENUM types
  * tables
  * relationships
  * constraints
  * indexes
  * RLS enablement and policies

Main entities currently present in schema:

* users
* shipping_addresses
* truffles
* truffle_images
* orders
* reviews
* favorites
* notifications
* seller_documents
* audit_logs

## Seed Data

* `seed.sql` created
* Local database can be populated with test users, truffles, orders and reviews

## Flutter + Supabase Integration

* `.env.local` loading added in Flutter bootstrap
* Environment validation for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
* Supabase initialized in `main.dart`
* App runs inside `ProviderScope`
* Supabase-backed startup/auth flow connected to router

## Flutter Project Architecture

Feature-first architecture is in place in `app/truffly_app/lib`.

Main areas already structured:

* `core/` for bootstrap, router, providers and theme
* `features/auth/`
* `features/onboarding/`
* `features/home/`
* placeholder feature roots for marketplace/product areas

The app currently uses:

* Riverpod for application state
* go_router for route-driven navigation
* Supabase Auth + database integration

## Bootstrap + Routing Foundation

Implemented and integrated:

* typed bootstrap state machine
* startup loading / error screens
* route-driven app entry
* bootstrap/auth redirect orchestration
* onboarding gating based on `public.users.onboarding_completed`
* auth state evaluation after bootstrap and after auth events

Current route behavior:

* unauthenticated -> login
* authenticated but unverified -> verify email
* authenticated, verified, onboarding incomplete -> onboarding
* authenticated and onboarding complete -> home

## Auth Feature

Auth MVP foundation is implemented with:

* login
* signup
* verify email
* forgot password
* reset password
* auth notifier state machine
* profile read for onboarding gating
* user-friendly error mapping

Implemented auth behavior:

* session restore on startup
* verified email gating
* onboarding-required gating
* password recovery support
* sign out and session refresh handling

## Onboarding Feature Implemented

The onboarding feature is no longer a placeholder. It now has dedicated domain, application, data and presentation layers under `features/onboarding/`.

Implemented onboarding architecture:

* `onboarding_notifier.dart` orchestrates:
  * path selection
  * step progression
  * per-step validation
  * full validation before submit
  * buyer submit
  * seller submit
  * notification choice state
* `onboarding_state.dart` stores:
  * local onboarding draft
  * current step index
  * active step list
  * validation failures
  * submit failure state
* `onboarding_step_definition.dart` and `onboarding_step_id.dart` define the flow catalog
* `onboarding_service.dart` provides:
  * buyer onboarding completion
  * seller onboarding submission
  * notification permission fallback flow

## Onboarding Entry + Navigation

Current onboarding entry behavior:

* app routes to `OnboardingScreen` when auth state is `AuthAuthenticatedOnboardingRequired`
* onboarding starts from role selection
* role selection is local-first and only commits path on `Next`
* once a path is selected, the dedicated onboarding flow screen renders the active step

Recent navigation hardening:

* stale in-memory onboarding state is reset when onboarding screen is first opened for an onboarding-required user
* the previous `PageView` + `PageController` synchronization layer was removed from onboarding flow rendering
* the flow now renders the current step directly from provider state, reducing desynchronization risk between state and displayed page

## Buyer Onboarding Flow

Buyer onboarding currently includes:

* role selection entry
* three buyer info pages
* name page
* buyer country / region page
* notifications page
* welcome page

Buyer onboarding persistence:

* buyer final submit updates `public.users`
* fields persisted:
  * `first_name`
  * `last_name`
  * `country_code`
  * `region`
  * `onboarding_completed = true`
* after persistence, auth state is refreshed so router can promote the user to app-ready flow

Buyer validation currently implemented:

* first name required and minimum length
* last name required and minimum length
* country required
* country format validation
* region required only when country is `IT`

## Seller Onboarding Flow

Seller onboarding currently includes:

* role selection entry
* four seller info pages
* name page
* seller region page
* seller documents page
* notifications page
* welcome page

Seller validation currently implemented:

* first name required and minimum length
* last name required and minimum length
* region required
* tesserino number required
* identity document required
* tesserino document required

## Seller Document Flow

Seller document capture is implemented in-app.

Current behavior:

* document selection is local-first during onboarding
* picker source options:
  * camera
  * gallery
  * cancel
* supported local formats:
  * PNG
  * JPG
  * JPEG
* local file checks:
  * path present
  * file exists
  * file not empty
* picker/runtime failures are mapped to localized UI errors
* cancel remains non-destructive
* document errors are tracked separately for identity document and tesserino document

Async hardening already added:

* `setState()` after dispose protections for async picker flows
* central error clearing helpers for document state

## Seller Submit Backend Integration

Seller onboarding final submit is connected to Supabase Edge Functions.

Client-side behavior:

* local document files are read at final submit time
* files are base64-encoded
* seller payload is sent through `supabase.functions.invoke('submit_seller_application')`
* successful response triggers auth refresh

Backend behavior in `supabase/functions/submit_seller_application/index.ts`:

* auth is validated through request bearer token
* current user row is loaded from `users`
* seller application is blocked if:
  * user missing
  * account inactive
  * onboarding already completed
  * seller status not allowed
* documents are decoded and uploaded into private `seller_documents` storage bucket
* `seller_documents` metadata is upserted
* `users` row is updated with:
  * first name
  * last name
  * country code forced to `IT`
  * region uppercased
  * tesserino number
  * `seller_status = 'pending'`
  * `onboarding_completed = true`
* notification insert and audit log insert are non-blocking side effects
* rollback logic exists for:
  * user row update
  * seller_documents metadata
  * uploaded storage objects

## Onboarding Error Mapping

Typed onboarding submission failures are implemented.

Current categories:

* network
* validation
* document upload
* server
* unimplemented
* unknown

Current mapping behavior:

* buyer onboarding maps through `ProfileService` auth/profile failures
* seller onboarding maps through edge function HTTP status + backend error codes
* seller validation-like backend errors are distinguished from generic server errors

## Onboarding Notifications Step

Notifications UI is implemented as a standalone onboarding step.

Current status:

* user can choose to enable notifications or continue without them
* notifier tracks:
  * notification choice
  * notification permission status
* real platform permission integration is not implemented yet
* current fallback result is a non-throwing denied result, so the step remains functional without native permission wiring

## Onboarding UI Status

Onboarding UI has been brought much closer to the auth visual language.

Implemented UI work:

* role selection screen aligned with auth look-and-feel
* left-aligned headers across onboarding pages
* shared auth-style spacing tokens
* shared auth-style radii and shadows
* auth-consistent CTA buttons
* auth-consistent text input styling
* unified onboarding progress indicator excluding notifications and welcome
* buyer/seller info pages
* buyer/seller form pages
* seller document upload cards
* localized bottom sheet for document source choice
* localized country/region selection with anchored menu-style dropdown

Recent UI refinements already applied:

* global auth radius increased from 25 to 30
* role cards height aligned to 60
* onboarding content kept top-aligned instead of vertically centered
* document cards compacted and refined
* seller document outer card border aligned with other inputs
* seller document empty state now uses document type label instead of generic “no file selected”

## Localization

Onboarding strings are localized through ARB files.

Updated localization coverage includes:

* role selection
* buyer/seller info pages
* name / country / region / seller documents
* submit errors
* notifications
* welcome pages
* document picker errors and actions

## Current Validation / Analysis Status

Verified in current codebase:

* `flutter analyze` clean after recent onboarding/auth UI and flow changes

Existing automated tests in repository still primarily cover:

* router redirects
* auth notifier
* auth validators
* bootstrap notifier
* startup gate

## Remaining Gaps / Known Limitations

The following items are still incomplete or still need stronger verification:

* no dedicated automated test coverage yet for onboarding notifier / onboarding flow UI
* notification permission step still uses fallback behavior instead of platform-native permission integration
* onboarding asset strategy currently relies on safe fallback rendering if onboarding images are missing
* manual end-to-end verification of the latest buyer flow progression fix is still recommended
* home / marketplace / orders / profile areas are still placeholders or only lightly wired compared to auth/onboarding

---

# Current Task

## Marketplace / Product Surface Still Pending

Auth and onboarding are now materially implemented.  
The next major product phase is the actual marketplace experience.

Planned next tasks:

* implement marketplace listing flow
* implement truffle detail screens
* replace placeholder home with real authenticated shell
* add profile view/editing beyond onboarding completion
* wire seller review/admin follow-up flows after seller application submission
* implement favorites / orders / profile feature surfaces
* add dedicated onboarding test coverage
