"use client";

import Image from "next/image";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { ExpenseForm, type ExpenseInput } from "./expense-form";

export type User = { id: number; name: string; email: string; profile_status: string };
export type Friendship = { id: number; status: string; requester_id: number; friend: User };
export type Member = { id: number; user_id: number; name: string; email: string; role: string; removed_at: string | null };
type Invitation = { id: number; email: string; role: string; status: string };
export type Group = { id: number; name: string; description: string | null; group_type: string; members?: Member[]; invitations?: Invitation[] };
type Expense = { id: number; description: string; amount_minor: number; currency_code: string; expense_date: string; split_method: string; category: string; payers: { user_id: number; name: string; amount_minor: number }[] };
type Tab = "overview" | "friends" | "groups" | "profile";

async function api<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`/api/backend/${path}`, { ...options, headers: { "Content-Type": "application/json", ...options?.headers } });
  const payload = response.status === 204 ? {} : await response.json();
  if (response.status === 401) window.location.href = "/";
  if (!response.ok) throw new Error(payload?.error?.message ?? payload?.error ?? "Request failed.");
  return payload as T;
}

export function Dashboard({ initialUser, initialFriends, initialGroups }: { initialUser: User; initialFriends: Friendship[]; initialGroups: Group[] }) {
  const router = useRouter();
  const [tab, setTab] = useState<Tab>("overview");
  const [user, setUser] = useState(initialUser);
  const [friends, setFriends] = useState(initialFriends);
  const [groups, setGroups] = useState(initialGroups);
  const [selectedGroup, setSelectedGroup] = useState<Group | null>(null);
  const [selectedExpenses, setSelectedExpenses] = useState<Expense[]>([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      const [profileData, friendshipData, groupData] = await Promise.all([api<{ user: User }>("profile"), api<{ friendships: Friendship[] }>("friendships"), api<{ groups: Group[] }>("groups")]);
      setUser(profileData.user); setFriends(friendshipData.friendships); setGroups(groupData.groups);
    } catch (requestError) { setError(requestError instanceof Error ? requestError.message : "Unable to load your account."); }
  }

  async function mutate(action: () => Promise<unknown>) {
    setError("");
    try { await action(); await load(); return true; }
    catch (requestError) { setError(requestError instanceof Error ? requestError.message : "Request failed."); return false; }
  }

  async function openGroup(groupId: number) {
    try {
      const [groupData, expenseData] = await Promise.all([api<{ group: Group }>(`groups/${groupId}`), api<{ expenses: Expense[] }>(`groups/${groupId}/expenses`)]);
      setSelectedGroup(groupData.group); setSelectedExpenses(expenseData.expenses);
    } catch (requestError) { setError(requestError instanceof Error ? requestError.message : "Unable to load group."); }
  }

  async function submitFriend(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = event.currentTarget; const email = String(new FormData(form).get("email") ?? "");
    if (await mutate(() => api("friendships", { method: "POST", body: JSON.stringify({ friendship: { email } }) }))) form.reset();
  }

  async function submitGroup(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const form = event.currentTarget; const values = new FormData(form);
    if (await mutate(() => api("groups", { method: "POST", body: JSON.stringify({ group: { name: values.get("name"), group_type: values.get("group_type"), description: values.get("description") } }) }))) form.reset();
  }

  async function updateGroup(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); if (!selectedGroup) return; const values = new FormData(event.currentTarget);
    await mutate(() => api(`groups/${selectedGroup.id}`, { method: "PATCH", body: JSON.stringify({ group: { name: values.get("name"), description: values.get("description") } }) })); await openGroup(selectedGroup.id);
  }

  async function submitMember(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); if (!selectedGroup) return; const userId = Number(new FormData(event.currentTarget).get("user_id"));
    await mutate(() => api(`groups/${selectedGroup.id}/memberships`, { method: "POST", body: JSON.stringify({ membership: { user_id: userId, role: "member" } }) })); await openGroup(selectedGroup.id);
  }

  async function submitInvitation(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); if (!selectedGroup) return; const form = event.currentTarget; const email = String(new FormData(form).get("email") ?? "");
    if (await mutate(() => api(`groups/${selectedGroup.id}/invitations`, { method: "POST", body: JSON.stringify({ invitation: { email, role: "member" } }) }))) form.reset(); await openGroup(selectedGroup.id);
  }

  async function submitExpense(expense: ExpenseInput) {
    if (!selectedGroup) return false;
    const saved = await mutate(() => api(`groups/${selectedGroup.id}/expenses`, { method: "POST", body: JSON.stringify({ expense }) }));
    if (saved) await openGroup(selectedGroup.id); return saved;
  }

  async function updateProfile(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const name = String(new FormData(event.currentTarget).get("name") ?? "");
    await mutate(() => api("profile", { method: "PATCH", body: JSON.stringify({ user: { name } }) }));
  }

  async function signOut() { await fetch("/api/auth/sign-out", { method: "DELETE" }); router.push("/"); router.refresh(); }
  const activeMembers = selectedGroup?.members?.filter((member) => !member.removed_at) ?? [];
  const availableFriends = friends.filter((friend) => friend.status === "accepted" && !activeMembers.some((member) => member.user_id === friend.friend.id));

  return <main className="app-shell">
    <aside className="app-sidebar">
      <div className="app-brand"><Image src="/brand/zplitwise-mark.svg" alt="" width={34} height={34} /><strong>Zplitwise</strong></div>
      <nav aria-label="Primary navigation">{(["overview", "friends", "groups", "profile"] as Tab[]).map((item) => <button key={item} className={tab === item ? "active" : ""} onClick={() => setTab(item)}>{item}</button>)}</nav>
      <button className="signout-button" onClick={signOut}>Sign out</button>
    </aside>

    <section className="app-content">
      <header className="content-header"><div><p>Welcome back</p><h1>{user.name}</h1></div><span className="avatar">{user.name.charAt(0).toUpperCase()}</span></header>
      {error ? <p className="app-error" role="alert">{error}</p> : null}
      {tab === "overview" ? <div className="dashboard-grid"><article className="stat-card"><span>Groups</span><strong>{groups.length}</strong></article><article className="stat-card"><span>Friends</span><strong>{friends.filter((friend) => friend.status === "accepted").length}</strong></article><article className="empty-card"><h2>Your expense dashboard is ready</h2><p>Create a group, add members, and record shared expenses.</p><button onClick={() => setTab("groups")}>Open groups</button></article></div> : null}
      {tab === "friends" ? <section className="workspace"><div className="section-title"><div><h2>Friends</h2><p>Manage direct relationships and requests.</p></div><form className="inline-form" onSubmit={submitFriend}><input name="email" type="email" placeholder="friend@example.com" required /><button>Add friend</button></form></div><div className="list-grid">{friends.map((friend) => <article className="list-card" key={friend.id}><span className="avatar small">{friend.friend.name.charAt(0)}</span><div><strong>{friend.friend.name}</strong><p>{friend.friend.email}</p></div><span className={`status ${friend.status}`}>{friend.status}</span>{friend.status === "pending" && friend.requester_id !== user.id ? <button onClick={() => mutate(() => api(`friendships/${friend.id}/accept`, { method: "PATCH" }))}>Accept</button> : null}</article>)}</div></section> : null}
      {tab === "groups" ? <section className="workspace"><div className="section-title"><div><h2>Groups</h2><p>Trips, homes, partners, family, and friends.</p></div></div><form className="create-card" onSubmit={submitGroup}><input name="name" placeholder="Group name" required /><select name="group_type" defaultValue="trip"><option value="trip">Trip</option><option value="household">Household</option><option value="partner">Partner</option><option value="family">Family</option><option value="friends">Friends</option><option value="other">Other</option></select><input name="description" placeholder="Description (optional)" /><button>Create group</button></form><div className="group-grid">{groups.map((group) => <button className="group-card" key={group.id} onClick={() => openGroup(group.id)}><span>{group.group_type}</span><h3>{group.name}</h3><p>{group.description || "No description yet"}</p></button>)}</div></section> : null}
      {tab === "profile" ? <section className="workspace narrow"><div className="section-title"><div><h2>Profile</h2><p>Update your account identity.</p></div></div><form className="profile-form" onSubmit={updateProfile}><label>Name<input name="name" defaultValue={user.name} required /></label><label>Email<input value={user.email} disabled /></label><label>Status<input value={user.profile_status} disabled /></label><button>Save profile</button></form></section> : null}
    </section>

    {selectedGroup ? <div className="modal-backdrop" role="presentation" onMouseDown={() => setSelectedGroup(null)}><section className="group-modal" role="dialog" aria-modal="true" aria-labelledby="group-title" onMouseDown={(event) => event.stopPropagation()}>
      <button className="modal-close" onClick={() => setSelectedGroup(null)} aria-label="Close">×</button><p className="eyebrow">{selectedGroup.group_type}</p><h2 id="group-title">{selectedGroup.name}</h2>
      <form className="modal-edit-form" onSubmit={updateGroup}><input name="name" defaultValue={selectedGroup.name} required /><input name="description" defaultValue={selectedGroup.description ?? ""} placeholder="Description" /><button>Save group</button></form>
      <h3>Expenses</h3><ExpenseForm key={selectedGroup.id} members={activeMembers} currentUserId={user.id} onSubmit={submitExpense} />
      {selectedExpenses.map((expense) => <div className="modal-row expense-row" key={expense.id}><span><strong>{expense.description}</strong><small>{expense.category.replaceAll("_", " ")} · {expense.expense_date} · {expense.split_method} · paid by {expense.payers.map((payer) => payer.name).join(", ")}</small></span><b>{expense.currency_code} {(expense.amount_minor / 100).toFixed(2)}</b><button onClick={async () => { await mutate(() => api(`expenses/${expense.id}`, { method: "DELETE" })); await openGroup(selectedGroup.id); }}>Delete</button></div>)}
      <h3>Members</h3>{activeMembers.map((member) => <div className="modal-row" key={member.id}><span>{member.name}<small>{member.email}</small></span><b>{member.role}</b>{member.role !== "owner" ? <button onClick={async () => { await mutate(() => api(`memberships/${member.id}`, { method: "DELETE" })); await openGroup(selectedGroup.id); }}>Remove</button> : null}</div>)}
      {availableFriends.length ? <form className="inline-form" onSubmit={submitMember}><select name="user_id" required>{availableFriends.map((friend) => <option key={friend.friend.id} value={friend.friend.id}>{friend.friend.name}</option>)}</select><button>Add member</button></form> : null}
      <h3>Invite by email</h3><form className="inline-form" onSubmit={submitInvitation}><input name="email" type="email" placeholder="person@example.com" required /><button>Invite</button></form>
      {selectedGroup.invitations?.map((invite) => <div className="modal-row" key={invite.id}><span>{invite.email}<small>{invite.status}</small></span>{invite.status === "pending" ? <button onClick={async () => { await mutate(() => api(`invitations/${invite.id}/revoke`, { method: "PATCH" })); await openGroup(selectedGroup.id); }}>Revoke</button> : null}</div>)}
    </section></div> : null}
  </main>;
}
