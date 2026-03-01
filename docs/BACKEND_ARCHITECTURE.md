# TRUFFLY – BACKEND ARCHITECTURE (MVP)

This document describes the backend architecture of Truffly.
It complements SECURITY_RLS.md and defines system structure, responsibilities, and business logic flows.

---

# 1. HIGH LEVEL ARCHITECTURE

Flutter Mobile App
        |
        v
Supabase Backend
 ├── Postgres Database (RLS Enabled)
 ├── Auth (JWT)
 ├── Storage (Public + Private Buckets)
 ├── Edge Functions
 ├── Scheduled Jobs
        |
        v
Stripe
 ├── PaymentIntent
 ├── Connect Express Accounts
 ├── Transfers
 ├── Webhooks

---

# 2. RESPONSIBILITY SEPARATION

## Flutter App

Responsible for:
- UI rendering
- Navigation
- Sending requests to Edge Functions
- Reading allowed DB data (via RLS)
- Receiving push notifications

Not responsible for:
- Commission calculation
- Order status transitions
- Refunds
- Payouts
- Stripe secret logic

---

## Supabase Postgres

Stores:

- users
- shipping_addresses
- truffles
- truffle_images
- orders
- reviews
- favorites
- notifications
- seller_documents
- audit_logs

All tables:
- RLS enabled
- FK constraints
- Enum constraints
- No direct client access to sensitive writes

---

## Supabase Auth

Handles:
- Email/password login
- Google login
- JWT tokens

Login blocked if:
- users.is_active = false

---

## Supabase Storage

Buckets:

### Public Bucket
- truffle_images

### Private Bucket
- seller_documents (tesserino only)

Identity document:
- Deleted after seller approval

---

# 3. EDGE FUNCTIONS (CORE BUSINESS LOGIC)

All monetary logic runs in Edge Functions.

---

## 3.1 create-payment-intent

Input:
- truffle_id

Server Logic:
- Verify user authenticated
- Verify truffle status = active
- Verify buyer != seller
- Fetch price from DB
- Calculate:
  - commission = 10%
  - seller_amount = 90%
- Create Stripe PaymentIntent
- Return client_secret

Order NOT created here.

---

## 3.2 Stripe Webhook: payment_intent.succeeded

Triggered by Stripe.

Server Logic:
- Validate webhook signature
- Create order record:
  - status = paid
  - snapshot shipping address copied
- Mark truffle status = sold
- Write audit log

---

## 3.3 mark-as-shipped

Input:
- order_id
- tracking_code

Server Logic:
- Verify seller ownership
- Verify order status = paid
- Save tracking_code
- status = shipped
- Write audit log

Tracking insertion and shipped transition happen together.

---

## 3.4 confirm-delivery

Input:
- order_id

Server Logic:
- Verify buyer ownership
- Verify status = shipped
- status = completed
- Trigger Stripe transfer to seller
- Write audit log

---

## 3.5 cancel-order

Input:
- order_id

Server Logic:
- Verify seller ownership
- Verify status = paid
- Trigger Stripe refund
- status = cancelled
- Reactivate truffle
- Write audit log

Buyer cannot cancel directly.

---

# 4. AUTOMATED JOBS

## 4.1 48h Auto-Cancel Job

Query:
- orders where status = paid
- created_at + 48h < now()

Action:
- Refund Stripe
- status = cancelled
- Reactivate truffle
- Audit log entry

---

## 4.2 7-Day Auto-Release Job

Query:
- status = shipped
- shipped_at + 7 days < now()

Step 1:
- Send reminder notification

After 48h:
- status = completed
- Stripe transfer seller
- Audit log entry

---

# 5. STRIPE CONNECT FLOW

## Seller Approval

Seller:
- Uploads tesserino
- seller_status = pending

Admin:
- Reviews manually
- Sets approved or rejected

If approved:
- Seller must complete Stripe Express onboarding
- stripe_account_id saved

Seller cannot publish truffles without:
- seller_status = approved
- stripe_account_id != null

---

# 6. ORDER LIFECYCLE

paid → shipped → completed  
paid → cancelled  
shipped → auto-completed  

No other transitions allowed.

All transitions enforced server-side.

---

# 7. SHIPPING ADDRESS STRATEGY

Shipping addresses table:
- Owner only access

At purchase:
- Shipping fields copied into orders table:
  - shipping_full_name
  - shipping_street
  - shipping_city
  - shipping_postal_code
  - shipping_country
  - shipping_phone

Seller reads only snapshot inside order.

---

# 8. ACCOUNT DEACTIVATION

Users are not hard-deleted if they have orders.

On deletion:
- is_active = false
- deleted_at = timestamp
- profile data anonymized

Seller deletion:
- Reviews removed
- Orders preserved

Login blocked if is_active = false.

---

# 9. AUDIT LOG SYSTEM

audit_logs table stores:

- entity_type
- entity_id
- action
- performed_by
- created_at

Logged events:
- seller approval/rejection
- order status transitions
- refunds
- payouts
- account deactivation
- truffle deletion

Audit logs never deleted.

---

# 10. SECURITY GUARANTEES

- No direct order insertion from client
- No client-side commission logic
- No self-purchase allowed
- No Stripe keys exposed
- All critical writes via Edge Functions
- RLS enforced on all tables

---

# END