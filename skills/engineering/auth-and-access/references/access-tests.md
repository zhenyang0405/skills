# Access tests

Read this when writing the forbidden-case tests in Step 4. Each row of the access table needs a test
for who is allowed and tests for who is refused. Test at the highest level that's practical (HTTP
request, server action call, or database session), not by calling a private helper, so the test
covers the real path an attacker would use.

## The minimum set for a user-owned resource

For each action (list, read, create, update, delete):

| Caller | Expect |
|---|---|
| Anonymous | 401 (or redirect), body has no resource data |
| Owner | Allowed, correct result |
| Another logged-in user | 404 (or 403), body has no resource data, **database unchanged** |
| Wrong role (for admin actions) | 403, database unchanged |
| Owner sending protected fields (`ownerId`, `role`, `price`) | Field ignored or request rejected; stored value unchanged |

Also cover lists: user B's list doesn't include user A's records, and filters or search can't
widen the scope (`?userId=A`).

## HTTP tests (Node.js built-in test runner, any framework)

```js
const test = require('node:test');
const assert = require('node:assert');

test('another user cannot read a note', async () => {
  const alice = await login('alice'), bob = await login('bob');
  const note = await createNote(alice, { body: 'secret' });

  const res = await request('GET', `/notes/${note.id}`, bob);

  assert.strictEqual(res.status, 404);
  assert.ok(!JSON.stringify(res.body).includes('secret'));
});

test('another user cannot update a note, and it stays unchanged', async () => {
  const alice = await login('alice'), bob = await login('bob');
  const note = await createNote(alice, { body: 'original' });

  const res = await request('PATCH', `/notes/${note.id}`, bob, { body: 'hacked' });

  assert.strictEqual(res.status, 404);
  const after = await request('GET', `/notes/${note.id}`, alice);
  assert.strictEqual(after.body.body, 'original');
});

test('the owner cannot reassign a note to someone else', async () => {
  const alice = await login('alice'), bob = await login('bob');
  const note = await createNote(alice, { body: 'mine' });

  await request('PATCH', `/notes/${note.id}`, alice, { ownerId: bob.userId });

  const after = await request('GET', `/notes/${note.id}`, alice);
  assert.strictEqual(after.status, 200); // still Alice's
});
```

Check the **database state** after a refused write, not just the status code. A handler can return
403 after it already saved the change.

## Row-level security tests (Supabase / Postgres)

Run as the roles the API uses, inside a transaction you roll back:

```sql
begin;
-- as user A
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a"}';
insert into public.notes (body) values ('a-secret');

-- as user B: sees nothing, can't change A's rows
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b"}';
select count(*) from public.notes;                       -- expect 0
update public.notes set body = 'hacked';                 -- expect 0 rows updated

-- as anonymous: sees nothing
set local role anon;
select count(*) from public.notes;                       -- expect 0
rollback;
```

pgTAP or the Supabase CLI (`supabase test db`) can run these as automated tests. A quick check that
every exposed table has RLS on:

```sql
select tablename from pg_tables
where schemaname = 'public' and rowsecurity = false;   -- expect no rows
```

## Firebase rules tests

Use the emulator with `@firebase/rules-unit-testing`: `assertFails` reads and writes as an
unauthenticated context and as a second user, and `assertSucceeds` as the owner.
