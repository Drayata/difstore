# Fase 0 — Hosting & Technology Feasibility

Tanggal audit: 12 Oktober 2026.

## Keputusan sementara

**Cloudflare Workers Free: kandidat PoC, belum disetujui untuk produksi.** Cloudflare merekomendasikan vinext 1.1.0 untuk Next.js 16; vinext masih beta. App Router, SSR, Route Handlers, metadata, dan Server Actions tercatat didukung, image optimization hanya parsial.

Workers Free memberi 100.000 request/hari, 10 ms CPU/request, 128 MB memory, 50 subrequest/request. Cloudflare menyatakan SSR/auth berat lazimnya 10–20 ms CPU. Difstore memakai SSR, Supabase auth, Zod, dan checkout; risiko melewati 10 ms tinggi. Network wait tidak dihitung sebagai CPU, tetapi parsing/render/validation dihitung.

**Vercel Hobby: ditolak untuk produksi.** Dokumen Vercel menyatakan non-commercial personal use only. Vercel Pro tetap fallback berbayar.

## Matriks opsi

| Opsi | Komersial | Biaya awal | Risiko | Status |
|---|---|---:|---|---|
| Cloudflare Workers Free + vinext | Perlu tetap tunduk terms akun; tidak ditemukan larangan komersial pada dokumen limit | Rp0 selain domain | 10 ms CPU, beta compatibility, image partial | PoC wajib |
| Cloudflare Workers Paid + vinext | Ya sesuai plan/terms | Berbayar | vinext beta tetap ada | Fallback utama bila CPU gagal |
| Vercel Hobby | Tidak | Rp0 | Melanggar fair use komersial | Ditolak |
| Vercel Pro | Ya | Berbayar | Biaya berulang | Fallback stabil |
| Static export + Supabase Functions | Tergantung plan | Potensial rendah | Bukan drop-in; SEO/update dinamis lebih rumit | Fallback terakhir |

## Validasi yang belum bisa diklaim

1. Deployment preview nyata: credentials Cloudflare belum tersedia.
2. Supabase auth/DB nyata: project URL/key belum tersedia.
3. CPU p50/p95/p99, startup time, bundle size, error 1102: belum diukur remote.
4. Kuota trafik dan load model produksi: belum disepakati/diukur.
5. Terms komersial Cloudflare: owner perlu menyetujui Terms of Service akun saat provisioning; audit hukum bukan pengganti legal review.

## Prosedur gate

1. Provision Supabase Free staging dan Cloudflare account.
2. Isi secrets lewat platform secret manager; jangan commit `.env`.
3. Jalankan migrations fase 1 dan provision satu admin test.
4. Jalankan `npm run cf:check`, `npm run cf:build`, lalu `npm run cf:deploy`.
5. Uji `/`, `/products/poc-product`, `/admin/login`, cookie session, `/api/health`, `/api/checkout` validation.
6. Jalankan load test terhadap SSR product, authenticated dashboard, checkout validation dan DB call; rekam Workers invocation CPU/wall time/error.
7. Lulus hanya bila p95 CPU stabil di bawah 10 ms dengan headroom, tidak ada compatibility blocker, dan traffic estimate di bawah 100.000 request/hari. Jika gagal, pilih Workers Paid atau Vercel Pro; jangan klaim Rp0.

## Sumber resmi

- https://developers.cloudflare.com/workers/framework-guides/web-apps/nextjs/ (updated 25 Agustus 2026)
- https://developers.cloudflare.com/workers/platform/limits/ (updated 8 Oktober 2026)
- https://vercel.com/docs/plans/hobby (updated 14 September 2026)
- https://supabase.com/docs/guides/platform/manage-your-usage/compute
