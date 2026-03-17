create table if not exists public.publish_truffle_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  request_id text not null,
  request_status text not null
    check (request_status in ('processing', 'succeeded', 'failed')),
  request_fingerprint text not null,
  truffle_id uuid references public.truffles(id) on delete set null,
  failure_code text,
  failure_message text,
  failure_http_status integer,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint publish_truffle_requests_user_id_request_id_key
    unique (user_id, request_id)
);

create index if not exists publish_truffle_requests_user_id_idx
  on public.publish_truffle_requests (user_id);

create index if not exists publish_truffle_requests_truffle_id_idx
  on public.publish_truffle_requests (truffle_id);
