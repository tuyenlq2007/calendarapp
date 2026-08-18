import { describe, expect, it } from "vitest";
import { renderToStaticMarkup } from "react-dom/server";

import Home from "./page";
import LoginPage from "./login/page";
import { CalendarEntryTable } from "@/features/calendar/calendar-entry-table";
import { CalendarForm } from "@/features/calendar/calendar-form";

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

describe("calendar entry form", () => {
  it("renders bilingual fields and workflow actions", () => {
    const markup = renderToStaticMarkup(
      CalendarForm({
        entry: {
          id: "entry",
          gregorianDate: "2026-08-17",
          tibetanDateText: "10th lunar day",
          titleEn: "Practice",
          titleBo: "དུས་ཆེན།",
          descriptionEn: "Daily practice",
          descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
          status: "draft",
        },
      }),
    );

    expect(markup).toContain('name="gregorianDate"');
    expect(markup).toContain('name="tibetanDateText"');
    expect(markup).toContain('name="titleEn"');
    expect(markup).toContain('name="titleBo"');
    expect(markup).toContain('value="draft"');
    expect(markup).toContain('value="review"');
  });

  it("renders publish controls only for publishing roles", () => {
    const entry = {
      id: "entry",
      gregorianDate: "2026-08-17",
      tibetanDateText: "10th lunar day",
      titleEn: "Practice",
      titleBo: "དུས་ཆེན།",
      descriptionEn: "Daily practice",
      descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
      status: "review" as const,
    };

    const editorMarkup = renderToStaticMarkup(
      CalendarEntryTable({
        entries: [entry],
        canPublish: false,
        publishAction: "#publish",
      }),
    );
    const reviewerMarkup = renderToStaticMarkup(
      CalendarEntryTable({
        entries: [entry],
        canPublish: true,
        publishAction: "#publish",
      }),
    );

    expect(editorMarkup).toContain("No action");
    expect(editorMarkup).not.toContain("Publish");
    expect(reviewerMarkup).toContain("Publish");
  });
});
