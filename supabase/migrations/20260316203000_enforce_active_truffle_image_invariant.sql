create or replace function public.assert_active_truffle_image_count(
  p_truffle_id uuid
)
returns void
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  truffle_status public.truffle_status_enum;
  image_count integer;
begin
  if p_truffle_id is null then
    return;
  end if;

  select t.status
    into truffle_status
  from public.truffles t
  where t.id = p_truffle_id;

  if not found or truffle_status <> 'active' then
    return;
  end if;

  select count(*)
    into image_count
  from public.truffle_images ti
  where ti.truffle_id = p_truffle_id;

  if image_count < 1 or image_count > 3 then
    raise exception 'active_truffle_requires_1_to_3_images'
      using errcode = '23514';
  end if;
end;
$$;

create or replace function public.truffles_assert_active_image_count()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.status = 'active' and old.status is distinct from new.status then
    perform public.assert_active_truffle_image_count(new.id);
  end if;

  return new;
end;
$$;

drop trigger if exists truffles_require_images_before_active on public.truffles;

create trigger truffles_require_images_before_active
before update of status on public.truffles
for each row
execute function public.truffles_assert_active_image_count();

drop function if exists public.ensure_truffle_can_activate();

create or replace function public.truffle_images_assert_active_image_count()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.assert_active_truffle_image_count(old.truffle_id);
    return old;
  end if;

  perform public.assert_active_truffle_image_count(new.truffle_id);

  if tg_op = 'UPDATE' and old.truffle_id is distinct from new.truffle_id then
    perform public.assert_active_truffle_image_count(old.truffle_id);
  end if;

  return new;
end;
$$;

drop trigger if exists truffle_images_assert_active_image_count_on_insert on public.truffle_images;
drop trigger if exists truffle_images_assert_active_image_count_on_update on public.truffle_images;
drop trigger if exists truffle_images_assert_active_image_count_on_delete on public.truffle_images;

create constraint trigger truffle_images_assert_active_image_count_on_insert
after insert on public.truffle_images
deferrable initially deferred
for each row
execute function public.truffle_images_assert_active_image_count();

create constraint trigger truffle_images_assert_active_image_count_on_update
after update on public.truffle_images
deferrable initially deferred
for each row
execute function public.truffle_images_assert_active_image_count();

create constraint trigger truffle_images_assert_active_image_count_on_delete
after delete on public.truffle_images
deferrable initially deferred
for each row
execute function public.truffle_images_assert_active_image_count();
