# AI Coding Rules – Truffly

This file defines the rules that all AI coding agents (Codex, Cursor, Aider, etc.) must follow when generating or modifying code in this repository.

The goal is to ensure consistent architecture, security, and maintainability across the project.

All generated code must follow these rules strictly.

---

# 1. Project Context

Truffly is a mobile marketplace for buying and selling fresh truffles.

The platform connects verified truffle hunters (sellers) with buyers.

Core characteristics:

- Mobile-first application
- Marketplace model
- Escrow payments via Stripe
- Verified sellers
- Fresh product listings with expiration

---

# 2. Source of Truth Documents

The following documents define the system architecture and must always be respected.

AI must read these before generating code.

docs/PRD.md  
docs/DOMAIN_MODEL.md  
docs/SECURITY_RLS.md  
docs/BACKEND_ARCHITECTURE.md  
docs/USER_FLOWS.md  
docs/UI_SPEC.md  
docs/SCOPE_MVP.md  
docs/PROJECT_STATUS.md  

Never introduce features or database structures that conflict with these documents.

---

# 3. Tech Stack

Frontend (mobile)

- Flutter
- Dart
- Riverpod for state management

Backend

- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- Supabase Edge Functions

Payments

- Stripe
- Stripe Connect Express
- PaymentIntent API

Notifications

- Firebase Cloud Messaging
- Supabase database notifications

Infrastructure

- Git
- GitHub
- Supabase CLI
- SQL migrations

---

# 4. Architecture Rules

All backend schema must be created through SQL migrations.

Never modify the database manually through the Supabase dashboard.

Database schema must be defined inside: supabase/migrations/

Edge functions must be placed in: supabase/functions/

---

# 5. Database Design Rules

Database rules are critical.

The database schema must always follow the definitions in:

docs/DOMAIN_MODEL.md

Rules:

- All primary keys must be UUID
- All tables must define foreign keys
- All constraints must be explicit
- Use snake_case for all column names
- Table names must be plural
- Foreign keys must use: <entity>_id


---

# 6. Security Rules

Security rules are defined in:

docs/SECURITY_RLS.md

Key requirements:

- All tables must have Row Level Security enabled
- Sensitive data must never be public
- Orders must only be visible to buyer and seller
- Seller documents must be stored in private storage
- Payment logic must never be handled client-side

All payment calculations must happen server-side.

Never trust client-provided values for:

- price
- commission
- order status
- refunds

---

# 7. Supabase Rules

Supabase is the backend platform.

AI must follow these rules:

- Never expose service_role keys
- Never bypass RLS policies
- Use Edge Functions for business logic
- Do not embed secret keys in client code

Database changes must always be made via migrations.

---

# 8. Stripe Rules

Stripe is used for payment processing.

Payments must follow this model:

Buyer → PaymentIntent → Stripe escrow → Seller payout

Rules:

- Always use PaymentIntent
- Use Stripe Connect Express for sellers
- Platform takes 10% commission
- Funds released only after order completion

Never store card details in the database.

All card data must be handled by Stripe.

---

# 9. Flutter Development Rules

Flutter is used for the mobile application.

Rules:

- Use Riverpod for state management
- Separate UI from business logic
- Use typed models for API responses
- Avoid large widget files

---

# 10. Forbidden Patterns

AI must never introduce the following patterns.

- No jQuery
- No client-side payment logic
- No database schema changes outside migrations
- No direct SQL queries from the mobile client
- No bypass of RLS policies
- No hardcoded secrets

---

# 11. Code Generation Rules

When generating code:

- Prefer simple, readable solutions
- Avoid unnecessary dependencies
- Follow the existing architecture
- Reuse existing models when possible

Never duplicate database fields or business logic already defined in the documentation.

---

# 12. Project Status Awareness

Before generating new code, AI must read:

docs/PROJECT_STATUS.md

This file tracks:

- completed features
- current development stage
- next steps

AI must update PROJECT_STATUS.md when major milestones are completed.

---

# 13. Guiding Principle

The AI agent must prioritize:

1. Security
2. Data integrity
3. Maintainability
4. Simplicity

Never introduce complexity that is not required by the PRD.