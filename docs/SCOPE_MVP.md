# TRUFFLY – MVP SCOPE LOCK

This document defines what is included and excluded in the MVP.

The purpose is to prevent feature creep and ensure fast, secure delivery.

---

# INCLUDED IN MVP

## Authentication
- Email & password login
- Google OAuth
- Mandatory email verification
- Account deactivation logic

---

## Buyer Features
- Browse truffles
- Browse sellers
- Filter truffles (type, quality, region, price, weight)
- Filter sellers (region, rating, completed orders)
- View product detail
- Purchase single truffle (no cart)
- Manage shipping addresses
- Manage payment methods (via Stripe)
- Confirm delivery
- Leave review (1 per order)
- View orders by status:
  - In progress
  - Cancelled
  - Completed
  - All
- Add/remove favorites
- Receive push notifications
- In-app notifications

---

## Seller Features
- Apply to become seller
- Upload tesserino document
- Manual approval process
- Complete Stripe Express onboarding
- Publish truffles (1–3 images)
- Delete active truffles (if not sold)
- View active and completed orders
- Insert tracking code
- View seller rating
- View total completed orders

---

## Escrow & Payments
- Stripe Connect (Express)
- PaymentIntent-based escrow
- 10% commission
- 48h shipping rule
- 7+2 day auto-release rule
- Automatic refund on timeout

---

## Notifications
- Push notifications
- In-app notifications
- Transactional emails for:
  - Order confirmation
  - Refund
  - Seller approval
  - Payment release

---

## Admin
- Approve / reject sellers
- View users
- View orders

---

# NOT INCLUDED IN MVP

- No web purchasing (mobile only)
- No multi-product cart
- No discount codes
- No analytics dashboard for sellers
- No chat between buyer and seller
- No automated fraud detection
- No multi-currency support
- No tax calculation logic
- No seller ranking system
- No advanced performance metrics
- No moderation system
- No dispute resolution system

---

# FUTURE PHASE (POST-MVP)

- Seller analytics dashboard
- Ecosystem tools for truffle hunters
- Expanded EU shipping logic
- Multi-category marketplace
- Advanced trust score system
- Dispute center
- Web frontend

---

# RULE

If a feature is not listed under INCLUDED IN MVP,
it must not be implemented.