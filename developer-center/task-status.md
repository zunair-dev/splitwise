# Task Status

Status values:

- `todo`: not started.
- `in_progress`: actively being worked.
- `blocked`: waiting on a decision or dependency.
- `done`: completed and verified.

## Foundation

| Task | Status | Notes |
| --- | --- | --- |
| Monorepo scaffold | done | Rails API, Next web, Expo mobile. |
| Root dev runner | done | `bin/dev` uses Foreman and `Procfile.dev`. |
| Local API boot | done | Rails health check verified on `3101`. |
| Local web boot | done | Next verified on `3100`. |
| Local mobile boot | done | Expo Metro verified on `8082`. |
| Developer center | done | Roadmap and status docs added. |
| API versioning | done | Added `/api/v1` namespace for the first domain endpoints. |
| CORS setup | todo | Permit local web/mobile origins. |
| Root CI scripts | todo | Add root commands for API, web, mobile checks. |
| Environment examples | todo | Add `.env.example` files. |
| Balance invariant test plan | todo | Cover split math before exposing expense APIs broadly. |

## Product Core

| Task | Status | Notes |
| --- | --- | --- |
| Authentication design | todo | Decide cookie/session for web and token flow for mobile. |
| User model | done | Name, normalized email, password digest, profile status, avatar attachment. |
| Friend model | done | Pair-unique direct friendships with pending/accepted/blocked states. |
| Group model | done | Name, description, type, creator, archived/deleted state. |
| Membership model | done | Role, invitation state, joined timestamp, removed state. |
| Invitation model | done | Pending normalized email invitations before email delivery is added. |
| Expense model | todo | Minor units, currency, date, notes, category. |
| Expense payer model | todo | Supports multiple payers. |
| Expense share model | todo | Supports equal, exact, percentage, and shares. |
| Balance calculation service | todo | Derived from expenses and settlements. |
| Settlement model | todo | Manual settlement first, no payment provider. |
| Activity feed | todo | Persist user-visible group events. |
| Comments | todo | Expense comments and system comments. |
| Attachments | todo | Active Storage receipt images. |
| Non-group expenses | todo | Add after group expense flow is stable. |

## Web App

| Task | Status | Notes |
| --- | --- | --- |
| App shell | todo | Authenticated layout, navigation, responsive basics. |
| Auth screens | todo | Sign in, sign up, sign out. |
| Dashboard | todo | Overall balances and recent activity. |
| Groups list | todo | Groups and balances summary. |
| Group detail | todo | Members, expenses, balances, activity. |
| Add/edit expense | todo | Core split editor. |
| Settle up flow | todo | Record manual settlement. |

## Mobile App

| Task | Status | Notes |
| --- | --- | --- |
| Navigation structure | todo | Expo Router can be introduced when screens begin. |
| Auth screens | todo | Token storage required. |
| Groups list | todo | Mobile-first balances overview. |
| Add expense flow | todo | Fast entry is the key workflow. |
| Push token registration | todo | After auth exists. |
| Local draft storage | todo | Add before receipt uploads/OCR. |

## Decisions Needed

| Decision | Status | Recommendation |
| --- | --- | --- |
| Auth library | todo | Rails-native auth or Devise, with mobile token support. |
| API response format | todo | Plain REST JSON with OpenAPI docs. |
| Frontend data fetching | todo | TanStack Query for web and mobile server state. |
| Component system | todo | Tailwind plus shadcn/ui on web. |
| Mobile UI style | todo | React Native components first; add NativeWind only if useful. |
