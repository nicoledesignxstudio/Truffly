create or replace function public.notification_order_metadata(
  p_order_id uuid,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_truffle_id uuid;
  v_truffle_type text;
  v_weight_grams integer;
  v_truffle_label text;
  v_display_name text;
begin
  select
    t.id,
    t.truffle_type::text,
    t.weight_grams,
    case t.truffle_type::text
      when 'TUBER_MAGNATUM' then 'Bianco pregiato'
      when 'TUBER_MELANOSPORUM' then 'Nero pregiato'
      when 'TUBER_AESTIVUM' then 'Scorzone'
      when 'TUBER_UNCINATUM' then 'Uncinato'
      when 'TUBER_BORCHII' then 'Bianchetto'
      when 'TUBER_BRUMALE' then 'Brumale'
      when 'TUBER_MACROSPORUM' then 'Nero liscio'
      when 'TUBER_BRUMALE_MOSCHATUM' then 'Brumale moscato'
      when 'TUBER_MESENTERICUM' then 'Mesenterico'
      else initcap(replace(t.truffle_type::text, '_', ' '))
    end
  into v_truffle_id, v_truffle_type, v_weight_grams, v_truffle_label
  from public.orders o
  join public.truffles t on t.id = o.truffle_id
  where o.id = p_order_id;

  if not found then
    return coalesce(p_metadata, '{}'::jsonb);
  end if;

  v_display_name := v_truffle_label || ' ' || v_weight_grams::text || 'g';

  return coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
    'order_id', p_order_id,
    'truffle_id', v_truffle_id,
    'truffle_type', v_truffle_type,
    'truffle_name', v_display_name,
    'truffle_display_name', v_display_name,
    'weight_grams', v_weight_grams
  );
end;
$$;

create or replace function public.enrich_notification_order_metadata()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_order_id uuid;
begin
  if new.metadata is null or not (new.metadata ? 'order_id') then
    return new;
  end if;

  begin
    v_order_id := (new.metadata ->> 'order_id')::uuid;
  exception
    when invalid_text_representation then
      return new;
  end;

  new.metadata := public.notification_order_metadata(v_order_id, new.metadata);
  return new;
end;
$$;

drop trigger if exists notifications_enrich_order_metadata on public.notifications;
create trigger notifications_enrich_order_metadata
before insert or update of metadata on public.notifications
for each row execute function public.enrich_notification_order_metadata();

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

  insert into public.notifications (
    user_id,
    type,
    message,
    target_route,
    target_id,
    metadata
  )
  values
    (
      v_attempt.buyer_id,
      'order_confirmed',
      'Your order has been confirmed.',
      '/orders/' || v_created_order_id::text,
      v_created_order_id::text,
      jsonb_build_object('order_id', v_created_order_id)
    ),
    (
      v_attempt.seller_id,
      'seller_new_order',
      'You received a new order.',
      '/seller/orders/' || v_created_order_id::text,
      v_created_order_id::text,
      jsonb_build_object('order_id', v_created_order_id)
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

revoke all on function public.notification_order_metadata(uuid, jsonb) from public, anon, authenticated;
revoke all on function public.enrich_notification_order_metadata() from public, anon, authenticated;
revoke all on function public.create_order_from_payment_attempt(uuid, text) from public, anon, authenticated;
grant execute on function public.create_order_from_payment_attempt(uuid, text) to service_role;
