# Seasonal Highlight (Buyer Home)

## How It Works
- Data source: `public.truffle_season_windows` (national-only windows, no region logic).
- Backend resolver: `public.get_buyer_home_seasonal_highlight(lang text default 'it')`.
- Response shape is always stable:
  - `mode`
  - `cards` (always an array)
  - `countdown` (object or `null`)
- Active mode:
  - uses `current_date`
  - returns all enabled rows where `current_date between start_date and end_date`
  - ordered by ascending `priority`
- Countdown mode:
  - when no active rows exist
  - returns nearest future `start_date` row
  - `days_remaining` is non-negative integer

## Yearly Update (Example for 2027)
```sql
insert into public.truffle_season_windows (
  season_year,
  truffle_type,
  start_date,
  end_date,
  priority,
  title_it,
  subtitle_it,
  title_en,
  subtitle_en,
  image_key,
  is_enabled
)
select
  2027 as season_year,
  truffle_type,
  start_date + interval '1 year',
  end_date + interval '1 year',
  priority,
  title_it,
  subtitle_it,
  title_en,
  subtitle_en,
  image_key,
  is_enabled
from public.truffle_season_windows
where season_year = 2026
on conflict (season_year, truffle_type) do update
set
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  priority = excluded.priority,
  title_it = excluded.title_it,
  subtitle_it = excluded.subtitle_it,
  title_en = excluded.title_en,
  subtitle_en = excluded.subtitle_en,
  image_key = excluded.image_key,
  is_enabled = excluded.is_enabled;
```

After duplication, manually adjust `start_date` and `end_date` as needed.
`season_year` is only a grouping key, and `end_date` can cross into the next calendar year.

## Backend Validation Queries
```sql
-- Active mode ordering check
select public.get_buyer_home_seasonal_highlight('it');

-- Countdown fallback localization checks
select public.get_buyer_home_seasonal_highlight('fr');
select public.get_buyer_home_seasonal_highlight(null);
```

## Verification Commands
```bash
# 1) Regenerate localizations (ARB is source of truth)
cd app/truffly_app
flutter gen-l10n

# 2) Run feature-focused Flutter tests
flutter test test/features/home -r expanded

# 3) Run executable backend verification
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  -f supabase/scripts/verify_seasonal_highlight.sql
```

`app_localizations*.dart` files are generated artifacts and must come from
`app_en.arb` + `app_it.arb` via `flutter gen-l10n`.

## Manual QA
- Expected on `2026-03-19` with provided seed:
  - `mode = "active"`
  - cards include:
    - `TUBER_BORCHII` (priority 3)
    - `TUBER_BRUMALE` (priority 4)
  - ordered by priority asc.
- To force countdown mode:
```sql
update public.truffle_season_windows
set is_enabled = false
where start_date <= '2026-03-19'
  and end_date >= '2026-03-19';
```
- Then call RPC again and verify:
  - `mode = "countdown"`
  - exactly one `countdown` object
  - `cards = []`.
