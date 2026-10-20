import Link from "next/link";

export default function HomePage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-6xl flex-col justify-center px-5 py-16 sm:px-8">
      <p className="mb-5 text-sm font-semibold uppercase tracking-[0.2em] text-[var(--color-accent)]">Difstore</p>
      <h1 className="max-w-4xl text-5xl font-semibold leading-[0.95] tracking-tight sm:text-7xl">
        Produk digital yang bikin ide lebih cepat jadi nyata.
      </h1>
      <p className="mt-7 max-w-2xl text-lg leading-8 text-[var(--color-muted)]">
        Pilih produk, buat pesanan tanpa akun, hubungi admin melalui WhatsApp, lalu bayar memakai QRIS statis yang sesuai pemilik produk.
      </p>
      <div className="mt-10 flex flex-wrap gap-3">
        <Link className="min-h-11 rounded-xl bg-[var(--color-primary)] px-6 py-3 font-semibold text-white" href="/products/poc-product">
          Lihat produk PoC
        </Link>
        <Link className="min-h-11 rounded-xl border border-[var(--color-border)] bg-white px-6 py-3 font-semibold" href="/admin/login">
          Login admin
        </Link>
      </div>
      <p className="mt-12 border-l-2 border-[var(--color-warning)] pl-4 text-sm text-[var(--color-muted)]">
        PoC fase 0. Belum menerima transaksi produksi.
      </p>
    </main>
  );
}
