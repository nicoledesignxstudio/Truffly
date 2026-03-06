# EDGE_FUNCTIONS_RULES.md

This document defines how all Supabase Edge Functions must be implemented in the Truffly backend.

Edge Functions handle all sensitive operations such as payments, order lifecycle, and seller verification.

All functions must follow these rules.


---

# 1. GENERAL PRINCIPLES

Edge Functions are the **only place where business-critical logic is executed**.

The client (mobile app) must never:

- calculate prices
- calculate commissions
- change order status
- release payments
- create or cancel orders directly
- approve sellers
- access sensitive user data

All of these operations must be executed inside Edge Functions.

Edge Functions run with **service_role privileges**.


---

# 2. AUTHENTICATION

Every Edge Function must verify the authenticated user.

Use the JWT from the request headers.

Required validation:

- Extract `auth.uid`
- Ensure the user exists
- Ensure the user account is active (`users.is_active = true`)

If authentication fails, return:
401 Unauthorized
 
---

# 3. INPUT VALIDATION

Every function must validate all incoming parameters.

Rules:

- Reject missing parameters
- Reject invalid UUIDs
- Reject invalid enum values
- Reject negative numbers for prices or weights
- Reject invalid order states

Never trust client input.


---

# 4. DATABASE ACCESS

All database operations must use the **Supabase server client with service_role key**.

Client applications must never bypass RLS rules.

Edge Functions may bypass RLS only when required for system logic.


---

# 5. ORDER STATE TRANSITIONS

Order state transitions must be strictly controlled.

Allowed transitions:
paid → shipped
paid → cancelled
shipped → completed


Any other transition must be rejected.


---

# 6. PAYMENT SECURITY

All payment operations must be handled through Stripe.

Rules:

- PaymentIntent must be created server-side
- Commission must be calculated server-side
- Funds release must be triggered server-side
- Refunds must be executed server-side

Client must never interact directly with Stripe secret keys.


---

# 7. PRICE CALCULATIONS

All monetary values must be calculated server-side.

Values that must never come from the client:

- total_price
- commission_amount
- seller_amount
- price_per_kg

Always calculate using database values.


---

# 8. ERROR HANDLING

All functions must return consistent error responses.

Standard error format:
{
"error": "error_message"
}  

HTTP status codes:
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
500 Internal Server Error



---

# 9. NOTIFICATIONS

Edge Functions must generate notifications for important events.

Examples:

- order created
- order shipped
- order completed
- seller approved
- seller rejected
- payment released


Notifications must be inserted into:
notifications table



---

# 10. AUDIT LOGGING

Security-sensitive actions must be logged in `audit_logs`.

Log events for:

- seller approval
- seller rejection
- order cancellation
- payment release
- account deactivation
- truffle deletion


---

# 11. STRIPE INTEGRATION

Stripe must only be used inside Edge Functions.

Required integrations:

- PaymentIntent creation
- Refund handling
- Stripe Connect account creation
- Seller payouts

Never expose Stripe secret keys to the client.


---

# 12. FILE STORAGE RULES

Uploads must follow strict rules.

Truffle images:

bucket: truffle_images
path: {truffle_id}/{image_name}

bucket: seller_documents
path: {user_id}/{document_name}


Only the owner or admin may access seller documents.


---

# 13. SECURITY REQUIREMENTS

Edge Functions must always enforce:

- user ownership checks
- seller verification checks
- order ownership checks
- strict validation of order status transitions

No function should trust client-provided IDs without verification.


---

# 14. PERFORMANCE

Edge Functions should:

- avoid unnecessary database queries
- use indexes for frequent lookups
- fetch only required fields

Heavy operations should be handled asynchronously when possible.


---

# 15. IDENTITY RULE

Never trust client-provided `user_id`.

Always derive the user identity from:
auth.uid()