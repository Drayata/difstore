import "server-only";

import { cache } from "react";
import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export const requireAdmin = cache(async () => {
  const supabase = await createSupabaseServerClient();
  const { data: { user }, error: userError } = await supabase.auth.getUser();

  if (userError || !user) redirect("/admin/login");

  const { data: profile, error: profileError } = await supabase
    .from("admin_profiles")
    .select("display_name")
    .eq("user_id", user.id)
    .eq("is_active", true)
    .maybeSingle();

  if (profileError || !profile) redirect("/admin/login?error=not_admin");

  return { userId: user.id, displayName: profile.display_name };
});
