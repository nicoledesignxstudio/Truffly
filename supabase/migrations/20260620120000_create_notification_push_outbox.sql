create table if not exists public.notification_push_outbox (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid not null unique
    references public.notifications(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'processing', 'sent')),
  attempts integer not null default 0 check (attempts >= 0),
  next_attempt_at timestamptz not null default timezone('utc', now()),
  locked_at timestamptz,
  processed_at timestamptz,
  last_error text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.notification_push_outbox enable row level security;

create index if not exists notification_push_outbox_dispatch_idx
  on public.notification_push_outbox (status, next_attempt_at, created_at);

revoke all on table public.notification_push_outbox
  from public, anon, authenticated;

create or replace function public.queue_high_importance_notification_push()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  if new.type = any (array[
    'order_confirmed',
    'order_shipped',
    'order_auto_cancelled_unshipped',
    'refund_started',
    'refund_completed',
    'delivery_confirmation_reminder',
    'order_completed',
    'review_request',
    'seller_approved',
    'seller_rejected',
    'seller_new_order',
    'seller_shipping_24h_reminder',
    'seller_shipping_final_reminder',
    'seller_order_cancelled_unshipped',
    'seller_payment_released',
    'seller_new_review'
  ]::text[]) then
    insert into public.notification_push_outbox (notification_id)
    values (new.id)
    on conflict (notification_id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists notifications_queue_high_importance_push
  on public.notifications;
create trigger notifications_queue_high_importance_push
after insert on public.notifications
for each row execute function public.queue_high_importance_notification_push();

create or replace function public.claim_notification_push_outbox(
  p_limit integer default 25
)
returns table (
  outbox_id uuid,
  notification_id uuid,
  user_id uuid,
  type text,
  target_route text,
  target_id text,
  metadata jsonb,
  attempts integer
)
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  return query
  with claimable as (
    select o.id
    from public.notification_push_outbox o
    where (
        o.status = 'pending'
        or (
          o.status = 'processing'
          and o.locked_at < timezone('utc', now()) - interval '10 minutes'
        )
      )
      and o.next_attempt_at <= timezone('utc', now())
      and o.attempts < 8
    order by o.created_at
    limit greatest(1, least(coalesce(p_limit, 25), 100))
    for update skip locked
  ),
  claimed as (
    update public.notification_push_outbox o
    set
      status = 'processing',
      locked_at = timezone('utc', now()),
      attempts = o.attempts + 1,
      updated_at = timezone('utc', now())
    from claimable c
    where o.id = c.id
    returning o.*
  )
  select
    c.id,
    n.id,
    n.user_id,
    n.type,
    n.target_route,
    n.target_id,
    n.metadata,
    c.attempts
  from claimed c
  join public.notifications n on n.id = c.notification_id;
end;
$$;

revoke all on function public.claim_notification_push_outbox(integer)
  from public, anon, authenticated;
grant execute on function public.claim_notification_push_outbox(integer)
  to service_role;
