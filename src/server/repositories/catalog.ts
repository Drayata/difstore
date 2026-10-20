import "server-only";

import { cache } from "react";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type CatalogProduct = {
  id: string;
  slug: string;
  title: string;
  shortDescription: string;
  formatType: string;
  licenseSummary: string | null;
  compatibility: string | null;
  instructionsPublic: string | null;
  seoTitle: string | null;
  seoDescription: string | null;
  publishedAt: string;
  category: { name: string; slug: string } | null;
  variants: Array<{
    id: string;
    name: string;
    priceIdr: number;
    salePriceIdr: number | null;
    saleStartsAt: string | null;
    saleEndsAt: string | null;
    licenseType: string;
    isDefault: boolean;
  }>;
};

type ProductRow = {
  id: string;
  slug: string;
  title: string;
  short_description: string;
  format_type: string;
  license_summary: string | null;
  compatibility: string | null;
  instructions_public: string | null;
  seo_title: string | null;
  seo_description: string | null;
  published_at: string;
  categories: Array<{ name: string; slug: string }>;
  product_variants: Array<{
    id: string;
    name: string;
    price_idr: number;
    sale_price_idr: number | null;
    sale_starts_at: string | null;
    sale_ends_at: string | null;
    license_type: string;
    is_default: boolean;
  }>;
};

const productSelect = `
  id, slug, title, short_description, format_type, license_summary,
  compatibility, instructions_public, seo_title, seo_description, published_at,
  categories(name, slug),
  product_variants(id, name, price_idr, sale_price_idr, sale_starts_at, sale_ends_at, license_type, is_default)
`;

function mapProduct(row: ProductRow): CatalogProduct {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    shortDescription: row.short_description,
    formatType: row.format_type,
    licenseSummary: row.license_summary,
    compatibility: row.compatibility,
    instructionsPublic: row.instructions_public,
    seoTitle: row.seo_title,
    seoDescription: row.seo_description,
    publishedAt: row.published_at,
    category: row.categories[0] ?? null,
    variants: row.product_variants.map((variant) => ({
      id: variant.id,
      name: variant.name,
      priceIdr: variant.price_idr,
      salePriceIdr: variant.sale_price_idr,
      saleStartsAt: variant.sale_starts_at,
      saleEndsAt: variant.sale_ends_at,
      licenseType: variant.license_type,
      isDefault: variant.is_default,
    })),
  };
}

export const listPublishedProducts = cache(async (): Promise<CatalogProduct[]> => {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase
    .from("products")
    .select(productSelect)
    .order("published_at", { ascending: false })
    .order("sort_order", { referencedTable: "product_variants", ascending: true });

  if (error) throw new Error("Katalog gagal dimuat.", { cause: error });
  return (data as ProductRow[]).map(mapProduct);
});

export const getPublishedProductBySlug = cache(async (slug: string): Promise<CatalogProduct | null> => {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase
    .from("products")
    .select(productSelect)
    .eq("slug", slug)
    .order("sort_order", { referencedTable: "product_variants", ascending: true })
    .maybeSingle();

  if (error) throw new Error("Produk gagal dimuat.", { cause: error });
  return data ? mapProduct(data as ProductRow) : null;
});
