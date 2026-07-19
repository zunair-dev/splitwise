"use client";

import { FormEvent, useState } from "react";
import type { Member } from "./dashboard";

type SplitMethod = "equal" | "exact" | "percentage" | "shares";
type Amounts = Record<number, string>;

export type ExpenseInput = {
  description: string; notes: string; amount_minor: number; currency_code: string;
  expense_date: string; category: string; split_method: SplitMethod;
  payers: { user_id: number; amount_minor: number }[];
  participant_user_ids?: number[];
  shares?: { user_id: number; amount_minor?: number; percentage_basis_points?: number; share_units?: number }[];
};

const CATEGORIES = [["general", "General"], ["food_drink", "Food & drink"], ["groceries", "Groceries"], ["transportation", "Transportation"], ["accommodation", "Accommodation"], ["utilities", "Utilities"], ["entertainment", "Entertainment"], ["shopping", "Shopping"]];

function parseHundredths(value: string) {
  const match = value.trim().match(/^(\d+)(?:\.(\d{1,2}))?$/);
  return match ? Number(match[1]) * 100 + Number((match[2] ?? "").padEnd(2, "0")) : null;
}

export function ExpenseForm({ members, currentUserId, onSubmit }: { members: Member[]; currentUserId: number; onSubmit: (expense: ExpenseInput) => Promise<boolean> }) {
  const [splitMethod, setSplitMethod] = useState<SplitMethod>("equal");
  const [amount, setAmount] = useState("");
  const [payerAmounts, setPayerAmounts] = useState<Amounts>({});
  const [splitValues, setSplitValues] = useState<Amounts>({});
  const [participantIds, setParticipantIds] = useState(() => new Set(members.map((member) => member.user_id)));
  const [formError, setFormError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setFormError("");
    const form = event.currentTarget;
    const values = new FormData(form);
    const amountMinor = parseHundredths(amount);
    if (!amountMinor || amountMinor <= 0) { setFormError("Enter a valid positive expense amount."); return; }
    const payers = members.flatMap((member) => { const value = payerAmounts[member.user_id]?.trim(); if (!value) return []; const minor = parseHundredths(value); return minor && minor > 0 ? [{ user_id: member.user_id, amount_minor: minor }] : []; });
    if (!payers.length || payers.reduce((sum, payer) => sum + payer.amount_minor, 0) !== amountMinor) { setFormError("Payer amounts must add up exactly to the total."); return; }
    const selectedIds = members.map((member) => member.user_id).filter((id) => participantIds.has(id));
    if (!selectedIds.length) { setFormError("Select at least one participant."); return; }

    const expense: ExpenseInput = { description: String(values.get("description")), notes: String(values.get("notes") ?? ""), amount_minor: amountMinor, currency_code: String(values.get("currency_code")).toUpperCase(), expense_date: String(values.get("expense_date")), category: String(values.get("category")), split_method: splitMethod, payers };
    if (splitMethod === "equal") expense.participant_user_ids = selectedIds;
    if (splitMethod === "exact") { const shares = selectedIds.map((userId) => ({ user_id: userId, amount_minor: parseHundredths(splitValues[userId] ?? "") ?? -1 })); if (shares.some((share) => share.amount_minor <= 0) || shares.reduce((sum, share) => sum + share.amount_minor, 0) !== amountMinor) { setFormError("Exact shares must be positive and add up to the total."); return; } expense.shares = shares; }
    if (splitMethod === "percentage") { const shares = selectedIds.map((userId) => ({ user_id: userId, percentage_basis_points: parseHundredths(splitValues[userId] ?? "") ?? -1 })); if (shares.some((share) => share.percentage_basis_points <= 0) || shares.reduce((sum, share) => sum + share.percentage_basis_points, 0) !== 10_000) { setFormError("Percentages must be positive and total exactly 100%."); return; } expense.shares = shares; }
    if (splitMethod === "shares") { const shares = selectedIds.map((userId) => ({ user_id: userId, share_units: Number(splitValues[userId]) })); if (shares.some((share) => !Number.isInteger(share.share_units) || share.share_units <= 0)) { setFormError("Share weights must be positive whole numbers."); return; } expense.shares = shares; }

    setSubmitting(true); const saved = await onSubmit(expense); setSubmitting(false);
    if (saved) { form.reset(); setAmount(""); setPayerAmounts({}); setSplitValues({}); setSplitMethod("equal"); setParticipantIds(new Set(members.map((member) => member.user_id))); }
  }

  return <form className="advanced-expense-form" onSubmit={submit}>
    <div className="expense-basics"><input name="description" placeholder="What was this for?" required /><input value={amount} onChange={(event) => setAmount(event.target.value)} inputMode="decimal" placeholder="Total 0.00" required /><input name="currency_code" defaultValue="USD" maxLength={3} aria-label="Currency" required /><input name="expense_date" type="date" defaultValue={new Date().toISOString().slice(0, 10)} required /><select name="category" defaultValue="general" aria-label="Category">{CATEGORIES.map(([value, label]) => <option key={value} value={value}>{label}</option>)}</select><select value={splitMethod} onChange={(event) => setSplitMethod(event.target.value as SplitMethod)} aria-label="Split method"><option value="equal">Split equally</option><option value="exact">Exact amounts</option><option value="percentage">Percentages</option><option value="shares">Weighted shares</option></select></div>
    <fieldset><legend>Who paid?</legend><button type="button" className="text-button" onClick={() => setPayerAmounts({ [currentUserId]: amount })}>I paid the full amount</button><div className="allocation-grid">{members.map((member) => <label key={member.user_id}><span>{member.name}</span><input value={payerAmounts[member.user_id] ?? ""} onChange={(event) => setPayerAmounts((current) => ({ ...current, [member.user_id]: event.target.value }))} inputMode="decimal" placeholder="0.00" /></label>)}</div></fieldset>
    <fieldset><legend>Who shares it?</legend><div className="allocation-grid">{members.map((member) => <label key={member.user_id} className={!participantIds.has(member.user_id) ? "disabled-allocation" : ""}><span><input type="checkbox" checked={participantIds.has(member.user_id)} onChange={() => setParticipantIds((current) => { const next = new Set(current); if (next.has(member.user_id)) next.delete(member.user_id); else next.add(member.user_id); return next; })} />{member.name}</span>{splitMethod === "equal" ? <small>Equal share</small> : <input value={splitValues[member.user_id] ?? ""} disabled={!participantIds.has(member.user_id)} onChange={(event) => setSplitValues((current) => ({ ...current, [member.user_id]: event.target.value }))} inputMode="decimal" placeholder={splitMethod === "exact" ? "0.00" : splitMethod === "percentage" ? "0.00%" : "1"} />}</label>)}</div></fieldset>
    <input name="notes" placeholder="Notes (optional)" />{formError ? <p className="form-error" role="alert">{formError}</p> : null}<button className="primary-action" disabled={submitting}>{submitting ? "Adding expense…" : "Add expense"}</button>
  </form>;
}
