create table if not exists public.truffle_guides (
  id uuid primary key default gen_random_uuid(),
  truffle_type public.truffle_type_enum not null unique,
  latin_name text not null,
  title_it text not null,
  title_en text not null,
  short_description_it text not null,
  short_description_en text not null,
  description_it text not null,
  description_en text not null,
  aroma_it text not null,
  aroma_en text not null,
  price_min_eur integer not null,
  price_max_eur integer not null,
  rarity smallint not null check (rarity between 1 and 5),
  symbiotic_plants_it text[] not null default '{}',
  symbiotic_plants_en text[] not null default '{}',
  soil_composition_it text not null,
  soil_composition_en text not null,
  soil_structure_it text not null,
  soil_structure_en text not null,
  soil_ph_it text not null,
  soil_ph_en text not null,
  soil_altitude_it text not null,
  soil_altitude_en text not null,
  soil_humidity_it text not null,
  soil_humidity_en text not null,
  harvest_start_month smallint not null check (harvest_start_month between 1 and 12),
  harvest_end_month smallint not null check (harvest_end_month between 1 and 12),
  is_published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint truffle_guides_price_range_chk check (price_max_eur >= price_min_eur)
);

create index if not exists truffle_guides_published_sort_idx
  on public.truffle_guides (is_published, sort_order);

alter table public.truffle_guides enable row level security;

create policy "Authenticated users can read published truffle guides"
  on public.truffle_guides
  for select
  to authenticated
  using (is_published = true);

create or replace function public.set_truffle_guides_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists truffle_guides_set_updated_at
on public.truffle_guides;

create trigger truffle_guides_set_updated_at
before update on public.truffle_guides
for each row
execute function public.set_truffle_guides_updated_at();

grant select on public.truffle_guides to authenticated;