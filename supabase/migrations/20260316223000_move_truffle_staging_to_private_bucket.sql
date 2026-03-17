insert into storage.buckets (id, name, public)
values ('truffle_images_staging', 'truffle_images_staging', false)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

drop policy if exists storage_truffle_images_insert_authenticated_staging on storage.objects;
drop policy if exists storage_truffle_images_delete_authenticated_staging on storage.objects;
drop policy if exists storage_truffle_images_staging_insert_authenticated on storage.objects;
drop policy if exists storage_truffle_images_staging_delete_authenticated on storage.objects;

create policy storage_truffle_images_staging_insert_authenticated
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'truffle_images_staging'
    and name like ('staging/' || auth.uid()::text || '/%')
  );

create policy storage_truffle_images_staging_delete_authenticated
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'truffle_images_staging'
    and name like ('staging/' || auth.uid()::text || '/%')
  );
