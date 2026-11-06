---
name: auth-and-access
description: Build and review login, sessions and permissions so every user can only see and change what they're allowed to. Use whenever adding or changing sign-up, login, logout, password reset, sessions, tokens or API keys, roles or admin features, teams or multi-tenant data, Supabase/Postgres row-level security or Firebase rules, or any endpoint, query, page or table that reads or changes user-owned data, including requests like "add an endpoint for X", "let users edit their Y" or "add a profiles table", even when nobody says "auth" or "security".
---

# Auth and access

**Core rule: the server checks, on every request, that this caller may do this action on this
specific record, and refuses by default.**

Most real breaches aren't broken login screens. They're a logged-in user, or anyone, reading or
changing someone else's data: an endpoint that trusts the ID in the URL, a database table with no
row-level security, a service key shipped to the browser. Broken access control is #1 in the OWASP
Top 10 (2025), and object-level authorization is #1 in the OWASP API Security Top 10. AI-generated
apps fail here constantly, because the feature works fine when you test it as yourself.

## When to use

- Adding or changing sign-up, login, logout, password reset, sessions, tokens, API keys or MFA.
- Adding or changing anything that reads or writes data belonging to a user, team or tenant: endpoints,
  queries, pages, server actions, database tables, storage buckets, background jobs, exports.
- Adding roles, admin features or sharing.

Do not use for: endpoints that are public by design and touch no user data (health checks, public
marketing pages), beyond confirming they really expose nothing. General input safety (injection, XSS,
secrets in code) belongs to secure-coding work, not here.

## Step 1: Map who may do what

Before writing code, write a small access table for the resources you're touching. Read the existing
code first: how users are identified, how existing endpoints check access, and whether there's a
central policy function, middleware or row-level security already.

| Who | Resource | List | Read | Create | Update | Delete | Fields they may set |
|---|---|---|---|---|---|---|---|
| Anonymous | Note | no | no | no | no | no | — |
| Owner | Own note | own only | yes | yes | yes | yes | title, body |
| Other user | Someone's note | no | no | — | no | no | — |
| Admin | Any note | yes | yes | no | no | yes | — |

- Include every kind of caller that exists: anonymous, each role, team members, admins, other services.
- Name the **boundary**: is data owned by a user, a team, or a tenant? Every query must stay inside it.
- List **protected fields** that callers must never set themselves: `owner_id`, `user_id`, `tenant_id`,
  `role`, `is_admin`, prices, balances, status fields an admin controls.

Checkpoint: for every action you're adding or changing, the table says who is allowed and everyone
else is a "no". If the brief doesn't say, ask; don't guess permissions.

## Step 2: Authentication: use a proven provider

Don't build login, password storage or session handling from scratch unless you must. Use the
framework's built-in auth or a managed provider (e.g. Supabase Auth, Auth.js, Clerk, Auth0, Firebase
Auth, Cognito, Django/Rails auth). Their defaults have been attacked for years; yours haven't.

If you do touch authentication code, follow
[references/authentication.md](references/authentication.md): password rules (NIST SP 800-63B-4),
hashing (Argon2id or bcrypt), session cookies, token checks, reset flows, rate limits and MFA. The
recurring mistakes to check for:

- **Fail-open defaults:** `SECRET = env.SECRET || 'dev-secret'`, `AUTH_ENABLED=false` fallbacks, debug
  bypasses. A missing secret or setting must stop the app, not quietly weaken it.
- **Tokens trusted without verification:** a JWT decoded instead of verified, `alg: none` accepted,
  expiry or audience not checked.
- **Account enumeration:** login or reset saying "no such email" while revealing that others exist.
- **Sessions that outlive logout or a password change.**

## Step 3: Enforce access on the server

1. **Check on the server, every request.** Hidden buttons, client-side checks and IDs from the client
   prove nothing. Anyone can call the API directly.
2. **Deny by default.** A new route, table or bucket starts with no access, and you add exactly what
   the table in Step 1 allows. Prefer one central place for the rules (a policy function, middleware,
   or row-level security) that every handler uses, so a new endpoint can't forget it silently.
3. **Record level (IDOR / BOLA).** Scope the query to the caller, don't fetch and hope:
   `WHERE id = $1 AND owner_id = $currentUser`. For a record the caller can't access, return the same
   response as for one that doesn't exist (usually 404), so IDs can't be probed.
4. **Action level.** Admin and other privileged actions check the caller's role on the server, in the
   handler or its middleware, not in the UI.
5. **Field level (mass assignment).** Accept only an allowlist of fields from the request. Set
   protected fields on the server (`owner_id = currentUser`). Return only fields the caller may see:
   never password hashes, tokens, or other users' private data.
6. **The places people forget:** list and search endpoints, counts, exports, file downloads and
   signed URLs, WebSocket messages, GraphQL resolvers, webhooks, background jobs and admin tools.
   Each follows the same table.
7. **In the database too, when clients talk to it directly.** With Supabase, Postgres exposed through
   an API, or Firebase, the database rules *are* the access control: enable row-level security on every
   table clients can reach, write a policy per action, and keep service or admin keys on the server
   only. See [references/stacks.md](references/stacks.md).
8. **Look at the neighbors.** When you touch one endpoint or table, check the others for the same
   resource use the same rule. If one doesn't (e.g. a GET that skips the ownership check your new PATCH
   has), report it. Fix it if it's in scope; otherwise flag it clearly as a separate security issue.

## Step 4: Prove it with forbidden-case tests

The happy path works when you test as yourself, which is why these bugs ship. For every action you
added or changed, write tests for who is **refused**, not just who is allowed. See
[references/access-tests.md](references/access-tests.md) for patterns.

- **Anonymous** → 401 (or a redirect to login), and no data in the response.
- **Another user** on the owner's record → 404 (or 403), no data returned, nothing changed.
- **Wrong role** on an admin action → 403, nothing changed.
- **Protected field** in the request (`owner_id`, `role`) → ignored or rejected, and the stored value unchanged.
- **The owner** → allowed (the one test everyone already writes).
- **Row-level security:** query as anonymous and as a second user, and check they get nothing.

A change to access control without a forbidden-case test isn't finished. Finish with
`verify-before-done`.

## Report

In your final message, include:

- The access table for what you built or changed.
- Which test proves each "no" in the table.
- Any existing gaps you found nearby, marked as fixed or as needing a separate fix, with the risk in one line.

## Done when

- [ ] An access table exists for every resource and action touched, with protected fields listed
- [ ] Authentication uses a proven provider or follows references/authentication.md, with no fail-open defaults
- [ ] Every new or changed handler, query or table enforces the table on the server, deny by default
- [ ] Queries are scoped to the caller's user, team or tenant; protected fields are set by the server
- [ ] Row-level security or database rules are enabled and tested where clients reach the database
- [ ] Forbidden-case tests exist and pass for anonymous, other user, wrong role and protected fields
- [ ] Neighboring endpoints were checked, and gaps were fixed or reported
- [ ] The report includes the access table and the tests that prove it

## Common excuses

| Excuse | Reality |
|---|---|
| "The UI only shows users their own items." | The API answers anyone who asks. Check on the server. |
| "IDs are random UUIDs, nobody can guess them." | IDs leak through URLs, logs, shares and lists. Unguessable isn't authorized. |
| "It works when I test it." | You tested as the owner. Test as someone else. |
| "We'll add permissions before launch." | Retrofitting access rules means auditing every endpoint again. Deny by default now. |
| "RLS slows us down; the service key is easier." | The service key bypasses every rule. In a browser, it hands your whole database to anyone. |
| "It's an internal/admin tool." | Internal tools get exposed, and admin endpoints are the most valuable to attack. Same rules. |
| "Writing our own login is simple." | Hashing, sessions, resets, rate limits and MFA each have known traps. Use a provider. |
