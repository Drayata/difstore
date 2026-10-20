import type { Metadata } from "next";
import Link from "next/link";
import { currentPrice, formatIdr } from "@/lib/money";
import { listPublishedProducts } from "@/server/repositories/catalog";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
  title: "Produk digital",
  description: "Jelajahi produk digital Difstore yang sudah dipublikasikan.",
};

export default async function ProductsPage() {
  const products = await listPublishedProducts();

  return (
    <main className="mx-auto min-h-screen max-w-6xl px-5 py-12 sm:px-8">
      <Link className="text-sm font-semibold text-[var(--color-accent)]" href="/">Difstore</Link>
      <h1 className="mt-6 text-4xl font-semibold tracking-tight sm:text-6xl">Produk digital</h1>
      <p className="mt-4 max-w-2xl text-[var(--color-muted)]">Katalog hanya menampilkan produk aktif yang telah dipublikasikan.</p>

      {products.length === 0 ? (
        <section className="mt-12 rounded-2xl border border-[var(--color-border)] bg-white p-8">
          <h2 className="text-xl font-semibold">Belum ada produk</h2>
          <p className="mt-2 text-[var(--color-muted)]">Produk yang siap dijual akan tampil di sini.</p>
        </section>
      ) : (
        <ul className="mt-10 grid list-none gap-5 p-0 sm:grid-cols-2 lg:grid-cols-3">
          {products.map((product) => {
            const variant = product.variants.find(({ isDefault }) => isDefault) ?? product.variants[0];
            return (
              <li key={product.id}>
                <Link className="block min-h-full rounded-2xl border border-[var(--color-border)] bg-white p-6 transition-transform hover:-translate-y-0.5" href={`/products/${product.slug}`}>
                  <p className="text-sm text-[var(--color-muted)]">{product.category?.name ?? product.formatType}</p>
                  <h2 className="mt-3 text-2xl font-semibold">{product.title}</h2>
                  <p className="mt-3 line-clamp-2 text-[var(--color-muted)]">{product.shortDescription}</p>
                  <p className="mt-8 font-semibold">{variant ? formatIdr(currentPrice(variant)) : "Harga belum tersedia"}</p>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </main>
  );
}
