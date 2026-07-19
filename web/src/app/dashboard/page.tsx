import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { Dashboard, type Friendship, type Group, type User } from "./dashboard";

const API_BASE_URL = process.env.API_BASE_URL ?? "http://127.0.0.1:3000";

async function loadResource<T>(path: string, token: string): Promise<T> {
  const response = await fetch(`${API_BASE_URL}/api/v1/${path}`, {
    headers: { Authorization: `Bearer ${token}` },
    cache: "no-store",
  });
  if (response.status === 401) redirect("/");
  if (!response.ok) throw new Error(`Unable to load ${path}.`);
  return response.json() as Promise<T>;
}

export default async function DashboardPage() {
  const token = (await cookies()).get("zplitwise_session")?.value;
  if (!token) redirect("/");

  const [profileData, friendshipData, groupData] = await Promise.all([
    loadResource<{ user: User }>("profile", token),
    loadResource<{ friendships: Friendship[] }>("friendships", token),
    loadResource<{ groups: Group[] }>("groups", token),
  ]);

  return <Dashboard initialUser={profileData.user} initialFriends={friendshipData.friendships} initialGroups={groupData.groups} />;
}
