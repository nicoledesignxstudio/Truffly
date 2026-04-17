create or replace function public.is_seller_stripe_ready(
  p_user_id uuid default auth.uid()
)
returns boolean
language sql
stable
set search_path = pg_catalog, public, auth
as $$
  select exists (
    select 1
    from public.users u
    where u.id = p_user_id
      and u.role = 'seller'
      and u.seller_status = 'approved'
      and u.is_active = true
      and u.stripe_account_id is not null
      and btrim(u.stripe_account_id) <> ''
      and u.stripe_details_submitted = true
      and u.stripe_payouts_enabled = true
      and u.stripe_requirements_pending = false
      and u.stripe_ready_at is not null
  );
$$;
