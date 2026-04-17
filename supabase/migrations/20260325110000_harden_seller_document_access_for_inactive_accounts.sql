drop policy if exists seller_documents_owner_or_admin_select on public.seller_documents;
drop policy if exists seller_documents_owner_or_admin_delete on public.seller_documents;

create policy seller_documents_owner_or_admin_select
  on public.seller_documents
  for select
  to authenticated
  using (
    public.is_active_account()
    and (
      public.is_admin()
      or user_id = (select auth.uid())
    )
  );

create policy seller_documents_owner_or_admin_delete
  on public.seller_documents
  for delete
  to authenticated
  using (
    public.is_active_account()
    and (
      public.is_admin()
      or user_id = (select auth.uid())
    )
  );

drop policy if exists storage_seller_documents_select_owner_or_admin on storage.objects;
drop policy if exists storage_seller_documents_delete_owner_or_admin on storage.objects;

create policy storage_seller_documents_select_owner_or_admin
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'seller_documents'
    and public.is_active_account()
    and (
      public.is_admin()
      or split_part(name, '/', 1) = (select auth.uid())::text
    )
  );

create policy storage_seller_documents_delete_owner_or_admin
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'seller_documents'
    and public.is_active_account()
    and (
      public.is_admin()
      or split_part(name, '/', 1) = (select auth.uid())::text
    )
  );
