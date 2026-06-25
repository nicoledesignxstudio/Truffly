update public.users
set role = 'seller'
where seller_status = 'approved'
  and role is distinct from 'seller';

create or replace function public.sync_seller_role_from_user_status()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.seller_status = 'approved' then
    new.role := 'seller';
  end if;

  return new;
end;
$$;

drop trigger if exists users_sync_seller_role_on_approval on public.users;
create trigger users_sync_seller_role_on_approval
before update of seller_status on public.users
for each row
execute function public.sync_seller_role_from_user_status();
