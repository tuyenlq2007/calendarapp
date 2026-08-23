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
});
