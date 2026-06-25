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
  v_review_rows integer := 0;
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
    if p_reason = 'auto_cancel_unshipped_48h' then
      insert into public.reviews (
        order_id,
        rating,
        comment,
        is_auto,
        auto_created_at
      )
      values (
        v_order.id,
        2,
        'Automatic review: order was not shipped within 48 hours.',
        true,
        v_now
      )
      on conflict (order_id) do nothing;

      get diagnostics v_review_rows = row_count;

      if v_review_rows > 0 then
        insert into public.audit_logs (
          entity_type,
          entity_id,
          action,
          performed_by,
          metadata
        )
        values (
          'review',
          v_order.id,
          'auto_created',
          p_actor_user_id,
          jsonb_build_object(
            'order_id', v_order.id,
            'reason', p_reason,
            'status', 'cancelled',
            'result', 'succeeded',
            'request_id', p_request_id,
            'rating', 2,
            'is_auto', true
          )
        );
      end if;
    end if;

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

  if p_reason = 'auto_cancel_unshipped_48h' then
    insert into public.notifications (user_id, type, message)
    values (
      v_order.buyer_id,
      'order_auto_cancelled_unshipped_48h_buyer',
      'Your order was cancelled and refunded because the seller did not ship it within 48 hours.'
    );

    insert into public.notifications (user_id, type, message)
    values (
      v_order.seller_id,
      'order_auto_cancelled_unshipped_48h_seller',
      'The order was cancelled and refunded because it was not shipped within 48 hours.'
    );

    insert into public.reviews (
      order_id,
      rating,
      comment,
      is_auto,
      auto_created_at
    )
    values (
      v_order.id,
      2,
      'Automatic review: order was not shipped within 48 hours.',
      true,
      v_now
    )
    on conflict (order_id) do nothing;

    get diagnostics v_review_rows = row_count;

    if v_review_rows > 0 then
      insert into public.audit_logs (
        entity_type,
        entity_id,
        action,
        performed_by,
        metadata
      )
      values (
        'review',
        v_order.id,
        'auto_created',
        p_actor_user_id,
        jsonb_build_object(
          'order_id', v_order.id,
          'reason', p_reason,
          'status', 'cancelled',
          'result', 'succeeded',
          'request_id', p_request_id,
          'rating', 2,
          'is_auto', true
        )
      );
    end if;
  else
    insert into public.notifications (user_id, type, message)
    values (
      v_order.buyer_id,
      'order_cancelled',
      'Your order has been cancelled and refunded.'
    );
  end if;

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

create or replace function public.update_order_status_atomic(
  p_order_id uuid,
  p_actor_user_id uuid,
  p_action text,
  p_tracking_code text default null,
  p_request_id text default null
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
  v_tracking_code text := nullif(btrim(coalesce(p_tracking_code, '')), '');
  v_now timestamptz := timezone('utc', now());
begin
  if p_actor_user_id is null then
    raise exception 'order_not_accessible'
      using errcode = 'P0001';
  end if;

  select *
    into v_order
  from public.orders o
  where o.id = p_order_id
  for update;

  if not found then
    raise exception 'order_not_found'
      using errcode = 'P0001';
  end if;

  case p_action
    when 'confirm_receipt' then
      if v_order.buyer_id <> p_actor_user_id then
        raise exception 'order_not_accessible'
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
        'A buyer confirmed receipt for one of your orders.'
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
        p_actor_user_id,
        jsonb_build_object(
          'order_id', v_order.id,
          'action', p_action,
          'status', 'completed',
          'result', 'succeeded',
          'request_id', p_request_id
        )
      );

      return query
      select v_order.id, 'completed'::public.order_status_enum, false;
      return;

    when 'mark_shipped' then
      if v_order.seller_id <> p_actor_user_id then
        raise exception 'order_not_accessible'
          using errcode = 'P0001';
      end if;

      if v_tracking_code is null then
        raise exception 'invalid_tracking_code'
          using errcode = 'P0001';
      end if;

      if v_order.status in ('shipped', 'completed')
         and v_order.tracking_code = v_tracking_code then
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
        status = 'shipped',
        tracking_code = v_tracking_code,
        shipped_at = coalesce(shipped_at, v_now)
      where id = v_order.id;

      insert into public.notifications (user_id, type, message)
      values (
        v_order.buyer_id,
        'order_shipped',
        'Your order has been marked as shipped.'
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
        'shipped',
        p_actor_user_id,
        jsonb_build_object(
          'order_id', v_order.id,
          'action', p_action,
          'status', 'shipped',
          'tracking_code_suffix', right(v_tracking_code, 4),
          'tracking_code_length', char_length(v_tracking_code),
          'result', 'succeeded',
          'request_id', p_request_id
        )
      );

      return query
      select v_order.id, 'shipped'::public.order_status_enum, false;
      return;

    when 'cancel_order' then
      if v_order.seller_id <> p_actor_user_id then
        raise exception 'order_not_accessible'
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
        'Your order has been cancelled.'
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
          'action', p_action,
          'status', 'cancelled',
          'result', 'succeeded',
          'request_id', p_request_id
        )
      );

      return query
      select v_order.id, 'cancelled'::public.order_status_enum, false;
      return;

    else
      raise exception 'invalid_action'
        using errcode = 'P0001';
  end case;
end;
$$;
