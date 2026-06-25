alter table public.truffle_season_windows enable row level security;

drop policy if exists truffle_season_windows_select_authenticated on public.truffle_season_windows;
create policy truffle_season_windows_select_authenticated
  on public.truffle_season_windows
  for select
  to authenticated
  using (public.is_active_account());

alter table public.truffle_season_windows
  alter column is_enabled set default true;

create or replace function public.get_buyer_home_seasonal_highlight(lang text default 'it')
returns jsonb
language plpgsql
stable
security invoker
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

revoke all on function public.get_buyer_home_seasonal_highlight(text)
  from public, anon;
grant execute on function public.get_buyer_home_seasonal_highlight(text)
  to authenticated;

revoke all on function public.admin_list_seller_requests()
  from public, anon, authenticated;

revoke all on function public.recalculate_seller_review_stats_for_order()
  from public, anon, authenticated;
