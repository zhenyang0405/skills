# Stack notes

Read the section for the stack you're working in (check `my-context` stack.md and the project).
Each shows where access control has to live and the mistakes that cause real breaches.

## Supabase (and any Postgres exposed through an API, e.g. PostgREST)

The browser talks to the database directly with the public `anon` key, so **row-level security
(RLS) is the access control**. A table in an exposed schema without RLS is readable and writable by
anyone who has your public key, which is everyone who loads your site.

```sql
create table public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  body text not null,
  created_at timestamptz not null default now()
);

alter table public.notes enable row level security;

create policy "notes: owner can read"   on public.notes for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "notes: owner can insert" on public.notes for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "notes: owner can update" on public.notes for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "notes: owner can delete" on public.notes for delete to authenticated
  using ((select auth.uid()) = user_id);
```

- **Enable RLS on every table** in exposed schemas (`public` by default), including join tables and
  tables you think are internal. Put truly internal tables in a schema the API doesn't expose.
- **One policy per action**, scoped `to authenticated` (or `anon` only where public access is intended).
  `using` controls which rows are visible; `with check` controls what may be written. An update policy
  needs both, or a user can move a row to someone else.
- **Protected columns:** policies are per row, not per column. Stop users changing columns like
  `role` or `user_id` with `with check`, a trigger, column privileges (`revoke update (role) ...`), or by
  keeping those columns in a separate table only the server writes.
- **The `service_role` key bypasses RLS.** It belongs only in server code and secrets, never in client
  code, `NEXT_PUBLIC_*` or `VITE_*` variables, or the repo.
- Don't base policies on `auth.jwt() -> 'user_metadata'`; users can edit their own user metadata. Use
  `app_metadata` or a roles table for authorization.
- `security definer` functions run with the owner's rights. Check access inside them, and set
  `search_path`.
- Storage buckets have their own policies on `storage.objects`. Private by default; scope by path
  (e.g. `(storage.foldername(name))[1] = auth.uid()::text`).
- Test policies as `anon` and as two different users (see access-tests.md). The Supabase dashboard's
  security advisor flags tables without RLS.

## Firebase (Firestore and Storage rules)

Like Supabase, the client talks to the database directly, so the rules are the access control.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /notes/{noteId} {
      allow read, update, delete: if request.auth != null && resource.data.ownerId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
    }
  }
}
```

- Never ship `allow read, write: if true;` or rules that expire "in 30 days" from the starter template.
- Check `request.resource.data` on writes so users can't set `ownerId` or `role` to someone else.
- Storage buckets need their own rules; the Tea app leak was an open storage bucket.
- Test with the Firebase emulator and `@firebase/rules-unit-testing`.

## Node.js (Express, Fastify, Next.js route handlers and server actions)

- Authenticate in middleware that sets `req.user` (or reads the session) and returns 401 when missing.
- Put ownership in the query, not after it:
  `db.note.findFirst({ where: { id, userId: req.user.id } })` → 404 when null.
- Use one helper for "load this resource for this user", and use it in every handler for that resource.
- Validate request bodies with a schema (zod, valibot, joi) that lists allowed fields, so extra
  fields like `userId` or `role` are dropped.
- **Next.js:** middleware alone isn't enough. Check auth and ownership again inside every route handler
  and server action (server actions are public POST endpoints). Never put secrets in `NEXT_PUBLIC_*`.

## Python (Django, FastAPI, Flask)

- **Django:** `get_object_or_404(Note, pk=pk, owner=request.user)`; filter querysets by owner in
  `get_queryset` for DRF views; use permission classes; list fields explicitly in serializers (never
  `fields = '__all__'` for writable serializers).
- **FastAPI:** a dependency that returns the current user, used by every route; separate Pydantic models
  for input (no `owner_id`, `role`) and output (no password hash).
- **Flask:** a `login_required` decorator plus an ownership-scoped query in each view.

## Rails

- Scope through the association: `current_user.notes.find(params[:id])`, never `Note.find(params[:id])`.
- Strong parameters: `params.require(:note).permit(:title, :body)`, never `permit!`.
- A policy library (Pundit, Action Policy) with `verify_authorized` so a missing check fails loudly.
