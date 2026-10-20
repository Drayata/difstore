# Testing Evidence

Do not mark checks passed without command output and date.

## Fase 0 — 12 Oktober 2026

| Command | Hasil aktual |
|---|---|
| `npm run lint` | Lulus, 0 warning/error |
| `npm run typecheck` | Lulus |
| `npm run test` | Lulus, 1 file / 2 tests |
| `npm run build` | Lulus |
| `npm run test:e2e -- --reporter=list` | Lulus, 1 mobile Chromium test |
| `npm run cf:check` | Lulus dengan 96% compatibility; `reactStrictMode` partial pada vinext App Router |
| `npm run cf:build` | Lulus; route classification beberapa halaman `?` dan warning ineffective dynamic import |
| `npm audit --omit=dev` | Lulus, 0 vulnerability produksi |
| `npm audit` | Gagal, 8 high pada transitive dev tooling `braces` melalui `eslint-config-next` dan `vinext`; audit fix menawarkan downgrade tidak kompatibel |

Catatan: E2E awal gagal karena browser Playwright belum terpasang, bukan kegagalan aplikasi. `npx playwright install chromium` dijalankan, lalu test lulus.

Cloudflare remote checks tetap terblokir sampai credentials tersedia. Belum ada klaim deployment, auth nyata, CPU, quota, atau fase 0 gate lulus. Lihat `docs/PHASE_0_FEASIBILITY.md`.

## Fase 1 — 12 Oktober 2026

| Command | Hasil aktual |
|---|---|
| `npx supabase db push --dry-run` | Lulus; satu migration terdeteksi |
| `npx supabase db push` | Lulus; `20261012193000_phase1_core_schema.sql` diterapkan ke staging `dhfxhtchbffuvjztndku` |
| `npx supabase migration list` | Local dan remote cocok pada `20261012193000` |
| `npx supabase db lint --linked --level warning` | Lulus sekali: no schema errors; percobaan paralel berikut gagal karena `SUPABASE_DB_PASSWORD` tidak terbaca pada proses tersebut |
| `npx supabase inspect db table-stats --linked` | Lulus; satu `admin_profiles`, tabel transaksi/katalog kosong |
| `npx supabase db advisors --linked --type security` | Sisa satu warning: leaked-password protection belum aktif |
| `npx supabase test db --linked supabase/tests/rls_phase1.test.sql` | Belum jalan: CLI mencoba Docker tetapi akses `/var/run/docker.sock` ditolak |

Push membuat schema inti, constraints, RLS, minimal grants, public safe views, bucket preview publik, bucket asset privat, dan bucket QRIS privat. `SECURITY DEFINER` admin helper sudah dipindah dari exposed `public` ke schema `private`; advisor warning RPC hilang. Satu akun admin nyata terdeteksi. Belum ada seed, order, produk, atau data demo. Gate fase 1 belum lulus sampai SQL RLS tests dan penolakan user non-admin diuji.

## Audit lanjutan — 20 Oktober 2026

| Command | Hasil aktual |
|---|---|
| `npm ci` | Lulus, 549 package terpasang |
| `npm run check` | Lulus: lint, typecheck, 2 file / 4 unit tests, production build |
| `npm audit --omit=dev` | Lulus, 0 vulnerability produksi |
| `npm run test:e2e -- --reporter=list` | Awalnya terblokir karena browser belum terpasang; setelah `npx playwright install chromium`, lulus 1 mobile Chromium test |

Katalog list/detail kini membaca produk published melalui RLS Supabase. Integrasi katalog DB belum bisa diklaim lulus tanpa data staging yang dikendalikan.
