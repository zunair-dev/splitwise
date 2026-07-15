# Feature Inventory

This inventory is inspired by Splitwise's public product, help center, and API documentation. It is not a commitment to clone every feature.

## Core Concepts

- Users: account identity, profile, email, avatar.
- Friends: direct relationships outside a group.
- Groups: ongoing shared expense spaces for trips, households, partners, family, and friends.
- Group members: membership, invitation state, role, removed/archived state.
- Expenses: cost, date, description, notes, category, currency, payers, participants.
- Splits: equal, exact amount, percentage, shares.
- Balances: calculated debts between users.
- Settlements: manually recorded repayments.
- Comments: user comments and system comments on expenses.
- Notifications: activity updates for relevant users.
- Categories: expense classification.
- Currencies: supported currency list and per-expense currency code.

## MVP Features

- Sign up and sign in.
- Create a group.
- Add existing users to a group.
- Create pending invitations by email without email delivery.
- Add, edit, delete, and restore an expense.
- Split equally.
- Split by exact amount.
- Split by percentage.
- Split by shares.
- Support multiple payers.
- View group balances.
- View total balances across groups.
- Record manual settlement.
- Add comments to an expense.
- View group activity.
- Categorize expenses.
- Support direct non-group expenses between friends after group expenses are stable.

## Important Financial Rules

- Store money as integer minor units, for example cents.
- Store currency code on every expense and settlement.
- Do not mix currencies in one balance number.
- Validate payer total equals expense total.
- Validate participant share total equals expense total.
- Recalculate balances from ledger records instead of editing balances directly.
- Treat settlement as a financial record, not as deletion of debt history.
- Keep expense edit history once real users exist.

## Later Features

- Debt simplification.
- Email invitation delivery.
- Recurring expenses.
- Offline mode.
- Cloud sync hardening.
- Spending totals and charts.
- Expense search.
- Default splits.
- Currency conversion.
- Receipt scanning/OCR.
- Receipt image upload.
- Itemized receipts.
- Transaction import.
- Payment provider integrations.
- Subscription/pro features.

## Explicit Non-Goals For MVP

- Sending real money.
- Bank integrations.
- Card issuing.
- Public API for third-party developers.
- Full offline merge/conflict resolution.
- Complex multi-currency conversion.
- Microservices.
