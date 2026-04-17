create type public.payment_attempt_status_enum as enum (
  'requires_payment_method',
  'succeeded',
  'failed',
  'expired'
);

create type public.stripe_webhook_event_status_enum as enum (
  'processing',
  'processed',
  'failed',
  'ignored'
);

create table public.payment_attempts (
  id uuid primary key,
  buyer_id uuid not null references public.users(id) on delete restrict,
  seller_id uuid not null references public.users(id) on delete restrict,
  truffle_id uuid not null references public.truffles(id) on delete restrict,
  shipping_address_id uuid not null references public.shipping_addresses(id) on delete restrict,
  order_id uuid unique references public.orders(id) on delete set null,
  status public.payment_attempt_status_enum not null default 'requires_payment_method',
  request_fingerprint text not null,
  stripe_payment_intent_id text unique,
  failure_code text,
  failure_message text,
  shipping_full_name text not null,
  shipping_street text not null,
  shipping_city text not null,
  shipping_postal_code text not null,
  shipping_country_code char(2) not null,
  shipping_phone text not null,
  currency text not null default 'eur',
  total_price numeric(10,2) not null,
  commission_amount numeric(10,2) not null,
  seller_amount numeric(10,2) not null,
  expires_at timestamptz not null,
  processed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint payment_attempts_buyer_not_seller_chk check (buyer_id <> seller_id),
  constraint payment_attempts_shipping_country_code_format_chk check (shipping_country_code ~ '^[A-Z]{2}$'),
  constraint payment_attempts_currency_chk check (currency = 'eur'),
  constraint payment_attempts_total_price_chk check (total_price > 0),
  constraint payment_attempts_commission_amount_chk check (commission_amount >= 0),
  constraint payment_attempts_seller_amount_chk check (seller_amount >= 0),
  constraint payment_attempts_amounts_sum_chk check (total_price = commission_amount + seller_amount),
  constraint payment_attempts_commission_ratio_chk check (commission_amount = round(total_price * 0.10, 2)),
  constraint payment_attempts_expires_after_created_chk check (expires_at > created_at)
);

create index payment_attempts_buyer_id_created_at_idx
  on public.payment_attempts (buyer_id, created_at desc);

create index payment_attempts_seller_id_created_at_idx
  on public.payment_attempts (seller_id, created_at desc);

create index payment_attempts_truffle_id_created_at_idx
  on public.payment_attempts (truffle_id, created_at desc);

create index payment_attempts_status_created_at_idx
  on public.payment_attempts (status, created_at desc);

create unique index payment_attempts_one_open_attempt_per_truffle_idx
  on public.payment_attempts (truffle_id)
  where status = 'requires_payment_method';

create table public.stripe_webhook_events (
  id uuid primary key default gen_random_uuid(),
  stripe_event_id text not null unique,
  event_type text not null,
  stripe_object_id text,
  processing_status public.stripe_webhook_event_status_enum not null default 'processing',
  request_id text,
  error_code text,
  error_message text,
  metadata jsonb not null default '{}'::jsonb,
  received_at timestamptz not null default timezone('utc', now()),
  processed_at timestamptz
);

create index stripe_webhook_events_event_type_received_at_idx
  on public.stripe_webhook_events (event_type, received_at desc);

create index stripe_webhook_events_processing_status_received_at_idx
  on public.stripe_webhook_events (processing_status, received_at desc);

alter table public.payment_attempts enable row level security;
alter table public.stripe_webhook_events enable row level security;

drop policy if exists payment_attempts_select_service_only on public.payment_attempts;
drop policy if exists payment_attempts_insert_service_only on public.payment_attempts;
drop policy if exists payment_attempts_update_service_only on public.payment_attempts;

create policy payment_attempts_select_service_only
  on public.payment_attempts
  for select
  to service_role
  using (true);

create policy payment_attempts_insert_service_only
  on public.payment_attempts
  for insert
  to service_role
  with check (true);

create policy payment_attempts_update_service_only
  on public.payment_attempts
  for update
  to service_role
  using (true)
  with check (true);

drop policy if exists stripe_webhook_events_select_service_only on public.stripe_webhook_events;
drop policy if exists stripe_webhook_events_insert_service_only on public.stripe_webhook_events;
drop policy if exists stripe_webhook_events_update_service_only on public.stripe_webhook_events;

create policy stripe_webhook_events_select_service_only
  on public.stripe_webhook_events
  for select
  to service_role
  using (true);

create policy stripe_webhook_events_insert_service_only
  on public.stripe_webhook_events
  for insert
  to service_role
  with check (true);

create policy stripe_webhook_events_update_service_only
  on public.stripe_webhook_events
  for update
  to service_role
  using (true)
  with check (true);

create or replace function public.set_payment_attempt_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists payment_attempts_set_updated_at on public.payment_attempts;
create trigger payment_attempts_set_updated_at
before update on public.payment_attempts
for each row
execute function public.set_payment_attempt_updated_at();
