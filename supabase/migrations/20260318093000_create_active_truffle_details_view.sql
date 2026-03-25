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
