import { createServerClient } from "@supabase/ssr";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { cookies } from "next/headers";

export type CalendarStatus =
  | "draft"
  | "review"
  | "scheduled"
  | "published"
  | "archived";

export type StaffRole = "editor" | "reviewer" | "administrator";

export type CalendarDraft = {
  id?: string;
  gregorianDate: string;
  tibetanDateText: string;
  titleEn: string;
  titleBo: string;
  descriptionEn: string;
  descriptionBo: string;
  status: CalendarStatus;
};

export type CalendarDraftInput = Omit<CalendarDraft, "status">;

export type CalendarRepository = {
  getStaffRole(): Promise<StaffRole | null>;
  saveDraft(input: CalendarDraftInput): Promise<{ id: string }>;
  transition(id: string, status: CalendarStatus): Promise<void>;
  listEntries(): Promise<CalendarDraft[]>;
};

export type PublishInput = {
  id: string;
  titleEn: string;
  titleBo: string;
  tibetanDateText: string;
};

export type SaveCalendarInput = CalendarDraftInput & {
  intent: "draft" | "review";
};

type ValidationFailure = {
  ok: false;
  field: "titleEn" | "titleBo" | "tibetanDateText" | "authorization";
  message: string;
};

type Success = {
  ok: true;
  id?: string;
};

export class CalendarMutationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "CalendarMutationError";
  }
}

function requiredEnvironment(name: string) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`${name} is required to edit calendar entries`);
  }

  return value;
}

function validatePublication(input: PublishInput): ValidationFailure | null {
  if (!input.titleEn.trim()) {
    return {
      ok: false,
      field: "titleEn",
      message: "English title is required",
    };
  }

  if (!input.titleBo.trim()) {
    return {
      ok: false,
      field: "titleBo",
      message: "Tibetan title is required",
    };
  }

  if (!input.tibetanDateText.trim()) {
    return {
      ok: false,
      field: "tibetanDateText",
      message: "Tibetan date is required",
    };
  }

  return null;
}

function stringField(formData: FormData, name: string) {
  const value = formData.get(name);

  return typeof value === "string" ? value : "";
}

export async function publishEntry(
  db: CalendarRepository,
  input: PublishInput,
): Promise<Success | ValidationFailure> {
  const failure = validatePublication(input);
  if (failure) return failure;

  const role = await db.getStaffRole();
  if (role !== "reviewer" && role !== "administrator") {
    return {
      ok: false,
      field: "authorization",
      message: "Reviewer access is required to publish entries",
    };
  }

  try {
    await db.transition(input.id, "published");
  } catch (error) {
    if (error instanceof CalendarMutationError) {
      return {
        ok: false,
        field: "authorization",
        message: error.message,
      };
    }

    throw error;
  }

  return { ok: true };
}

export async function saveCalendarEntry(
  db: CalendarRepository,
  input: SaveCalendarInput,
): Promise<Success | ValidationFailure> {
  if (input.intent === "review") {
    const failure = validatePublication({
      id: input.id ?? "",
      titleEn: input.titleEn,
      titleBo: input.titleBo,
      tibetanDateText: input.tibetanDateText,
    });
    if (failure) return failure;
  }

  const saved = await db.saveDraft({
    id: input.id?.trim() || undefined,
    gregorianDate: input.gregorianDate,
    tibetanDateText: input.tibetanDateText,
    titleEn: input.titleEn,
    titleBo: input.titleBo,
    descriptionEn: input.descriptionEn,
    descriptionBo: input.descriptionBo,
  });

  if (input.intent === "review") {
    await db.transition(saved.id, "review");
  }

  return { ok: true, id: saved.id };
}

export async function createCalendarRepository(): Promise<CalendarRepository> {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_URL"),
    requiredEnvironment("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
    },
  );

  return {
    async getStaffRole() {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      if (!user) return null;

      const { data, error } = await supabase
        .from("staff_profiles")
        .select("role")
        .eq("user_id", user.id)
        .maybeSingle();

      if (error) throw error;

      return (data?.role as StaffRole | undefined) ?? null;
    },
    async saveDraft(input) {
      const row = {
        gregorian_date: input.gregorianDate,
        tibetan_date_text: input.tibetanDateText,
        title_en: input.titleEn,
        title_bo: input.titleBo,
        description_en: input.descriptionEn,
        description_bo: input.descriptionBo,
        status: "draft" as const,
      };

      if (input.id) {
        const { error } = await supabase
          .from("calendar_entries")
          .update(row)
          .eq("id", input.id)
          .select("id")
          .single();

        if (error) {
          throw new CalendarMutationError(
            "Calendar entry could not be updated by the current role",
          );
        }

        return { id: input.id };
      }

      const { data, error } = await supabase
        .from("calendar_entries")
        .insert(row)
        .select("id")
        .single();

      if (error) {
        throw new CalendarMutationError(
          "Calendar entry could not be created by the current role",
        );
      }

      return { id: data.id as string };
    },
    async transition(id, status) {
      const { error } = await supabase
        .from("calendar_entries")
        .update({ status })
        .eq("id", id)
        .select("id")
        .single();

      if (error) {
        throw new CalendarMutationError(
          status === "published"
            ? "Calendar entry could not be published by the current role"
            : "Calendar entry could not be updated by the current role",
        );
      }
    },
    async listEntries() {
      const { data, error } = await supabase
        .from("calendar_entries")
        .select(
          "id, gregorian_date, tibetan_date_text, title_en, title_bo, description_en, description_bo, status",
        )
        .order("gregorian_date", { ascending: true });

      if (error) throw error;

      return (data ?? []).map((row) => ({
        id: row.id as string,
        gregorianDate: row.gregorian_date as string,
        tibetanDateText: row.tibetan_date_text as string,
        titleEn: row.title_en as string,
        titleBo: row.title_bo as string,
        descriptionEn: row.description_en as string,
        descriptionBo: row.description_bo as string,
        status: row.status as CalendarStatus,
      }));
    },
  };
}

export async function saveCalendarDraft(formData: FormData) {
  "use server";

  const db = await createCalendarRepository();
  const intent = stringField(formData, "intent") === "review" ? "review" : "draft";
  const result = await saveCalendarEntry(db, {
    id: stringField(formData, "id"),
    gregorianDate: stringField(formData, "gregorianDate"),
    tibetanDateText: stringField(formData, "tibetanDateText"),
    titleEn: stringField(formData, "titleEn"),
    titleBo: stringField(formData, "titleBo"),
    descriptionEn: stringField(formData, "descriptionEn"),
    descriptionBo: stringField(formData, "descriptionBo"),
    intent,
  });

  if (!result.ok) {
    const error = new URLSearchParams({
      field: result.field,
      message: result.message,
    });

    redirect(`/calendar/new?${error}`);
  }

  revalidatePath("/calendar");
  redirect("/calendar");
}

export async function publishCalendarEntry(formData: FormData) {
  "use server";

  const db = await createCalendarRepository();
  const result = await publishEntry(db, {
    id: stringField(formData, "id"),
    titleEn: stringField(formData, "titleEn"),
    titleBo: stringField(formData, "titleBo"),
    tibetanDateText: stringField(formData, "tibetanDateText"),
  });

  if (!result.ok) {
    const error = new URLSearchParams({
      field: result.field,
      message: result.message,
    });

    redirect(`/calendar?${error}`);
  }

  revalidatePath("/calendar");
  redirect("/calendar");
}
