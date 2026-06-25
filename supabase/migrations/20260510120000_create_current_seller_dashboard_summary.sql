create or replace function public.get_current_seller_dashboard_summary()
returns table (
  completed_earnings numeric(10,2),
  pending_earnings numeric(10,2),
  completed_orders_count integer,
  in_progress_orders_count integer,
  active_truffles_count integer,
  average_rating numeric(2,1),
  review_count integer
)
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_user_id uuid := auth.uid();
  v_user public.users%rowtype;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select *
    into v_user
  from public.users
  where id = v_user_id;

  if not found or v_user.is_active is not true or v_user.seller_status <> 'approved' then
    raise exception 'seller not allowed';
  end if;

  return query
  with order_stats as (
    select
      coalesce(sum(case when o.status = 'completed' then o.seller_amount end), 0)::numeric(10,2) as completed_earnings,
      coalesce(sum(case when o.status in ('paid', 'shipped') then o.seller_amount end), 0)::numeric(10,2) as pending_earnings,
      coalesce(count(*) filter (where o.status = 'completed'), 0)::integer as completed_orders_count,
      coalesce(count(*) filter (where o.status in ('paid', 'shipped')), 0)::integer as in_progress_orders_count
    from public.orders o
    where o.seller_id = v_user_id
  ),
  truffle_stats as (
    select coalesce(count(*) filter (where t.status = 'active'), 0)::integer as active_truffles_count
    from public.truffles t
    where t.seller_id = v_user_id
  ),
  review_stats as (
    select
      coalesce(round(avg(r.rating)::numeric, 1), v_user.seller_rating_avg::numeric(2,1), 0)::numeric(2,1) as average_rating,
      coalesce(count(r.*), v_user.seller_review_count, 0)::integer as review_count
    from public.reviews r
    join public.orders o on o.id = r.order_id
    where o.seller_id = v_user_id
  )
  select
    order_stats.completed_earnings,
    order_stats.pending_earnings,
    order_stats.completed_orders_count,
    order_stats.in_progress_orders_count,
    truffle_stats.active_truffles_count,
    review_stats.average_rating,
    review_stats.review_count
  from order_stats, truffle_stats, review_stats;
end;
$$;

revoke all on function public.get_current_seller_dashboard_summary() from public;
grant execute on function public.get_current_seller_dashboard_summary() to authenticated;
