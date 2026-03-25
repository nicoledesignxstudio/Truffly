begin;

create or replace function pg_temp.assert_true(condition boolean, message text)
returns void
language plpgsql
as $$
begin
  if not condition then
    raise exception '%', message;
  end if;
end;
$$;

select pg_temp.assert_true(
  to_regclass('public.truffle_season_windows') is not null,
  'missing table public.truffle_season_windows'
);

-- Seed-based deterministic check requested by product/review.
do $$
declare
  active_types text[];
begin
  select array_agg(w.truffle_type::text order by w.priority asc)
    into active_types
  from public.truffle_season_windows w
  where w.is_enabled = true
    and date '2026-03-19' between w.start_date and w.end_date
    and w.season_year = 2026;

  perform pg_temp.assert_true(
    active_types = array['TUBER_BORCHII', 'TUBER_BRUMALE'],
    'seed expectation failed for 2026-03-19 active ordering'
  );
end;
$$;

-- Unauthenticated must be denied.
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '', true);

do $$
begin
  perform public.get_buyer_home_seasonal_highlight('it');
  raise exception 'expected unauthenticated request to be denied';
exception
  when sqlstate '42501' then
    null;
end;
$$;

-- Create an inactive authenticated profile for denial checks.
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values (
  '00000000-0000-0000-0000-000000000000',
  '99999999-9999-9999-9999-999999999999',
  'authenticated',
  'authenticated',
  'inactive-seasonal@test.com',
  crypt('DevPass123!', gen_salt('bf')),
  timezone('utc', now()),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
)
on conflict (id) do update
set
  email = excluded.email,
  encrypted_password = excluded.encrypted_password,
  updated_at = excluded.updated_at;

insert into public.users (
  id,
  country_code,
  region,
  role,
  seller_status,
  is_active,
  onboarding_completed
)
values (
  '99999999-9999-9999-9999-999999999999',
  'IT',
  'TOSCANA',
  'buyer',
  'not_requested',
  false,
  true
)
on conflict (id) do update
set
  is_active = false,
  role = 'buyer',
  seller_status = 'not_requested',
  country_code = 'IT',
  region = 'TOSCANA',
  onboarding_completed = true;

select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '99999999-9999-9999-9999-999999999999', true);

do $$
begin
  perform public.get_buyer_home_seasonal_highlight('it');
  raise exception 'expected inactive authenticated account to be denied';
exception
  when sqlstate '42501' then
    null;
end;
$$;

-- Active authenticated account must be allowed.
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '11111111-1111-1111-1111-111111111111', true);

-- Isolate RPC contract checks by disabling existing windows and inserting controlled rows.
update public.truffle_season_windows
set is_enabled = false;

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
values
(
  2099,
  'TUBER_BORCHII',
  current_date - 3,
  current_date + 2,
  1,
  'IT Active One',
  'IT Active One Subtitle',
  'EN Active One',
  'EN Active One Subtitle',
  'seasonal/test-active-one',
  true
),
(
  2099,
  'TUBER_BRUMALE',
  current_date - 2,
  current_date + 4,
  2,
  'IT Active Two',
  'IT Active Two Subtitle',
  'EN Active Two',
  'EN Active Two Subtitle',
  'seasonal/test-active-two',
  true
),
(
  2099,
  'TUBER_MAGNATUM',
  current_date + 7,
  current_date + 25,
  3,
  'IT Countdown',
  'IT Countdown Subtitle',
  'EN Countdown',
  'EN Countdown Subtitle',
  'seasonal/test-countdown',
  true
)
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

do $$
declare
  payload jsonb;
  active_types text[];
begin
  payload := public.get_buyer_home_seasonal_highlight('it');
  perform pg_temp.assert_true(payload ? 'mode', 'payload missing mode key');
  perform pg_temp.assert_true(payload ? 'cards', 'payload missing cards key');
  perform pg_temp.assert_true(payload ? 'countdown', 'payload missing countdown key');
  perform pg_temp.assert_true(payload->>'mode' = 'active', 'expected active mode');

  select array_agg(item->>'truffle_type' order by (item->>'priority')::int asc)
    into active_types
  from jsonb_array_elements(payload->'cards') item;

  perform pg_temp.assert_true(
    active_types = array['TUBER_BORCHII', 'TUBER_BRUMALE'],
    'active cards are not ordered by ascending priority'
  );

  perform pg_temp.assert_true(
    (payload->'countdown') is null,
    'countdown must be null in active mode'
  );
end;
$$;

do $$
declare
  payload_en jsonb;
begin
  payload_en := public.get_buyer_home_seasonal_highlight('en');
  perform pg_temp.assert_true(
    payload_en->'cards'->0->>'title' = 'EN Active One',
    'lang=en should return english title'
  );
end;
$$;

-- Force countdown mode.
update public.truffle_season_windows
set is_enabled = false
where season_year = 2099
  and truffle_type in ('TUBER_BORCHII', 'TUBER_BRUMALE');

do $$
declare
  payload_it jsonb;
  payload_fr jsonb;
  payload_null jsonb;
  days_remaining integer;
begin
  payload_it := public.get_buyer_home_seasonal_highlight('it');
  perform pg_temp.assert_true(payload_it->>'mode' = 'countdown', 'expected countdown mode');
  perform pg_temp.assert_true(
    jsonb_array_length(payload_it->'cards') = 0,
    'cards must be empty array in countdown mode'
  );
  perform pg_temp.assert_true(
    payload_it->'countdown'->>'truffle_type' = 'TUBER_MAGNATUM',
    'countdown should point to nearest upcoming season'
  );

  days_remaining := (payload_it->'countdown'->>'days_remaining')::int;
  perform pg_temp.assert_true(days_remaining >= 0, 'days_remaining must be >= 0');

  payload_fr := public.get_buyer_home_seasonal_highlight('fr');
  perform pg_temp.assert_true(
    payload_fr->'countdown'->>'title' = 'IT Countdown',
    'unknown lang must fallback to italian title'
  );

  payload_null := public.get_buyer_home_seasonal_highlight(null);
  perform pg_temp.assert_true(
    payload_null->'countdown'->>'title' = 'IT Countdown',
    'null lang must fallback to italian title'
  );
end;
$$;

rollback;
