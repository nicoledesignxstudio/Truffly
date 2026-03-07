# Truffly — Authentication Flow Implementation Specification

## Objective

Implement a robust and scalable authentication system for the Flutter app **Truffly** using:

- Flutter
- Riverpod
- Supabase Auth
- go_router

This document defines the **architecture, responsibilities, flows, and implementation roadmap** for the authentication system.

It is designed to be used as a **technical specification for code generation with Codex**.

---

# Architecture Overview

## Responsibility Separation

The application separates two domains.

### Authentication (Supabase Auth)

Supabase Auth is responsible for:

- user signup
- user login
- user logout
- session management
- email verification
- password reset
- session restoration

Supabase Auth is the **source of truth for authentication**.

---

### Application Profile (`public.users`)

The application database is responsible for:

- storing application-specific user data
- tracking onboarding status

The database is the **source of truth for application user state**.

---

## Architectural Rule

Do **not duplicate authentication data** already managed by Supabase Auth, such as:

- email verification status
- authentication session state

---

# Global Authentication States

The application must explicitly model the global authentication state.

checking
unauthenticated
authenticated_unverified
authenticated_onboarding_required
authenticated_ready


## State Definitions

| State | Description |
|------|------|
| checking | App is verifying the session on startup |
| unauthenticated | No user session |
| authenticated_unverified | User logged in but email not verified |
| authenticated_onboarding_required | User verified but onboarding incomplete |
| authenticated_ready | User fully authenticated and ready |

These states drive:

- routing
- navigation guards
- UI behavior

---

# Routing

## Main Routes


/login
/signup
/verify-email
/forgot-password
/reset-password
/onboarding
/home


---

## Access Rules

### Unauthenticated Users

Allowed routes:

/login
/signup
/forgot-password


If an unauthenticated user attempts to access:


/home
/onboarding


→ redirect to `/login`.

---

### Authenticated but Email Not Verified

Redirect to:

/verify-email

---

### Authenticated but Onboarding Not Completed

Redirect to:

/onboarding

---

### Fully Authenticated Users

Redirect to:

/home

---

### Authenticated Users Must Not Access

/login
/signup

---

## Architectural Rule

All authentication redirects must be implemented **inside the router layer**.

UI screens must **not contain global navigation logic**.

---

# Screens to Implement

login_screen
signup_screen
verify_email_screen
forgot_password_screen
reset_password_screen
home_screen

The onboarding flow will be implemented separately and is **not part of this document**.

---

# Shared Authentication UI Components

Reusable components:

auth_scaffold
auth_text_field
auth_password_field
auth_primary_button
auth_error_message
auth_loading_indicator

These components should be reused across all authentication screens.

---

# Service Architecture

## Authentication Layer

Main components:

auth_service
auth_state
auth_failure
auth_notifier

Responsibilities:

- signup
- login
- logout
- password reset
- session restoration
- checking email verification
- reacting to authentication state changes

---

## Profile Layer

Main component:

profile_service

Responsibilities:

- retrieving the user record from `public.users`
- checking the `onboarding_completed` status

---

## Validators

Main component:

auth_validators

Responsibilities:

- email validation
- password validation
- confirm password validation

---

# App Bootstrap

At application startup:

1. Check Supabase session.

2. If no session exists → state = `unauthenticated`.

3. If a session exists:

   Check email verification status.

4. If email is not verified → state = `authenticated_unverified`.

5. If email is verified:

   Retrieve the user record from `public.users`.

6. If onboarding is not completed → state = `authenticated_onboarding_required`.

7. If onboarding is completed → state = `authenticated_ready`.

---

# Supabase Authentication Event Listener

The application must react to **Supabase authentication events** to keep the global authentication state synchronized.

The client must subscribe to:

supabase.auth.onAuthStateChange

Events that must be handled:

signedIn
signedOut
tokenRefreshed
userUpdated
passwordRecovery

When an event occurs, the application must:

1. Update the authentication state.
2. Re-evaluate routing conditions.
3. Redirect the user if necessary.

Examples:

### User logs in

Update state → evaluate:

- email verified
- onboarding completed

Then redirect to:

/verify-email
/onboarding
/home

---

### User logs out

State becomes:

unauthenticated

Router redirects to:

/login

---

### Session restored on app restart

State becomes:

checking

Then follow the normal bootstrap logic.

---

# Operational Flows

## Signup Flow

Signup requires only:

email
password
confirm password

### Process

1. Validate form input.
2. Create account with Supabase Auth.
3. A corresponding record in `public.users` is automatically created.
4. Send email verification.
5. Redirect to `/verify-email`.

Personal user information is **not collected during signup**.

---

## Login Flow

1. Validate form input.
2. Perform email/password login.
3. Check email verification status.

If email is not verified:

→ redirect `/verify-email`.

If email is verified:

4. Retrieve the user record from `public.users`.

5. If onboarding is not completed:

→ redirect `/onboarding`.

6. If onboarding is completed:

→ redirect `/home`.

---

# Email Verification Flow

Screen:

/verify-email

Features:

- instructions explaining the verification process
- resend verification email button
- loading state during resend
- protection against multiple rapid submissions

The user cannot access the application until the email is verified.

The verification status must always be read from **Supabase Auth**.

---

# Password Recovery Flow

## Forgot Password

Screen:

/forgot-password

Features:

- request password reset email
- loading state
- network error handling
- success confirmation message

---

## Reset Password

Screen:

/reset-password

Features:

- new password input
- confirm password input
- password validation
- handling expired or invalid reset links
- success confirmation

---

# Error Handling

Authentication errors must be **type-safe**.

At minimum distinguish:

email_already_used
invalid_credentials
email_not_verified
network_error
timeout
reset_link_invalid
user_profile_missing
unknown_error

Rules:

- never show raw exceptions to the user
- map failures to user-friendly messages in the presentation layer
- no UI strings inside service or domain layers

---

# Form Validation

Signup and login forms must validate:

valid email
secure password
matching confirm password

Validation behavior:

- live validation after user interaction
- full validation on form submission

---

# Form UX Requirements

- use Form + validators
- correct keyboard types
- field focus management
- password show/hide toggle
- disable submit during loading
- show loading indicators
- prevent double submission
- avoid keyboard layout overflow
- display clear error messages

---

# Security Guidelines

- never log passwords
- never log authentication tokens
- normalize email input
- trim user input
- handle logout correctly
- support persistent sessions

---

# Automatic User Record Creation

When a new user is created in **Supabase Auth**, a corresponding record must exist in `public.users`.

### Recommended Solution

Use a **Supabase database trigger** that:

- listens for new users in `auth.users`
- automatically creates the corresponding `public.users` record

### Benefits

- guarantees consistency between authentication and database
- removes client-side responsibility
- prevents race conditions after signup

The Flutter client should **not manually create this record**.

---

# Minimal Testing Strategy

## Unit Tests

Test:

email validator
password validator
confirm password validator
auth error mapping
authentication redirect logic

---

## State / Notifier Tests

Test:

successful login
successful signup
email not verified case
logout behavior
network error handling

---

## Router Tests

Test navigation rules:

unauthenticated user accessing /home → redirect /login
authenticated but unverified → redirect /verify-email
authenticated with incomplete onboarding → redirect /onboarding
fully authenticated → redirect /home

---

# Implementation Roadmap

## Phase 1 — Authentication Foundations

Implement:

auth_state
auth_service
auth_notifier
session bootstrap logic
router authentication guards
supabase auth event listener

---

## Phase 2 — Core Authentication Screens

Implement:

login_screen
signup_screen
verify_email_screen
logout

---

## Phase 3 — Profile Integration

Implement:

profile_service
fetch user record from public.users
check onboarding_completed
redirect to onboarding when required

---

## Phase 4 — Password Recovery

Implement:

forgot_password_screen
reset_password_screen
deep link handling

---

## Phase 5 — Refinement

Implement:

error mapping improvements
shared auth UI components
UX improvements
minimal testing suite

---

# Final User Flows

## New User

signup
verify email
redirect onboarding

---

## Existing User With Unverified Email

login
verify email

---

## Verified User With Incomplete Onboarding

login
redirect onboarding

---

## Fully Authenticated User

login
home