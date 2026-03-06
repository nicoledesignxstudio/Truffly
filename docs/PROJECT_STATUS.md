# Project Status - Truffly

Current phase: Flutter startup architecture completed (Riverpod + go_router)
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
* Local Supabase stack running

## Database

* Migration file created: `init_schema.sql`

Initial MVP PostgreSQL schema generated in migration:

* ENUM types
* Tables
* Relationships
* Constraints
* Indexes
* RLS enabled on all tables
* RLS policies generated

Main entities implemented:

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
* Local database populated with test users, truffles, orders and reviews

## Flutter + Local Supabase Integration

* Added `.env.local` loading in Flutter bootstrap
* Added environment validation for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
* Initialized Supabase in `main.dart` using local env config
* Replaced default counter app with dedicated Health screen
* Added connection test from Flutter app to local Supabase (`/auth/v1/health`)
* Added session status visibility in Health screen (`none` / `active`)

## Flutter Project Architecture (Feature-First)

Completed architectural refactor in `app/truffly_app/lib` with a production-ready base structure.

What was done:

* Introduced clear app entry separation:
  * `main.dart` kept minimal for bootstrap only (bindings, dotenv, Env validation, Supabase init, `runApp`)
  * `app.dart` as root app composition (`MaterialApp`)
* Reorganized code into feature-first folders:
  * `core/` for cross-cutting concerns
  * `features/` for domain features (`auth`, `home`, `startup`, `marketplace`, `orders`, `profile`, `truffle`)
  * `shared/widgets/` for reusable UI primitives
* Added dedicated startup architecture folders:
  * `core/bootstrap/domain`
  * `core/bootstrap/application`
  * `core/bootstrap/data`
  * `core/router`
* Removed ambiguous/redundant structure:
  * removed generic `services/` root folder
  * removed `shared/components/` (kept `shared/widgets/` only)
  * removed legacy startup/health flow from main app path

## Riverpod Foundation Integration

Introduced Riverpod as application state foundation before building auth and feature flows.

What was done:

* Added `flutter_riverpod` dependency
* Updated `main.dart` to run app inside `ProviderScope`
* Added centralized dependency providers in `core/providers/app_providers.dart`:
  * `supabaseClientProvider`
  * `backendHealthServiceProvider`
  * `authSessionServiceProvider`
* Removed startup dependency creation from widgets
* Kept bootstrap orchestration in dedicated application layer (`Notifier`)

## Bootstrap Hardening (Final Startup Flow)

Refactored startup flow into a type-safe state machine with strict separation of concerns.

What was done:

* Added `core/bootstrap/domain/bootstrap_state.dart` (sealed states):
  * `BootstrapInitial`
  * `BootstrapLoading`
  * `BootstrapAuthenticated`
  * `BootstrapUnauthenticated`
  * `BootstrapError`
* Added `core/bootstrap/domain/bootstrap_failure.dart` (typed failures):
  * `BackendUnavailableFailure`
  * `NetworkTimeoutFailure`
  * `ConfigFailure`
  * `InvalidSessionFailure`
  * `UnknownBootstrapFailure`
* Added `core/bootstrap/data/backend_health_service.dart`
  * health-check endpoint: `${SUPABASE_URL}/auth/v1/health`
  * typed result model instead of boolean
  * explicit mapping for unavailable backend, timeout, network, config, unknown
* Added `core/bootstrap/data/auth_session_service.dart`
  * dedicated auth session status read/validation
* Added `core/bootstrap/application/bootstrap_notifier.dart`
  * explicit startup entry (`startBootstrap`)
  * retry flow (`retryBootstrap`)
  * no user-facing strings in notifier
  * structured startup logs (`[BOOTSTRAP] ...`)
  * session missing handled as `unauthenticated` state (not error)
* Added startup presentation feature:
  * `features/startup/presentation/startup_gate_screen.dart`
  * `features/startup/presentation/startup_loading_screen.dart`
  * `features/startup/presentation/startup_error_screen.dart`
* `StartupGateScreen` only triggers bootstrap and renders loading/error UI

## Routing Refactor with go_router

Replaced direct home/screen startup mounting with route-driven startup.

What was done:

* Added route constants in `core/router/app_routes.dart`
* Added centralized router in `core/router/app_router.dart`
* Updated `app.dart` to use `MaterialApp.router` with provider-based `routerConfig`
* Implemented reactive redirect driven by bootstrap state:
  * `initial/loading/error` -> `/startup`
  * `authenticated` -> `/home`
  * `unauthenticated` -> `/login`
* Removed imperative navigation from startup flow

## App Entry & Placeholders

* `app.dart` now owns router configuration and keeps `debugShowCheckedModeBanner: false`
* Placeholder screens kept for next auth phase:
  * `features/auth/presentation/login_screen.dart`
  * `features/home/presentation/home_screen.dart`
* Legacy `HealthScreen` startup path removed from current main flow

---

# Current Task

## Implement Auth Feature (MVP Foundation)

The project architecture and startup hardening are complete.  
Next step is implementing authentication flows on top of the new base.

Planned tasks:

* Implement real login/sign-up UI and validation
* Add auth repository/service integration with Supabase Auth
* Manage session lifecycle (sign-in, sign-out, restore)
* Connect bootstrap authenticated/unauthenticated states to real auth flow
* Add basic auth error mapping for user-friendly messages
