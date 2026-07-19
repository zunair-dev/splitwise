import { LoginForm } from "./login-form";

function BrandMark() {
  return (
    <div className="brand-mark" aria-hidden="true">
      <svg viewBox="0 0 48 48" role="img">
        <path d="M9 11.5 24 4l15 7.5v25L24 44 9 36.5v-25Z" fill="currentColor" />
        <path
          d="M17 27.8c2.3 2 4.8 3 7.4 3 2.8 0 4.5-1.1 4.5-2.8 0-1.5-1.2-2.2-5.2-3.1-5.2-1.2-7.5-3.3-7.5-6.7 0-3.8 3.2-6.5 7.8-6.5 3.2 0 6.2 1 8.7 2.9l-3 4.1a9.6 9.6 0 0 0-5.8-2.1c-2.2 0-3.5.8-3.5 2.2 0 1.3 1.2 2 5.2 2.9 5.3 1.2 7.5 3.4 7.5 6.9 0 4.2-3.4 7.1-8.3 7.1-4 0-7.6-1.3-10.6-3.8l3.8-4.1Z"
          fill="white"
        />
      </svg>
    </div>
  );
}

export default function Home() {
  return (
    <main className="login-page">
      <div className="ambient-shape ambient-shape-left" />
      <div className="ambient-shape ambient-shape-right" />

      <section className="login-shell" aria-labelledby="login-title">
        <header className="brand-lockup">
          <BrandMark />
          <span>Splitwise</span>
        </header>

        <div className="login-card">
          <div className="login-heading">
            <p className="eyebrow">Welcome back</p>
            <h1 id="login-title">Log in to your account</h1>
            <p>Keep track of shared expenses and settle up with ease.</p>
          </div>

          <LoginForm />
        </div>

        <p className="login-footer">Shared expenses, simplified.</p>
      </section>
    </main>
  );
}
