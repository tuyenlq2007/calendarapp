import {
  publishCalendarEntry,
  type CalendarDraft,
} from "./calendar-actions";

type CalendarEntryTableProps = {
  entries: CalendarDraft[];
  canPublish: boolean;
  publishAction?: string | ((formData: FormData) => void | Promise<void>);
};

export function CalendarEntryTable({
  entries,
  canPublish,
  publishAction = publishCalendarEntry,
}: CalendarEntryTableProps) {
  return (
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
                  <form action={publishAction}>
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
  );
}
