# Roadmap

## Current Status

Project scaffold is complete.

- Rails API exists in `api`.
- Next.js web app exists in `web`.
- Expo mobile app exists in `mobile`.
- `bin/dev` starts API, web, and mobile through `Procfile.dev`.
- No product models, API endpoints, auth, or UI workflows have been implemented yet.

## Phase 0: Foundation

Goal: make the repo ready for product development.

- Define API versioning under `/api/v1`.
- Add CORS policy for web and mobile development origins.
- Add shared environment examples.
- Add CI commands for API, web, and mobile checks.
- Decide auth strategy and session/token shape.
- Add error response conventions.
- Add request ID propagation and basic structured logging.
- Add automated tests for balance calculation invariants before expense APIs grow.

Exit criteria:

- `bin/dev` runs locally.
- API, web, and mobile checks run from the root.
- API has a versioned health or ping endpoint.

## Phase 1: MVP Expense Tracking

Goal: users can create groups, add expenses, see balances, and record settlements.

- User accounts: sign up, sign in, sign out, profile basics.
- Friends: add friend by email, list friends, remove friendship.
- Groups: create group, update group, archive/delete group, add/remove existing users.
- Invitations: create pending invitations by email without sending email yet.
- Expenses: create, view, edit, delete, restore.
- Splits: equal split, exact amount split, percentage split, share-based split.
- Payments: support one or more payers on an expense.
- Balances: calculate who owes whom per group and overall.
- Settlements: record a cash/manual settlement between two users.
- Activity: group activity feed for expense and settlement events.
- Comments: comments on expenses.
- Categories: initial local category list.
- Currencies: store currency code per expense; do not convert currencies yet.
- Non-group expenses: support direct expenses between friends after group expense flow works.

Exit criteria:

- A user can complete a full trip workflow: create group, invite members, add expenses, view balances, record settlement.
- Money uses integer minor units, never floats.
- Expense payer totals and participant owed totals are validated transactionally.
- Balance tests cover equal, exact, percentage, share-based, multi-payer, and settlement cases.

## Phase 2: Production-Ready Collaboration

Goal: make the app useful for real shared usage.

- Email invitations for non-users.
- Accept/decline group invitation flow.
- Notifications for new expenses, comments, settlements, and group membership changes.
- Push notification registration for mobile.
- Expense attachments with Active Storage.
- Receipt image upload.
- Search and filters for expenses.
- Pagination and cursor-based feeds.
- Soft delete and restore for user-facing financial records.
- Audit trail for expense edits.
- Idempotency keys for create expense and create settlement.

Exit criteria:

- Duplicate mobile submits do not create duplicate expenses.
- Users can understand what changed on an edited expense.
- Group feeds remain fast with realistic data.

## Phase 3: Mobile-First Usability

Goal: make mobile expense entry fast and resilient.

- Mobile auth using short-lived access tokens and rotating refresh tokens.
- Optimistic expense creation with retry.
- Local draft expense storage.
- Contact picker integration.
- Camera upload for receipts.
- Deep links for group invitations.
- Basic offline read cache for groups and recent expenses.

Exit criteria:

- A user can add an expense from mobile in under a few interactions.
- Lost connectivity does not lose an in-progress expense draft.

## Phase 4: Balance Optimization and Reporting

Goal: improve settlement recommendations and give useful financial summaries.

- Debt simplification within a group.
- Group spending totals by member.
- Category spending summaries.
- Monthly personal summary.
- Export CSV for groups.
- Charts for spending by category, group, and time period.

Exit criteria:

- Users can choose simple pairwise balances or simplified group settlement recommendations.
- Reports are derived from immutable financial records, not hand-edited balance rows.

## Phase 5: Advanced Features

Goal: selectively add features that increase retention without making the MVP fragile.

- Recurring expenses.
- Default splits per group.
- Saved payer/split presets.
- Multi-currency conversion using a third-party exchange-rate provider.
- Receipt OCR.
- Itemized receipts.
- Transaction import.
- In-app payment provider integration.
- Pro/subscription packaging if needed.

Exit criteria:

- Advanced features are isolated from core balance correctness.
- Payment integration is not started until compliance, reconciliation, fraud, and support workflows are explicitly planned.

## Deferred Until Later

- Real money movement.
- Bank account linking.
- Card issuing.
- Public third-party API.
- Microservices.
- Full offline conflict resolution.
- Multi-region deployment.
