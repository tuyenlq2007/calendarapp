import { describe, expect, it } from "vitest";

import {
  publishEntry,
  saveCalendarEntry,
  type CalendarDraft,
  type CalendarRepository,
  type CalendarStatus,
  type StaffRole,
} from "./calendar-actions";

class WorkflowRepository implements CalendarRepository {
  private entries = new Map<string, CalendarDraft>();
  private nextId = 1;

  constructor(private role: StaffRole) {}

  setRole(role: StaffRole) {
    this.role = role;
  }

  async getStaffRole() {
    return this.role;
  }

  async saveDraft(input: Omit<CalendarDraft, "status">) {
    const id = input.id ?? `entry-${this.nextId++}`;
    const current = this.entries.get(id);
    this.entries.set(id, {
      ...current,
      ...input,
      id,
      status: "draft",
    });

    return { id };
  }

  async transition(id: string, status: CalendarStatus) {
    const entry = this.entries.get(id);
    if (!entry) throw new Error("Entry not found");

    if (status === "published" && this.role === "editor") {
      throw new Error("Editor cannot publish");
    }

    this.entries.set(id, { ...entry, status });
  }

  async listEntries() {
    return [...this.entries.values()];
  }
}

describe("calendar publishing workflow", () => {
  it("lets an editor save and submit a draft, lets a reviewer publish, and denies editor publishing", async () => {
    const db = new WorkflowRepository("editor");

    const draft = await saveCalendarEntry(db, {
      gregorianDate: "2026-08-17",
      tibetanDateText: "10th lunar day",
      titleEn: "Practice",
      titleBo: "དུས་ཆེན།",
      descriptionEn: "Daily practice",
      descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
      intent: "draft",
    });

    expect(draft).toEqual({ ok: true, id: "entry-1" });

    const review = await saveCalendarEntry(db, {
      id: "entry-1",
      gregorianDate: "2026-08-17",
      tibetanDateText: "10th lunar day",
      titleEn: "Practice",
      titleBo: "དུས་ཆེན།",
      descriptionEn: "Daily practice",
      descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
      intent: "review",
    });

    expect(review).toEqual({ ok: true, id: "entry-1" });

    await expect(
      publishEntry(db, {
        id: "entry-1",
        tibetanDateText: "10th lunar day",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
      }),
    ).resolves.toEqual({
      ok: false,
      field: "authorization",
      message: "Reviewer access is required to publish entries",
    });

    db.setRole("reviewer");

    await expect(
      publishEntry(db, {
        id: "entry-1",
        tibetanDateText: "10th lunar day",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
      }),
    ).resolves.toEqual({ ok: true });

    expect(await db.listEntries()).toMatchObject([
      {
        id: "entry-1",
        status: "published",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
      },
    ]);
  });
});
