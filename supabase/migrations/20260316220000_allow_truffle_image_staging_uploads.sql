drop policy if exists storage_truffle_images_insert_authenticated_staging on storage.objects;
drop policy if exists storage_truffle_images_delete_authenticated_staging on storage.objects;

create policy storage_truffle_images_insert_authenticated_staging
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'truffle_images'
    and name like ('staging/' || auth.uid()::text || '/%')
  );

create policy storage_truffle_images_delete_authenticated_staging
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'truffle_images'
    and name like ('staging/' || auth.uid()::text || '/%')
  );
