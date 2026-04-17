create type public.financial_operation_kind_enum as enum (
  'payment',
  'refund',
  'transfer'
);

create type public.financial_operation_status_enum as enum (
  'pending',
  'processing',
  'succeeded',
  'failed'
);

alter table public.orders
  add column if not exists paid_at timestamptz,
  add column if not exists shipped_at timestamptz,
  add column if not exists completed_at timestamptz,
  add column if not exists cancelled_at timestamptz,
  add column if not exists buyer_delivery_reminder_sent_at timestamptz;

update public.orders
set paid_at = created_at
where paid_at is null;

update public.orders
set shipped_at = created_at
where status = 'shipped'
  and shipped_at is null;

update public.orders
set completed_at = coalesce(shipped_at, created_at)
where status = 'completed'
  and completed_at is null;

update public.orders
set cancelled_at = created_at
where status = 'cancelled'
  and cancelled_at is null;

alter table public.orders
  alter column paid_at set not null;

create table if not exists public.order_financial_operations (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  kind public.financial_operation_kind_enum not null,
  logical_key text not null,
  idempotency_key text not null,
  status public.financial_operation_status_enum not null default 'pending',
  amount numeric(10,2) not null,
  currency char(3) not null default 'EUR',
  stripe_payment_intent_id text,
  stripe_refund_id text,
  stripe_transfer_id text,
  source_charge_id text,
  destination_account_id text,
  request_id text,
  triggered_by uuid references public.users(id) on delete set null,
  trigger_source text not null,
  failure_code text,
  failure_message text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  processed_at timestamptz,
  constraint order_financial_operations_logical_key_key unique (logical_key),
  constraint order_financial_operations_idempotency_key_key unique (idempotency_key),
  constraint order_financial_operations_amount_chk check (amount >= 0),
  constraint order_financial_operations_currency_chk check (currency = upper(currency))
);

create unique index if not exists order_financial_operations_stripe_refund_id_key
  on public.order_financial_operations (stripe_refund_id)
  where stripe_refund_id is not null;

create unique index if not exists order_financial_operations_stripe_transfer_id_key
  on public.order_financial_operations (stripe_transfer_id)
  where stripe_transfer_id is not null;

create index if not exists order_financial_operations_order_created_at_idx
  on public.order_financial_operations (order_id, created_at desc);

create index if not exists order_financial_operations_kind_status_idx
  on public.order_financial_operations (kind, status, created_at asc);

create or replace function public.set_order_financial_operation_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists order_financial_operations_set_updated_at on public.order_financial_operations;

create trigger order_financial_operations_set_updated_at
before update on public.order_financial_operations
for each row
execute function public.set_order_financial_operation_updated_at();

insert into public.order_financial_operations (
  order_id,
  kind,
  logical_key,
  idempotency_key,
  status,
  amount,
  currency,
  stripe_payment_intent_id,
  request_id,
  triggered_by,
  trigger_source,
  metadata,
  processed_at,
  created_at,
  updated_at
)
select
  o.id,
  'payment'::public.financial_operation_kind_enum,
  'payment:order:' || o.id::text,
  'payment:order:' || o.id::text,
  'succeeded'::public.financial_operation_status_enum,
  o.total_price,
  'EUR',
  o.stripe_payment_intent_id,
  'payment_webhook_backfill',
  null,
  'payment_webhook',
  jsonb_build_object(
    'backfilled', true,
    'stripe_payment_intent_id', o.stripe_payment_intent_id
  ),
  coalesce(o.paid_at, o.created_at),
  o.created_at,
  timezone('utc', now())
from public.orders o
where not exists (
  select 1
  from public.order_financial_operations fo
  where fo.logical_key = 'payment:order:' || o.id::text
);

create or replace function public.create_order_from_payment_attempt(
  p_payment_attempt_id uuid,
  p_request_id text default null
)
returns table (
  order_id uuid,
  payment_attempt_status public.payment_attempt_status_enum,
  created boolean
)
language plpgsql
security invoker
set search_path = pg_catalog, public
as $$
declare
  v_attempt public.payment_attempts%rowtype;
  v_existing_order_id uuid;
  v_created_order_id uuid;
  v_now timestamptz := timezone('utc', now());
begin
  select *
    into v_attempt
  from public.payment_attempts pa
  where pa.id = p_payment_attempt_id
  for update;

  if not found then
    raise exception 'payment_attempt_not_found'
      using errcode = 'P0001';
  end if;

  if v_attempt.order_id is not null then
    insert into public.order_financial_operations (
      order_id,
      kind,
      logical_key,
      idempotency_key,
      status,
      amount,
      currency,
      stripe_payment_intent_id,
      request_id,
      triggered_by,
      trigger_source,
      metadata,
      processed_at
    )
    select
      v_attempt.order_id,
      'payment'::public.financial_operation_kind_enum,
      'payment:order:' || v_attempt.order_id::text,
      'payment:order:' || v_attempt.order_id::text,
      'succeeded'::public.financial_operation_status_enum,
      v_attempt.total_price,
      'EUR',
      v_attempt.stripe_payment_intent_id,
      p_request_id,
      v_attempt.buyer_id,
      'payment_webhook',
      jsonb_build_object(
        'payment_attempt_id', v_attempt.id,
        'stripe_payment_intent_id', v_attempt.stripe_payment_intent_id
      ),
      v_now
    where not exists (
      select 1
      from public.order_financial_operations fo
      where fo.logical_key = 'payment:order:' || v_attempt.order_id::text
    );

    return query
    select v_attempt.order_id, v_attempt.status, false;
    return;
  end if;

  if v_attempt.status = 'failed' then
    raise exception 'payment_attempt_failed'
      using errcode = 'P0001';
  end if;

  if v_attempt.status = 'expired' then
    raise exception 'payment_attempt_expired'
      using errcode = 'P0001';
  end if;

  if v_attempt.stripe_payment_intent_id is null then
    raise exception 'payment_attempt_missing_payment_intent'
      using errcode = 'P0001';
  end if;

  select o.id
    into v_existing_order_id
  from public.orders o
  where o.stripe_payment_intent_id = v_attempt.stripe_payment_intent_id
  for update;

  if found then
    update public.payment_attempts
    set
      status = 'succeeded',
      order_id = v_existing_order_id,
      processed_at = v_now,
      failure_code = null,
      failure_message = null
    where id = v_attempt.id;

    insert into public.order_financial_operations (
      order_id,
      kind,
      logical_key,
      idempotency_key,
      status,
      amount,
      currency,
      stripe_payment_intent_id,
      request_id,
      triggered_by,
      trigger_source,
      metadata,
      processed_at
    )
    select
      v_existing_order_id,
      'payment'::public.financial_operation_kind_enum,
      'payment:order:' || v_existing_order_id::text,
      'payment:order:' || v_existing_order_id::text,
      'succeeded'::public.financial_operation_status_enum,
      v_attempt.total_price,
      'EUR',
      v_attempt.stripe_payment_intent_id,
      p_request_id,
      v_attempt.buyer_id,
      'payment_webhook',
      jsonb_build_object(
        'payment_attempt_id', v_attempt.id,
        'stripe_payment_intent_id', v_attempt.stripe_payment_intent_id
      ),
      v_now
    where not exists (
      select 1
      from public.order_financial_operations fo
      where fo.logical_key = 'payment:order:' || v_existing_order_id::text
    );

    return query
    select v_existing_order_id, 'succeeded'::public.payment_attempt_status_enum, false;
    return;
  end if;

  if exists (
    select 1
    from public.orders o
    where o.truffle_id = v_attempt.truffle_id
      and o.status in ('paid', 'shipped', 'completed')
  ) then
    raise exception 'payment_attempt_truffle_unavailable'
      using errcode = 'P0001';
  end if;

  insert into public.orders (
    truffle_id,
    buyer_id,
    seller_id,
    status,
    shipping_full_name,
    shipping_street,
    shipping_city,
    shipping_postal_code,
    shipping_country_code,
    shipping_phone,
    total_price,
    commission_amount,
    seller_amount,
    stripe_payment_intent_id,
    paid_at
  )
  values (
    v_attempt.truffle_id,
    v_attempt.buyer_id,
    v_attempt.seller_id,
    'paid',
    v_attempt.shipping_full_name,
    v_attempt.shipping_street,
    v_attempt.shipping_city,
    v_attempt.shipping_postal_code,
    v_attempt.shipping_country_code,
    v_attempt.shipping_phone,
    v_attempt.total_price,
    v_attempt.commission_amount,
    v_attempt.seller_amount,
    v_attempt.stripe_payment_intent_id,
    v_now
  )
  returning id into v_created_order_id;

  insert into public.order_financial_operations (
    order_id,
    kind,
    logical_key,
    idempotency_key,
    status,
    amount,
    currency,
    stripe_payment_intent_id,
    request_id,
    triggered_by,
    trigger_source,
    metadata,
    processed_at
  )
  values (
    v_created_order_id,
    'payment',
    'payment:order:' || v_created_order_id::text,
    'payment:order:' || v_created_order_id::text,
    'succeeded',
    v_attempt.total_price,
    'EUR',
    v_attempt.stripe_payment_intent_id,
    p_request_id,
    v_attempt.buyer_id,
    'payment_webhook',
    jsonb_build_object(
      'payment_attempt_id', v_attempt.id,
      'stripe_payment_intent_id', v_attempt.stripe_payment_intent_id
    ),
    v_now
  );

  update public.payment_attempts
  set
    status = 'succeeded',
    order_id = v_created_order_id,
    processed_at = v_now,
    failure_code = null,
    failure_message = null
  where id = v_attempt.id;

  return query
  select v_created_order_id, 'succeeded'::public.payment_attempt_status_enum, true;
end;
$$;
