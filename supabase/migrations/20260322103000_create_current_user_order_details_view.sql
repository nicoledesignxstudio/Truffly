create or replace view public.current_user_order_details as
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
