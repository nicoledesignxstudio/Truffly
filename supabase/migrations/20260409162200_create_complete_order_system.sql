create or replace function public.complete_order_system(
  p_order_id uuid,
  p_request_id text default null,
  p_reason text default 'auto_complete'
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

  if v_order.status = 'completed' then
    return query
    select v_order.id, v_order.status, true;
    return;
  end if;

  if v_order.status <> 'shipped' then
    raise exception 'invalid_order_transition'
      using errcode = 'P0001';
  end if;

  update public.orders
  set
    status = 'completed',
    completed_at = coalesce(completed_at, v_now)
  where id = v_order.id;

  insert into public.notifications (user_id, type, message)
  values (
    v_order.seller_id,
    'order_completed',
    'An order has been completed and is ready for payout processing.'
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
    'completed',
    null,
    jsonb_build_object(
      'order_id', v_order.id,
      'reason', p_reason,
      'status', 'completed',
      'result', 'succeeded',
      'request_id', p_request_id
    )
  );

  return query
  select v_order.id, 'completed'::public.order_status_enum, false;
end;
$$;
