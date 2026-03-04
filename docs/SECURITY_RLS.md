# TRUFFLY – SECURITY & RLS SPEC (FINAL MVP)

This document defines Row Level Security (RLS), access rules, and data protection strategy for Truffly.

All tables MUST have RLS enabled.
All business logic is enforced server-side via Edge Functions.

---

# 1. GLOBAL PRINCIPLES

- No public access. All content requires authentication.
- is_active must be true for any data access.
- Client is never trusted for:
  - price
  - commission
  - order status transitions
  - refunds
  - payouts
- Payments handled only via Edge Functions.
- All IDs are UUID.
- Stripe secret keys never exposed.
- No service_role usage in frontend.

Storage buckets:
- public bucket → truffle images
- private bucket → seller documents

---

# 2. USERS TABLE

Fields:
- id (uuid)
- email (unique)
- role (buyer / seller)
- seller_status
- stripe_account_id
- stripe_customer_id
- first_name
- last_name
- country_code
- region
- bio
- profile_image_url
- tesserino_number (unique, nullable)
- is_active (boolean)
- deleted_at

RLS:

SELECT:
- User can read only own row.
- Must have is_active = true.

INSERT: 
- no insert from client, user profile created server-side

UPDATE:
- User can update:
  - first_name
  - last_name
  - region (only if country_code equal to 'IT') 
  - country_code 
  - bio
  - profile_image_url
- Cannot update:
  - role
  - seller_status
  - stripe_account_id
  - stripe_customer_id
  - tesserino_number

Admin:
- Can update seller_status.

Account Deactivation:
- Hard delete allowed only if:
  - no orders
  - no reviews
  - no sold truffles
- Otherwise:
  - is_active = false
  - deleted_at = now()
  - profile anonymized
  - seller reviews deleted

Login must fail if is_active = false.

---

# 3. SHIPPING_ADDRESSES

Private table.

RLS:

SELECT / INSERT / UPDATE / DELETE:
- Owner only (user_id = auth.uid())

Important:
Seller NEVER reads this table.
Shipping data copied into orders at purchase (snapshot).

---

# 4. TRUFFLES

RLS:

SELECT:
- Any authenticated user
- status = active

INSERT:
- auth.uid() = seller_id
- role = seller
- seller_status = approved
- stripe_account_id IS NOT NULL
- is_active = true

UPDATE:
- Not allowed.

DELETE:
- Seller only
- status = active
- no linked orders

Expiration:
- Scheduled job sets status = expired.

Constraints:
- price_per_kg calculated server-side.
- weight_grams > 0
- price_total > 0

---

# 5. TRUFFLE_IMAGES

SELECT:
- Authenticated users.

INSERT / DELETE:
- Seller owner only.
- Only if truffle status = active.

ON DELETE CASCADE when truffle deleted.

---

# 6. ORDERS

RLS:

SELECT:
- Buyer (buyer_id = auth.uid())
- Seller (seller_id = auth.uid())

INSERT:
- Edge Function only.

UPDATE:
- Not allowed directly from client.
- Tracking insertion via Edge Function only.

DELETE:
- Not allowed.

Rules:
- buyer_id != seller_id
- Commission = 10% server-side.
- Price validated server-side.
- Status transitions enforced server-side.

---

# 7. REVIEWS

SELECT:
- Authenticated users.

INSERT:
- buyer_id = auth.uid()
- order.status = completed
- One per order (unique constraint)

UPDATE:
- Not allowed.

DELETE:
- Not allowed from client.

Constraint:
- rating between 1 and 5.

If seller deactivated:
- Reviews deleted.

---

# 8. SELLER DOCUMENTS

Stored in private bucket.

RLS:
- Owner + admin only.

INSERT:
- During onboarding only.

DELETE:
- On rejection automatically.

Policy:
- Identity document deleted after approval.
- Only tesserino_number retained in users table.

---

# 9. FAVORITES

SELECT / INSERT / DELETE:
- Owner only.

ON DELETE CASCADE when truffle deleted.

---

# 10. NOTIFICATIONS

SELECT:
- Owner only.

UPDATE:
- Owner can mark read.

INSERT:
- Server only.

DELETE:
- Owner allowed.

---

# 11. AUDIT_LOGS

SELECT:
- Admin only.

INSERT:
- Server only.

UPDATE:
- Not allowed.

DELETE:
- Never allowed.

Includes:
- seller approval/rejection
- order transitions
- refunds
- payouts
- account deactivation
- truffle deletion

Immutable log.

---

# 12. ORDER STATE TRANSITIONS (SERVER ENFORCED)

Allowed:

paid → shipped
paid → cancelled
shipped → completed
shipped → auto completed (7+2 days)

No other transitions allowed.

---

# 13. DATABASE CONSTRAINTS

- Unique email
- Unique tesserino_number
- Unique review per order
- buyer_id != seller_id
- Commission = 10% enforced server-side
- Foreign keys with correct ON DELETE rules
- Rating CHECK (rating BETWEEN 1 AND 5)

---

# 14. SECURITY CRITICAL CHECKS

- Prevent seller self-purchase
- Prevent status tampering
- No direct monetary logic in client
- RLS enabled on all tables
- Stripe webhook signature verification
- JWT validation required on every request