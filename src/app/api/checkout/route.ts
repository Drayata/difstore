import { createHash, randomUUID } from "node:crypto";
import { NextResponse } from "next/server";
import { z } from "zod";

export const runtime = "nodejs";

const requestSchema = z.object({
  buyerName: z.string().trim().min(2).max(80),
  buyerWhatsapp: z.string().regex(/^\+[1-9]\d{7,14}$/),
  items: z.array(z.object({ variantId: z.uuid(), quantity: z.literal(1) })).min(1).max(30),
  consent: z.literal(true),
});

export async function POST(request: Request) {
  const requestId = randomUUID();
  const idempotencyKey = request.headers.get("idempotency-key");
  if (!idempotencyKey || !z.uuid().safeParse(idempotencyKey).success) {
    return NextResponse.json({ data: null, error: { code: "INVALID_IDEMPOTENCY_KEY", message: "Idempotency-Key wajib UUID." }, requestId }, { status: 400 });
  }

  const body = await request.json().catch(() => null);
  const parsed = requestSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ data: null, error: { code: "VALIDATION_ERROR", message: "Data checkout tidak valid." }, requestId }, { status: 400 });
  }

  // Phase 0 probe only. Never create partial/mock orders before transactional RPC exists.
  const fingerprint = createHash("sha256").update(JSON.stringify(parsed.data)).digest("hex");
  return NextResponse.json({ data: { accepted: false, fingerprint }, error: { code: "CHECKOUT_NOT_ENABLED", message: "Checkout menunggu transactional RPC fase 3." }, requestId }, { status: 503 });
}
