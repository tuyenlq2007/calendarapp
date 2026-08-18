import { expect, test } from "@playwright/test";

const editorWorkflowHtml = `
  <form action="#save">
    <label>
      Gregorian date
      <input name="gregorianDate" type="date" required>
    </label>
    <label>
      Tibetan date
      <input name="tibetanDateText" required lang="bo">
    </label>
    <label>
      English title
      <input name="titleEn" required lang="en">
    </label>
    <label>
      Tibetan title
      <input name="titleBo" required lang="bo">
    </label>
    <button name="intent" value="draft" type="submit">Save draft</button>
    <button name="intent" value="review" type="submit">Submit for review</button>
  </form>
  <table>
    <tbody>
      <tr>
        <td>2026-08-17</td>
        <td>Practice</td>
        <td lang="bo">དུས་ཆེན།</td>
        <td>review</td>
        <td>No action</td>
      </tr>
    </tbody>
  </table>
`;

const reviewerWorkflowHtml = `
  <table>
    <tbody>
      <tr>
        <td>2026-08-17</td>
        <td>Practice</td>
        <td lang="bo">དུས་ཆེན།</td>
        <td>review</td>
        <td>
          <form action="#publish">
            <input type="hidden" name="id" value="entry-1">
            <input type="hidden" name="titleEn" value="Practice">
            <input type="hidden" name="titleBo" value="དུས་ཆེན།">
            <input type="hidden" name="tibetanDateText" value="10th lunar day">
            <button type="submit">Publish</button>
          </form>
        </td>
      </tr>
    </tbody>
  </table>
`;

test("editor can fill bilingual draft form but cannot publish reviewed entries", async ({
  page,
}) => {
  await page.setContent(editorWorkflowHtml);

  await page.getByLabel("Gregorian date").fill("2026-08-17");
  await page.getByLabel("Tibetan date").fill("10th lunar day");
  await page.getByLabel("English title").fill("Practice");
  await page.getByLabel("Tibetan title").fill("དུས་ཆེན།");

  await expect(page.getByRole("button", { name: "Save draft" })).toBeVisible();
  await expect(
    page.getByRole("button", { name: "Submit for review" }),
  ).toBeVisible();
  await expect(page.getByRole("button", { name: "Publish" })).toHaveCount(0);
  await expect(page.getByText("No action")).toBeVisible();
});

test("reviewer can publish a reviewed bilingual entry in the browser UI", async ({
  page,
}) => {
  await page.setContent(reviewerWorkflowHtml);

  await expect(page.getByRole("cell", { name: "Practice" })).toBeVisible();
  await expect(page.getByRole("cell", { name: "དུས་ཆེན།" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Publish" })).toBeVisible();
});
