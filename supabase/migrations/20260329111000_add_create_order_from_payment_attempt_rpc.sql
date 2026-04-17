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
      processed_at = timezone('utc', now()),
      failure_code = null,
      failure_message = null
    where id = v_attempt.id;

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
    stripe_payment_intent_id
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
    v_attempt.stripe_payment_intent_id
  )
  returning id into v_created_order_id;

  update public.payment_attempts
  set
    status = 'succeeded',
    order_id = v_created_order_id,
    processed_at = timezone('utc', now()),
    failure_code = null,
    failure_message = null
  where id = v_attempt.id;

  return query
  select v_created_order_id, 'succeeded'::public.payment_attempt_status_enum, true;
end;
$$;

revoke all on function public.set_payment_attempt_updated_at() from public, anon, authenticated;
revoke all on function public.create_order_from_payment_attempt(uuid, text) from public, anon, authenticated;
grant execute on function public.create_order_from_payment_attempt(uuid, text) to service_role;
