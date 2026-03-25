alter table public.publish_truffle_requests enable row level security;

drop policy if exists publish_truffle_requests_service_select
  on public.publish_truffle_requests;
drop policy if exists publish_truffle_requests_service_insert
  on public.publish_truffle_requests;
drop policy if exists publish_truffle_requests_service_update
  on public.publish_truffle_requests;
drop policy if exists publish_truffle_requests_service_delete
  on public.publish_truffle_requests;

create policy publish_truffle_requests_service_select
  on public.publish_truffle_requests
  for select
  to service_role
  using (true);

create policy publish_truffle_requests_service_insert
  on public.publish_truffle_requests
  for insert
  to service_role
  with check (true);

create policy publish_truffle_requests_service_update
  on public.publish_truffle_requests
  for update
  to service_role
  using (true)
  with check (true);

create policy publish_truffle_requests_service_delete
  on public.publish_truffle_requests
  for delete
  to service_role
  using (true);
