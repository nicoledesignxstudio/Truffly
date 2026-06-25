create extension if not exists pgcrypto;

alter table public.reviews
  add column if not exists is_auto boolean not null default false,
  add column if not exists auto_created_at timestamptz;

alter table public.reviews
  drop constraint if exists reviews_rating_chk;

alter table public.reviews
  add constraint reviews_rating_chk check (rating between 1 and 5);

create table if not exists public.user_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  token text not null unique,
  platform text not null,
  device_id text,
  enabled boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  last_seen_at timestamptz
);

alter table public.user_push_tokens
  add constraint user_push_tokens_platform_chk
  check (platform in ('ios', 'android'));

alter table public.user_push_tokens enable row level security;

create index if not exists user_push_tokens_user_id_enabled_idx
  on public.user_push_tokens (user_id, enabled);

create index if not exists user_push_tokens_last_seen_at_idx
  on public.user_push_tokens (last_seen_at desc);

create or replace function public.set_user_push_tokens_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists set_user_push_tokens_updated_at on public.user_push_tokens;
create trigger set_user_push_tokens_updated_at
before update on public.user_push_tokens
for each row execute function public.set_user_push_tokens_updated_at();

revoke update on table public.reviews from authenticated;
revoke delete on table public.reviews from authenticated;

drop policy if exists user_push_tokens_owner_select on public.user_push_tokens;
drop policy if exists user_push_tokens_owner_insert on public.user_push_tokens;
drop policy if exists user_push_tokens_owner_update on public.user_push_tokens;
drop policy if exists user_push_tokens_owner_delete on public.user_push_tokens;

create policy user_push_tokens_owner_select
  on public.user_push_tokens
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy user_push_tokens_owner_insert
  on public.user_push_tokens
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

create policy user_push_tokens_owner_update
  on public.user_push_tokens
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

create policy user_push_tokens_owner_delete
  on public.user_push_tokens
  for delete
  to authenticated
  using (
    user_id = (select auth.uid())
    and public.is_active_account()
  );

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

create or replace function public.recalculate_seller_review_stats_for_order()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_seller_id uuid;
begin
  select o.seller_id
    into v_seller_id
  from public.orders o
  where o.id = new.order_id;

  if v_seller_id is null then
    return new;
  end if;

  update public.users u
  set
    seller_review_count = review_stats.review_count,
    seller_rating_avg = coalesce(review_stats.rating_avg, 0)
  from (
    select
      count(*)::integer as review_count,
      round(avg(r.rating)::numeric, 1) as rating_avg
    from public.reviews r
    join public.orders o on o.id = r.order_id
    where o.seller_id = v_seller_id
  ) review_stats
  where u.id = v_seller_id;

  return new;
end;
$$;

drop trigger if exists reviews_recalculate_seller_stats on public.reviews;
create trigger reviews_recalculate_seller_stats
after insert on public.reviews
for each row execute function public.recalculate_seller_review_stats_for_order();
