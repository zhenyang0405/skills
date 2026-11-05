# Interviewing about something to build

Ground to cover. This is territory, not a script: skip what's already answered, and never read the
list out as questions.

## Intent (ask open, before anything else)

- What problem does this solve, and for whom? Ask for one real situation where it hurt.
- Why now? What changed, or what does it unblock?
- What would make them say "this was worth it"? Push for something observable or a number.

## Shape

- What exists today: their current workaround, earlier attempts, code that's already there.
- Prior art: what they've seen elsewhere that they loved or hated.
- The two or three details they care about most. These are where to spend effort.
- Goals, non-goals, and **anti-goals**: what would make this a failure even if it technically works
  (too slow, too hard to change, embarrassing to show).

## Constraints

- Time (a deadline, or "a weekend project"), budget, and who maintains it afterwards.
- Stack: default to `my-context` stack.md and what the project already uses. Only ask when the
  request conflicts with them.
- Where it runs, who uses it, and how many: one person, a team, the public.
- Data: what it reads or writes, anything sensitive, anything that can't be lost.

## How it gets made

Read from how they talk whether they want a say in the *how*:

- They ask about trade-offs or name tools: they want options. Give two or three, with your pick and
  why.
- They talk only about outcomes: they're handing you the how. Make the calls, put each in the brief
  under **Assumptions**, and let them correct you.

## Good probes

- "Walk me through the last time you needed this. What did you do instead?"
- "If it only did one thing well, which thing?"
- "What would you be annoyed to find out I built?"
- "Who else touches this, and what will they expect?"
- "What happens if it's down or wrong for a day?"
