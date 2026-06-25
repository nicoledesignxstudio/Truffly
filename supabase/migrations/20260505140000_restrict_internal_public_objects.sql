create schema if not exists app_private;

revoke all on schema app_private from public;
grant usage on schema app_private to authenticated, service_role;

--
-- Hide server-side tables from client roles while preserving service access.
--
revoke all on table public.audit_logs from public, anon, authenticated;
grant all on table public.audit_logs to service_role;

revoke all on table public.payment_attempts from public, anon, authenticated;
grant all on table public.payment_attempts to service_role;

revoke all on table public.publish_truffle_requests from public, anon, authenticated;
grant all on table public.publish_truffle_requests to service_role;

revoke all on table public.seller_documents from public, anon, authenticated;
grant all on table public.seller_documents to service_role;

revoke all on table public.stripe_webhook_events from public, anon, authenticated;
grant all on table public.stripe_webhook_events to service_role;

revoke all on table public.truffle_season_windows from public, anon, authenticated;

--
-- Keep the seasonal highlight RPC public, but move the privileged logic out of
-- the exposed schema so the app can keep using the same RPC name without
-- exposing a SECURITY DEFINER function in public.
--
create or replace function app_private.get_buyer_home_seasonal_highlight_impl(lang text default 'it')
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  normalized_lang text := case
    when lower(coalesce(lang, '')) = 'en' then 'en'
    else 'it'
  end;
  active_cards jsonb := '[]'::jsonb;
  countdown_card jsonb := null;
begin
  if (select auth.uid()) is null or not public.is_active_account() then
    raise exception 'Not allowed'
      using errcode = '42501';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'truffle_type', w.truffle_type::text,
        'priority', w.priority,
        'title', case
          when normalized_lang = 'en' then w.title_en
          else w.title_it
        end,
        'subtitle', case
          when normalized_lang = 'en' then w.subtitle_en
          else w.subtitle_it
        end,
        'image_key', w.image_key,
        'start_date', to_char(w.start_date, 'YYYY-MM-DD'),
        'end_date', to_char(w.end_date, 'YYYY-MM-DD')
      )
      order by w.priority asc
    ),
    '[]'::jsonb
  )
    into active_cards
  from public.truffle_season_windows w
  where w.is_enabled = true
    and current_date between w.start_date and w.end_date;

  if jsonb_array_length(active_cards) > 0 then
    return jsonb_build_object(
      'mode', 'active',
      'cards', active_cards,
      'countdown', null
    );
  end if;

  select jsonb_build_object(
      'truffle_type', w.truffle_type::text,
      'title', case
        when normalized_lang = 'en' then w.title_en
        else w.title_it
      end,
      'subtitle', case
        when normalized_lang = 'en' then w.subtitle_en
        else w.subtitle_it
      end,
      'image_key', w.image_key,
      'target_date', to_char(w.start_date, 'YYYY-MM-DD'),
      'days_remaining', greatest((w.start_date - current_date), 0)
    )
    into countdown_card
  from public.truffle_season_windows w
  where w.is_enabled = true
    and w.start_date > current_date
  order by w.start_date asc, w.priority asc
  limit 1;

  return jsonb_build_object(
    'mode', 'countdown',
    'cards', '[]'::jsonb,
    'countdown', countdown_card
  );
end;
$$;

revoke all on function app_private.get_buyer_home_seasonal_highlight_impl(text)
  from public, anon;
grant execute on function app_private.get_buyer_home_seasonal_highlight_impl(text)
  to authenticated, service_role;

create or replace function public.get_buyer_home_seasonal_highlight(lang text default 'it')
returns jsonb
language sql
stable
security invoker
set search_path = pg_catalog, public, auth
as $$
  select app_private.get_buyer_home_seasonal_highlight_impl(lang);
$$;

revoke all on function public.get_buyer_home_seasonal_highlight(text)
  from public, anon;
grant execute on function public.get_buyer_home_seasonal_highlight(text)
  to authenticated;

--
-- Keep the review stats trigger working without exposing the trigger function.
--
create or replace function app_private.recalculate_seller_review_stats_for_order()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_seller_id uuid;
begin
  select o.seller_id
    into v_seller_id
  from public.orders o
  where o.id = new.order_id;

  if v_seller_id is null then
    return new;
  end if;

  update public.users u
  set
    seller_review_count = review_stats.review_count,
    seller_rating_avg = coalesce(review_stats.rating_avg, 0)
  from (
    select
      count(*)::integer as review_count,
      round(avg(r.rating)::numeric, 1) as rating_avg
    from public.reviews r
    join public.orders o on o.id = r.order_id
    where o.seller_id = v_seller_id
  ) review_stats
  where u.id = v_seller_id;

  return new;
end;
$$;

drop trigger if exists reviews_recalculate_seller_stats on public.reviews;
create trigger reviews_recalculate_seller_stats
after insert on public.reviews
for each row execute function app_private.recalculate_seller_review_stats_for_order();

drop function if exists public.recalculate_seller_review_stats_for_order();

--
-- Remove the exposed admin helper from public and keep it private-only.
-- It is not referenced by the mobile app and only exists for internal flows.
--
drop function if exists public.admin_list_seller_requests();
