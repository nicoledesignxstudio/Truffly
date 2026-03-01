# TRUFFLY – MVP PRODUCT REQUIREMENTS DOCUMENT

## 1. Product Overview

**Product Name:** Truffly  
**Platform:** Mobile App (iOS & Android)  
**Technology:** Flutter + Supabase + Stripe  

### Description
Truffly is a mobile marketplace connecting verified truffle hunters (sellers) with buyers seeking fresh, high-quality truffles.

The platform operates with a real escrow payment system using Stripe Connect.

All content is accessible only to authenticated users.

---

## 2. Core Value Proposition

### For Buyers
- Access to fresh, authentic truffles
- Secure escrow payments
- Transparent seller ratings
- 48-hour shipping guarantee

### For Sellers
- Sell truffles without intermediaries
- Automatic payment handling
- Verified buyer base
- Structured and secure order management

---

## 3. Monetization

- 10% commission per completed order
- Commission calculated server-side
- Managed via Stripe Connect (Express accounts)

Currency: EUR only  
Languages: Italian (default), English

---

## 4. Tech Stack

### Frontend
- Flutter (Mobile only)
- Riverpod (state management)

### Backend
- Supabase
  - Auth (JWT-based)
  - PostgreSQL
  - Storage
  - Row Level Security (RLS)
  - Edge Functions
  - Scheduled jobs

### Payments
- Stripe
  - Stripe Connect Express
  - PaymentIntent-based escrow
  - Webhook signature verification

### Notifications
- Firebase Cloud Messaging (Push)
- In-app notifications (database stored)
- Transactional emails (TBD provider)

---

## 5. User Roles

### Buyer
- Browse active truffles
- Browse seller profiles
- Purchase truffles
- Confirm delivery
- Leave review
- Manage shipping addresses
- View order history
- Filter orders by:
  - In progress (paid + shipped)
  - Cancelled
  - Completed
  - All

### Seller (Approved Only)
- Publish truffles
- Delete active truffles (if not sold)
- Insert tracking code (marks order as shipped)
- View orders
- Filter orders by:
  - In progress
  - Cancelled
  - Completed
  - All
- Browse truffles
- Browse seller profiles
- View rating and total completed orders
- Edit public seller profile

### Admin (via Supabase Dashboard)
- Approve/reject sellers
- Review tesserino documents
- View users
- View orders

---

## 6. Authentication

- Email & password
- Google OAuth
- Mandatory email verification
- Login blocked if `is_active = false`

Users must be authenticated to access any content.

---

## 7. Users Table

`users`
- id (uuid, auth.uid)
- email
- first_name
- last_name
- region
- country_code
- role (buyer / seller)
- seller_status:
  - not_requested
  - pending
  - approved
  - rejected
- stripe_account_id
- stripe_customer_id
- tesserino_number
- bio
- profile_image_url
- is_active (boolean)
- deleted_at (nullable)
- created_at

### Account Deletion Policy

Users WITHOUT:
- Orders
- Reviews
- Sold truffles

→ Can be permanently deleted (hard delete)  
All related data removed:
- Shipping addresses
- Favorites
- Notifications
- Active truffles

Users WITH transaction history:
→ Cannot be hard deleted  
→ Account deactivated:
  - is_active = false
  - deleted_at = timestamp
  - Public profile data anonymized
  - Seller reviews removed
  - Orders preserved for legal compliance

---

## 8. Database Structure

### Shipping Addresses (Private)

`shipping_addresses`
- id
- user_id
- full_name
- country
- city
- postal_code
- street
- phone
- is_default

Shipping data is copied into the order at purchase time (snapshot model).

---

### Truffles

`truffles`
- id
- seller_id (FK users)
- latin_name
- quality
- weight_grams
- price_total
- price_per_kg (calculated automatically)
- region
- harvest_date
- expires_at (created_at + 5 days)
- shipping_price_italy
- shipping_price_abroad
- status:
  - active
  - sold
  - expired
- created_at

Rules:
- No modification after publication
- Hard delete allowed only if not sold
- Auto-expire after 5 days

---

### Truffle Images

`truffle_images`
- id
- truffle_id
- image_url
- order_index

Each truffle must have 1–3 images.

---

### Orders

`orders`
- id
- buyer_id
- seller_id
- truffle_id
- shipping_full_name
- shipping_street
- shipping_city
- shipping_postal_code
- shipping_country
- shipping_phone
- total_price
- commission_amount (10%)
- seller_amount (90%)
- stripe_payment_intent_id
- status:
  - paid
  - cancelled
  - shipped
  - completed
- tracking_code
- created_at

Rules:
- Self-purchase forbidden
- Order created only via Edge Function after Stripe confirmation
- All status transitions server-side
- No direct client updates

---

### Reviews

`reviews`
- id
- order_id
- seller_id
- buyer_id
- rating (1–5)
- comment
- created_at

Rules:
- One review per order
- Insert only if order status = completed
- Automatic 5-star review if none submitted
- Reviews removed if seller account deactivated

---

### Notifications

`notifications`
- id
- user_id
- type
- message
- read
- created_at

Private per user.

---

### Audit Logs

`audit_logs`
- id
- entity_type
- entity_id
- action
- performed_by
- created_at

Tracks:
- Seller approval/rejection
- Order transitions
- Refunds
- Payouts
- Account deactivation
- Truffle deletion

Never deleted.

---

## 9. Payment Logic (Escrow)

### Purchase Flow

1. Buyer selects truffle
2. Edge Function:
   - Validates truffle
   - Prevents self-buy
   - Calculates commission server-side
   - Creates Stripe PaymentIntent
3. Stripe confirms payment (webhook)
4. Order created with status `paid`
5. 48-hour countdown begins

---

### 48-Hour Rule

If seller does not insert tracking within 48 hours:
- Order cancelled
- Full refund issued
- Truffle reactivated

If seller inserts tracking:
- Status → `shipped`
- 7-day countdown begins

---

### 7-Day Rule

If buyer confirms delivery:
- Status → `completed`
- Funds released (90% seller, 10% platform)

If buyer does not respond:
- Reminder sent
- After 48 additional hours:
  - Automatic completion
  - Funds released

---

## 10. Seller Onboarding

- Seller uploads tesserino
- Admin reviews manually
- If approved:
  - Seller completes Stripe Express onboarding
  - stripe_account_id saved
- Identity document deleted after verification
- Only tesserino number retained

Seller cannot publish without:
- seller_status = approved
- stripe_account_id not null

---

## 11. Security Requirements

- RLS enabled on all tables
- No anonymous access
- No client-side money logic
- No direct order insertion from client
- Snapshot shipping model
- Stripe webhook signature verification
- Self-purchase prevention
- Sensitive data never publicly exposed
- No card details stored in DB

---

## 12. Scalability

Architecture supports:
- Ecosystem expansion (future seller tools)
- EU expansion
- Additional product categories
- Web frontend (future)
- 10k+ users without structural change

A user can:
- Be seller
- Be buyer
- Appear as seller in one order
- Appear as buyer in another

Role does not restrict browsing.

---

## 13. Non-Functional Requirements

- Pagination on listings
- Lazy image loading
- Secure JWT storage
- GDPR-compliant data handling
- Error handling on all flows
- Server-side enforcement of business logic
- Scheduled jobs for time-based rules

---

# END OF FINAL MVP PRD