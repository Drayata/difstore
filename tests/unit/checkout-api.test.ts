import { describe, expect, it } from "vitest";
import { POST } from "../../src/app/api/checkout/route";

function request(body: unknown, key = "550e8400-e29b-41d4-a716-446655440000") {
  return new Request("http://localhost/api/checkout", { method: "POST", headers: { "content-type": "application/json", "idempotency-key": key }, body: JSON.stringify(body) });
}

describe("checkout phase 0 boundary", () => {
  it("rejects invalid input without creating a fake order", async () => {
    const response = await POST(request({ buyerName: "A", buyerWhatsapp: "0812", items: [], consent: false }));
    expect(response.status).toBe(400);
  });

  it("validates input but stays disabled until transactional RPC exists", async () => {
    const response = await POST(request({ buyerName: "Pembeli", buyerWhatsapp: "+628123456789", items: [{ variantId: "550e8400-e29b-41d4-a716-446655440000", quantity: 1 }], consent: true }));
    expect(response.status).toBe(503);
    expect((await response.json()).error.code).toBe("CHECKOUT_NOT_ENABLED");
  });
});
