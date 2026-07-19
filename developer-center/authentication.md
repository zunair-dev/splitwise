# Authentication

The Rails API uses Devise with JWT bearer tokens.

## Endpoints

| Action | Method | Path | Auth |
| --- | --- | --- | --- |
| Sign up | `POST` | `/api/v1/auth/sign_up` | None |
| Sign in | `POST` | `/api/v1/auth/sign_in` | None |
| Sign out | `DELETE` | `/api/v1/auth/sign_out` | Bearer token |
| Current profile | `GET` | `/api/v1/profile` | Bearer token |
| Update profile | `PATCH` | `/api/v1/profile` | Bearer token |

## Sign Up Body

```json
{
  "user": {
    "name": "Example User",
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

## Sign In Body

```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

## Token Handling

Successful sign-up and sign-in responses return `201 Created` and `200 OK` respectively. Both include the JWT in two places:

- `Authorization` response header as `Bearer <token>`.
- `token` field in the JSON response body.

Clients should send authenticated requests with:

```http
Authorization: Bearer <token>
```

Sign out returns `204 No Content` and revokes the current token by rotating the user's `jti`, so the same bearer token cannot be reused afterward.
