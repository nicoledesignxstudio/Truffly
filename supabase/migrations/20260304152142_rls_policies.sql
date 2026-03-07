create or replace function public.is_admin()
returns boolean
language sql
stable
set search_path = pg_catalog, public, auth
as $$
  select coalesce(
    ((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin',
    false
  );
$$;

create or replace function public.is_active_account()
returns boolean
language sql
stable
set search_path = pg_catalog, public, auth
as $$
  select exists (
    select 1
    from public.users u
    where u.id = (select auth.uid())
      and u.is_active = true
  );
$$;

create or replace function public.admin_list_seller_requests()
returns table (
  user_id uuid,
  first_name text,
  last_name text,
  country_code char(2),
  region public.region_enum,
  seller_status public.seller_status_enum
)
language plpgsql
stable
security definer
set search_path = pg_catalog, public, auth
as $$
begin
  if not public.is_admin() then
    raise exception 'Not allowed';
  end if;

  return query
  select
    u.id,
    u.first_name,
    u.last_name,
    u.country_code,
    u.region,
    u.seller_status
  from public.users u
  where u.seller_status = 'pending';
end;
$$;

grant execute on function public.admin_list_seller_requests() to authenticated;

alter table public.users enable row level security;
alter table public.shipping_addresses enable row level security;
alter table public.truffles enable row level security;
alter table public.truffle_images enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.favorites enable row level security;
alter table public.notifications enable row level security;
alter table public.seller_documents enable row level security;
alter table public.audit_logs enable row level security;

-- USERS
revoke update on table public.users from authenticated;
grant update (first_name, last_name, region, bio, profile_image_url, country_code, onboarding_completed) on table public.users to authenticated;

drop policy if exists users_select_own_active on public.users;
drop policy if exists users_insert_own_active on public.users;
drop policy if exists users_update_own_profile on public.users;

create policy users_select_own_active
  on public.users
  for select
  to authenticated
  using (
    id = (select auth.uid())
    and is_active = true
  ); 

create policy users_update_own_profile
  on public.users
  for update
  to authenticated
  using (
    id = (select auth.uid())
    and is_active = true
  )
  with check (
    id = (select auth.uid())
    and is_active = true
    and (
      onboarding_completed = false
      or (
        first_name is not null
        and btrim(first_name) <> ''
        and last_name is not null
        and btrim(last_name) <> ''
        and country_code ~ '^[A-Z]{2}$'
        and (
          (country_code = 'IT' and region is not null)
          or
          (country_code <> 'IT' and region is null)
        )
      )
    )
  );

-- SHIPPING_ADDRESSES

drop policy if exists shipping_addresses_owner_select on public.shipping_addresses;
drop policy if exists shipping_addresses_owner_insert on public.shipping_addresses;
drop policy if exists shipping_addresses_owner_update on public.shipping_addresses;
drop policy if exists shipping_addresses_owner_delete on public.shipping_addresses;

create policy shipping_addresses_owner_select
  on public.shipping_addresses
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy shipping_addresses_owner_insert
  on public.shipping_addresses
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy shipping_addresses_owner_update
  on public.shipping_addresses
  for update
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  )
  with check (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy shipping_addresses_owner_delete
  on public.shipping_addresses
  for delete
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

-- TRUFFLES

drop policy if exists truffles_select_active_authenticated on public.truffles;
drop policy if exists truffles_insert_approved_seller_only on public.truffles;
drop policy if exists truffles_delete_owner_active_without_orders on public.truffles;

create policy truffles_select_active_authenticated
  on public.truffles
  for select
  to authenticated
  using (
    status = 'active'
    and public.is_active_account()
  );

create policy truffles_insert_approved_seller_only
  on public.truffles
  for insert
  to authenticated
  with check (
    seller_id = (select auth.uid())
    and status = 'active'
    and exists (
      select 1
      from public.users u
      where u.id = (select auth.uid())
        and u.role = 'seller'
        and u.seller_status = 'approved'
        and u.stripe_account_id is not null
        and u.is_active = true
    )
  );

create policy truffles_delete_owner_active_without_orders
  on public.truffles
  for delete
  to authenticated
  using (
    seller_id = (select auth.uid())
    and status = 'active'
    and public.is_active_account()
    and not exists (
      select 1
      from public.orders o
      where o.truffle_id = public.truffles.id
    )
  );

-- TRUFFLE_IMAGES

drop policy if exists truffle_images_select_authenticated on public.truffle_images;
drop policy if exists truffle_images_insert_owner_active_truffle on public.truffle_images;
drop policy if exists truffle_images_delete_owner_active_truffle on public.truffle_images;

create policy truffle_images_select_authenticated
  on public.truffle_images
  for select
  to authenticated
  using (public.is_active_account());

create policy truffle_images_insert_owner_active_truffle
  on public.truffle_images
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.truffles t
      where t.id = truffle_id
        and t.seller_id = (select auth.uid())
        and t.status = 'active'
    )
    and public.is_active_account()
  );

create policy truffle_images_delete_owner_active_truffle
  on public.truffle_images
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.truffles t
      where t.id = truffle_id
        and t.seller_id = (select auth.uid())
        and t.status = 'active'
    )
    and public.is_active_account()
  );

-- ORDERS

drop policy if exists orders_select_buyer_or_seller on public.orders;
drop policy if exists orders_insert_service_only on public.orders;
drop policy if exists orders_update_service_only on public.orders;

create policy orders_select_buyer_or_seller
  on public.orders
  for select
  to authenticated
  using (
    (buyer_id = (select auth.uid()) or seller_id = (select auth.uid()))
    and public.is_active_account()
  );

create policy orders_insert_service_only
  on public.orders
  for insert
  to service_role
  with check (true);

create policy orders_update_service_only
  on public.orders
  for update
  to service_role
  using (true)
  with check (true);

-- REVIEWS

drop policy if exists reviews_select_authenticated on public.reviews;
drop policy if exists reviews_insert_buyer_completed_order on public.reviews;

create policy reviews_select_authenticated
  on public.reviews
  for select
  to authenticated
  using (public.is_active_account());

create policy reviews_insert_buyer_completed_order
  on public.reviews
  for insert
  to authenticated
  with check (
    public.is_active_account()
    and exists (
      select 1
      from public.orders o
      where o.id = order_id
        and o.buyer_id = (select auth.uid())
        and o.status = 'completed'
    )
  );

-- FAVORITES

drop policy if exists favorites_owner_select on public.favorites;
drop policy if exists favorites_owner_insert on public.favorites;
drop policy if exists favorites_owner_delete on public.favorites;

create policy favorites_owner_select
  on public.favorites
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy favorites_owner_insert
  on public.favorites
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and public.is_active_account()
    and exists (
      select 1
      from public.truffles t
      where t.id = truffle_id
        and t.status = 'active'
    )
  );

create policy favorites_owner_delete
  on public.favorites
  for delete
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

-- NOTIFICATIONS
revoke update on table public.notifications from authenticated;
grant update (read) on table public.notifications to authenticated;

drop policy if exists notifications_owner_select on public.notifications;
drop policy if exists notifications_owner_update on public.notifications;
drop policy if exists notifications_owner_delete on public.notifications;
drop policy if exists notifications_insert_service_only on public.notifications;

create policy notifications_owner_select
  on public.notifications
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy notifications_owner_update
  on public.notifications
  for update
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  )
  with check (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy notifications_owner_delete
  on public.notifications
  for delete
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy notifications_insert_service_only
  on public.notifications
  for insert
  to service_role
  with check (true);

-- SELLER_DOCUMENTS

drop policy if exists seller_documents_owner_or_admin_select on public.seller_documents;
drop policy if exists seller_documents_owner_insert_onboarding_only on public.seller_documents;
drop policy if exists seller_documents_owner_or_admin_delete on public.seller_documents;

create policy seller_documents_owner_or_admin_select
  on public.seller_documents
  for select
  to authenticated
  using (
    public.is_admin()
    or (
      user_id = (select auth.uid())
      and public.is_active_account()
    )
  );

create policy seller_documents_owner_insert_onboarding_only
  on public.seller_documents
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1
      from public.users u
      where u.id = (select auth.uid())
        and u.is_active = true
        and u.role = 'seller'
        and u.seller_status in ('not_requested', 'pending', 'rejected')
    )
  );

create policy seller_documents_owner_or_admin_delete
  on public.seller_documents
  for delete
  to authenticated
  using (
    public.is_admin()
    or (
      user_id = (select auth.uid())
      and public.is_active_account()
    )
  );

-- AUDIT_LOGS

drop policy if exists audit_logs_select_admin_only on public.audit_logs;
drop policy if exists audit_logs_insert_service_only on public.audit_logs;

create policy audit_logs_select_admin_only
  on public.audit_logs
  for select
  to authenticated
  using (public.is_admin());

create policy audit_logs_insert_service_only
  on public.audit_logs
  for insert
  to service_role
  with check (true);

-- STORAGE BUCKETS
insert into storage.buckets (id, name, public)
values ('truffle_images', 'truffle_images', false)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

insert into storage.buckets (id, name, public)
values ('seller_documents', 'seller_documents', false)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

-- STORAGE POLICIES: truffle_images

drop policy if exists storage_truffle_images_select_authenticated on storage.objects;
drop policy if exists storage_truffle_images_insert_owner_active_truffle on storage.objects;
drop policy if exists storage_truffle_images_delete_owner_active_truffle on storage.objects;

create policy storage_truffle_images_select_authenticated
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'truffle_images'
    and public.is_active_account()
  );

create policy storage_truffle_images_insert_owner_active_truffle
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'truffle_images'
    and public.is_active_account()
    and exists (
      select 1
      from public.truffles t
      where t.id::text = split_part(name, '/', 1)
        and t.seller_id = (select auth.uid())
        and t.status = 'active'
    )
  );

create policy storage_truffle_images_delete_owner_active_truffle
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'truffle_images'
    and public.is_active_account()
    and exists (
      select 1
      from public.truffles t
      where t.id::text = split_part(name, '/', 1)
        and t.seller_id = (select auth.uid())
        and t.status = 'active'
    )
  );

-- STORAGE POLICIES: seller_documents

drop policy if exists storage_seller_documents_select_owner_or_admin on storage.objects;
drop policy if exists storage_seller_documents_insert_owner_onboarding_only on storage.objects;
drop policy if exists storage_seller_documents_delete_owner_or_admin on storage.objects;

create policy storage_seller_documents_select_owner_or_admin
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'seller_documents'
    and (
      public.is_admin()
      or split_part(name, '/', 1) = (select auth.uid())::text
    )
  );

create policy storage_seller_documents_insert_owner_onboarding_only
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'seller_documents'
    and split_part(name, '/', 1) = (select auth.uid())::text
    and exists (
      select 1
      from public.users u
      where u.id = (select auth.uid())
        and u.is_active = true
        and u.role = 'seller'
        and u.seller_status in ('not_requested', 'pending', 'rejected')
    )
  );

create policy storage_seller_documents_delete_owner_or_admin
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'seller_documents'
    and (
      public.is_admin()
      or split_part(name, '/', 1) = (select auth.uid())::text
    )
  );
