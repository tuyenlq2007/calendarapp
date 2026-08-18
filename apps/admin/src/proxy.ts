import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

import { createSupabaseServerClient } from "@/lib/supabase/server";

type AuthUserResult = {
  data: {
    user: unknown | null;
  };
};

type GetUser = () => Promise<AuthUserResult>;

const protectedPrefixes = ["/calendar", "/staff"];

function isProtectedRoute(pathname: string) {
  return protectedPrefixes.some(
    (prefix) => pathname === prefix || pathname.startsWith(`${prefix}/`),
  );
}

export async function protectStaffRoutes(
  request: NextRequest,
  getUser: GetUser,
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

  return NextResponse.next();
}

export async function proxy(request: NextRequest) {
  const response = NextResponse.next({ request });
  const supabase = createSupabaseServerClient(request, response);
  const authResponse = await protectStaffRoutes(request, () =>
    supabase.auth.getUser(),
  );

  response.cookies.getAll().forEach((cookie) => {
    authResponse.cookies.set(cookie);
  });

  return authResponse;
}

export const config = {
  matcher: ["/calendar/:path*", "/staff/:path*"],
};
