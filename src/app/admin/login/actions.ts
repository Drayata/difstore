"use server";

import { redirect } from "next/navigation";
import { z } from "zod";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const loginSchema = z.object({ email: z.email().trim(), password: z.string().min(8).max(128) });

export async function login(formData: FormData) {
  const credentials = loginSchema.safeParse({ email: formData.get("email"), password: formData.get("password") });
  if (!credentials.success) redirect("/admin/login?error=invalid_credentials");

  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.signInWithPassword(credentials.data);

  if (error) redirect("/admin/login?error=invalid_credentials");
  redirect("/admin");
}
