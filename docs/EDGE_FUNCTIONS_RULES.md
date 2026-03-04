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
