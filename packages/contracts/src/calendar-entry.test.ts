import { describe, expect, test } from "vitest";

import { CalendarEntrySchema } from "./index";

const validCalendarEntry = {
  id: "3f447e33-f9e9-4d24-947b-d2925062f89f",
  gregorianDate: "2026-08-17",
  tibetanDateText: "བོད་ཟླ་༧ ཚེས་༥",
  titleEn: "Dakini Day",
  titleBo: "མཁའ་འགྲོ་མའི་དུས་ཆེན།",
  descriptionEn: "Practice day",
  descriptionBo: "སྒྲུབ་པའི་ཉིན།",
  elementTibetanLine:
    "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
  status: "published",
  version: 1,
};

describe("CalendarEntrySchema", () => {
  test("rejects a published entry missing required Tibetan content", () => {
    const result = CalendarEntrySchema.safeParse({
      ...validCalendarEntry,
      tibetanDateText: "",
    });

    expect(result.success).toBe(false);
  });

  test("rejects impossible Gregorian calendar dates", () => {
    const result = CalendarEntrySchema.safeParse({
      ...validCalendarEntry,
      gregorianDate: "2026-99-99",
    });

    expect(result.success).toBe(false);
  });

  test("accepts an element Tibetan line for daily element content", () => {
    const result = CalendarEntrySchema.safeParse(validCalendarEntry);

    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.elementTibetanLine).toBe(
        "ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།",
      );
    }
  });

  test("accepts explicit practice day metadata", () => {
    const result = CalendarEntrySchema.safeParse({
      ...validCalendarEntry,
      isPracticeDay: true,
      practiceDayTitle: "Green Tara Practice",
      practiceDayDescription: "Practice of Green Tara.",
      practiceDayImageUrl:
        "https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG",
    });

    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.isPracticeDay).toBe(true);
      expect(result.data.practiceDayTitle).toBe("Green Tara Practice");
      expect(result.data.practiceDayDescription).toBe(
        "Practice of Green Tara.",
      );
      expect(result.data.practiceDayImageUrl).toContain("Tara.JPG");
    }
  });

  test("defaults missing practice day flag to false", () => {
    const result = CalendarEntrySchema.safeParse(validCalendarEntry);

    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.isPracticeDay).toBe(false);
      expect(result.data.practiceDayTitle).toBeUndefined();
      expect(result.data.practiceDayDescription).toBeUndefined();
      expect(result.data.practiceDayImageUrl).toBeUndefined();
    }
  });
});
