create or replace function public.save_shipping_address(
  p_address_id uuid default null,
  p_full_name text default null,
  p_street text default null,
  p_city text default null,
  p_postal_code text default null,
  p_country_code text default null,
  p_phone text default null,
  p_is_default boolean default false
)
returns public.shipping_addresses
language plpgsql
security invoker
set search_path = pg_catalog, public, auth
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_full_name text := btrim(coalesce(p_full_name, ''));
  v_street text := btrim(coalesce(p_street, ''));
  v_city text := btrim(coalesce(p_city, ''));
  v_postal_code text := btrim(coalesce(p_postal_code, ''));
  v_country_code text := upper(btrim(coalesce(p_country_code, '')));
  v_phone text := btrim(coalesce(p_phone, ''));
  v_existing_count integer := 0;
  v_current_is_default boolean := false;
  v_saved public.shipping_addresses;
  v_target_is_default boolean := coalesce(p_is_default, false);
begin
  if v_user_id is null or not public.is_active_account() then
    raise exception 'Not allowed'
      using errcode = '42501';
  end if;

  if p_address_id is not null then
    select sa.is_default
      into v_current_is_default
    from public.shipping_addresses sa
    where sa.id = p_address_id
      and sa.user_id = v_user_id;

    if not found then
      raise exception 'shipping_address_not_found'
        using errcode = 'P0001';
    end if;
  end if;

  if v_full_name = '' then
    raise exception 'shipping_address_full_name_required'
      using errcode = 'P0001';
  end if;

  if v_street = '' then
    raise exception 'shipping_address_street_required'
      using errcode = 'P0001';
  end if;

  if v_city = '' then
    raise exception 'shipping_address_city_required'
      using errcode = 'P0001';
  end if;

  if v_postal_code = '' then
    raise exception 'shipping_address_postal_code_required'
      using errcode = 'P0001';
  end if;

  if v_country_code = '' or v_country_code !~ '^[A-Z]{2}$' then
    raise exception 'shipping_address_country_code_invalid'
      using errcode = 'P0001';
  end if;

  if v_phone = '' then
    raise exception 'shipping_address_phone_required'
      using errcode = 'P0001';
  end if;

  select count(*)
    into v_existing_count
  from public.shipping_addresses sa
  where sa.user_id = v_user_id
    and (p_address_id is null or sa.id <> p_address_id);

  if v_target_is_default or v_existing_count = 0 then
    update public.shipping_addresses
    set is_default = false
    where user_id = v_user_id
      and (p_address_id is null or id <> p_address_id)
      and is_default = true;

    v_target_is_default := true;
  end if;

  if p_address_id is null then
    insert into public.shipping_addresses (
      user_id,
      full_name,
      street,
      city,
      postal_code,
      country_code,
      phone,
      is_default
    )
    values (
      v_user_id,
      v_full_name,
      v_street,
      v_city,
      v_postal_code,
      v_country_code,
      v_phone,
      v_target_is_default
    )
    returning *
      into v_saved;
  else
    update public.shipping_addresses
    set
      full_name = v_full_name,
      street = v_street,
      city = v_city,
      postal_code = v_postal_code,
      country_code = v_country_code,
      phone = v_phone,
      is_default = v_target_is_default
    where id = p_address_id
      and user_id = v_user_id
    returning *
      into v_saved;
  end if;

  if exists (
    select 1
    from public.shipping_addresses sa
    where sa.user_id = v_user_id
  ) and not exists (
    select 1
    from public.shipping_addresses sa
    where sa.user_id = v_user_id
      and sa.is_default = true
  ) then
    update public.shipping_addresses
    set is_default = true
    where id = (
      select sa.id
      from public.shipping_addresses sa
      where sa.user_id = v_user_id
      order by sa.created_at asc
      limit 1
    );
  end if;

  select *
    into v_saved
  from public.shipping_addresses sa
  where sa.id = v_saved.id;

  return v_saved;
end;
$$;

create or replace function public.delete_shipping_address(
  p_address_id uuid
)
returns uuid
language plpgsql
security invoker
set search_path = pg_catalog, public, auth
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_deleted_id uuid;
  v_deleted_was_default boolean := false;
begin
  if v_user_id is null or not public.is_active_account() then
    raise exception 'Not allowed'
      using errcode = '42501';
  end if;

  select sa.is_default
    into v_deleted_was_default
  from public.shipping_addresses sa
  where sa.id = p_address_id
    and sa.user_id = v_user_id;

  if not found then
    raise exception 'shipping_address_not_found'
      using errcode = 'P0001';
  end if;

  delete from public.shipping_addresses
  where id = p_address_id
    and user_id = v_user_id
  returning id
    into v_deleted_id;

  if v_deleted_was_default then
    update public.shipping_addresses
    set is_default = true
    where id = (
      select sa.id
      from public.shipping_addresses sa
      where sa.user_id = v_user_id
      order by sa.created_at asc
      limit 1
    );
  end if;

  return v_deleted_id;
end;
$$;

revoke all on function public.save_shipping_address(uuid, text, text, text, text, text, text, boolean) from public;
grant execute on function public.save_shipping_address(uuid, text, text, text, text, text, text, boolean) to authenticated;

revoke all on function public.delete_shipping_address(uuid) from public;
grant execute on function public.delete_shipping_address(uuid) to authenticated;
