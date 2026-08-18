import { saveCalendarDraft, type CalendarDraft } from "./calendar-actions";

type CalendarFormProps = {
  entry: CalendarDraft;
  errorMessage?: string;
  saveAction?: string | ((formData: FormData) => void | Promise<void>);
};

export function CalendarForm({
  entry,
  errorMessage,
  saveAction = saveCalendarDraft,
}: CalendarFormProps) {
  return (
    <form action={saveAction}>
      {entry.id ? <input type="hidden" name="id" value={entry.id} /> : null}
      {errorMessage ? <p role="alert">{errorMessage}</p> : null}
      <label>
        Gregorian date
        <input
          name="gregorianDate"
          type="date"
          required
          defaultValue={entry.gregorianDate}
        />
      </label>
      <label>
        Tibetan date
        <input
          name="tibetanDateText"
          required
          lang="bo"
          defaultValue={entry.tibetanDateText}
        />
      </label>
      <label>
        English title
        <input name="titleEn" required lang="en" defaultValue={entry.titleEn} />
      </label>
      <label>
        Tibetan title
        <input name="titleBo" required lang="bo" defaultValue={entry.titleBo} />
      </label>
      <label>
        English description
        <textarea name="descriptionEn" lang="en" defaultValue={entry.descriptionEn} />
      </label>
      <label>
        Tibetan description
        <textarea name="descriptionBo" lang="bo" defaultValue={entry.descriptionBo} />
      </label>
      <div>
        <button name="intent" value="draft" type="submit">
          Save draft
        </button>
        <button name="intent" value="review" type="submit">
          Submit for review
        </button>
      </div>
    </form>
  );
}
