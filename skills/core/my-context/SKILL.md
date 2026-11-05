---
name: my-context
description: Background on the user - who they are, their goals, how they like to work, their preferred tech stack, and their current projects and startup ideas. Use when tailoring advice, plans, code choices or writing to the user, or when another skill needs user, stack or startup context.
---

# My context

Facts about the user that make answers fit them instead of a generic person. A short summary is
always loaded from the user's profile; this skill holds the detail. Read only the file the task needs:

| File | Read when the task involves |
|---|---|
| [references/about-me.md](references/about-me.md) | Background, working style, how they want answers delivered |
| [references/goals.md](references/goals.md) | Prioritizing, planning, or career, life or startup decisions |
| [references/stack.md](references/stack.md) | Choosing languages, frameworks, tools, cloud or infrastructure |
| [references/projects.md](references/projects.md) | Their current projects, startup ideas and what stage each is at |

## Rules

- **Private overrides.** If `<file>.private.md` exists next to a file (e.g. `about-me.private.md`),
  read it too. It holds details kept out of git. Where the two disagree, the private file wins.
- **Placeholders are unknowns.** Text like `<...>` or `TODO` means the user has not filled it in.
  Ask when it matters; do not guess.
- **Use it, don't recite it.** Apply the context silently. Don't repeat it back to the user.
- **Keep it current.** If the user states a lasting fact that contradicts or extends these files,
  offer to update the right file. Don't edit it without asking.
