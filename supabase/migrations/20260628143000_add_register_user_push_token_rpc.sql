create or replace function public.register_user_push_token(
  p_token text,
  p_platform text default 'android'
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_user_id uuid := auth.uid();
  v_token text := nullif(btrim(p_token), '');
  v_platform text := coalesce(nullif(btrim(p_platform), ''), 'android');
  v_now timestamptz := timezone('utc', now());
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if v_token is null then
    raise exception 'missing_push_token' using errcode = '22023';
  end if;

  if v_platform not in ('android', 'ios') then
    raise exception 'invalid_push_platform' using errcode = '22023';
  end if;

  update public.user_push_tokens
  set
    user_id = v_user_id,
    platform = v_platform,
    enabled = true,
    last_seen_at = v_now,
    updated_at = v_now
  where token = v_token;

  if found then
    return;
  end if;

  insert into public.user_push_tokens (
    user_id,
    token,
    platform,
    enabled,
    last_seen_at,
    updated_at
  )
  values (
    v_user_id,
    v_token,
    v_platform,
    true,
    v_now,
    v_now
  );
end;
$$;

revoke all on function public.register_user_push_token(text, text) from public;
grant execute on function public.register_user_push_token(text, text) to authenticated;
