import { z } from "zod";

const isoDatePattern = /^\d{4}-\d{2}-\d{2}$/;

function isGregorianDate(value: string) {
  if (!isoDatePattern.test(value)) return false;

  const [year, month, day] = value.split("-").map(Number);
  const parsed = new Date(Date.UTC(year, month - 1, day));

  return (
    parsed.getUTCFullYear() === year &&
    parsed.getUTCMonth() === month - 1 &&
    parsed.getUTCDate() === day
  );
}

export const PublicationStatusSchema = z.enum([
  "draft",
  "review",
  "scheduled",
  "published",
  "archived",
]);

export const CalendarEntrySchema = z.object({
  id: z.string().uuid(),
  gregorianDate: z
    .string()
    .refine(isGregorianDate, "Expected valid YYYY-MM-DD Gregorian date"),
  tibetanDateText: z.string().trim().min(1),
  titleEn: z.string().trim().min(1),
  titleBo: z.string().trim().min(1),
  descriptionEn: z.string(),
  descriptionBo: z.string(),
  elementTibetanLine: z.string(),
  status: PublicationStatusSchema,
  version: z.number().int().positive(),
});

export type CalendarEntry = z.infer<typeof CalendarEntrySchema>;
