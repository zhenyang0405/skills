---
name: skill-name
description: <What this skill does, in one sentence>. Use when <the situations, phrases or file types that should trigger it>.
---

<!--
How to use this template
1. Copy this folder to skills/<pack>/<skill-name>/ and rename `name` above to match the folder.
2. The description is the only part the agent sees before it decides to load the skill.
   Say what it does AND when to use it, using words the user would actually say. Max 1024 chars.
3. Keep this file under ~500 lines. Put long checklists, examples and docs in references/
   and link to them, so they load only when needed.
4. Delete any section you do not need, and delete this comment.
5. Write 2-3 test cases in evals/ (see evals/README.md) and test them with skill-creator.
6. Run: python3 scripts/skills.py sync-marketplace && python3 scripts/skills.py validate
-->

# <Skill title>

<One or two sentences: the outcome this skill produces and why the process matters.>

## When to use

- <Situation 1>
- <Situation 2>

Do not use for: <near-misses that belong to another skill>.

## Before you start

- Read the `my-context` skill's relevant files if the task depends on who the user is, their stack or their startup.
- Gather: <inputs the agent needs; ask the user only for what it cannot find itself>.

## Steps

1. **<Step name>.** <What to do.>
   - Checkpoint: <what must be true before moving on>.
2. **<Step name>.** <What to do.>
3. **<Step name>.** <What to do.>

## Done when

Exit criteria, each backed by evidence (output, file, link), not by "it looks right":

- [ ] <Criterion 1, and how to show it>
- [ ] <Criterion 2>

## Common rationalizations

Excuses agents use to skip steps, and the answer to each.

| Excuse | Reality |
|---|---|
| "<e.g. This is too small to need tests>" | <e.g. Small changes break things too; a test takes a minute.> |

## References

- [references/example.md](references/example.md): <what it holds and when to read it>
