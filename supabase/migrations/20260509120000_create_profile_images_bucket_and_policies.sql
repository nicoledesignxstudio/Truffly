insert into storage.buckets (id, name, public)
values ('profile_images', 'profile_images', true)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

drop policy if exists storage_profile_images_select_owner on storage.objects;
drop policy if exists storage_profile_images_insert_owner on storage.objects;
drop policy if exists storage_profile_images_delete_owner on storage.objects;

create policy storage_profile_images_select_owner
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'profile_images'
    and split_part(name, '/', 1) = (select auth.uid())::text
  );

create policy storage_profile_images_insert_owner
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'profile_images'
    and split_part(name, '/', 1) = (select auth.uid())::text
  );

create policy storage_profile_images_delete_owner
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'profile_images'
    and split_part(name, '/', 1) = (select auth.uid())::text
  );
