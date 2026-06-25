create or replace view public.seller_public_reviews as
select
  r.id,
  o.seller_id,
  r.rating,
  r.comment,
  r.created_at,
  r.is_auto
from public.reviews r
join public.orders o on o.id = r.order_id
join public.users u on u.id = o.seller_id
where u.is_active = true
  and u.role = 'seller'
  and u.seller_status = 'approved'
  and u.onboarding_completed = true;

grant select on public.seller_public_reviews to authenticated;
