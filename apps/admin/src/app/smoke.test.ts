import { describe, expect, it } from "vitest";
import { renderToStaticMarkup } from "react-dom/server";

import Home from "./page";
import LoginPage from "./login/page";

describe("admin landing page", () => {
  it("introduces the staff-authored calendar dashboard", () => {
    const markup = renderToStaticMarkup(Home());

    expect(markup).toContain("Barom Kagyu Calendar Admin");
    expect(markup).toContain("staff-authored calendar content");
  });
});

describe("staff login page", () => {
  it("renders a Supabase credential form with the protected next path", async () => {
    const markup = renderToStaticMarkup(
      await LoginPage({
        searchParams: Promise.resolve({
          next: "/calendar",
          error: "staff",
        }),
      }),
    );

    expect(markup).toContain("Staff sign in");
    expect(markup).toContain('name="email"');
    expect(markup).toContain('name="password"');
    expect(markup).toContain('name="next" value="/calendar"');
    expect(markup).toContain("not assigned to the calendar staff dashboard");
  });
});
