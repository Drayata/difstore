import { describe, expect, it } from "vitest";
import { currentPrice, formatIdr } from "../../src/lib/money";

const variant = {
  priceIdr: 50_000,
  salePriceIdr: 35_000,
  saleStartsAt: "2026-10-01T00:00:00.000Z",
  saleEndsAt: "2026-11-01T00:00:00.000Z",
};

describe("catalog money", () => {
  it("memakai sale price hanya selama periode aktif", () => {
    expect(currentPrice(variant, new Date("2026-10-20T00:00:00.000Z"))).toBe(35_000);
    expect(currentPrice(variant, new Date("2026-11-01T00:00:00.000Z"))).toBe(50_000);
  });

  it("memformat integer rupiah tanpa pecahan", () => {
    expect(formatIdr(25_000)).toMatch(/Rp\s?25\.000/);
  });
});
