"use server";

import { createServerClient } from "@supabase/ssr";
import { redirect } from "next/navigation";
import { cookies } from "next/headers";

function requiredEnvironment(name: string) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`${name} is required to sign in with Supabase`);
  }

  return value;
}

function safeNextPath(value: FormDataEntryValue | null) {
  if (typeof value !== "string") return "/calendar";
  if (!value.startsWith("/") || value.startsWith("//")) return "/calendar";

  return value;
}

export async function signInStaff(formData: FormData) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_URL"),
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
    },
  );

  const email = String(formData.get("email") ?? "");
  const password = String(formData.get("password") ?? "");
  const nextPath = safeNextPath(formData.get("next"));

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    const loginUrl = new URL("http://localhost/login");
    loginUrl.pathname = "/login";
    loginUrl.searchParams.set("next", nextPath);
    loginUrl.searchParams.set("error", "credentials");

    redirect(`${loginUrl.pathname}${loginUrl.search}`);
  }

  redirect(nextPath);
}
