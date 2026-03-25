# TRUFFLY – DOMAIN MODEL (MVP)

This document defines the complete database domain model for the MVP.

All IDs are UUID.
All business logic enforced server-side.

---

# ENUMS

## user_role_enum
- buyer
- seller

## seller_status_enum
- not_requested
- pending
- approved
- rejected

## region_enum (Italy)

- ABRUZZO
- BASILICATA
- CALABRIA
- CAMPANIA
- EMILIA_ROMAGNA
- FRIULI_VENEZIA_GIULIA
- LAZIO
- LIGURIA
- LOMBARDIA
- MARCHE
- MOLISE
- PIEMONTE
- PUGLIA
- SARDEGNA
- SICILIA
- TOSCANA
- TRENTINO_ALTO_ADIGE
- UMBRIA
- VALLE_DAOSTA
- VENETO

## truffle_type_enum (Latin base)

- TUBER_MAGNATUM          (White Truffle)
- TUBER_MELANOSPORUM      (Black Winter Truffle)
- TUBER_AESTIVUM          (Scorzone / Summer Truffle)
- TUBER_UNCINATUM         (Uncinato)
- TUBER_BORCHII           (Bianchetto)
- TUBER_BRUMALE           (Brumale)
- TUBER_MACROSPORUM       (Smooth Black Truffle)
- TUBER_BRUMALE_MOSCHATUM (Musky Brumal Truffle)
- TUBER_MESENTERICUM      (Mesenteric Truffle)

App layer handles translation:
- Latin label always stored (enum)
- Italian label (UI)
- English label (UI)

## truffle_quality_enum
- FIRST
- SECOND
- THIRD

## order_status_enum
- paid
- cancelled
- shipped
- completed

---

# COUNTRY HANDLING (MVP RULES)

## country_code
- Stored as ISO 3166-1 alpha-2 string (e.g., "IT", "FR", "DE")

Rules:
- Buyers can be from any country.
- Sellers must be Italian:
  - country_code must be "IT"
  - region must be NOT NULL

Buyer onboarding:
- Always asks country_code
- If country_code == "IT" → ask region
- Otherwise → region = NULL

---

# TABLES

---

## users

- id (uuid, PK)
- country_code (char(2))  ← ISO-2 country code
- region (region_enum, nullable)  ← required if country_code = "IT"
- role (user_role_enum)
- seller_status (seller_status_enum)
- stripe_account_id (nullable)
- stripe_customer_id (nullable)
- first_name
- last_name
- bio (nullable)
- profile_image_url (nullable)
- tesserino_number (unique, nullable)
- is_active (boolean)
- deleted_at (nullable)
- created_at

Constraints (recommended):
- CHECK: (country_code = 'IT' AND region IS NOT NULL) OR (country_code <> 'IT' AND region IS NULL)
- CHECK: If role = 'seller' OR seller_status IN ('pending','approved','rejected') THEN country_code = 'IT' AND region IS NOT NULL

Relationships:
- One-to-many orders (as buyer)
- One-to-many orders (as seller)
- One-to-many truffles
- One-to-many reviews (as buyer)
- One-to-many reviews (as seller)

---

## shipping_addresses

- id (uuid, PK)
- user_id (FK → users.id)
- full_name
- street
- city
- postal_code
- country_code (char(2))  ← ISO-2
- phone
- is_default
- created_at

Private table.

---

## truffles

- id (uuid, PK)
- seller_id (FK → users.id)
- truffle_type (truffle_type_enum)
- quality (truffle_quality_enum)
- weight_grams (int)
- price_total (decimal)
- price_per_kg (decimal, generated/stored, server-derived)
- shipping_price_italy (decimal)
- shipping_price_abroad (decimal)
- region (region_enum)  ← region of harvest (Italy)
- harvest_date (date, no future dates)
- status (active / sold / expired)
- expires_at (timestamp)
- created_at

Constraints:
- weight_grams > 0
- price_total > 0

---

## truffle_images

- id (uuid, PK)
- truffle_id (FK → truffles.id)
- image_url
- order_index

One truffle must have 1–3 images.

---

## orders

- id (uuid, PK)
- truffle_id (FK → truffles.id)
- buyer_id (FK → users.id)
- seller_id (FK → users.id)
- status (order_status_enum)
- tracking_code (nullable)

Shipping snapshot fields:
- shipping_full_name
- shipping_street
- shipping_city
- shipping_postal_code
- shipping_country_code (char(2))
- shipping_phone

Financial fields:
- total_price (decimal)
- commission_amount (decimal)
- seller_amount (decimal)
- stripe_payment_intent_id
- created_at

Constraints:
- buyer_id != seller_id
- commission = 10% (server enforced)

---

## reviews

- id (uuid, PK)
- order_id (FK → orders.id, unique)
- rating (1–5)
- comment (nullable)
- created_at

Constraint:
- One review per order

Note: seller/buyer derived from orders via join

---

## favorites

- id (uuid, PK)
- user_id (FK → users.id)
- truffle_id (FK → truffles.id)
- created_at

Unique:
- (user_id, truffle_id)

---

## notifications

- id (uuid, PK)
- user_id (FK → users.id)
- type
- message
- read (boolean)
- created_at

---

## seller_documents

Metadata table only (no public URLs).

- id (uuid, PK)
- user_id (FK → users.id, unique)
- tesserino_number
- uploaded_at

Files stored in private Supabase Storage bucket:
- identity document (temporary, deleted on approval)
- tesserino (kept on approval; deleted on rejection)

---

## audit_logs

- id (uuid, PK)
- entity_type
- entity_id
- action
- performed_by
- metadata (json)
- created_at

Immutable log table.

---

# RELATIONAL SUMMARY

users
  ├── shipping_addresses
  ├── truffles
  ├── orders (buyer)
  ├── orders (seller)
  ├── reviews (buyer)
  ├── reviews (seller)
  ├── favorites
  ├── notifications
  └── seller_documents

orders
  └── reviews (1:1)

truffles
  └── truffle_images (1:many)

---

# STATE MACHINE

paid → shipped  
paid → cancelled  
shipped → completed  

All transitions server-enforced.
