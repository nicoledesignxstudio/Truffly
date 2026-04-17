create or replace view public.active_truffle_details as
select
  t.id,
  t.seller_id,
  t.truffle_type,
  t.quality,
  t.weight_grams,
  t.price_total,
  t.price_per_kg,
  t.shipping_price_italy,
  t.shipping_price_abroad,
  t.region,
  t.harvest_date,
  t.created_at,
  t.expires_at,
  u.first_name as seller_first_name,
  u.last_name as seller_last_name,
  u.profile_image_url as seller_profile_image_url,
  u.seller_review_count,
  u.seller_rating_avg
from public.truffles t
join public.users u on u.id = t.seller_id
where t.status = 'active'
  and u.is_active = true;

grant select on public.active_truffle_details to authenticated;

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
  coalesce(completed_orders.completed_orders_count, 0)::integer as completed_orders_count
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
  r.created_at
from public.reviews r
join public.orders o on o.id = r.order_id
join public.users u on u.id = o.seller_id
where u.is_active = true
  and u.role = 'seller'
  and u.seller_status = 'approved'
  and u.onboarding_completed = true;

grant select on public.seller_public_reviews to authenticated;

create or replace view public.seller_active_truffle_cards as
select
  t.id,
  t.seller_id,
  t.truffle_type,
  t.quality,
  t.weight_grams,
  t.price_total,
  t.shipping_price_italy,
  t.shipping_price_abroad,
  t.region,
  t.harvest_date,
  t.created_at,
  t.expires_at,
  primary_image.image_url as primary_image_url
from public.truffles t
left join lateral (
  select ti.image_url
  from public.truffle_images ti
  where ti.truffle_id = t.id
  order by ti.order_index asc
  limit 1
) primary_image on true
where t.status = 'active';

grant select on public.seller_active_truffle_cards to authenticated;
