export type CalendarLocale = "en" | "bo";

export type CalendarContentSource = "staff-authored";

export {
  CalendarEntrySchema,
  PublicationStatusSchema,
  type CalendarEntry,
} from "./calendar-entry";

export {
  ContentEntrySchema,
  ContentTypeSchema,
  type ContentEntry,
} from "./content-entry";
