import styles from "../../page.module.css";
import { CalendarForm } from "@/features/calendar/calendar-form";
import type { CalendarDraft } from "@/features/calendar/calendar-actions";

type NewCalendarEntryPageProps = {
  searchParams?: Promise<{
    message?: string;
  }>;
};

const emptyEntry: CalendarDraft = {
  gregorianDate: "",
  tibetanDateText: "",
  titleEn: "",
  titleBo: "",
  descriptionEn: "",
  descriptionBo: "",
  status: "draft",
};

export default async function NewCalendarEntryPage({
  searchParams,
}: NewCalendarEntryPageProps) {
  const params = await searchParams;

  return (
    <main className={styles.main}>
      <div className={styles.intro}>
        <p className={styles.kicker}>Calendar publishing</p>
        <h1>New calendar entry</h1>
        <CalendarForm entry={emptyEntry} errorMessage={params?.message} />
      </div>
    </main>
  );
}
