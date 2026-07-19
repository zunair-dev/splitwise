# Zplitwise Development TDL

This is the execution checklist for the basic, locally runnable product. Work is ordered by dependency; a task is only `done` after its acceptance checks pass.

Status: `todo` · `in_progress` · `done` · `blocked`

## Milestone 1 — Account and Collaboration Foundation

| ID | Task | Status | Acceptance |
| --- | --- | --- | --- |
| M1-01 | Devise JWT API authentication | done | Sign up, sign in, authenticated profile, sign out, and token revocation are tested. |
| M1-02 | Development user seed | done | `bin/rails db:seed` creates one repeatable local user. |
| M1-03 | Web sign-in and secure session cookie | done | Login uses a server-only HTTP-only cookie and shows API failures. |
| M1-04 | Authenticated web shell and sign-out | done | Signed-in users reach the app; anonymous users return to login. |
| M1-05 | Profile view and edit | done | User can view and update name and profile status. |
| M1-06 | Friends workflow | done | User can list friends, send requests, and accept incoming requests. |
| M1-07 | Groups workflow | done | User can list, create, view, and edit groups. |
| M1-08 | Group membership workflow | done | Owner/admin can add and remove existing users. |
| M1-09 | Pending group invitations | done | Owner/admin can invite by email and revoke pending invitations. |

## Milestone 2 — Expense Ledger

| ID | Task | Status | Acceptance |
| --- | --- | --- | --- |
| M2-01 | Expense, payer, and share schema | todo | Money uses integer minor units; database constraints protect ledger totals. |
| M2-02 | Equal split service | todo | Remainders are deterministic and totals always match. |
| M2-03 | Exact, percentage, and share splits | todo | Every supported split mode validates to the expense total. |
| M2-04 | Expense CRUD API | todo | Authorized members can create, view, edit, soft-delete, and restore expenses. |
| M2-05 | Multi-payer support | todo | One expense can have multiple payers whose payments equal its total. |
| M2-06 | Expense web form | todo | User can select group, payers, participants, split method, date, category, and notes. |

## Milestone 3 — Balances and Settlements

| ID | Task | Status | Acceptance |
| --- | --- | --- | --- |
| M3-01 | Balance calculation service | todo | Balances derive from ledger records and remain zero-sum per currency. |
| M3-02 | Group and overall balance APIs | todo | Responses never combine different currencies into one number. |
| M3-03 | Manual settlement model and API | todo | Repayments are immutable financial records and affect derived balances. |
| M3-04 | Dashboard balances | todo | User sees what they owe and are owed by currency. |
| M3-05 | Settle-up web flow | todo | User can record a repayment and immediately see updated balances. |

## Milestone 4 — Collaboration History

| ID | Task | Status | Acceptance |
| --- | --- | --- | --- |
| M4-01 | Activity events | todo | Expense, settlement, and membership changes appear chronologically. |
| M4-02 | Expense comments | todo | Group members can add and read comments. |
| M4-03 | Categories | todo | Seeded category list is selectable and stable. |
| M4-04 | Receipt attachments | todo | Authorized users can upload and view receipt images. |

## Milestone 5 — Mobile Basic Product

| ID | Task | Status | Acceptance |
| --- | --- | --- | --- |
| M5-01 | Mobile navigation and secure auth storage | todo | Session survives restart and sign-out removes credentials. |
| M5-02 | Mobile group and balance screens | todo | Core group information matches the web/API. |
| M5-03 | Mobile add-expense flow | todo | User can create an equal-split expense from a phone. |
| M5-04 | Local expense drafts | todo | Interrupted entry can be resumed without data loss. |

## Release Gate

- API tests cover authorization and financial invariants.
- Web lint and production build pass.
- Mobile TypeScript and Expo configuration checks pass.
- A seeded user can complete: login → create group → add/invite member → add expense → view balance → record settlement → sign out.
- `bin/dev` starts the complete local stack from the repository root.
