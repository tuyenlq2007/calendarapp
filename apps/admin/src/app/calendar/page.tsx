import Link from "next/link";

import styles from "../page.module.css";
import {
  createCalendarRepository,
  publishCalendarEntry,
} from "@/features/calendar/calendar-actions";

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
        <table>
          <thead>
            <tr>
              <th scope="col">Date</th>
              <th scope="col">English</th>
              <th scope="col">Tibetan</th>
              <th scope="col">Status</th>
              <th scope="col">Action</th>
            </tr>
          </thead>
          <tbody>
            {entries.length === 0 ? (
              <tr>
                <td colSpan={5}>No calendar entries yet.</td>
              </tr>
            ) : (
              entries.map((entry) => (
                <tr key={entry.id}>
                  <td>{entry.gregorianDate}</td>
                  <td>{entry.titleEn}</td>
                  <td lang="bo">{entry.titleBo}</td>
                  <td>{entry.status}</td>
                  <td>
                    {canPublish &&
                    (entry.status === "review" || entry.status === "scheduled") ? (
                      <form action={publishCalendarEntry}>
                        <input type="hidden" name="id" value={entry.id} />
                        <input type="hidden" name="titleEn" value={entry.titleEn} />
                        <input type="hidden" name="titleBo" value={entry.titleBo} />
                        <input
                          type="hidden"
                          name="tibetanDateText"
                          value={entry.tibetanDateText}
                        />
                        <button type="submit">Publish</button>
                      </form>
                    ) : (
                      "No action"
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </main>
  );
}
