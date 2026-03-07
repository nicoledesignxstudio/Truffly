
create extension if not exists "pgcrypto";

create type public.user_role_enum as enum ('buyer', 'seller');
create type public.seller_status_enum as enum ('not_requested', 'pending', 'approved', 'rejected');
create type public.region_enum as enum (
  'ABRUZZO',
  'BASILICATA',
  'CALABRIA',
  'CAMPANIA',
  'EMILIA_ROMAGNA',
  'FRIULI_VENEZIA_GIULIA',
  'LAZIO',
  'LIGURIA',
  'LOMBARDIA',
  'MARCHE',
  'MOLISE',
  'PIEMONTE',
  'PUGLIA',
  'SARDEGNA',
  'SICILIA',
  'TOSCANA',
  'TRENTINO_ALTO_ADIGE',
  'UMBRIA',
  'VALLE_DAOSTA',
  'VENETO'
);
create type public.truffle_type_enum as enum (
  'TUBER_MAGNATUM',
  'TUBER_MELANOSPORUM',
  'TUBER_AESTIVUM',
  'TUBER_UNCINATUM',
  'TUBER_BORCHII',
  'TUBER_BRUMALE'
);
create type public.truffle_quality_enum as enum ('FIRST', 'SECOND', 'THIRD');
create type public.truffle_status_enum as enum ('active', 'sold', 'expired');
create type public.order_status_enum as enum ('paid', 'cancelled', 'shipped', 'completed');

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  country_code char(2),
  region public.region_enum,
  role public.user_role_enum not null default 'buyer',
  seller_status public.seller_status_enum not null default 'not_requested',
  stripe_account_id text,
  stripe_customer_id text,
  first_name text,
  last_name text,
  bio text,
  profile_image_url text,
  tesserino_number text unique,
  seller_review_count integer not null default 0,
  seller_rating_avg numeric(2,1) not null default 0,
  is_active boolean not null default true,
  onboarding_completed boolean not null default false;
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  constraint users_country_code_format_chk check (country_code ~ '^[A-Z]{2}$'),
  constraint users_country_region_chk check (
    (country_code = 'IT' and region is not null)
    or (country_code <> 'IT' and region is null)
  ),
  constraint users_seller_italy_chk check (
    not (
      role = 'seller'
      or seller_status in ('pending', 'approved', 'rejected')
    )
    or (country_code = 'IT' and region is not null)
  )
);

create table public.shipping_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  full_name text not null,
  street text not null,
  city text not null,
  postal_code text not null,
  country_code char(2) not null,
  phone text not null,
  is_default boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  constraint shipping_addresses_country_code_format_chk check (country_code ~ '^[A-Z]{2}$')
);

create table public.truffles (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.users(id) on delete restrict,
  truffle_type public.truffle_type_enum not null,
  quality public.truffle_quality_enum not null,
  weight_grams integer not null,
  price_total numeric(10,2) not null,
  price_per_kg numeric(10,2) generated always as ((price_total / weight_grams) * 1000) stored,
  shipping_price_italy numeric(10,2) not null,
  shipping_price_abroad numeric(10,2) not null,
  region public.region_enum not null,
  harvest_date date not null,
  status public.truffle_status_enum not null default 'active',
  expires_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now()),
  constraint truffles_weight_grams_chk check (weight_grams > 0),
  constraint truffles_price_total_chk check (price_total > 0),
  constraint truffles_price_per_kg_chk check (price_per_kg > 0),
  constraint truffles_shipping_price_italy_chk check (shipping_price_italy >= 0),
  constraint truffles_shipping_price_abroad_chk check (shipping_price_abroad >= 0),
  constraint truffles_expires_after_created_chk check (expires_at > created_at),
  constraint truffles_harvest_date_chk check (harvest_date <= current_date)
);

create table public.truffle_images (
  id uuid primary key default gen_random_uuid(),
  truffle_id uuid not null references public.truffles(id) on delete cascade,
  image_url text not null,
  order_index smallint not null,
  constraint truffle_images_order_index_chk check (order_index between 1 and 3),
  constraint truffle_images_truffle_id_order_index_key unique (truffle_id, order_index)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  truffle_id uuid not null references public.truffles(id) on delete restrict,
  buyer_id uuid not null references public.users(id) on delete restrict,
  seller_id uuid not null references public.users(id) on delete restrict,
  status public.order_status_enum not null default 'paid',
  tracking_code text,
  shipping_full_name text not null,
  shipping_street text not null,
  shipping_city text not null,
  shipping_postal_code text not null,
  shipping_country_code char(2) not null,
  shipping_phone text not null,
  total_price numeric(10,2) not null,
  commission_amount numeric(10,2) not null,
  seller_amount numeric(10,2) not null,
  stripe_payment_intent_id text not null unique,
  created_at timestamptz not null default timezone('utc', now()),
  constraint orders_buyer_not_seller_chk check (buyer_id <> seller_id),
  constraint orders_shipping_country_code_format_chk check (shipping_country_code ~ '^[A-Z]{2}$'),
  constraint orders_total_price_chk check (total_price > 0),
  constraint orders_commission_amount_chk check (commission_amount >= 0),
  constraint orders_seller_amount_chk check (seller_amount >= 0),
  constraint orders_amounts_sum_chk check (total_price = commission_amount + seller_amount),
  constraint orders_commission_ratio_chk check (commission_amount = round(total_price * 0.10, 2))
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references public.orders(id) on delete restrict,
  rating smallint not null,
  comment text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint reviews_rating_chk check (rating between 1 and 5)
);

create table public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  truffle_id uuid not null references public.truffles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint favorites_user_id_truffle_id_key unique (user_id, truffle_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  type text not null,
  message text not null,
  read boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create table public.seller_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  tesserino_number text not null,
  uploaded_at timestamptz not null default timezone('utc', now())
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid not null,
  action text not null,
  performed_by uuid references public.users(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index users_role_idx on public.users (role);
create index users_seller_status_idx on public.users (seller_status);
create index users_country_region_idx on public.users (country_code, region);

create index shipping_addresses_user_id_idx on public.shipping_addresses (user_id);
create unique index shipping_addresses_default_per_user_idx
  on public.shipping_addresses (user_id)
  where is_default = true;

create index truffles_seller_id_idx on public.truffles (seller_id);
create index truffles_status_idx on public.truffles (status);
create index truffles_type_idx on public.truffles (truffle_type);
create index truffles_quality_idx on public.truffles (quality);
create index truffles_region_idx on public.truffles (region);
create index truffles_expires_at_idx on public.truffles (expires_at);
create index truffles_created_at_idx on public.truffles (created_at desc);

create index truffle_images_truffle_id_idx on public.truffle_images (truffle_id);

create index orders_truffle_id_idx on public.orders (truffle_id);
create index orders_buyer_id_created_at_idx on public.orders (buyer_id, created_at desc);
create index orders_seller_id_created_at_idx on public.orders (seller_id, created_at desc);
create index orders_status_idx on public.orders (status);

create index reviews_created_at_idx on public.reviews (created_at desc);

create index favorites_user_id_idx on public.favorites (user_id);
create index favorites_truffle_id_idx on public.favorites (truffle_id);

create index notifications_user_id_read_created_at_idx
  on public.notifications (user_id, read, created_at desc);

create index seller_documents_user_id_idx on public.seller_documents (user_id);

create index audit_logs_entity_idx on public.audit_logs (entity_type, entity_id);
create index audit_logs_performed_by_idx on public.audit_logs (performed_by);
create index audit_logs_created_at_idx on public.audit_logs (created_at desc);

alter table public.users enable row level security;
alter table public.shipping_addresses enable row level security;
alter table public.truffles enable row level security;
alter table public.truffle_images enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.favorites enable row level security;
alter table public.notifications enable row level security;
alter table public.seller_documents enable row level security;
alter table public.audit_logs enable row level security;

