import { describe, expect, it } from "vitest";
import { NextRequest } from "next/server";

import { config, protectStaffRoutes } from "./proxy";

function requestFor(pathname: string) {
  return new NextRequest(`https://admin.example.test${pathname}`);
}

describe("staff route protection", () => {
  it("redirects unauthenticated staff routes to login", async () => {
    const response = await protectStaffRoutes(requestFor("/calendar"), async () => ({
      data: { user: null },
    }));

    expect(response.status).toBe(307);
    expect(response.headers.get("location")).toBe(
      "https://admin.example.test/login?next=%2Fcalendar",
    );
  });

  it("allows authenticated staff routes", async () => {
    const response = await protectStaffRoutes(
      requestFor("/staff/invitations"),
      async () => ({
        data: { user: { id: "staff-user" } },
      }),
    );

    expect(response.status).toBe(200);
    expect(response.headers.get("location")).toBeNull();
  });

  it("does not protect public routes", async () => {
    const response = await protectStaffRoutes(requestFor("/login"), async () => {
      throw new Error("public routes should not read Supabase auth");
    });

    expect(response.status).toBe(200);
  });

  it("matches calendar and staff dashboard routes", () => {
    expect(config.matcher).toEqual(["/calendar/:path*", "/staff/:path*"]);
  });
});
