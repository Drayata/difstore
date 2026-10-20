export function formatIdr(value: number): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(value);
}

export function currentPrice(variant: {
  priceIdr: number;
  salePriceIdr: number | null;
  saleStartsAt: string | null;
  saleEndsAt: string | null;
}, now = new Date()): number {
  if (variant.salePriceIdr === null) return variant.priceIdr;
  if (variant.saleStartsAt && new Date(variant.saleStartsAt) > now) return variant.priceIdr;
  if (variant.saleEndsAt && new Date(variant.saleEndsAt) <= now) return variant.priceIdr;
  return variant.salePriceIdr;
}
