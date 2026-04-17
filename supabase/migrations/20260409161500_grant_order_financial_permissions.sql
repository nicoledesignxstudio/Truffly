revoke all on table public.order_financial_operations from public, anon, authenticated;
grant select on public.order_financial_operations to service_role;
grant insert, update on public.order_financial_operations to service_role;
