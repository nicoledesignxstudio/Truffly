alter type public.truffle_status_enum add value if not exists 'reserved';

do $$
begin
  if exists (
    select 1
    from public.orders o
    where o.status in ('paid', 'shipped')
    group by o.truffle_id
    having count(*) > 1
  ) then
    raise exception
      'Cannot enforce order/truffle invariants: multiple open orders already exist for the same truffle.'
      using errcode = '23514';
  end if;

  if exists (
    select 1
    from public.orders o
    where o.status = 'completed'
    group by o.truffle_id
    having count(*) > 1
  ) then
    raise exception
      'Cannot enforce order/truffle invariants: multiple completed orders already exist for the same truffle.'
      using errcode = '23514';
  end if;

  if exists (
    select 1
    from public.orders open_order
    where open_order.status in ('paid', 'shipped')
      and exists (
        select 1
        from public.orders completed_order
        where completed_order.truffle_id = open_order.truffle_id
          and completed_order.status = 'completed'
      )
  ) then
    raise exception
      'Cannot enforce order/truffle invariants: a truffle cannot have both an open order and a completed order.'
      using errcode = '23514';
  end if;
end;
$$;

create or replace function public.derive_truffle_status_from_domain_facts(
  p_current_status public.truffle_status_enum,
  p_expires_at timestamptz,
  p_has_open_order boolean,
  p_has_completed_order boolean
)
returns public.truffle_status_enum
language plpgsql
stable
set search_path = pg_catalog, public
as $$
begin
  if p_has_completed_order then
    return 'sold'::public.truffle_status_enum;
  end if;

  if p_has_open_order then
    return 'reserved'::public.truffle_status_enum;
  end if;

  if p_current_status = 'publishing' then
    return 'publishing'::public.truffle_status_enum;
  end if;

  if p_expires_at <= timezone('utc', now()) then
    return 'expired'::public.truffle_status_enum;
  end if;

  return 'active'::public.truffle_status_enum;
end;
$$;

update public.truffles t
set status = public.derive_truffle_status_from_domain_facts(
  t.status,
  t.expires_at,
  exists (
    select 1
    from public.orders o
    where o.truffle_id = t.id
      and o.status in ('paid', 'shipped')
  ),
  exists (
    select 1
    from public.orders o
    where o.truffle_id = t.id
      and o.status = 'completed'
  )
);

create unique index if not exists orders_one_open_incompatible_order_per_truffle_idx
  on public.orders (truffle_id)
  where status in ('paid', 'shipped');

create unique index if not exists orders_one_completed_order_per_truffle_idx
  on public.orders (truffle_id)
  where status = 'completed';

create or replace function public.validate_order_truffle_invariants()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  v_truffle public.truffles%rowtype;
begin
  if tg_op = 'INSERT' then
    if new.status <> 'paid' then
      raise exception 'orders_must_start_in_paid_status'
        using errcode = '23514';
    end if;
  elsif tg_op = 'UPDATE' then
    if new.truffle_id is distinct from old.truffle_id then
      raise exception 'orders_truffle_id_is_immutable'
        using errcode = '23514';
    end if;

    if new.status is not distinct from old.status then
      raise exception 'orders_status_transition_must_change_status'
        using errcode = '23514';
    end if;

    if not (
      (old.status = 'paid' and new.status in ('shipped', 'cancelled'))
      or (old.status = 'shipped' and new.status = 'completed')
    ) then
      raise exception 'orders_invalid_status_transition'
        using errcode = '23514',
              detail = format(
                'Transition from %s to %s is not allowed.',
                old.status,
                new.status
              );
    end if;
  end if;

  select *
    into v_truffle
  from public.truffles t
  where t.id = new.truffle_id
  for update;

  if not found then
    raise exception 'orders_truffle_not_found'
      using errcode = '23514';
  end if;

  if v_truffle.status = 'publishing' then
    raise exception 'orders_forbidden_while_truffle_is_publishing'
      using errcode = '23514';
  end if;

  if new.status in ('paid', 'shipped') then
    if exists (
      select 1
      from public.orders o
      where o.truffle_id = new.truffle_id
        and o.status = 'completed'
        and o.id <> new.id
    ) then
      raise exception 'orders_open_status_forbidden_when_completed_order_exists'
        using errcode = '23514';
    end if;
  elsif new.status = 'completed' then
    if exists (
      select 1
      from public.orders o
      where o.truffle_id = new.truffle_id
        and o.status in ('paid', 'shipped')
        and o.id <> new.id
    ) then
      raise exception 'orders_completed_status_forbidden_when_other_open_order_exists'
        using errcode = '23514';
    end if;
  end if;

  return new;
end;
$$;

create or replace function public.validate_truffle_status_matches_domain_facts()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  v_has_open_order boolean;
  v_has_completed_order boolean;
  v_expected_status public.truffle_status_enum;
begin
  select exists (
      select 1
      from public.orders o
      where o.truffle_id = new.id
        and o.status in ('paid', 'shipped')
    ),
    exists (
      select 1
      from public.orders o
      where o.truffle_id = new.id
        and o.status = 'completed'
    )
    into v_has_open_order, v_has_completed_order;

  if tg_op = 'UPDATE'
    and new.status = 'publishing'
    and old.status <> 'publishing' then
    raise exception 'truffle_cannot_transition_back_to_publishing'
      using errcode = '23514';
  end if;

  v_expected_status := public.derive_truffle_status_from_domain_facts(
    new.status,
    new.expires_at,
    v_has_open_order,
    v_has_completed_order
  );

  if new.status is distinct from v_expected_status then
    raise exception 'truffle_status_must_match_domain_facts'
      using errcode = '23514',
            detail = format(
              'truffle_id=%s expected=%s received=%s has_open_order=%s has_completed_order=%s expires_at=%s',
              new.id,
              v_expected_status,
              new.status,
              v_has_open_order,
              v_has_completed_order,
              new.expires_at
            );
  end if;

  return new;
end;
$$;

create or replace function public.sync_truffle_status_from_orders(
  p_truffle_id uuid
)
returns void
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  v_truffle public.truffles%rowtype;
  v_has_open_order boolean;
  v_has_completed_order boolean;
  v_expected_status public.truffle_status_enum;
begin
  if p_truffle_id is null then
    return;
  end if;

  select *
    into v_truffle
  from public.truffles t
  where t.id = p_truffle_id
  for update;

  if not found then
    return;
  end if;

  select exists (
      select 1
      from public.orders o
      where o.truffle_id = p_truffle_id
        and o.status in ('paid', 'shipped')
    ),
    exists (
      select 1
      from public.orders o
      where o.truffle_id = p_truffle_id
        and o.status = 'completed'
    )
    into v_has_open_order, v_has_completed_order;

  if v_has_open_order and v_has_completed_order then
    raise exception 'truffle_cannot_have_open_and_completed_orders_simultaneously'
      using errcode = '23514';
  end if;

  v_expected_status := public.derive_truffle_status_from_domain_facts(
    v_truffle.status,
    v_truffle.expires_at,
    v_has_open_order,
    v_has_completed_order
  );

  if v_truffle.status is distinct from v_expected_status then
    update public.truffles
    set status = v_expected_status
    where id = p_truffle_id;
  end if;
end;
$$;

create or replace function public.orders_sync_truffle_status_after_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.sync_truffle_status_from_orders(old.truffle_id);
    return old;
  end if;

  perform public.sync_truffle_status_from_orders(new.truffle_id);
  return new;
end;
$$;

drop trigger if exists orders_validate_truffle_invariants on public.orders;
create trigger orders_validate_truffle_invariants
before insert or update of truffle_id, status on public.orders
for each row
execute function public.validate_order_truffle_invariants();

drop trigger if exists truffles_validate_order_state_consistency on public.truffles;
create trigger truffles_validate_order_state_consistency
before insert or update of status, expires_at on public.truffles
for each row
execute function public.validate_truffle_status_matches_domain_facts();

drop trigger if exists orders_sync_truffle_status_after_insert on public.orders;
drop trigger if exists orders_sync_truffle_status_after_update on public.orders;
drop trigger if exists orders_sync_truffle_status_after_delete on public.orders;

create constraint trigger orders_sync_truffle_status_after_insert
after insert on public.orders
deferrable initially deferred
for each row
execute function public.orders_sync_truffle_status_after_change();

create constraint trigger orders_sync_truffle_status_after_update
after update of status on public.orders
deferrable initially deferred
for each row
execute function public.orders_sync_truffle_status_after_change();

create constraint trigger orders_sync_truffle_status_after_delete
after delete on public.orders
deferrable initially deferred
for each row
execute function public.orders_sync_truffle_status_after_change();
