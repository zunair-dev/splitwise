import { cookies } from "next/headers";
import { NextResponse } from "next/server";

const API_BASE_URL = process.env.API_BASE_URL ?? "http://127.0.0.1:3000";
const SESSION_COOKIE = "zplitwise_session";
const ALLOWED_PATHS = [
  /^profile$/,
  /^friendships(?:\/\d+\/accept)?$/,
  /^groups(?:\/\d+)?$/,
  /^groups\/\d+\/(?:memberships|invitations)$/,
  /^memberships\/\d+$/,
  /^invitations\/\d+\/revoke$/,
];

type RouteContext = { params: Promise<{ path: string[] }> };

async function proxyRequest(request: Request, context: RouteContext) {
  const path = (await context.params).path.join("/");
  if (!ALLOWED_PATHS.some((pattern) => pattern.test(path))) {
    return NextResponse.json({ error: "Route not available." }, { status: 404 });
  }

  const cookieStore = await cookies();
  const token = cookieStore.get(SESSION_COOKIE)?.value;
  if (!token) {
    return NextResponse.json({ error: "Authentication required." }, { status: 401 });
  }

  const body = request.method === "GET" ? undefined : await request.text();
  let upstream: Response;

  try {
    upstream = await fetch(`${API_BASE_URL}/api/v1/${path}`, {
      method: request.method,
      headers: {
        Authorization: `Bearer ${token}`,
        ...(body ? { "Content-Type": "application/json" } : {}),
      },
      body,
      cache: "no-store",
    });
  } catch {
    return NextResponse.json({ error: "The API is unavailable." }, { status: 503 });
  }

  const responseBody = await upstream.text();
  const response = new NextResponse(responseBody || null, {
    status: upstream.status,
    headers: responseBody ? { "Content-Type": "application/json" } : undefined,
  });

  if (upstream.status === 401) response.cookies.delete(SESSION_COOKIE);
  return response;
}

export const GET = proxyRequest;
export const POST = proxyRequest;
export const PATCH = proxyRequest;
export const DELETE = proxyRequest;
