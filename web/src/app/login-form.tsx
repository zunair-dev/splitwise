"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";

type SignInResponse = {
  user?: {
    name: string;
    email: string;
  };
  error?: string;
};

export function LoginForm() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setIsSubmitting(true);

    const formData = new FormData(event.currentTarget);

    try {
      const response = await fetch("/api/auth/sign-in", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: formData.get("email"),
          password: formData.get("password"),
        }),
      });
      const result = (await response.json()) as SignInResponse;

      if (!response.ok || !result.user) {
        setError(result.error ?? "We couldn't log you in. Please try again.");
        return;
      }

      router.push("/dashboard");
      router.refresh();
    } catch {
      setError("The server is unavailable right now. Please try again shortly.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="login-form" onSubmit={handleSubmit}>
      <div className="field-group">
        <label htmlFor="email">Email address</label>
        <div className="input-wrap">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M3.75 5.75h16.5v12.5H3.75z" />
            <path d="m4.5 7 7.5 5.25L19.5 7" />
          </svg>
          <input
            id="email"
            name="email"
            type="email"
            autoComplete="email"
            placeholder="you@example.com"
            required
            autoFocus
          />
        </div>
      </div>

      <div className="field-group">
        <label htmlFor="password">Password</label>
        <div className="input-wrap">
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <rect x="5" y="10" width="14" height="10" rx="2" />
            <path d="M8 10V7a4 4 0 0 1 8 0v3" />
          </svg>
          <input
            id="password"
            name="password"
            type={showPassword ? "text" : "password"}
            autoComplete="current-password"
            placeholder="Enter your password"
            minLength={6}
            required
          />
          <button
            className="password-toggle"
            type="button"
            onClick={() => setShowPassword((current) => !current)}
            aria-label={showPassword ? "Hide password" : "Show password"}
            aria-pressed={showPassword}
          >
            {showPassword ? "Hide" : "Show"}
          </button>
        </div>
      </div>

      {error ? <p className="form-error" role="alert">{error}</p> : null}

      <button className="submit-button" type="submit" disabled={isSubmitting}>
        {isSubmitting ? <span className="spinner" aria-hidden="true" /> : null}
        {isSubmitting ? "Logging in…" : "Log in"}
      </button>

      <p className="signup-copy">
        New to Zplitwise? <span>Account creation is coming next.</span>
      </p>
    </form>
  );
}
