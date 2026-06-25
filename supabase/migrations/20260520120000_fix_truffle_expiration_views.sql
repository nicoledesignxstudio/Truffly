create or replace view public.active_truffle_cards with (security_invoker = true) as
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
where t.status = 'active'
  and t.expires_at > timezone('utc', now())
  and public.is_seller_stripe_ready(t.seller_id);

grant select on public.active_truffle_cards to authenticated;

create or replace view public.active_truffle_details with (security_invoker = true) as
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
  and t.expires_at > timezone('utc', now())
  and u.is_active = true
  and public.is_seller_stripe_ready(u.id);

grant select on public.active_truffle_details to authenticated;

create or replace view public.seller_active_truffle_cards with (security_invoker = true) as
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
where t.status = 'active'
  and t.expires_at > timezone('utc', now());

grant select on public.seller_active_truffle_cards to authenticated;

create or replace view public.seller_owned_truffle_cards with (security_invoker = true) as
select
  t.id,
  t.seller_id,
  case
    when exists (
      select 1
      from public.orders o
      where o.truffle_id = t.id
        and o.status = 'completed'
    ) then 'sold'::public.truffle_status_enum
    when exists (
      select 1
      from public.orders o
      where o.truffle_id = t.id
        and o.status in ('paid', 'shipped')
    ) then 'reserved'::public.truffle_status_enum
    when t.status = 'publishing' then 'publishing'::public.truffle_status_enum
    when t.expires_at <= timezone('utc', now()) then 'expired'::public.truffle_status_enum
    else 'active'::public.truffle_status_enum
  end as status,
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
where t.seller_id = auth.uid()
  and public.is_active_account();

grant select on public.seller_owned_truffle_cards to authenticated;
