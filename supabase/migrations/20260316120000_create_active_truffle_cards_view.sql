create or replace view public.active_truffle_cards
with (security_invoker = true) as
select
  t.id,
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

grant select on public.active_truffle_cards to authenticated;
