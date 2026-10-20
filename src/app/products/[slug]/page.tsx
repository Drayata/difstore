import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { currentPrice, formatIdr } from "@/lib/money";
import { getPublishedProductBySlug } from "@/server/repositories/catalog";

export const dynamic = "force-dynamic";

type Props = PageProps<"/products/[slug]">;

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const product = await getPublishedProductBySlug(slug);
  if (!product) return { title: "Produk tidak ditemukan" };

  return {
    title: product.seoTitle ?? product.title,
    description: product.seoDescription ?? product.shortDescription,
    alternates: { canonical: `/products/${product.slug}` },
  };
}

export default async function ProductPage({ params }: Props) {
  const { slug } = await params;
  const product = await getPublishedProductBySlug(slug);
  if (!product) notFound();

  return (
    <main className="mx-auto max-w-5xl px-5 py-12 sm:px-8">
      <nav aria-label="Breadcrumb" className="text-sm text-[var(--color-muted)]">
        <Link href="/products">Produk</Link> / {product.category?.name ?? product.formatType}
      </nav>
      <div className="mt-8 grid gap-8 lg:grid-cols-[1fr_22rem]">
        <article>
          <p className="text-sm font-semibold uppercase tracking-widest text-[var(--color-accent)]">{product.formatType}</p>
          <h1 className="mt-4 text-4xl font-semibold tracking-tight sm:text-6xl">{product.title}</h1>
          <p className="mt-6 max-w-2xl text-lg leading-8 text-[var(--color-muted)]">{product.shortDescription}</p>

          <dl className="mt-10 grid gap-5 border-t border-[var(--color-border)] pt-8 sm:grid-cols-2">
            {product.compatibility && <div><dt className="font-semibold">Kompatibilitas</dt><dd className="mt-1 text-[var(--color-muted)]">{product.compatibility}</dd></div>}
            {product.licenseSummary && <div><dt className="font-semibold">Lisensi</dt><dd className="mt-1 text-[var(--color-muted)]">{product.licenseSummary}</dd></div>}
            {product.instructionsPublic && <div><dt className="font-semibold">Cara penggunaan</dt><dd className="mt-1 text-[var(--color-muted)]">{product.instructionsPublic}</dd></div>}
          </dl>
        </article>

        <aside className="h-fit rounded-2xl border border-[var(--color-border)] bg-white p-6">
          <h2 className="text-lg font-semibold">Pilihan produk</h2>
          {product.variants.length === 0 ? (
            <p className="mt-4 text-[var(--color-muted)]">Belum tersedia untuk dibeli.</p>
          ) : (
            <ul className="mt-4 list-none divide-y divide-[var(--color-border)] p-0">
              {product.variants.map((variant) => (
                <li className="flex items-center justify-between gap-4 py-4" key={variant.id}>
                  <span>{variant.name}</span>
                  <strong>{formatIdr(currentPrice(variant))}</strong>
                </li>
              ))}
            </ul>
          )}
          <p className="mt-6 text-sm leading-6 text-[var(--color-muted)]">Checkout belum dibuka sampai transaksi atomik dan seller split teruji. Tidak ada pesanan palsu dibuat.</p>
        </aside>
      </div>
    </main>
  );
}
