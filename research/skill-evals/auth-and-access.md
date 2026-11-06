# auth-and-access: evaluation log

Each round runs the skill's test cases (`skills/engineering/auth-and-access/evals/`) once with the skill and once without it, using the `skill-creator` loop. Run outputs live in `.workspace/` (not committed).

| Round | Date | Cases | With skill | Without | Time (with / without) | Tokens (with / without) |
|---|---|---|---|---|---|---|
| 1 | 2026-11-06 | edit endpoint with IDOR nearby, Supabase table needing RLS, public health endpoint | 15/15 (100%) | 15/15 (100%) | 162 s / 51 s | 101k / 89k |

**Status: not shipped by the quality bar.** It ties the baseline on scored checks at about 3x the time.

## Round 1 findings

- **The model already gets the basics right.** Without the skill it still checked ownership on the new endpoint, enabled RLS with owner-only policies on the new table, ignored `ownerId` in updates, kept the health check public, and flagged both nearby holes.
- **What the skill added, unscored:**
  - **Edit case:** it fixed the neighboring `GET /notes/:id` IDOR with a shared owner-only lookup and a test that fails on the old code. The baseline only flagged it, so Bob could still read Alice's notes.
  - **Supabase case:** it wrote 13 RLS tests (as anonymous and as another user), proved the `todos` exposure on a real Postgres, and added column grants so `user_id` can't be set from the client. The baseline had correct policies but no tests.
- **Cost:** about 3x the time, mostly from that extra testing.

## Decisions needed

- **Fix or flag neighboring security holes?** The skill fixed one outside the request. `verify-before-done`'s scope rule says behavior changes outside the request need approval.
- **Harder evals.** Use cases where models plausibly fail:
  - mass assignment via object spread
  - a list filter that widens scope (`?userId=`)
  - a Next.js server action without its own auth check
  - a JWT decoded instead of verified
  - an RLS policy based on `user_metadata`
  - a service key in a `NEXT_PUBLIC_` variable
  - an assertion that access rules are tested as anonymous and as another user
- **Trim cost.** Keep forbidden-case tests, but make heavy verification (spinning up a database) proportional.
