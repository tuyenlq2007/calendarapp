import { createServerClient } from "@supabase/ssr";
import type { NextRequest, NextResponse } from "next/server";

function requiredEnvironment(name: string) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`${name} is required to create the Supabase server client`);
  }

  return value;
}

export function createSupabaseServerClient(
  request: NextRequest,
  response: NextResponse,
) {
  return createServerClient(
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_URL"),
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => {
            request.cookies.set(name, value);
          });
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options);
          });
        },
      },
    },
  );
}
