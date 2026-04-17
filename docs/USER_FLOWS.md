# TRUFFLY – USER FLOWS DOCUMENT (MVP – UPDATED)

---

# 1. APP ENTRY FLOW

## 1.1 Splash Screen

- Display animated Truffly logo
- Duration: 2–3 seconds
- Check authentication state:
  - If authenticated → go to Home
  - If not authenticated → go to Welcome Screen

---

# 2. UNAUTHENTICATED FLOW

## 2.1 Welcome Screen

Content:
- Value proposition text
- Supporting image
- Buttons:
  - Sign Up
  - Log In
  - Continue with Google

---

# 3. AUTHENTICATION FLOW

## 3.1 Sign Up (Email)

Fields:
- Email
- Password
- Confirm Password

Validation:
- Valid email format
- Password strength suggestion
- Password confirmation match
- Required fields

On submit:
- Create account via Supabase
- Send email verification
- Navigate to Email Verification screen

---

## 3.2 Email Verification Screen

Message:
"Please verify your email to continue."

Actions:
- Resend verification email
- Refresh verification status

If verified:
- Navigate to Onboarding

---

## 3.3 Login (Email or Google)

If first login:
- Navigate to Onboarding

If returning user:
- Navigate directly to Home

---

# 4. ONBOARDING FLOW

## 4.1 Role Selection Screen

User chooses:
- Buyer
- Seller

Role stored in database.

---

# 5. BUYER ONBOARDING

## 5.1 Informational Screens

Explain:
- Fresh truffles
- Escrow payment protection
- Verified sellers

---

## 5.2 Profile Data Collection

Required:
- First Name
- Last Name
- Country
- Region (if Country is Italy)

seller_status = not_requested

---

## 5.3 Notification Permission Screen

Explain:
"Notifications help you stay updated on your purchases and deliveries."

Button:
- Enable Notifications

If accepted:
- Register FCM token

If denied:
- Continue anyway

---

## 5.4 Welcome Screen

Message:
"Welcome to Truffly"

Button:
- Enter App

Navigate to Buyer Home.

---

# 6. SELLER ONBOARDING

## 6.1 Informational Screens

Explain:
- 10% commission
- 48h shipping rule
- 7-day confirmation window
- Escrow logic
- Stripe onboarding required

User must accept terms.

---

## 6.2 Profile Data

Required:
- First Name
- Last Name
- Region
- Country Code

---

## 6.3 Document Upload

Required:
- Identity document
- Truffle license/permit

Stored in private Supabase Storage bucket.

On submit:
- seller_status = pending
- Notify admin

Show:
"Your request is under review."

---

## 6.4 Seller Approval Flow

Admin reviews documents manually.

If approved:
- seller_status = approved
- Send push + in-app notification

If rejected:
- seller_status = rejected
- Send push notification
- Delete uploaded documents
- After 48h → seller_status = not_requested

---

# 7. STRIPE CONNECT ONBOARDING

Condition:
seller_status = approved
AND stripe_account_id = null

Flow:
- Generate Stripe Express onboarding link
- Redirect seller to Stripe
- Seller enters:
  - IBAN
  - Identity info
  - Tax info

On success:
- Save stripe_account_id
- Refresh seller Stripe status server-side
- Seller can publish truffles only when Stripe status is really ready

---

# 8. PUBLISH TRUFFLE FLOW

Entry:
- Seller Home → Publish button

Fields (required except notes):
- Latin name
- Quality
- Weight (grams)
- Total price
- Shipping price Italy
- Shipping price Abroad
- Region
- Harvest date
- 1–3 images
- Optional notes

Validation required.

On confirm:
- Insert truffle
- status = active
- expires_at = created_at + 5 days

Redirect to previous page.

---

# 9. DELETE TRUFFLE FLOW

Allowed only if:
- status = active

On delete:
- Remove truffle
- Remove related images
- Remove from favorites
- Notify users who saved it

---

# 10. PURCHASE FLOW (NO CART)

Buyer can purchase one truffle at a time.

Steps:
1. Select shipping address
2. Confirm order
3. Create PaymentIntent
4. Stripe payment

If success:
- status = paid
- Start 48h timer

If payment fails:
- No order created
- Truffle remains active

---

# 11. ORDER FLOW

## 11.1 Status Definitions

- paid
- cancelled
- shipped
- completed

---

## 11.2 48h Rule

If no tracking inserted in 48h:
- Order cancelled
- Full refund
- Truffle reactivated
- Refund and cancellation stay replay-safe server-side

---

## 11.3 Seller Insert Tracking

Required before marking shipped.

On submit:
- status = shipped
- Start 7-day timer

---

## 11.4 Buyer Confirmation

Buyer can:
- Confirm delivery
- Contact support

On confirm:
- status = completed
- Trigger payout release flow server-side (90% seller / 10% platform)
- Keep payout tracking separate from order business state

---

## 11.5 7-Day Auto Release

If buyer silent:
- Send reminder
- After 48h:
  - status = completed
  - Automatic fund release
  - server-side payout tracking updated

---

# 12. CANCELLATION RULES

Seller:
- Can cancel before shipped

Buyer:
- Cannot cancel after payment
- Must contact support

---

# 13. REVIEWS FLOW

After completed:

Buyer can leave one review.

If no review:
- Auto 5-star review created.

---

# 14. ACCOUNT PAGE FLOW

Buyer:
- View orders
- Filter by status
- Manage shipping addresses
- Edit profile

Seller:
- View sales
- View statistics
- View active truffles
- Edit profile

---

# 15. SELLER PROFILE PAGE (PUBLIC)

Displays:
- Profile image
- Bio
- Region
- Rating
- Completed orders
- Reviews
- Active truffles

---

# 16. SUPPORT FLOW

Buyer can:
- Contact support from order page

Disputes handled manually by platform.

---

# 17. EDGE CASES

- Expired truffles → status = expired
- Expired truffles cannot be purchased
- Stripe onboarding required before publishing
