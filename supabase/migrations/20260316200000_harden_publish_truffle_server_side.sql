alter type public.truffle_status_enum add value if not exists 'publishing';

create or replace function public.ensure_truffle_can_activate()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  image_count integer;
begin
  if new.status <> 'active' then
    return new;
  end if;

  if tg_op = 'INSERT' or old.status is distinct from new.status then
    select count(*)
      into image_count
    from public.truffle_images
    where truffle_id = new.id;

    if image_count < 1 or image_count > 3 then
      raise exception 'active_truffle_requires_1_to_3_images'
        using errcode = '23514';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists truffles_require_images_before_active on public.truffles;

create trigger truffles_require_images_before_active
before insert or update of status on public.truffles
for each row
execute function public.ensure_truffle_can_activate();

drop policy if exists truffles_insert_approved_seller_only on public.truffles;

create policy truffles_insert_service_only
  on public.truffles
  for insert
  to service_role
  with check (true);

drop policy if exists truffle_images_insert_owner_active_truffle on public.truffle_images;
drop policy if exists truffle_images_delete_owner_active_truffle on public.truffle_images;

create policy truffle_images_insert_service_only
  on public.truffle_images
  for insert
  to service_role
  with check (true);

create policy truffle_images_delete_service_only
  on public.truffle_images
  for delete
  to service_role
  using (true);

drop policy if exists storage_truffle_images_insert_owner_active_truffle on storage.objects;
drop policy if exists storage_truffle_images_delete_owner_active_truffle on storage.objects;

create policy storage_truffle_images_insert_service_only
  on storage.objects
  for insert
  to service_role
  with check (bucket_id = 'truffle_images');

create policy storage_truffle_images_delete_service_only
  on storage.objects
  for delete
  to service_role
  using (bucket_id = 'truffle_images');
