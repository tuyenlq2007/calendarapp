import styles from "./page.module.css";

export default function Home() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <p className={styles.kicker}>Staff dashboard</p>
          <h1>Barom Kagyu Calendar Admin</h1>
          <p>
            Phase one prepares the staff-authored calendar content workflow for
            dates, lunar days, practices, anniversaries, and translations.
          </p>
        </div>
      </main>
    </div>
  );
}
