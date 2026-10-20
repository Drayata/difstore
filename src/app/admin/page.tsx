import { requireAdmin } from "@/server/auth/require-admin";

export default async function AdminPage() {
  const admin = await requireAdmin();

  return <main className="mx-auto max-w-5xl px-5 py-16"><h1 className="text-4xl font-semibold">Dashboard PoC</h1><p className="mt-4 text-[var(--color-muted)]">Sesi valid untuk {admin.displayName}. CRUD masuk fase 2.</p></main>;
}
