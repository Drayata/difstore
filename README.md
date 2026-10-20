<<<<<<< HEAD
# difstore

DIGIDAW
=======
# Difstore

E-commerce produk digital dengan satu admin, dua seller penerima pembayaran, guest checkout, QRIS statis per pemilik, verifikasi pembayaran manual, dan fulfillment manual melalui WhatsApp.

Status: fase 0 PoC. Checkout produksi sengaja dinonaktifkan sampai transactional PostgreSQL RPC, RLS, dan integration tests tersedia.

## Local setup

```bash
cp .env.example .env.local
npm install
npm run dev
```

Gunakan project Supabase staging nyata untuk auth. Jangan isi secret produksi pada `.env.example` atau commit `.env.local`.

## Quality checks

```bash
npm run lint
npm run typecheck
npm run test
npm run build
npm run test:e2e
npm run cf:check
npm run cf:build
```

## Stack terpin

- Next.js 16.4.0, React 19.3.0, TypeScript 5.9.3
- Tailwind CSS 4.1.14
- Supabase JS 2.117.3, Supabase SSR 0.12.7
- Zod 4.5.0, Vitest 5.0.4, Playwright 1.56.0
- vinext 1.1.0 beta untuk Cloudflare Workers PoC

## Dokumen

- `Difstore_PRD_v1.0.md` — sumber kebenaran
- `docs/IMPLEMENTATION_PLAN.md` — checklist fase
- `docs/TRACEABILITY.md` — requirement ke file/test
- `docs/PHASE_0_FEASIBILITY.md` — gate hosting
- `docs/DECISIONS.md` — ADR
- `docs/TESTING.md` — bukti command aktual
>>>>>>> dea6ced (initial commit)
