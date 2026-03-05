# Project Status - Truffly

Current phase: Backend setup & Flutter integration
Goal: Build MVP marketplace for truffles

---

# Completed

## Project Setup

* Git repository initialized
* GitHub repository created
* Flutter project created
* Initial Flutter app runs successfully

## Supabase Setup

* Supabase project created
* Supabase CLI installed
* Supabase initialized locally
* Local Supabase stack running

## Database

* Migration file created: `init_schema.sql`

Initial MVP PostgreSQL schema generated in migration:

* ENUM types
* Tables
* Relationships
* Constraints
* Indexes
* RLS enabled on all tables
* RLS policies generated

Main entities implemented:

* users
* shipping_addresses
* truffles
* truffle_images
* orders
* reviews
* favorites
* notifications
* seller_documents
* audit_logs

## Seed Data

* `seed.sql` created
* Local database populated with test users, truffles, orders and reviews

---

# Current Task

## Connect Flutter to Local Supabase

The Flutter application must now connect to the **local Supabase instance** for development.

Tasks:

* Add `supabase_flutter` dependency
* Initialize Supabase client in Flutter
* Configure connection to local Supabase API
* Test authentication
* Test database queries
* Test RLS policies through Flutter app

---

# Next Task

## Define Flutter Project Architecture

The project will follow a **feature-first architecture with clean separation of layers**, making the code scalable and maintainable.

Recommended structure:

```
lib/

core/
  config/
    supabase_config.dart
  constants/
  utils/
  theme/

features/

  auth/
    data/
      models/
      repositories/
    domain/
      entities/
      repositories/
      usecases/
    presentation/
      screens/
      widgets/

  marketplace/
    data/
      models/
      repositories/
    domain/
      entities/
      usecases/
    presentation/
      screens/
      widgets/

  truffle/
    data/
      models/
      repositories/
    domain/
      entities/
      usecases/
    presentation/
      screens/
      widgets/

  orders/
    data/
      models/
      repositories/
    domain/
      entities/
      usecases/
    presentation/
      screens/
      widgets/

  profile/
    data/
      models/
      repositories/
    domain/
      entities/
      usecases/
    presentation/
      screens/
      widgets/

services/
  supabase_service.dart
  auth_service.dart
  storage_service.dart

shared/
  widgets/
  components/

main.dart
```

Architecture layers:

* **data** → API calls, Supabase queries, models
* **domain** → business logic and entities
* **presentation** → UI screens and widgets

This structure keeps the project modular and easier to extend.
