begin;

create extension if not exists pgcrypto with schema extensions;

create table public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete restrict,
  display_name text not null check (char_length(display_name) between 2 and 80),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.is_active_admin()
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

revoke all on function public.is_active_admin() from public;
grant execute on function public.is_active_admin() to authenticated;

create table public.sellers (
  id uuid primary key default extensions.gen_random_uuid(),
  code text not null unique check (code ~ '^[A-Z0-9_-]{1,20}$'),
  display_name text not null check (char_length(display_name) between 2 and 80),
  contact_label text not null,
  whatsapp_e164 text not null check (whatsapp_e164 ~ '^\+[1-9][0-9]{7,14}$'),
  primary_admin_id uuid references public.admin_profiles(user_id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.payment_accounts (
  id uuid primary key default extensions.gen_random_uuid(),
  seller_id uuid not null references public.sellers(id) on delete restrict,
  method text not null default 'qris_static' check (method = 'qris_static'),
  merchant_name text not null check (char_length(merchant_name) between 2 and 120),
  merchant_identifier text,
  qris_image_path text not null check (qris_image_path <> ''),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  check ((is_active and archived_at is null) or not is_active)
);
create unique index payment_accounts_one_active_per_seller
  on public.payment_accounts(seller_id, method) where is_active;

create table public.categories (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 80),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  description text,
  cover_path text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default extensions.gen_random_uuid(),
  seller_id uuid not null references public.sellers(id) on delete restrict,
  category_id uuid references public.categories(id) on delete set null,
  sku text unique,
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  title text not null check (char_length(title) between 2 and 160),
  short_description text not null default '',
  description_content jsonb not null default '{}'::jsonb,
  format_type text not null,
  product_status text not null default 'draft' check (product_status in ('draft','published','archived')),
  featured boolean not null default false,
  sort_order integer not null default 0,
  instructions_public text,
  compatibility text,
  license_summary text,
  seo_title text,
  seo_description text,
  og_image_path text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check ((product_status = 'published' and published_at is not null and deleted_at is null) or product_status <> 'published')
);
create index products_status_published_idx on public.products(product_status, published_at desc);
create index products_category_status_idx on public.products(category_id, product_status);
create index products_seller_idx on public.products(seller_id);

create table public.product_variants (
  id uuid primary key default extensions.gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  name text not null check (char_length(name) between 1 and 100),
  sku text unique,
  price_idr bigint not null check (price_idr >= 0),
  compare_at_price_idr bigint check (compare_at_price_idr >= price_idr),
  sale_price_idr bigint check (sale_price_idr >= 0 and sale_price_idr <= price_idr),
  sale_starts_at timestamptz,
  sale_ends_at timestamptz,
  license_type text not null,
  is_default boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (sale_starts_at is null or sale_ends_at is null or sale_starts_at < sale_ends_at)
);
create unique index product_variants_one_default on public.product_variants(product_id) where is_default;

create table public.product_media (
  id uuid primary key default extensions.gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  media_type text not null check (media_type in ('image','video_external','demo_link')),
  storage_path_or_url text not null,
  alt_text text not null default '',
  is_cover boolean not null default false,
  sort_order integer not null default 0
);
create unique index product_media_one_cover on public.product_media(product_id) where is_cover;

create table public.product_assets (
  id uuid primary key default extensions.gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  variant_id uuid references public.product_variants(id) on delete restrict,
  asset_type text not null check (asset_type in ('private_file','external_manual_link','instructions')),
  private_storage_path_or_ciphertext text not null,
  delivery_note text,
  created_at timestamptz not null default now()
);

create table public.checkout_groups (
  id uuid primary key default extensions.gen_random_uuid(),
  public_reference text not null unique,
  buyer_name text not null check (char_length(buyer_name) between 2 and 80),
  buyer_whatsapp_e164 text not null check (buyer_whatsapp_e164 ~ '^\+[1-9][0-9]{7,14}$'),
  buyer_email text,
  buyer_note text check (char_length(buyer_note) <= 500),
  total_display_idr bigint not null check (total_display_idr >= 0),
  currency text not null default 'IDR' check (currency = 'IDR'),
  access_token_hash text not null unique,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default extensions.gen_random_uuid(),
  order_number text not null unique,
  checkout_group_id uuid not null references public.checkout_groups(id) on delete restrict,
  seller_id uuid not null references public.sellers(id) on delete restrict,
  payment_account_id uuid not null references public.payment_accounts(id) on delete restrict,
  buyer_name_snapshot text not null,
  buyer_wa_snapshot text not null,
  buyer_email_snapshot text,
  merchant_name_snapshot text not null,
  qris_image_snapshot_path text not null,
  seller_wa_snapshot text not null,
  currency text not null default 'IDR' check (currency = 'IDR'),
  subtotal_idr bigint not null check (subtotal_idr >= 0),
  discount_idr bigint not null default 0 check (discount_idr >= 0 and discount_idr <= subtotal_idr),
  total_idr bigint not null check (total_idr >= 0 and total_idr = subtotal_idr - discount_idr),
  order_status text not null default 'open' check (order_status in ('open','cancelled','closed')),
  payment_status text not null default 'unpaid' check (payment_status in ('unpaid','awaiting_confirmation','under_review','paid','rejected','refund_pending','refunded')),
  fulfillment_status text not null default 'not_started' check (fulfillment_status in ('not_started','in_progress','fulfilled','failed')),
  access_token_hash text not null unique,
  wa_opened_at timestamptz,
  payment_verified_at timestamptz,
  payment_verified_by uuid references public.admin_profiles(user_id) on delete restrict,
  fulfilled_at timestamptz,
  fulfilled_by uuid references public.admin_profiles(user_id) on delete restrict,
  cancelled_at timestamptz,
  customer_note text,
  internal_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(checkout_group_id, seller_id),
  check (fulfillment_status <> 'fulfilled' or payment_status = 'paid'),
  check ((payment_status = 'paid') = (payment_verified_at is not null and payment_verified_by is not null)),
  check ((fulfillment_status = 'fulfilled') = (fulfilled_at is not null and fulfilled_by is not null))
);
create index orders_seller_created_idx on public.orders(seller_id, created_at desc);
create index orders_payment_created_idx on public.orders(payment_status, created_at desc);
create index orders_checkout_group_idx on public.orders(checkout_group_id);

create table public.order_items (
  id uuid primary key default extensions.gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  product_id uuid references public.products(id) on delete restrict,
  variant_id uuid references public.product_variants(id) on delete restrict,
  product_title_snapshot text not null,
  product_slug_snapshot text not null,
  variant_name_snapshot text not null,
  seller_id_snapshot uuid not null references public.sellers(id) on delete restrict,
  license_snapshot text not null,
  unit_price_idr bigint not null check (unit_price_idr >= 0),
  discount_idr bigint not null default 0 check (discount_idr >= 0),
  quantity integer not null default 1 check (quantity > 0),
  line_total_idr bigint not null check (line_total_idr >= 0 and line_total_idr = unit_price_idr * quantity - discount_idr),
  created_at timestamptz not null default now()
);
create index order_items_order_idx on public.order_items(order_id);

create or replace function public.enforce_order_item_seller()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (select 1 from public.orders where id = new.order_id and seller_id = new.seller_id_snapshot) then
    raise exception 'order item seller must match order seller' using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger order_items_seller_guard before insert or update on public.order_items
for each row execute function public.enforce_order_item_seller();

create table public.order_events (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders(id) on delete restrict,
  actor_admin_user_id uuid references public.admin_profiles(user_id) on delete restrict,
  event_type text not null,
  from_state jsonb,
  to_state jsonb,
  note text,
  metadata_redacted jsonb not null default '{}'::jsonb,
  request_id uuid not null,
  created_at timestamptz not null default now()
);
create index order_events_order_created_idx on public.order_events(order_id, created_at);

create table public.checkout_idempotency (
  key_hash text primary key,
  payload_fingerprint text not null,
  checkout_group_id uuid not null unique references public.checkout_groups(id) on delete restrict,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  check (expires_at > created_at)
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_admin_user_id uuid not null references public.admin_profiles(user_id) on delete restrict,
  action text not null,
  entity_type text not null,
  entity_id text not null,
  before_redacted jsonb,
  after_redacted jsonb,
  request_id uuid not null,
  created_at timestamptz not null default now()
);

create table public.site_settings (
  key text primary key,
  value jsonb not null,
  is_public boolean not null default false,
  updated_by uuid references public.admin_profiles(user_id) on delete restrict,
  updated_at timestamptz not null default now()
);

create or replace view public.public_categories with (security_invoker = true) as
select id, name, slug, description, cover_path, sort_order
from public.categories where is_active;

create or replace view public.public_products with (security_invoker = true) as
select p.id, p.seller_id, p.category_id, p.slug, p.title, p.short_description,
       p.description_content, p.format_type, p.featured, p.instructions_public,
       p.compatibility, p.license_summary, p.seo_title, p.seo_description,
       p.og_image_path, p.published_at
from public.products p
join public.sellers s on s.id = p.seller_id and s.is_active
where p.product_status = 'published' and p.deleted_at is null;

alter table public.admin_profiles enable row level security;
alter table public.sellers enable row level security;
alter table public.payment_accounts enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.product_media enable row level security;
alter table public.product_assets enable row level security;
alter table public.checkout_groups enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_events enable row level security;
alter table public.checkout_idempotency enable row level security;
alter table public.audit_logs enable row level security;
alter table public.site_settings enable row level security;

create policy admin_all_admin_profiles on public.admin_profiles for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_sellers on public.sellers for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_payment_accounts on public.payment_accounts for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_categories on public.categories for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy public_read_categories on public.categories for select to anon, authenticated using (is_active);
create policy admin_all_products on public.products for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy public_read_products on public.products for select to anon, authenticated using (product_status = 'published' and deleted_at is null and exists (select 1 from public.sellers s where s.id = seller_id and s.is_active));
create policy admin_all_variants on public.product_variants for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy public_read_variants on public.product_variants for select to anon, authenticated using (is_active and exists (select 1 from public.products p join public.sellers s on s.id = p.seller_id where p.id = product_id and p.product_status = 'published' and p.deleted_at is null and s.is_active));
create policy admin_all_media on public.product_media for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy public_read_media on public.product_media for select to anon, authenticated using (exists (select 1 from public.products p join public.sellers s on s.id = p.seller_id where p.id = product_id and p.product_status = 'published' and p.deleted_at is null and s.is_active));
create policy admin_all_assets on public.product_assets for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_checkout_groups on public.checkout_groups for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_orders on public.orders for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_all_order_items on public.order_items for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy admin_read_order_events on public.order_events for select to authenticated using ((select public.is_active_admin()));
create policy admin_read_audit_logs on public.audit_logs for select to authenticated using ((select public.is_active_admin()));
create policy admin_all_site_settings on public.site_settings for all to authenticated using ((select public.is_active_admin())) with check ((select public.is_active_admin()));
create policy public_read_site_settings on public.site_settings for select to anon, authenticated using (is_public);

revoke all on all tables in schema public from anon, authenticated;
grant select on public.categories, public.products, public.product_variants, public.product_media, public.site_settings to anon, authenticated;
grant select on public.public_categories, public.public_products to anon, authenticated;
grant select, insert, update, delete on public.admin_profiles, public.sellers, public.payment_accounts, public.categories, public.products, public.product_variants, public.product_media, public.product_assets, public.checkout_groups, public.orders, public.order_items, public.site_settings to authenticated;
grant select on public.order_events, public.audit_logs to authenticated;
grant usage, select on all sequences in schema public to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('product-previews', 'product-previews', true, 10485760, array['image/jpeg','image/png','image/webp','image/avif']),
  ('private-product-assets', 'private-product-assets', false, 52428800, null)
on conflict (id) do nothing;

create policy public_read_product_previews on storage.objects for select to anon, authenticated using (bucket_id = 'product-previews');
create policy admin_manage_product_previews on storage.objects for all to authenticated using (bucket_id = 'product-previews' and (select public.is_active_admin())) with check (bucket_id = 'product-previews' and (select public.is_active_admin()));
create policy admin_manage_private_assets on storage.objects for all to authenticated using (bucket_id = 'private-product-assets' and (select public.is_active_admin())) with check (bucket_id = 'private-product-assets' and (select public.is_active_admin()));

commit;
