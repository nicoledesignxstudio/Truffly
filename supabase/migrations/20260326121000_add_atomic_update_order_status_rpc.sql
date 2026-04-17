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
            'status', v_order.status,
            'result', 'idempotent_replay',
            'request_id', p_request_id
          )
        );

        return query
        select v_order.id, v_order.status, true;
        return;
      end if;

      if v_order.status <> 'shipped' then
        raise exception 'invalid_order_transition'
          using errcode = 'P0001';
      end if;

      update public.orders
      set status = 'completed'
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
            'status', v_order.status,
            'result', 'idempotent_replay',
            'request_id', p_request_id
          )
        );

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
        tracking_code = v_tracking_code
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
          'tracking_code', v_tracking_code,
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
            'status', v_order.status,
            'result', 'idempotent_replay',
            'request_id', p_request_id
          )
        );

        return query
        select v_order.id, v_order.status, true;
        return;
      end if;

      if v_order.status <> 'paid' then
        raise exception 'invalid_order_transition'
          using errcode = 'P0001';
      end if;

      update public.orders
      set status = 'cancelled'
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
