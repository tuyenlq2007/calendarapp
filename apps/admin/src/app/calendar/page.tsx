import Link from "next/link";

import styles from "../page.module.css";
import {
  createCalendarRepository,
} from "@/features/calendar/calendar-actions";
import { CalendarEntryTable } from "@/features/calendar/calendar-entry-table";

type CalendarPageProps = {
  searchParams?: Promise<{
    message?: string;
  }>;
};

export default async function CalendarPage({ searchParams }: CalendarPageProps) {
  const params = await searchParams;
  const db = await createCalendarRepository();
  const staffRole = await db.getStaffRole();
  const entries = await db.listEntries();
  const canPublish = staffRole === "reviewer" || staffRole === "administrator";

  return (
    <main className={styles.main}>
      <div className={styles.intro}>
        <p className={styles.kicker}>Calendar publishing</p>
        <h1>Entries</h1>
        <p>Draft, review, and publish Tibetan and English calendar content.</p>
        {params?.message ? <p role="alert">{params.message}</p> : null}
        <Link href="/calendar/new">New entry</Link>
        <CalendarEntryTable entries={entries} canPublish={canPublish} />
      </div>
    </main>
  );
}
