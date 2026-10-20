begin;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('merchant-qris', 'merchant-qris', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy admin_manage_merchant_qris
on storage.objects for all to authenticated
using (bucket_id = 'merchant-qris' and (select public.is_active_admin()))
with check (bucket_id = 'merchant-qris' and (select public.is_active_admin()));

commit;
