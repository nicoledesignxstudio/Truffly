create or replace view public.active_seller_cards as
select
  u.id,
  u.first_name,
  u.last_name,
  trim(concat(coalesce(u.first_name, ''), ' ', coalesce(u.last_name, ''))) as full_name,
  u.profile_image_url,
  u.region,
  u.seller_rating_avg,
  u.seller_review_count,
  coalesce(completed_orders.completed_orders_count, 0)::integer as completed_orders_count,
  u.created_at
from public.users u
left join (
  select
    o.seller_id,
    count(*)::integer as completed_orders_count
  from public.orders o
  where o.status = 'completed'
  group by o.seller_id
) completed_orders on completed_orders.seller_id = u.id
where u.is_active = true
  and u.role = 'seller'
  and u.seller_status = 'approved'
  and u.onboarding_completed = true;

grant select on public.active_seller_cards to authenticated;
