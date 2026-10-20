# Implementation Plan

Status: dimulai 12 Oktober 2026. PRD v1.0 sumber kebenaran.

## Fase 0 — Technical proof & repo baseline

- [x] Baseline Next.js App Router, TypeScript strict, Tailwind
- [x] Token desain PRD dan halaman mobile-first minimal
- [x] Supabase SSR cookie client dan login admin PoC
- [x] Route SSR dinamis + metadata
- [x] Route checkout trust-boundary: Zod + idempotency key; sengaja 503 sampai RPC atomik tersedia
- [x] Vitest, Playwright, ESLint, build scripts
- [x] Audit dokumen resmi Cloudflare/Vercel
- [ ] Hubungkan project Supabase nyata; butuh credentials
- [ ] Deploy Workers preview; butuh akun Cloudflare
- [ ] Uji auth, DB call, cookie refresh, image optimization, crawlability di deployment
- [ ] Load test realistis dan catat CPU/request, error 1102/1027, request quota
- [ ] Putuskan host produksi berdasarkan bukti

Gate: **BELUM LULUS** sampai deployment dan load test nyata selesai. Vercel Hobby dilarang untuk produksi komersial.

## Fase 1 — Database, migration, security

- [x] Schema inti, constraints, indexes, dan kolom snapshot diterapkan ke staging
- [x] Deny-by-default RLS dan grants minimal diterapkan ke staging
- [ ] Trigger immutable snapshot/order setelah checkout RPC tersedia
- [x] Tepat satu akun admin diprovisi; tidak ada signup publik/shared credential
- [x] Bucket preview publik, asset privat, dan QRIS privat dibuat
- [ ] SQL RLS tests untuk anon, non-admin, dan admin terprovisi (test ditulis; eksekusi terblokir Docker socket)
- [x] DAL authorization admin terpusat; secret tetap server-only
- [ ] Typed repositories/services katalog dan order

Gate: anon tidak bisa membaca order/PII/asset; satu admin terprovisi full access; non-admin ditolak.

## Fase 2 — Catalog end-to-end

- [ ] CRUD kategori, produk, varian, media, asset privat
- [ ] Publish validation seller + WA + QRIS
- [ ] Home, catalog, search/filter/sort/pagination, product detail (list + detail DB-backed selesai; search/filter/sort/pagination belum)
- [ ] Metadata, canonical, OG, JSON-LD aman (title/description/canonical selesai; OG/JSON-LD belum)
- [ ] Empty/loading/error/accessibility states (empty catalog selesai; loading/error review belum)

Gate: publish admin menghasilkan product publik dari DB; draft tetap privat.

## Fase 3 — Cart, checkout split, status

- [ ] Cart localStorage ID-only; server quote authoritative
- [ ] PostgreSQL transactional checkout RPC
- [ ] Split satu order per seller + snapshot QRIS/WA/harga
- [ ] Idempotency fingerprint/replay protection
- [ ] Group/order access token hash berentropi tinggi
- [ ] WA deep-link/copy fallback; QRIS statis; status guest
- [ ] Rollback, concurrency, mixed seller tests

Gate: AC-05–16, AC-23–28, AC-35, AC-38 lulus.

## Fase 4 — Admin operations

- [ ] Order list/detail/filter; status machine
- [ ] Manual mark paid dengan deklarasi cek mutasi
- [ ] Fulfillment manual hanya setelah paid
- [ ] Seller/QRIS settings dengan confirmation + audit
- [ ] Revenue verified-paid only; CSV formula protection

Gate: AC-17–22, AC-29–30, AC-36 lulus.

## Fase 5 — Marketing/content/analytics

- [ ] CMS legal/FAQ/hero; sanitized content
- [ ] Coupon seller-scoped + concurrency rules
- [ ] Bundle single-seller
- [ ] Testimonial consent gate; hide empty sections
- [ ] Internal analytics tanpa PII/token
- [ ] Sitemap, robots, campaign UTM

Gate: tidak ada fake proof, token/PII leak, atau purchase event dari WA click.

## Fase 6 — QA, security, compliance, release

- [ ] Semua 40 AC punya test/bukti
- [ ] WCAG 2.2 AA core flow; 320–1920 px/browser matrix
- [ ] RLS/security/fuzz/replay/secrets/dependency audit
- [ ] Cloudflare load/CPU/quota test
- [ ] Backup export + restore drill
- [ ] DNS/HTTPS/security headers/monitoring
- [ ] Merchant QRIS, WA, domain, legal copy, assets produksi diverifikasi

Gate: seluruh P0 hijau; gap P1 disetujui eksplisit.
