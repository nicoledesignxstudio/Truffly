revoke all on function public.set_order_financial_operation_updated_at() from public, anon, authenticated;
revoke all on function public.cancel_order_after_refund(uuid, text, uuid, text) from public, anon, authenticated;
revoke all on function public.complete_order_system(uuid, text, text) from public, anon, authenticated;

grant execute on function public.cancel_order_after_refund(uuid, text, uuid, text) to service_role;
grant execute on function public.complete_order_system(uuid, text, text) to service_role;
