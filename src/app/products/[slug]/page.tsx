import { notFound } from "next/navigation";

export const dynamic = "force-dynamic";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props) {
  const { slug } = await params;
  return { title: slug === "poc-product" ? "Produk PoC" : "Produk tidak ditemukan" };
}

export default async function ProductPage({ params }: Props) {
  const { slug } = await params;
  if (slug !== "poc-product") notFound();

  return (
    <main className="mx-auto max-w-4xl px-5 py-16 sm:px-8">
      <p className="text-sm text-[var(--color-muted)]">Produk / Proof of Concept</p>
      <h1 className="mt-4 text-4xl font-semibold tracking-tight sm:text-6xl">Produk PoC SSR</h1>
      <p className="mt-6 max-w-2xl text-lg leading-8 text-[var(--color-muted)]">
        Route dinamis ini membuktikan App Router SSR dan metadata dinamis. Data katalog Supabase nyata masuk fase 2 setelah schema dan RLS fase 1 lulus.
      </p>
      <div className="mt-10 rounded-2xl border border-[var(--color-border)] bg-white p-6">
        <p className="font-semibold">Tidak dijual</p>
        <p className="mt-2 text-sm text-[var(--color-muted)]">Tidak ada tombol pembayaran palsu atau order dummy.</p>
      </div>
    </main>
  );
}
