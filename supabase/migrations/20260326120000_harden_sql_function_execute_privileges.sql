revoke all on function public.is_admin() from public, anon, authenticated;
grant execute on function public.is_admin() to authenticated, service_role;

revoke all on function public.is_active_account() from public, anon, authenticated;
grant execute on function public.is_active_account() to authenticated, service_role;

revoke all on function public.admin_list_seller_requests() from public, anon;
grant execute on function public.admin_list_seller_requests() to authenticated;

revoke all on function public.handle_new_auth_user() from public, anon, authenticated;

revoke all on function public.set_truffle_expiration() from public, anon, authenticated;
revoke all on function public.assert_active_truffle_image_count(uuid) from public, anon, authenticated;
revoke all on function public.truffles_assert_active_image_count() from public, anon, authenticated;
revoke all on function public.truffle_images_assert_active_image_count() from public, anon, authenticated;
revoke all on function public.set_truffle_season_windows_updated_at() from public, anon, authenticated;
revoke all on function public.set_truffle_guides_updated_at() from public, anon, authenticated;
revoke all on function public.derive_truffle_status_from_domain_facts(public.truffle_status_enum, timestamptz, boolean, boolean) from public, anon, authenticated;
revoke all on function public.validate_order_truffle_invariants() from public, anon, authenticated;
revoke all on function public.validate_truffle_status_matches_domain_facts() from public, anon, authenticated;
revoke all on function public.sync_truffle_status_from_orders(uuid) from public, anon, authenticated;
revoke all on function public.orders_sync_truffle_status_after_change() from public, anon, authenticated;

revoke all on function public.get_enum_values(text) from public, anon, authenticated;
grant execute on function public.get_enum_values(text) to service_role;

revoke all on function public.get_buyer_home_seasonal_highlight(text) from public, anon;
grant execute on function public.get_buyer_home_seasonal_highlight(text) to authenticated;

revoke all on function public.save_shipping_address(uuid, text, text, text, text, text, text, boolean) from public, anon;
grant execute on function public.save_shipping_address(uuid, text, text, text, text, text, text, boolean) to authenticated;

revoke all on function public.delete_shipping_address(uuid) from public, anon;
grant execute on function public.delete_shipping_address(uuid) to authenticated;
