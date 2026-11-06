---
name: spec-and-plan
description: Turn a confirmed idea or request into a short spec (numbered, testable requirements with Given/When/Then examples, scope, decisions and risks) and a plan of small end-to-end slices that each say what they deliver, which requirements they cover and how to verify them. Use before building any feature, change or project that is bigger than a quick fix, after an interview-me brief, or when the user asks for a spec, PRD, requirements, acceptance criteria, user stories, a plan, tasks, tickets or "how should we build this?", even if they just say "let's build X".
---

# Spec and plan

A spec says **what** must be true when the work is done, in terms anyone can check. A plan says **in
what order** to make it true, in slices small enough to build and verify one at a time. Most bad
builds come from skipping one of these: vague requirements produce the wrong thing, and big
unordered tasks produce something that can't be checked until it's all broken at once.

The spec's requirements and examples become the tests, and the checklist `verify-before-done` uses.
So write them to be checked, not admired.

## When to use

- Before building a feature, change or project bigger than a quick fix.
- After `interview-me` produced a confirmed brief, or when the request already says who, why and what success is.
- When the user asks for a spec, PRD, requirements, acceptance criteria, user stories, a plan, tasks or tickets.

Do not use for: one-step changes ("rename this", "fix this typo", "bump this version"). For those, just do
the work. If the request doesn't yet say who it's for, why, or what success looks like, run
`interview-me` first. A spec built on guessed intent is a confident description of the wrong thing.

## Step 1: Size the work and gather context

- **Read before writing.** Read the brief, the request, and the relevant code, tests and docs. Use the
  project's own words for things (its domain terms, its existing modules). Read `my-context` for the
  user's default stack and constraints.
- **Follow the project's format.** If the repo already uses a spec system (Spec Kit, Kiro, OpenSpec,
  `docs/specs/`, `tasks/`), write in its format and location. Otherwise use `docs/specs/<feature>.md`.
  Never overwrite an existing spec or plan that still has open items; ask first.
- **Pick a size**, and say which in one line:

| Size | Looks like | What to write |
|---|---|---|
| Small | 1–2 slices, one area of code | Spec and plan together in one short document, one approval |
| Medium | 3–8 slices | Spec and plan in one document; approval before building |
| Large | Several capabilities with their own users or data (e.g. accounts, billing, notifications) | A capability map first (modules, dependencies, build order) for approval, then a spec and plan per capability |

Checkpoint: you can name the outcome, the size, and where the document will live.

## Step 2: Write the spec

Use [references/template.md](references/template.md). Keep it as short as the work allows. Sections:

1. **Outcome.** The problem and who has it, the outcome, and why now, in two to four lines from the brief.
2. **Scope.** In scope, and **out of scope** (non-goals). Out of scope is where most misunderstandings hide.
3. **Requirements.** Numbered (`R1`, `R2`, …), one behavior each, in the EARS patterns (see
   [references/requirements.md](references/requirements.md)):
   - `When <event>, the <system> shall <response>.` for things triggered by an action
   - `While <state>, the <system> shall <response>.` for things true during a state
   - `If <unwanted condition>, then the <system> shall <response>.` for errors, bad input and failures
   - `The <system> shall <response>.` for things always true

   Write the **unwanted-behavior** requirements on purpose: invalid input, empty and huge values, missing
   permissions, network or service failure, duplicates, concurrent edits. Agents and specs both skip
   these by default, and they are where production bugs live.
4. **Acceptance examples.** For each requirement, at least one `Given / When / Then` with **concrete
   values** (a real amount, a real role, a real date), tagged with its requirement (`R3.a`). Vague words
   ("fast", "secure", "user-friendly") get turned into a measurable target here, or flagged as an open
   question. These examples are the tests to write.
5. **Decisions and constraints.** Stack, data and storage, interfaces, anything already decided, with
   one line of why each. Note security, privacy and data-safety needs where the feature touches login,
   permissions, personal data, payments or migrations. Add an **Ask first** list: changes the builder
   must not make without approval (new dependencies, schema changes, deleting data, changing CI).
6. **Assumptions, risks and open questions.** Anything you filled in, the riskiest unknowns, and
   questions only the user can answer.

Checkpoint: every requirement is testable (you could write its test now), and every requirement has
at least one example. If one isn't testable, rewrite it or move it to open questions.

## Step 3: Write the plan

Slice the work **vertically**: each slice is a thin, complete path through every layer it needs (data,
logic, interface, tests) that delivers one observable behavior. Not "build the database, then the API,
then the UI": that delivers nothing checkable until the end.
[references/slicing.md](references/slicing.md) has ways to split and the expand–contract pattern for
migrations and wide refactors.

For each slice:

```
### S<n>: <what a user can now do or observe>
- Covers: R1, R4 (examples R1.a, R4.a)
- Blocked by: S<m> | none
- Size: S | M        (L means split it)
- Verify: <the command or check that proves it, e.g. the tests for R1.a and R4.a pass, plus a manual check>
- Notes: <risk, test seam, or the decision it depends on>
```

Order and shape:

- **Riskiest first.** Put the slice most likely to change the plan (an unknown API, a hard performance
  target, a data migration) as early as its dependencies allow. Bad news is cheapest early.
- **Prepare, then change.** If the code needs restructuring to make the change easy, make that its own
  first slice, with no behavior change.
- **Each slice leaves the system working**, with checks green, so work can stop after any slice.
- **Small enough to verify.** A slice an agent can finish and verify in one session, with no more than
  about three acceptance checks. If its title needs "and", it's probably two slices.
- **Name the test seam.** Say where each behavior is tested: the highest level that's practical (an
  API or command, not a private function), so tests survive refactoring.
- Add a **checkpoint** after every two or three slices: full checks green, the core flow works end to end.

## Step 4: Check traceability, then stop for approval

- Every requirement is covered by at least one slice. Every slice covers at least one requirement.
  A slice with no requirement is gold-plating; a requirement with no slice will be forgotten.
- Every unwanted-behavior requirement has a slice that tests it.
- Then present a short summary: the size, the slices in order (one line each), the open questions,
  and the assumptions. Ask the user to approve or change it: is the granularity right, are the
  dependencies right, is anything in or out of scope that shouldn't be?
- **End your turn there.** Start building only after the user approves. Changing a plan costs minutes;
  changing built code costs hours.

For a large piece of work, stop after the capability map, then again after each capability's spec and plan.

## Done when

- [ ] The size was stated, and the document is saved in the project's spec location
- [ ] Out of scope is written down
- [ ] Every requirement is numbered, testable, and uses an EARS pattern
- [ ] Unwanted behavior (errors, bad input, failures, permissions) has its own requirements
- [ ] Every requirement has a Given/When/Then example with concrete values
- [ ] Slices are vertical, sized S or M, ordered riskiest-first, each with Covers, Blocked by and Verify
- [ ] The traceability check passed both ways
- [ ] The summary was presented, and you stopped for approval without starting to build

## Common excuses

| Excuse | Reality |
|---|---|
| "It's obvious what to build." | Then the spec takes ten minutes. If it takes longer, it wasn't obvious. |
| "We'll handle errors later." | Later means in production. Unwanted behavior gets requirements now. |
| "Layers first is cleaner." | Horizontal tasks deliver nothing you can check until the end. Slice vertically. |
| "Acceptance criteria can be vague; the tests will sort it out." | The tests come *from* the criteria. Vague criteria give tests that check nothing. |
| "This plan is detailed enough to start." | Not until the user approves it. |
| "Let's spec the whole platform up front." | Large work gets a capability map, then one spec per capability, built in order. |
