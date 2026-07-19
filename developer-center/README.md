# Developer Center

This folder is the planning and delivery hub for Zplitwise.

## Documents

- [Roadmap](./roadmap.md): phased product roadmap from MVP through advanced features.
- [Task Status](./task-status.md): current implementation status and next tasks.
- [Feature Inventory](./feature-inventory.md): feature list inspired by Splitwise's public product, help, and API documentation.
- [Authentication](./authentication.md): Devise/JWT API auth contract.
- [Sources](./sources.md): public references used to shape the roadmap.

## Product Direction

Build a practical expense sharing app for web and mobile:

- Rails API owns authentication, financial records, balance calculation, and auditability.
- Next.js web portal supports full account, group, expense, and settlement workflows.
- Expo mobile app supports the same core workflows with mobile-first entry and notifications.
- PostgreSQL remains the source of truth for money, balances, memberships, and activity.

The first milestone is not payment processing. The first milestone is reliable expense tracking, balance calculation, and recorded settlements.
