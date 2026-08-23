import { describe, expect, it } from "vitest";

import {
  CalendarMutationError,
  publishEntry,
  saveCalendarEntry,
  type CalendarRepository,
} from "./calendar-actions";

function repository(): CalendarRepository & {
  transitions: Array<{ id: string; status: string }>;
  saved: unknown[];
  role: "editor" | "reviewer" | "administrator";
} {
  const transitions: Array<{ id: string; status: string }> = [];
  const saved: unknown[] = [];

  return {
    transitions,
    saved,
    role: "reviewer",
    async getStaffRole() {
      return this.role;
    },
    async saveDraft(input) {
      saved.push(input);

      return { id: input.id ?? "new-entry" };
    },
    async transition(id, status) {
      transitions.push({ id, status });
    },
    async listEntries() {
      return [];
    },
  };
}

describe("calendar publishing actions", () => {
  it("does not publish an entry without both titles", async () => {
    const db = repository();

    const result = await publishEntry(db, {
      id: "9a4136e0-7254-4ee3-943c-6f552e087452",
      titleEn: "Practice",
      titleBo: "",
      tibetanDateText: "10th lunar day",
    });

    expect(result).toEqual({
      ok: false,
      field: "titleBo",
      message: "Tibetan title is required",
    });
    expect(db.transitions).toEqual([]);
  });

  it("requires English title and Tibetan date before publishing", async () => {
    const db = repository();

    await expect(
      publishEntry(db, {
        id: "entry",
        titleEn: " ",
        titleBo: "དུས་ཆེན།",
        tibetanDateText: "10th lunar day",
      }),
    ).resolves.toEqual({
      ok: false,
      field: "titleEn",
      message: "English title is required",
    });

    await expect(
      publishEntry(db, {
        id: "entry",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
        tibetanDateText: " ",
      }),
    ).resolves.toEqual({
      ok: false,
      field: "tibetanDateText",
      message: "Tibetan date is required",
    });
  });

  it("publishes valid bilingual entries", async () => {
    const db = repository();

    const result = await publishEntry(db, {
      id: "entry",
      titleEn: "Practice",
      titleBo: "དུས་ཆེན།",
      tibetanDateText: "10th lunar day",
    });

    expect(result).toEqual({ ok: true });
    expect(db.transitions).toEqual([{ id: "entry", status: "published" }]);
  });

  it("does not let editors publish entries", async () => {
    const db = repository();
    db.role = "editor";

    const result = await publishEntry(db, {
      id: "entry",
      titleEn: "Practice",
      titleBo: "à½‘à½´à½¦à¼‹à½†à½ºà½“à¼",
      tibetanDateText: "10th lunar day",
    });

    expect(result).toEqual({
      ok: false,
      field: "authorization",
      message: "Reviewer access is required to publish entries",
    });
    expect(db.transitions).toEqual([]);
  });

  it("does not report success when the repository denies publication", async () => {
    const db = repository();
    db.transition = async () => {
      throw new CalendarMutationError(
        "Calendar entry could not be published by the current role",
      );
    };

    const result = await publishEntry(db, {
      id: "entry",
      titleEn: "Practice",
      titleBo: "à½‘à½´à½¦à¼‹à½†à½ºà½“à¼",
      tibetanDateText: "10th lunar day",
    });

    expect(result).toEqual({
      ok: false,
      field: "authorization",
      message: "Calendar entry could not be published by the current role",
    });
  });

  it("surfaces unexpected publication failures", async () => {
    const db = repository();
    db.transition = async () => {
      throw new Error("database unavailable");
    };

    await expect(
      publishEntry(db, {
        id: "entry",
        titleEn: "Practice",
        titleBo: "à½‘à½´à½¦à¼‹à½†à½ºà½“à¼",
        tibetanDateText: "10th lunar day",
      }),
    ).rejects.toThrow("database unavailable");
  });

  it("saves drafts and submits review through explicit workflow intents", async () => {
    const db = repository();

    await expect(
      saveCalendarEntry(db, {
        id: "",
        gregorianDate: "2026-08-17",
        tibetanDateText: "10th lunar day",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
        descriptionEn: "Daily practice",
        descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
        elementTibetanLine:
          "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
        intent: "draft",
      }),
    ).resolves.toEqual({ ok: true, id: "new-entry" });

    await expect(
      saveCalendarEntry(db, {
        id: "new-entry",
        gregorianDate: "2026-08-17",
        tibetanDateText: "10th lunar day",
        titleEn: "Practice",
        titleBo: "དུས་ཆེན།",
        descriptionEn: "Daily practice",
        descriptionBo: "ཉིན་རེའི་ཉམས་ལེན།",
        elementTibetanLine:
          "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
        intent: "review",
      }),
    ).resolves.toEqual({ ok: true, id: "new-entry" });

    expect(db.transitions).toEqual([{ id: "new-entry", status: "review" }]);
    expect(db.saved).toEqual([
      expect.objectContaining({
        elementTibetanLine:
          "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
      }),
      expect.objectContaining({
        elementTibetanLine:
          "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
      }),
    ]);
  });

  it("validates review submission before mutating drafts", async () => {
    const db = repository();

    const result = await saveCalendarEntry(db, {
      id: "existing-entry",
      gregorianDate: "2026-08-17",
      tibetanDateText: "10th lunar day",
      titleEn: "Practice",
      titleBo: "",
      descriptionEn: "Daily practice",
      descriptionBo: "",
      elementTibetanLine: "",
      intent: "review",
    });

    expect(result).toEqual({
      ok: false,
      field: "titleBo",
      message: "Tibetan title is required",
    });
    expect(db.saved).toEqual([]);
    expect(db.transitions).toEqual([]);
  });
});
