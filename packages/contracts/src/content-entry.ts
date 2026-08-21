import { z } from "zod";

import { PublicationStatusSchema } from "./calendar-entry";

const youtubeUrlSchema = z
  .string()
  .url()
  .refine((value) => {
    const url = new URL(value);
    return (
      url.hostname === "youtu.be" ||
      url.hostname === "www.youtube.com" ||
      url.hostname === "youtube.com"
    );
  }, "Expected a YouTube URL");

export const ContentTypeSchema = z.enum(["article", "video"]);

export const ContentEntrySchema = z
  .object({
    id: z.string().uuid(),
    slug: z.string().trim().min(1),
    type: ContentTypeSchema,
    category: z.string().trim().min(1),
    titleEn: z.string().trim().min(1),
    titleBo: z.string().trim().min(1),
    summaryEn: z.string(),
    summaryBo: z.string(),
    bodyEn: z.string(),
    bodyBo: z.string(),
    youtubeUrl: youtubeUrlSchema.nullable(),
    imageUrl: z.string().url().nullable(),
    offlineEligible: z.boolean(),
    status: PublicationStatusSchema,
    version: z.number().int().positive(),
  })
  .superRefine((entry, context) => {
    if (entry.type === "video" && entry.youtubeUrl === null) {
      context.addIssue({
        code: z.ZodIssueCode.custom,
        path: ["youtubeUrl"],
        message: "Video content requires a YouTube URL",
      });
    }

    if (entry.type === "article" && entry.offlineEligible) {
      if (entry.bodyEn.trim() === "" || entry.bodyBo.trim() === "") {
        context.addIssue({
          code: z.ZodIssueCode.custom,
          path: ["offlineEligible"],
          message: "Offline articles require bilingual body content",
        });
      }
    }
  });

export type ContentEntry = z.infer<typeof ContentEntrySchema>;
