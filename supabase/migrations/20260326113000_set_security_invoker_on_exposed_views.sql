create or replace view public.active_truffle_details
with (security_invoker = true) as
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

create or replace view public.active_seller_cards
with (security_invoker = true) as
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

create or replace view public.seller_public_profiles
with (security_invoker = true) as
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

create or replace view public.seller_public_reviews
with (security_invoker = true) as
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

create or replace view public.seller_active_truffle_cards
with (security_invoker = true) as
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

create or replace view public.seller_owned_truffle_cards
with (security_invoker = true) as
select
  t.id,
  t.seller_id,
  t.status,
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
where t.seller_id = (select auth.uid())
  and public.is_active_account();

grant select on public.seller_owned_truffle_cards to authenticated;

create or replace view public.current_user_order_details
with (security_invoker = true) as
select
  o.id,
  o.truffle_id,
  o.buyer_id,
  o.seller_id,
  o.status,
  o.tracking_code,
  o.shipping_full_name,
  o.shipping_street,
  o.shipping_city,
  o.shipping_postal_code,
  o.shipping_country_code,
  o.shipping_phone,
  o.total_price,
  o.commission_amount,
  o.seller_amount,
  o.created_at,
  t.truffle_type,
  t.quality,
  t.weight_grams,
  trim(concat(coalesce(buyer.first_name, ''), ' ', coalesce(buyer.last_name, ''))) as buyer_full_name,
  trim(concat(coalesce(seller.first_name, ''), ' ', coalesce(seller.last_name, ''))) as seller_full_name,
  seller.profile_image_url as seller_profile_image_url,
  image.image_url as primary_image_url
from public.orders o
join public.truffles t on t.id = o.truffle_id
join public.users buyer on buyer.id = o.buyer_id
join public.users seller on seller.id = o.seller_id
left join lateral (
  select ti.image_url
  from public.truffle_images ti
  where ti.truffle_id = o.truffle_id
  order by ti.order_index asc
  limit 1
) image on true
where auth.uid() is not null
  and (o.buyer_id = auth.uid() or o.seller_id = auth.uid());

grant select on public.current_user_order_details to authenticated;
