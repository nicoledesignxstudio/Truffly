create table if not exists public.truffle_season_windows (
  id uuid primary key default gen_random_uuid(),
  season_year integer not null,
  truffle_type public.truffle_type_enum not null,
  start_date date not null,
  end_date date not null,
  priority integer not null,
  title_it text not null,
  subtitle_it text not null,
  title_en text not null,
  subtitle_en text not null,
  image_key text,
  is_enabled boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint truffle_season_windows_year_type_key unique (season_year, truffle_type),
  constraint truffle_season_windows_end_after_start_chk check (end_date >= start_date),
  constraint truffle_season_windows_priority_positive_chk check (priority > 0)
);

comment on table public.truffle_season_windows is
  'National seasonal windows for buyer home highlights. season_year is a grouping key only; end_date may be in a different calendar year.';

alter table public.truffle_season_windows enable row level security;

revoke all on table public.truffle_season_windows from anon, authenticated;

create or replace function public.set_truffle_season_windows_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists truffle_season_windows_set_updated_at
on public.truffle_season_windows;

create trigger truffle_season_windows_set_updated_at
before update on public.truffle_season_windows
for each row
execute function public.set_truffle_season_windows_updated_at();

create or replace function public.get_buyer_home_seasonal_highlight(lang text default 'it')
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  normalized_lang text := case
    when lower(coalesce(lang, '')) = 'en' then 'en'
    else 'it'
  end;
  active_cards jsonb := '[]'::jsonb;
  countdown_card jsonb := null;
begin
  if (select auth.uid()) is null or not public.is_active_account() then
    raise exception 'Not allowed'
      using errcode = '42501';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'truffle_type', w.truffle_type::text,
        'priority', w.priority,
        'title', case
          when normalized_lang = 'en' then w.title_en
          else w.title_it
        end,
        'subtitle', case
          when normalized_lang = 'en' then w.subtitle_en
          else w.subtitle_it
        end,
        'image_key', w.image_key,
        'start_date', to_char(w.start_date, 'YYYY-MM-DD'),
        'end_date', to_char(w.end_date, 'YYYY-MM-DD')
      )
      order by w.priority asc
    ),
    '[]'::jsonb
  )
    into active_cards
  from public.truffle_season_windows w
  where w.is_enabled = true
    and current_date between w.start_date and w.end_date;

  if jsonb_array_length(active_cards) > 0 then
    return jsonb_build_object(
      'mode', 'active',
      'cards', active_cards,
      'countdown', null
    );
  end if;

  select jsonb_build_object(
      'truffle_type', w.truffle_type::text,
      'title', case
        when normalized_lang = 'en' then w.title_en
        else w.title_it
      end,
      'subtitle', case
        when normalized_lang = 'en' then w.subtitle_en
        else w.subtitle_it
      end,
      'image_key', w.image_key,
      'target_date', to_char(w.start_date, 'YYYY-MM-DD'),
      'days_remaining', greatest((w.start_date - current_date), 0)
    )
    into countdown_card
  from public.truffle_season_windows w
  where w.is_enabled = true
    and w.start_date > current_date
  order by w.start_date asc, w.priority asc
  limit 1;

  return jsonb_build_object(
    'mode', 'countdown',
    'cards', '[]'::jsonb,
    'countdown', countdown_card
  );
end;
$$;

revoke all on function public.get_buyer_home_seasonal_highlight(text) from public;
grant execute on function public.get_buyer_home_seasonal_highlight(text) to authenticated;
