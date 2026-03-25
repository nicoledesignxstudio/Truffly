create or replace view public.seller_owned_truffle_cards as
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
