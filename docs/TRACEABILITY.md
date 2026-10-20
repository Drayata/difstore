# Requirement-to-Test Traceability

Status: fase 1 berjalan. `Planned` berarti belum diimplementasikan atau belum dijalankan.

| AC | Fase | Target file/modul | Test/bukti | Status |
|---|---:|---|---|---|
| AC-01 | 2/6 | `src/app/page.tsx`, store UI | `tests/e2e/home.spec.ts` mobile passed; full viewport matrix pending | Partial |
| AC-02–04 | 2 | `src/server/repositories/catalog.ts`, `src/app/products/*`; admin CRUD/search/filter/sort pending | catalog integration + Playwright pending | Partial |
| AC-05–06 | 3 | cart + quote | cart unit/E2E price-change | Planned |
| AC-07–09 | 3 | checkout RPC | DB integration single/mixed seller | Planned |
| AC-10–12 | 3 | checkout RPC/idempotency | replay/unpublish/rollback tests | Planned |
| AC-13–16 | 3 | WA + QRIS + status | unit/E2E/manual QRIS verification | Planned |
| AC-17–19 | 4 | order transition service | DB integration/admin E2E | Planned |
| AC-20–22 | 1/4 | `20261012193000_phase1_core_schema.sql`, admin auth | RLS deployed; SQL role matrix + auth E2E pending | Partial |
| AC-23–24 | 3 | guest token service | integration enumeration tests | Planned |
| AC-25–26 | 1/3/4 | snapshots/seller settings | DB integration | Planned |
| AC-27–28 | 5 | coupon pricing/locking | unit/concurrency integration | Planned |
| AC-29–30 | 4 | reports/CSV | SQL report + CSV security unit | Planned |
| AC-31 | 2/5 | conditional public sections | catalog E2E | Planned |
| AC-32 | 2/6 | all core UI | axe/keyboard/device E2E + manual | Planned |
| AC-33 | 0/6 | Cloudflare deployment | remote load report | Blocked credentials |
| AC-34 | 6 | backup/security runbooks | restore log + secrets scan | Planned |
| AC-35 | 3 | transactional checkout RPC | forced second-seller failure SQL test | Planned |
| AC-36 | 4 | transition guard/audit | integration invalid transitions | Planned |
| AC-37 | 3/6 | token pages/headers/analytics | browser network/CSP test | Planned |
| AC-38 | 1/3 | seller DB invariant/RPC | adversarial SQL/API test | Planned |
| AC-39 | 1/2 | storage RLS | SQL/storage access test | Planned |
| AC-40 | 0/6 | operations runbook | recovery tabletop evidence | Planned |

## Fase 0 requirement mapping

| Requirement | File | Check |
|---|---|---|
| TypeScript strict | `tsconfig.json` | `npm run typecheck` |
| Next.js App Router SSR | `src/app/products/[slug]/page.tsx` | build + E2E |
| Supabase cookie auth | `src/lib/supabase/server.ts`, `src/app/admin/*` | build; remote auth pending |
| Server validation | `src/app/api/checkout/route.ts` | `tests/unit/checkout-api.test.ts` |
| No fake order/payment | `src/app/api/checkout/route.ts` | valid request returns 503, no persistence |
| Hosting gate | `docs/PHASE_0_FEASIBILITY.md` | remote deploy/load pending |
