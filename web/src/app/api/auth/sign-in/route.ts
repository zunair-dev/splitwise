import { NextResponse } from "next/server";

const API_BASE_URL = process.env.API_BASE_URL ?? "http://127.0.0.1:3000";
const SESSION_COOKIE = "zplitwise_session";
const SESSION_MAX_AGE_SECONDS = 60 * 60 * 24 * 14;

type RailsSignInResponse = {
  user?: {
    name: string;
    email: string;
  };
  token?: string;
};

export async function POST(request: Request) {
  let credentials: { email?: unknown; password?: unknown };

  try {
    credentials = (await request.json()) as typeof credentials;
  } catch {
    return NextResponse.json({ error: "Invalid request." }, { status: 400 });
  }

  if (
    typeof credentials.email !== "string" ||
    typeof credentials.password !== "string" ||
    !credentials.email.trim() ||
    !credentials.password
  ) {
    return NextResponse.json(
      { error: "Email and password are required." },
      { status: 422 },
    );
  }

  let railsResponse: Response;

  try {
    railsResponse = await fetch(`${API_BASE_URL}/api/v1/auth/sign_in`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        user: {
          email: credentials.email.trim().toLowerCase(),
          password: credentials.password,
        },
      }),
      cache: "no-store",
    });
  } catch {
    return NextResponse.json(
      { error: "The authentication service is unavailable." },
      { status: 503 },
    );
  }

  if (!railsResponse.ok) {
    const message =
      railsResponse.status === 401
        ? "Incorrect email or password."
        : "We couldn't log you in. Please try again.";

    return NextResponse.json({ error: message }, { status: railsResponse.status });
  }

  const result = (await railsResponse.json()) as RailsSignInResponse;

  if (!result.token || !result.user) {
    return NextResponse.json(
      { error: "The authentication service returned an invalid response." },
      { status: 502 },
    );
  }

  const response = NextResponse.json({ user: result.user });
  response.cookies.set(SESSION_COOKIE, result.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: SESSION_MAX_AGE_SECONDS,
    priority: "high",
  });

  return response;
}
