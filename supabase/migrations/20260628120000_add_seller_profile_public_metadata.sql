create or replace view public.seller_public_profiles as
select
  u.id,
  u.first_name,
  u.last_name,
  u.profile_image_url,
  u.region,
  u.bio,
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

grant select on public.seller_public_profiles to authenticated;

create or replace view public.seller_public_reviews as
select
  r.id,
  o.seller_id,
  r.rating,
  r.comment,
  r.created_at,
  r.is_auto,
  trim(concat(coalesce(buyer.first_name, ''), ' ', coalesce(buyer.last_name, ''))) as buyer_full_name
from public.reviews r
join public.orders o on o.id = r.order_id
join public.users seller on seller.id = o.seller_id
left join public.users buyer on buyer.id = o.buyer_id
where seller.is_active = true
  and seller.role = 'seller'
  and seller.seller_status = 'approved'
  and seller.onboarding_completed = true;

grant select on public.seller_public_reviews to authenticated;
