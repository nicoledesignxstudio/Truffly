create or replace function public.cancel_order_after_refund(
  p_order_id uuid,
  p_request_id text default null,
  p_actor_user_id uuid default null,
  p_reason text default 'refund_processed'
)
returns table (
  order_id uuid,
  resulting_status public.order_status_enum,
  idempotent boolean
)
language plpgsql
security invoker
set search_path = pg_catalog, public
as $$
declare
  v_order public.orders%rowtype;
  v_now timestamptz := timezone('utc', now());
begin
  select *
    into v_order
  from public.orders o
  where o.id = p_order_id
  for update;

  if not found then
    raise exception 'order_not_found'
      using errcode = 'P0001';
  end if;

  if v_order.status = 'cancelled' then
    return query
    select v_order.id, v_order.status, true;
    return;
  end if;

  if v_order.status <> 'paid' then
    raise exception 'invalid_order_transition'
      using errcode = 'P0001';
  end if;

  update public.orders
  set
    status = 'cancelled',
    cancelled_at = coalesce(cancelled_at, v_now)
  where id = v_order.id;

  insert into public.notifications (user_id, type, message)
  values (
    v_order.buyer_id,
    'order_cancelled',
    'Your order has been cancelled and refunded.'
  );

  insert into public.audit_logs (
    entity_type,
    entity_id,
    action,
    performed_by,
    metadata
  )
  values (
    'order',
    v_order.id,
    'cancelled',
    p_actor_user_id,
    jsonb_build_object(
      'order_id', v_order.id,
      'reason', p_reason,
      'status', 'cancelled',
      'result', 'succeeded',
      'request_id', p_request_id
    )
  );

  return query
  select v_order.id, 'cancelled'::public.order_status_enum, false;
end;
$$;
