# Architecture Decision Log

## ADR-001 — Split order per seller

Status: accepted by PRD. One checkout group creates exactly one order per seller. PostgreSQL RPC owns recomputation, snapshots, idempotency, and atomic commit.

## ADR-002 — Manual QRIS payment and fulfillment

Status: accepted. WA click and buyer statement never mark paid. Admin verifies merchant funds, then manually sends product. Fulfillment cannot precede paid.

## ADR-003 — Deny direct anonymous order access

Status: accepted. Public catalog uses safe projection. Orders, buyer PII, audit logs, and private assets deny anon. Guest status uses hashed high-entropy token through server boundary.

## ADR-004 — Hosting candidate

Status: provisional. Cloudflare Workers Free + vinext selected for PoC, not production approval. Vercel Hobby rejected. Workers Paid or Vercel Pro fallback when free CPU/compatibility gate fails.

## ADR-005 — One production admin

Status: accepted 12 Oktober 2026, owner scope change. V1 provisions exactly one full-access admin account. Credential sharing and public signup remain prohibited. Two seller/payment recipients remain unchanged. Schema remains multi-row capable to avoid unnecessary migration; provisioning policy and acceptance tests enforce one active admin. Adding another admin requires explicit product decision.
