import { describe, expect, it } from "vitest";
import { renderToStaticMarkup } from "react-dom/server";

import Home from "./page";

describe("admin landing page", () => {
  it("introduces the staff-authored calendar dashboard", () => {
    const markup = renderToStaticMarkup(Home());

    expect(markup).toContain("Barom Kagyu Calendar Admin");
    expect(markup).toContain("staff-authored calendar content");
  });
});
