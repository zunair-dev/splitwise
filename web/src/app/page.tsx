import Image from "next/image";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { LoginForm } from "./login-form";

function BrandMark() {
  return (
    <Image
      className="brand-mark"
      src="/brand/zplitwise-mark.svg"
      alt=""
      width={40}
      height={40}
      priority
    />
  );
}

export default async function Home() {
  if ((await cookies()).has("zplitwise_session")) redirect("/dashboard");

  return (
    <main className="login-page">
      <div className="ambient-shape ambient-shape-left" />
      <div className="ambient-shape ambient-shape-right" />

      <section className="login-shell" aria-labelledby="login-title">
        <header className="brand-lockup">
          <BrandMark />
          <span>Zplitwise</span>
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
