# ADMIN.md — Admin Role & Seller Approval Flow (Truffly)

## Overview

Truffly includes a special **Admin role** used to manage seller onboarding.

The Admin is responsible for reviewing seller applications and deciding whether to **approve or reject** them.

Admin capabilities include:

- Viewing seller requests with status `pending`
- Reviewing uploaded seller documentation
- Approving or rejecting sellers through server-side Edge Functions

The Admin role is separate from normal app roles (`buyer`, `seller`).

---

# Roles in the System

## Application Roles

The `public.users.role` column represents the role inside the application:

- `buyer`
- `seller`

These roles control normal app behavior (posting truffles, onboarding, etc.).

---

## Admin Role

The Admin role is **not stored in the database tables**.

Instead, it is determined from the authenticated user's **JWT token** using:
app_metadata.role = "admin"


This metadata is stored in Supabase Auth and is **not editable by the client application**.

Only a trusted backend process using the **service role key** can assign or change this metadata.

---

# Admin Detection

Admin privileges are determined using the SQL helper function:

```sql
public.is_admin()