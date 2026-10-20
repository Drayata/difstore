begin;

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create or replace function private.is_active_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_profiles
    where user_id = (select auth.uid()) and is_active
  );
$$;

revoke all on function private.is_active_admin() from public, anon;
grant execute on function private.is_active_admin() to authenticated;

alter policy admin_all_admin_profiles on public.admin_profiles using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_sellers on public.sellers using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_payment_accounts on public.payment_accounts using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_categories on public.categories using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_products on public.products using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_variants on public.product_variants using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_media on public.product_media using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_assets on public.product_assets using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_checkout_groups on public.checkout_groups using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_orders on public.orders using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_all_order_items on public.order_items using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_read_order_events on public.order_events using ((select private.is_active_admin()));
alter policy admin_read_audit_logs on public.audit_logs using ((select private.is_active_admin()));
alter policy admin_all_site_settings on public.site_settings using ((select private.is_active_admin())) with check ((select private.is_active_admin()));
alter policy admin_manage_product_previews on storage.objects using (bucket_id = 'product-previews' and (select private.is_active_admin())) with check (bucket_id = 'product-previews' and (select private.is_active_admin()));
alter policy admin_manage_private_assets on storage.objects using (bucket_id = 'private-product-assets' and (select private.is_active_admin())) with check (bucket_id = 'private-product-assets' and (select private.is_active_admin()));
alter policy admin_manage_merchant_qris on storage.objects using (bucket_id = 'merchant-qris' and (select private.is_active_admin())) with check (bucket_id = 'merchant-qris' and (select private.is_active_admin()));

drop function public.is_active_admin();

commit;
