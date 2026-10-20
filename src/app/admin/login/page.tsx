import { login } from "./actions";

type Props = { searchParams: Promise<{ error?: string }> };

export default async function AdminLoginPage({ searchParams }: Props) {
  const { error } = await searchParams;
  return (
    <main className="mx-auto flex min-h-screen max-w-md items-center px-5 py-16">
      <form action={login} className="w-full rounded-2xl border border-[var(--color-border)] bg-white p-7">
        <h1 className="text-3xl font-semibold tracking-tight">Login admin</h1>
        <p className="mt-2 text-sm text-[var(--color-muted)]">Hanya dua akun yang diprovisi. Tidak ada pendaftaran publik.</p>
        {error && <p role="alert" className="mt-5 rounded-lg bg-red-50 p-3 text-sm text-[var(--color-danger)]">Email atau kata sandi tidak valid.</p>}
        <label className="mt-6 block text-sm font-semibold" htmlFor="email">Email</label>
        <input className="mt-2 min-h-11 w-full rounded-lg border border-[var(--color-border)] px-3" id="email" name="email" type="email" autoComplete="email" required />
        <label className="mt-4 block text-sm font-semibold" htmlFor="password">Kata sandi</label>
        <input className="mt-2 min-h-11 w-full rounded-lg border border-[var(--color-border)] px-3" id="password" name="password" type="password" autoComplete="current-password" required />
        <button className="mt-6 min-h-11 w-full rounded-lg bg-[var(--color-primary)] px-5 py-3 font-semibold text-white" type="submit">Masuk</button>
      </form>
    </main>
  );
}
