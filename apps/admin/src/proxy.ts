import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

import { createSupabaseServerClient } from "@/lib/supabase/server";

type AuthUserResult = {
  data: {
    user: { id: string } | null;
  };
};

type GetUser = () => Promise<AuthUserResult>;
type GetStaffRole = (userId: string) => Promise<string | null>;

const protectedPrefixes = ["/calendar", "/staff"];

function isProtectedRoute(pathname: string) {
  return protectedPrefixes.some(
    (prefix) => pathname === prefix || pathname.startsWith(`${prefix}/`),
  );
}

export async function protectStaffRoutes(
  request: NextRequest,
  getUser: GetUser,
  getStaffRole: GetStaffRole,
) {
  if (!isProtectedRoute(request.nextUrl.pathname)) {
    return NextResponse.next();
  }

  const {
    data: { user },
  } = await getUser();

  if (!user) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("next", request.nextUrl.pathname);

    return NextResponse.redirect(loginUrl);
  }

  const staffRole = await getStaffRole(user.id);

  if (!staffRole) {
    const loginUrl = new URL("/login", request.url);
    loginUrl.searchParams.set("next", request.nextUrl.pathname);
    loginUrl.searchParams.set("error", "staff");

    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

export async function proxy(request: NextRequest) {
  const response = NextResponse.next({ request });
  const supabase = createSupabaseServerClient(request, response);
  const authResponse = await protectStaffRoutes(
    request,
    () => supabase.auth.getUser(),
    async (userId) => {
      const { data } = await supabase
        .from("staff_profiles")
        .select("role")
        .eq("user_id", userId)
        .maybeSingle();

      return data?.role ?? null;
    },
  );

  response.cookies.getAll().forEach((cookie) => {
    authResponse.cookies.set(cookie);
  });

  return authResponse;
}

export const config = {
  matcher: ["/calendar/:path*", "/staff/:path*"],
};
