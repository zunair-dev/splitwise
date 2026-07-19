# Splitwise

Initial monorepo scaffold for a Splitwise-style expense sharing product.

## Apps

- `api`: Rails API with PostgreSQL.
- `web`: Next.js App Router web portal.
- `mobile`: Expo React Native mobile app.
- `developer-center`: roadmap, task status, and product planning docs.

## Local Commands

```sh
bin/dev
```

Or run individual processes:

```sh
pnpm api
pnpm web
pnpm mobile
pnpm mobile:web
```

Run commands from the repository root.

Default local ports:

- Rails API: `http://127.0.0.1:3101`
- Next web: `http://localhost:3100`
- Expo Metro: `http://localhost:8082`
