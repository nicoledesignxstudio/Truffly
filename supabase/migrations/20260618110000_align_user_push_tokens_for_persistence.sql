update public.user_push_tokens
set
  platform = coalesce(nullif(btrim(platform), ''), 'android'),
  last_seen_at = coalesce(last_seen_at, timezone('utc', now()));

alter table public.user_push_tokens
  alter column platform set default 'android',
  alter column last_seen_at set default timezone('utc', now()),
  alter column last_seen_at set not null;

create index if not exists user_push_tokens_user_id_idx
  on public.user_push_tokens (user_id);
