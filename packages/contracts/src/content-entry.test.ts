import { describe, expect, test } from "vitest";

import { ContentEntrySchema } from "./index";

const validArticle = {
  id: "8c03f1f4-c78d-4b78-9431-281c9e7fb540",
  slug: "refuge-practice",
  type: "article",
  category: "Practice",
  titleEn: "Refuge Practice",
  titleBo: "སྐྱབས་འགྲོ།",
  summaryEn: "A short teaching for daily practice.",
  summaryBo: "ཉིན་རེའི་སྒྲུབ་པའི་ཆོས་ཁྲིད།",
  bodyEn: "Take refuge with clear motivation.",
  bodyBo: "དགོངས་པ་གསལ་པོས་སྐྱབས་འགྲོ་བྱ།",
  youtubeUrl: null,
  imageUrl: null,
  offlineEligible: true,
  status: "published",
  version: 1,
};

describe("ContentEntrySchema", () => {
  test("accepts bilingual offline-eligible articles", () => {
    const result = ContentEntrySchema.safeParse(validArticle);

    expect(result.success).toBe(true);
  });

  test("requires a valid YouTube URL for videos", () => {
    const result = ContentEntrySchema.safeParse({
      ...validArticle,
      type: "video",
      youtubeUrl: "https://example.com/watch?v=bad",
      offlineEligible: false,
    });

    expect(result.success).toBe(false);
  });

  test("rejects published content missing bilingual titles", () => {
    const result = ContentEntrySchema.safeParse({
      ...validArticle,
      titleBo: "",
    });

    expect(result.success).toBe(false);
  });
});
