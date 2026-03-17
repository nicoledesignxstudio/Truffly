# Truffly Onboarding Specification

Version: v1.0

Status: Source of truth for onboarding behavior and implementation planning.

## Purpose

This document defines the onboarding architecture and behavior for Truffly.

It is intended to guide future implementation steps in the existing Flutter + Riverpod + go_router + Supabase codebase without ambiguity.

This document covers:

- product rules
- route behavior
- flow structure
- page responsibilities
- local onboarding state
- notifier responsibilities
- service responsibilities
- final submission logic
- backend implications
- implementation phases

If older project documents contain conflicting onboarding assumptions, this document takes precedence.

## Current Project Alignment

The current codebase already contains:

- a single global onboarding route: `/onboarding`
- router-level auth gating that redirects onboarding-required users to `/onboarding`
- auth state evaluation based on `public.users.onboarding_completed`
- a placeholder onboarding screen

This specification preserves that architecture and replaces the placeholder with a real onboarding feature implementation later.

## Non-Negotiable Rules

1. Role selection does not update `users.role` in the database.
2. Choosing Buyer or Seller determines only which onboarding UX flow is shown.
3. Every newly onboarded user remains a buyer by default.
4. Seller role is not granted during onboarding.
5. Seller activation happens only after approval.
6. No database writes are allowed during intermediate onboarding steps.
7. All onboarding data must remain local and in memory until final submit.
8. `onboarding_completed` must be set to `true` only at final submit.
9. In the seller flow, `seller_status` must become `pending` only at final submit.
10. Seller flow must not ask for country.
11. Seller country is implicitly `IT`.
12. Seller must select only region.
13. Seller documents must remain local until final submit.
14. No early upload flow is allowed.
15. There must be only one global onboarding route: `/onboarding`.
16. Role selection must stay outside the PageView flow.
17. PageView navigation must be driven by onboarding state logic.
18. `PageController` must remain in the presentation layer, not inside the notifier.
19. Progress indicators must appear only in the `About Truffly` and `Your Details` sections.
20. No progress indicators must appear on `Documents`, `Notifications`, or `Welcome`.
21. Notification permission must be requested only when the user taps the CTA on the notifications page.
22. Notification permission must not be requested automatically when the page opens.
23. The user must be allowed to continue even if notification permission is denied.

## Route Behavior

Global onboarding route:

- `/onboarding`

Route entry condition:

- authenticated user
- email verified
- `onboarding_completed = false`

Route guard behavior:

- router redirects onboarding-required users to `/onboarding`
- router keeps fully onboarded users out of `/onboarding`
- router does not create sub-routes for onboarding steps

Architectural rule:

- onboarding step navigation is local feature navigation inside the onboarding screen tree
- global routing remains unchanged

## High-Level Flow Structure

Onboarding has:

1. Role Selection
2. Flow Container
3. Final Submit

Role Selection is a standalone screen section rendered inside `/onboarding`, but outside the PageView.

After the user selects a path, the flow container opens the corresponding PageView-driven experience.

Two flow variants exist:

- Buyer onboarding
- Seller onboarding

## Buyer Flow

Buyer pages after role selection:

1. Buyer Info Page 1
2. Buyer Info Page 2
3. Buyer Info Page 3
4. Name Page
5. Country and Region Page
6. Notifications Page
7. Welcome Page

Total:

- 7 pages after role selection

Buyer sections:

- About Truffly: 3 pages
- Your Details: 2 pages
- Notifications: 1 page
- Welcome: 1 page

## Seller Flow

Seller pages after role selection:

1. Seller Info Page 1
2. Seller Info Page 2
3. Seller Info Page 3
4. Seller Info Page 4
5. Name Page
6. Region Page
7. Documents Page
8. Notifications Page
9. Welcome Page

Total:

- 9 pages after role selection

Seller sections:

- About Truffly: 4 pages
- Your Details: 2 pages
- Documents: 1 page
- Notifications: 1 page
- Welcome: 1 page

## Section and Progress Indicator Rules

### Section: About Truffly

Buyer:

- 3 pages
- page indicator dots visible

Seller:

- 4 pages
- page indicator dots visible

### Section: Your Details

Buyer:

- 2 pages
- 2 dots visible

Seller:

- 2 pages
- 2 dots visible

### Standalone Pages Without Progress Indicators

- Documents
- Notifications
- Welcome

Architectural rule:

- progress indicator rendering is a presentation concern
- current section and current step metadata come from onboarding state

## Page-by-Page Definitions

### 1. Role Selection Screen

Screen ID:

- `onboarding_role_selection_screen`

Purpose:

- choose which onboarding UX path to enter

Options:

- Buyer
- Seller

Actions:

- `selectPath(OnboardingPath.buyer)`
- `selectPath(OnboardingPath.seller)`

State effect:

- updates onboarding draft path
- sets initial step for the selected flow

Navigation:

- enters the onboarding PageView container

Notes:

- does not write `users.role`
- does not write any backend data
- remains outside PageView

### 2. Onboarding Flow Container

Screen ID:

- `onboarding_flow_screen`

Purpose:

- host the PageView-based flow after role selection

Contains:

- `PageView`
- section header
- optional progress indicator
- page content
- navigation CTA area

Behavior:

- manual scrolling disabled
- page changes triggered by presentation layer in response to notifier state

Architectural rule:

- notifier decides intended current step
- presentation layer owns `PageController`
- presentation layer listens to state changes and animates or jumps controller accordingly

### 3. Buyer Info Pages

Screen IDs:

- `buyer_info_page_1`
- `buyer_info_page_2`
- `buyer_info_page_3`

Content:

- title
- description
- illustration
- primary CTA

Actions:

- `nextStep()`

Validation:

- none

### 4. Seller Info Pages

Screen IDs:

- `seller_info_page_1`
- `seller_info_page_2`
- `seller_info_page_3`
- `seller_info_page_4`

Content:

- title
- description
- illustration
- primary CTA

Actions:

- `nextStep()`

Validation:

- none

### 5. Name Page

Screen ID:

- `onboarding_name_page`

Fields:

- `first_name`
- `last_name`

Validation:

- required
- trim whitespace before validation and submit
- minimum length: 2

Actions:

- `updateFirstName()`
- `updateLastName()`
- `nextStep()`
- `previousStep()`

Applies to:

- buyer flow
- seller flow

### 6. Buyer Country and Region Page

Screen ID:

- `buyer_location_page`

Fields:

- `country_code`
- `region`

Rules:

- `country_code` required
- if `country_code == 'IT'`, `region` is required
- if `country_code != 'IT'`, `region` must be cleared to `null`

Actions:

- `updateBuyerCountry()`
- `updateBuyerRegion()`
- `nextStep()`
- `previousStep()`

### 7. Seller Region Page

Screen ID:

- `seller_region_page`

Fields:

- `region`

Rules:

- `region` required
- `country_code` not shown
- seller submit treats `country_code` as `IT`

Actions:

- `updateSellerRegion()`
- `nextStep()`
- `previousStep()`

### 8. Seller Documents Page

Screen ID:

- `seller_documents_page`

Required local files:

- `identity_document`
- `tesserino_document`

Rules:

- both files required before continuing
- onboarding data must remain local to the device and not be persisted remotely before final submit 
- seller documents may be stored as local file references in onboarding state until final submit
- no upload occurs when files are selected

Actions:

- `setIdentityDocument()`
- `setTesserinoDocument()`
- `clearIdentityDocument()`
- `clearTesserinoDocument()`
- `nextStep()`
- `previousStep()`

### 9. Notifications Page

Screen ID:

- `onboarding_notifications_page`

Purpose:

- explain the benefit of enabling notifications

Example topics:

- order updates
- shipping notifications
- seller approval updates
- payment release updates

Buttons:

- Enable Notifications
- Continue Without Notifications

Rules:

- opening the page does not trigger permission prompt
- tapping the enable CTA triggers permission request
- denial does not block onboarding

Actions:

- `requestNotificationPermission()`
- `setNotificationsChoice()`
- `nextStep()`
- `previousStep()`

State result:

- stores whether notifications were enabled, denied, or skipped

### 10. Welcome Page

Screen ID:

- `onboarding_welcome_page`

Content:

- welcome message
- summary tone aligned with chosen path
- Enter App CTA

Purpose:

- trigger the final onboarding submission

Actions:

- `submitOnboarding()`

Rules:

- this is the first point where backend writes are allowed
- user remains blocked from the app if final submit fails

## Local Draft State Rules

All onboarding data must be stored locally inside feature state until final submit.

No intermediate persistence is allowed in:

- database
- storage
- profile table
- seller_documents table

Recommended draft model:

### OnboardingPath

Values:

- `buyer`
- `seller`

### OnboardingDraft

Suggested fields:

- `path`
- `firstName`
- `lastName`
- `countryCode`
- `region`
- `identityDocument`
- `tesserinoDocument`
- `notificationsEnabled`
- `notificationsPermissionRequested`

Notes:

- seller draft may leave `countryCode` unset internally until final submit, but final submit must resolve it to `IT`
- buyer draft must clear `region` when country is not `IT`

### OnboardingState

Suggested responsibilities:

- hold current draft
- hold current flow step
- expose current section metadata
- expose validation status
- expose submit status
- expose recoverable submit error

Suggested state concerns:

- selected path present or absent
- current logical step
- can continue
- can go back
- is submitting
- submit failure message or typed failure

Architectural rule:

- onboarding state models logical navigation
- `PageController` is not part of onboarding state

## Notifier Responsibilities

Primary feature state holder:

- `onboarding_notifier`

Responsibilities:

- own onboarding state
- own onboarding draft
- implement step navigation rules
- implement per-step validation rules
- expose whether current step can continue
- orchestrate final submit
- expose loading and retry states for submit failures

Must not own:

- `PageController`
- widget-specific animation logic
- direct presentation concerns

Recommended notifier API surface:

- `selectPath()`
- `nextStep()`
- `previousStep()`
- `jumpToStep()`
- `updateFirstName()`
- `updateLastName()`
- `updateBuyerCountry()`
- `updateBuyerRegion()`
- `updateSellerRegion()`
- `setIdentityDocument()`
- `setTesserinoDocument()`
- `clearIdentityDocument()`
- `clearTesserinoDocument()`
- `setNotificationsChoice()`
- `validateCurrentStep()`
- `validateAllBeforeSubmit()`
- `canContinue()`
- `submitOnboarding()`

Presentation synchronization rule:

- the presentation layer observes state changes
- when logical current step changes, the UI moves the `PageController` accordingly
- the notifier never drives the controller directly

## Service Responsibilities

Prefer a single service abstraction initially:

- `onboarding_service`

Reason:

- current scope is narrow
- onboarding has one final orchestration point
- a single service keeps initial architecture small and aligned with existing project maturity

Responsibilities:

- execute buyer final submit
- execute seller final submit
- optionally wrap notification permission interaction if the team chooses to centralize it
- map backend and network failures into feature-level failures

Service boundaries:

- notifier decides when submit happens
- service performs the external work
- service does not own UI navigation state

Possible future split:

- only introduce separate buyer/seller submission services later if submit flows become materially more complex

## Buyer Final Submit Logic

Trigger:

- welcome page Enter App CTA

Required validation before submit:

1. path is `buyer`
2. first name valid
3. last name valid
4. country code valid
5. region valid when country is `IT`

Submit sequence:

1. Validate final draft.
2. Update `public.users` with:
   - `first_name`
   - `last_name`
   - `country_code`
   - `region`
   - `onboarding_completed = true`
3. Refresh application auth/profile state as required by the existing auth flow.
4. Allow router to move the user to `/home`.

Rules:

- no role update
- no seller status update
- no document upload

## Seller Final Submit Logic

Trigger:

- welcome page Enter App CTA

Required validation before submit:

1. path is `seller`
2. first name valid
3. last name valid
4. region valid
5. identity document present
6. tesserino document present

Submit sequence:

1. Validate final draft.
2. Resolve seller country to `IT`.
3. Submit seller onboarding through backend orchestration.
4. Backend stores seller documents and metadata.
5. Backend updates `public.users` with:
   - `first_name`
   - `last_name`
   - `country_code = 'IT'`
   - `region`
   - `seller_status = pending`
   - `onboarding_completed = true`
6. Refresh application auth/profile state as required by the existing auth flow.
7. Allow router to move the user to `/home`.

Rules:

- `users.role` remains unchanged during onboarding
- seller remains a buyer in the application until approval
- document upload happens only inside final submit orchestration
- the client must treat seller final submit as successful only if the full backend orchestration succeeds 
- the client must not assume that document upload or metadata insertion succeeded independently unless the final backend response confirms the whole operation

## Error Handling

Final submit must handle:

- network failure
- backend validation failure
- document upload failure
- server-side rejection
- unexpected failure

UX expectations:

- failure must keep the user on onboarding
- welcome page or submit surface must expose retry
- partial success must not be assumed on the client

Architectural rule:

- notifier stores submit state and exposes retryable error
- service maps low-level failures to feature-safe failures

## Backend Implications

The final onboarding rules introduce an important backend implication:

- seller onboarding can no longer rely on changing `users.role` before document submission

Current schema and policies already support:

- `onboarding_completed`
- `seller_status`
- `country_code`
- `region`
- `seller_documents`

However, the current RLS policy for inserting into `seller_documents` assumes:

- `users.role = 'seller'`

That assumption conflicts with the final onboarding rule that users remain buyers until approval.

## RLS Conflict Note

Current policy conflict:

- seller document insertion is gated by `u.role = 'seller'`
- onboarding rules explicitly forbid changing role during onboarding

Result:

- seller onboarding cannot rely on direct client-side insert into `seller_documents` under the current policies

Required architectural implication:

- seller final submit should be handled by a backend-controlled endpoint or Edge Function that performs the sensitive writes with elevated privileges

Recommended backend direction:

- final seller submit uploads documents and completes metadata creation server-side
- backend writes `seller_documents`
- backend updates `users.seller_status = 'pending'`
- backend updates `users.onboarding_completed = true`
- backend leaves `users.role` unchanged

This conflict must be resolved before seller onboarding implementation begins.

## Minimal Impact on Existing App Architecture

This onboarding plan intentionally keeps changes scoped.

Confirmed decisions:

- keep a single global route: `/onboarding`
- keep router auth gating unchanged in principle
- keep auth state based on `onboarding_completed`
- keep `PageController` in presentation
- keep onboarding state in a dedicated notifier
- avoid expanding `profile_service` at planning stage unless implementation later proves it necessary
- prefer one onboarding service abstraction first

## Implementation Phases Overview

### Phase 1: Domain and State Modeling

Define:

- `OnboardingPath`
- `OnboardingDraft`
- `OnboardingState`
- step and section metadata
- onboarding-specific failure model

### Phase 2: Notifier

Implement:

- onboarding state transitions
- path selection
- step validation
- final submit orchestration contract

### Phase 3: Presentation Shell

Implement:

- `/onboarding` replacement for placeholder screen
- role selection outside PageView
- flow container with presentation-owned `PageController`
- synchronization between notifier state and PageView

### Phase 4: Buyer and Seller Informational Pages

Implement:

- buyer info pages
- seller info pages
- progress indicators for `About Truffly`

### Phase 5: Detail Collection Pages

Implement:

- name page
- buyer country and region page
- seller region page
- progress indicators for `Your Details`

### Phase 6: Seller Documents and Notifications

Implement:

- seller documents page with local-only file selection
- notifications page with explicit permission CTA behavior

### Phase 7: Buyer Final Submit

Implement:

- buyer persistence logic
- state refresh after success
- retry handling

### Phase 8: Seller Final Submit

Implement:

- backend-compatible seller submission flow
- document upload during final submit only
- pending seller status transition
- RLS-safe orchestration

### Phase 9: Tests

Add coverage for:

- notifier navigation rules
- per-step validation
- buyer and seller flow branching
- progress indicator metadata
- notification permission trigger behavior
- buyer final submit
- seller final submit
- router behavior remains aligned with auth state

## Source of Truth Statement

For onboarding behavior, this file is the canonical implementation reference:

- `docs/ONBOARDING_SPEC.md`

If any older document states that:

- role selection writes `users.role`
- seller country must be asked explicitly
- seller documents upload before final submit
- onboarding steps use multiple routes

those assumptions must be treated as obsolete for future onboarding implementation work.
