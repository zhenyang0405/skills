---
name: interview-me
description: Interview the user, one question at a time, until what they actually want is clear, then confirm it in a short brief before any plan, spec or code. Use when the user says "interview me", "grill me", "stress-test this", "poke holes in it" or "before we start", or when a request to build, launch or decide something non-trivial is missing who it's for, why, what success looks like, or the main constraint. Works for software features, startup ideas, and personal or career decisions.
---

# Interview me

What people ask for and what they want are often different. "Build me a dashboard" can turn out to
mean "I need a list". This skill finds that gap while it is still free to fix: before anything is
planned or built. The output is a **confirmed brief**, not a plan.

## When to use

- The user asks to be interviewed, grilled or challenged on a plan, idea or decision.
- A request to build, launch or decide something non-trivial is missing at least one of: **who**
  it's for, **why** (and why now), what **success** looks like, or the binding **constraint**.
- You notice yourself filling in requirements the user never stated.

Do not use for: clear, self-contained tasks ("rename this", "fix this typo"), questions about how
something works, or when the user's request already says not to ask questions (then do the task and
list your assumptions). Never run it where no one can
answer (CI, scheduled or autonomous runs). There, list the open questions as blockers instead of
guessing.

## Step 1: Look before you ask

Facts are your job; decisions are the user's.

- Read the `my-context` skill's relevant files and anything the user pointed at (files, links,
  earlier conversation). In a project, read enough code or docs to explain how things work today.
- Never ask what you could find out yourself. If a lookup is slow, start it and ask about the
  parts that don't depend on it.
- If the request is really several independent things, say so and agree which to interview first.

Checkpoint: you can say in one sentence what you already know, and what only the user can tell you.

## Step 2: Open with your read

Your first message has three parts, plus an optional note:

```
My read: <one sentence: what I think you want and why>
Confidence: ~<0-100>% (still open: <the 1-3 biggest unknowns>)

<first question, in the format below>

<optional one-line note, e.g. "Skip any question you'd rather keep private.">
```

Be honest with the number. Start with the biggest unknown: for something to build or a personal
decision, that's usually **why** they want it; for a startup idea, it's **who exactly has the
problem** (see the startup reference).

## Step 3: Interview, one question per message

Keep a private map of the open decisions and what depends on what. Each turn, ask the single
question whose answer would change the most, out of those that don't depend on something still
unanswered. Format:

```
**Q<n>: <short title>**
<the question, built on their last answer or something you found>
Why I'm asking: <what the answer changes>
➡️ My guess: <your recommended answer and the reason>. "Yes" accepts it.   ← decision questions only
```

Rules:

- **Intent questions are open.** For *why*, *who* and *what success means*, leave out the guess
  line the first time you ask. Their phrasing carries intent your options would hide. Once they've
  answered in their own words, even vaguely, follow-ups on that topic may include a guess.
- **Decision questions get a recommendation.** Word them so "yes" accepts your pick. Reacting is
  faster than inventing an answer. Sometimes guess in a direction you expect them to push back on,
  so agreeing isn't just politeness.
- **A proposal can beat a question.** If the answer is probably obvious, state your call and the
  reason, and let them correct it.
- **Push on vague answers.** "Scalable", "seamless", "everyone", "the standard way" are not answers.
  Ask for a number, a name, an example. If an answer sounds like what they *should* want, ask:
  *"If you didn't have to justify this to anyone, what would you actually want?"*
- **Take a position on the evidence.** Don't say "that could work". Say whether it will, based on
  what you know, and what evidence would change your mind. For personal decisions, judge the
  reasoning and the facts, but don't push which option to pick unless they ask for your view.
- **Play back as you go.** Once one part is clear, summarize it in a few lines and ask what's wrong
  or missing, then move on to the next part.
- **Re-score.** Update the confidence line every few questions. If it stops rising after three
  questions, you're asking the wrong things. Step back and say so.
- **Batch only on request.** If the user asks for speed, ask every currently unblocked question in
  one numbered list, each with your guess, then recompute after their answers.

What to cover depends on the topic. Read the matching reference once you know the topic:

- Building software, a feature or a tool: [references/build.md](references/build.md)
- A startup or product idea: [references/startup.md](references/startup.md)
- A personal, career or life decision: [references/decision.md](references/decision.md)

## Step 4: Stop when you can predict them

You're done when you can honestly answer yes to: *"Could I predict the user's answers to the next
three questions I'd ask?"* If you've asked about ten questions and still can't, stop and say that
something foundational is missing, and offer to step back.

## Step 5: Restate the brief

Write it back in their words, short enough to check line by line:

```
Here's what I now think you want:

- Outcome:      <one line>
- For whom:     <who benefits>
- Why now:      <what changed or what it unlocks>
- Success:      <how we'll know it worked; a number if possible>
- Constraint:   <the binding limit: time, money, tech, people>
- Out of scope: <what we are explicitly not doing>
- Assumptions:  <anything I filled in that you didn't say>

Yes, no, or what would you change?
```

"Out of scope" and "Assumptions" are required. Half of all misunderstandings are about what is *not*
being done, or what was silently assumed.

## Step 6: Get an explicit yes, then stop

- Only a clear yes counts. "Sounds good", "sure" or "whatever you think" don't. Ask "Anything you'd
  change?" or offer two concrete options to choose between.
- If they correct something, fold it in and restate.
- After the yes, post the final brief and offer next steps: save it (in a project, to
  `docs/briefs/<topic>.md`), write a spec, or plan the work. **Then end your turn.** Start
  nothing until they choose.

## If the user wants to skip

- **First "just do it":** say you'll ask at most two more, then ask the two that matter most
  together in one message, numbered, each with your guess (so "yes, yes" works).
- **Second time:** stop asking. Their insistence is consent to go ahead without the yes-gate in
  Step 6. Post the brief with everything you're unsure of under **Assumptions**, then do what they
  asked for (e.g. the plan) in the same message. They can correct the assumptions afterwards.

## Done when

- [ ] Your first message stated your read and a confidence number with the open unknowns
- [ ] Questions came one per message (unless batching was requested), each saying why it matters
- [ ] Nothing was asked that `my-context`, the files or a quick lookup could have answered
- [ ] Vague or "should want" answers were pushed on at least once
- [ ] The brief has all seven lines, including Out of scope and Assumptions
- [ ] The user gave an explicit yes to the brief, or skipped twice and the brief lists your assumptions
- [ ] After a yes, you stopped without starting the work

## Common excuses

| Excuse | Reality |
|---|---|
| "The request is clear enough." | If you can't write the outcome and success in one line each, it isn't. |
| "Questions waste their time." | Five questions take minutes. Building the wrong thing takes days. |
| "I'll work it out while building." | Changing direction after work exists costs far more, and people talk themselves into keeping the wrong thing. |
| "Asking several at once is faster." | Later questions depend on earlier answers, and a list gets skimmed. Batch only when they ask. |
| "A guess leads them." | That's the point: reacting is faster. The risk is polite agreement, so be visibly ready to be wrong. |
| "They said 'whatever you think', so I'll decide." | That's handing it back, not deciding. Offer two concrete options. |
| "They said yes, let's go." | Yes to a vague summary is hollow. Restate concretely, then confirm. |
