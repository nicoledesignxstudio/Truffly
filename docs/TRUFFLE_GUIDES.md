# Truffle Guides

## How it works
- Data source: `public.truffle_guides` (one row per `truffle_type_enum`).
- Client reads only published guides (`is_published = true`) through RLS-authenticated `SELECT`.
- Images are never stored in DB and are derived from enum:
  - `assets/images/guides/<TRUFFLE_TYPE>.jpeg`
- App flow:
  - list page: `/guides`
  - detail page: `/guides/truffles/:truffleType`

## Backend
- Migration: `supabase/migrations/20260320130000_create_truffle_guides.sql`
  - table, checks, indexes
  - trigger function: `public.set_truffle_guides_updated_at()`
  - trigger: `truffle_guides_set_updated_at`
  - RLS enabled, read-only policy for authenticated users on published rows
- Seed: `supabase/seed.sql`
  - idempotent upsert of 9 guide rows (`ON CONFLICT (truffle_type) DO UPDATE`)

## Local run
1. Apply migrations + seed (local Supabase workflow already used in project).
2. Regenerate l10n:
   - `flutter gen-l10n`
3. Run checks:
   - `flutter analyze`
   - `flutter test`

## Notes
- Guide route params are strictly parsed via `TruffleType.tryFromDbValue`; invalid values redirect safely.
- `account/guide` now redirects to `/guides` for backward compatibility.
- Current guide assets available in repo were normalized to `.jpeg` names for enum-based resolution.