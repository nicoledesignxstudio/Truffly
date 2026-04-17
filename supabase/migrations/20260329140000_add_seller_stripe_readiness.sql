alter table public.users
  add column if not exists stripe_details_submitted boolean not null default false,
  add column if not exists stripe_charges_enabled boolean not null default false,
  add column if not exists stripe_payouts_enabled boolean not null default false,
  add column if not exists stripe_requirements_pending boolean not null default true,
  add column if not exists stripe_onboarding_completed_at timestamptz,
  add column if not exists stripe_ready_at timestamptz;

comment on column public.users.stripe_details_submitted is
  'Server-verified mirror of Stripe Connect details_submitted for the seller connected account.';
comment on column public.users.stripe_charges_enabled is
  'Server-verified mirror of Stripe Connect charges_enabled for the seller connected account.';
comment on column public.users.stripe_payouts_enabled is
  'Server-verified mirror of Stripe Connect payouts_enabled for the seller connected account.';
comment on column public.users.stripe_requirements_pending is
  'True when Stripe still reports blocking requirements or disabled reasons for the seller connected account.';
comment on column public.users.stripe_onboarding_completed_at is
  'First server-side timestamp when Stripe onboarding details were observed as submitted.';
comment on column public.users.stripe_ready_at is
  'Server-side timestamp when the seller connected account was last observed fully ready for marketplace publishing.';

create index if not exists users_stripe_ready_idx
  on public.users (stripe_ready_at)
  where stripe_ready_at is not null;

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
      and u.stripe_charges_enabled = true
      and u.stripe_payouts_enabled = true
      and u.stripe_requirements_pending = false
      and u.stripe_ready_at is not null
  );
$$;

grant execute on function public.is_seller_stripe_ready(uuid) to authenticated;

drop policy if exists truffles_insert_approved_seller_only on public.truffles;

create policy truffles_insert_approved_seller_only
  on public.truffles
  for insert
  to authenticated
  with check (
    seller_id = (select auth.uid())
    and status = 'active'
    and public.is_active_account()
    and public.is_seller_stripe_ready((select auth.uid()))
  );
