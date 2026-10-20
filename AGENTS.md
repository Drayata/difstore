# AGENTS.md — Difstore Engineering Contract

Read `Difstore_PRD_v1.0.md` fully before any implementation. The PRD is the source of truth and includes 40 numbered acceptance criteria, full schema, UI/UX and the phase plan.

## Non-negotiable invariants

1. One brand, one explicitly provisioned admin account with full access, public guest checkout only. Never share this credential; adding another admin later requires an explicit product decision.
2. Product always belongs to precisely one seller; seller determines WhatsApp and static merchant QRIS.
3. A cart may mix owners; one checkout group **must split into one order per seller**, each with independent ID, amount, QRIS and WhatsApp destination.
4. Never use browser-supplied prices, seller IDs or totals as authoritative. Recompute server-side and snapshot order price + recipient account.
5. Order creation must be atomic. Use a safely-scoped PostgreSQL transactional function/RPC or equivalent verified single DB transaction and idempotency protections.
6. QRIS is static. Buyer contacts seller through WhatsApp **before payment**, sends screenshot on WhatsApp, and admin verifies actual merchant funds manually. Clicking WhatsApp or “I paid” can **never** mark paid.
7. Fulfillment is **manual by admin** through WhatsApp. Unpaid orders may not be fulfilled.
8. Anonymous direct database access to orders, private product assets, or buyer personal data is prohibited. Restrict the service secret to server-only code.
9. Historical orders keep immutable owner/payment account/price snapshots. Both admins may read and operate all orders; log who did what.
10. Do not publish fake ratings, testimonials, scarcity, purchase counts, timers, or unverified conversion claims.
11. Vercel Hobby is for non-commercial use; it is unsuitable for commercial production. Evaluate Cloudflare Workers Free via compatible Next.js adapter, **validate its runtime constraints**, and document a fallback to compliant hosting if the free path fails.
12. Never describe a UI mock, fake API, fake payment confirmation or unrun test as a completed feature.

## Execution process

- Read the PRD and produce an implementation plan and requirement-to-test traceability matrix.
- First deliver a production-hosting PoC (Next.js SSR product, Supabase auth, database/API checkout flow) and record whether the selected host permits commercial use and meets quotas.
- Work in vertical slices: migrations/RLS/auth → catalog+CMS → cart+seller-split checkout → guest token status+WA/QRIS → admin payment verification/fulfillment → promo+SEO+analytics → QA/release.
- Use Next.js App Router, TypeScript strict, Tailwind, Supabase PostgreSQL/Auth/Storage, Zod, Vitest, Playwright and SQL RLS tests. Pin compatible stable dependencies and keep docs current.
- At the end of each slice run lint, typecheck, automated tests and build, reporting actual command outputs and remaining limitations.
- Keep `.env.example`, migration scripts, `README.md`, architecture/decision log, security and deployment runbooks. Secrets never appear in committed code or browser bundles.
- Do not ask for details explicitly provided by the PRD. Treat missing domain, merchant QRIS, numbers, logo, legal copy and production keys as configurable values; add a release-blockers checklist and do not invent them.

## Definition of Done

All PRD P0 acceptance criteria pass; target v1 P1 features also delivered unless owner explicitly changes scope; mixed seller orders verified; RLS and route authorization tested; no unauthorized file delivery; guest tracking uses unguessable access tokens; mobile and accessibility tests pass; verified merchant QRIS/WA routes are real; commercial hosting validated; screenshots/actual test logs accompany handoff.

<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
