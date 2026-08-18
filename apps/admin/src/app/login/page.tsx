import { signInStaff } from "./actions";
import styles from "../page.module.css";

type LoginPageProps = {
  searchParams?: Promise<{
    error?: string;
    next?: string;
  }>;
};

function safeNextParam(value: string | undefined) {
  if (!value) return "/calendar";
  if (!value.startsWith("/") || value.startsWith("//")) return "/calendar";

  return value;
}

function errorMessage(error: string | undefined) {
  if (error === "staff") {
    return "Your account is not assigned to the calendar staff dashboard.";
  }

  if (error === "credentials") {
    return "Check your email and password, then try again.";
  }

  return null;
}

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const nextPath = safeNextParam(params?.next);
  const message = errorMessage(params?.error);

  return (
    <main className={styles.main}>
      <div className={styles.intro}>
        <p className={styles.kicker}>Staff dashboard</p>
        <h1>Staff sign in</h1>
        <p>Use your Barom Kagyu Calendar staff account to continue.</p>
        {message ? <p role="alert">{message}</p> : null}
        <form action={signInStaff}>
          <input type="hidden" name="next" value={nextPath} />
          <label>
            Email
            <input name="email" type="email" autoComplete="email" required />
          </label>
          <label>
            Password
            <input
              name="password"
              type="password"
              autoComplete="current-password"
              required
            />
          </label>
          <button type="submit">Sign in</button>
        </form>
      </div>
    </main>
  );
}
