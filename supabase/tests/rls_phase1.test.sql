begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin-test@example.invalid', '', now(), now(), now()),
  ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'user-test@example.invalid', '', now(), now(), now());

insert into public.admin_profiles (user_id, display_name)
values ('00000000-0000-0000-0000-000000000001', 'Test Admin');

insert into public.sellers (id, code, display_name, contact_label, whatsapp_e164)
values ('10000000-0000-0000-0000-000000000001', 'TEST', 'Test Seller', 'Admin Test', '+628111111111');

insert into public.categories (id, name, slug, is_active)
values
  ('20000000-0000-0000-0000-000000000001', 'Published Category', 'published-category', true),
  ('20000000-0000-0000-0000-000000000002', 'Hidden Category', 'hidden-category', false);

insert into public.products (id, seller_id, category_id, slug, title, format_type, product_status, published_at)
values
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'published-product', 'Published Product', 'pdf', 'published', now()),
  ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'draft-product', 'Draft Product', 'pdf', 'draft', null);

set local role anon;
select is((select count(*)::integer from public.products), 1, 'anon sees only published product');
select is((select count(*)::integer from public.categories), 1, 'anon sees only active category');
select throws_ok('select * from public.orders', '42501', null, 'anon cannot read orders');
select throws_ok('select * from public.product_assets', '42501', null, 'anon cannot read private assets');
select is((select count(*)::integer from storage.objects where bucket_id = 'private-product-assets'), 0, 'anon receives no private asset rows');

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000002', true);
select is((select count(*)::integer from public.products), 1, 'non-admin sees only public products');
select throws_ok('select * from public.orders', '42501', null, 'non-admin cannot read orders');

select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);
select is((select count(*)::integer from public.products), 2, 'admin sees draft and published products');
select lives_ok('select * from public.orders', 'admin can read orders');

select * from finish();
rollback;
