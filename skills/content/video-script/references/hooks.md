# Hooks

Read this in the hook step of `video-script`. The hook is the first 1-3 seconds of a Short and the
first 15-30 seconds of a long video. Its only job is to make the right viewer think "I need to see
how this ends".

## A hook is three things at once

On short-form, viewers decide before they've heard a full sentence. Write all three, and make them
work together without repeating each other:

1. **The first frame**: what's on screen at 0:00. For tech: the end result, the error, the
   surprising output, the before/after, your face reacting to the screen. Never a logo, a title
   card or you saying hello.
2. **The spoken line**: ideally under ~12 words, with the topic in the first five.
3. **The on-screen text**: up to ~6 words, different from the spoken line, readable in one glance.

## Hook types

Use different types when writing options, so the comparison is real. Label each option.

| Type | Pattern | Tech/AI example |
|---|---|---|
| **Result first** | Show the outcome, then promise how | "This app took me 40 minutes with zero code. Here's the exact prompt." |
| **Mistake / warning** | Name a costly mistake the viewer is probably making | "If you paste your API key into ChatGPT, stop. Here's what happens." |
| **Test** | "I tried X so you don't have to" with stakes | "I let an AI agent run my side project for a week." |
| **Contrarian** | Disagree with a common belief you can defend | "Prompt engineering is the wrong skill to learn in 2026." |
| **Specific question** | A question the viewer has already asked themselves | "Why does your local LLM get dumber the longer you chat?" |
| **Versus** | Two things the viewer is choosing between | "Cursor or Claude Code for a beginner? I built the same app twice." |
| **Number + constraint** | A concrete number that makes it feel achievable or surprising | "Three commands to run Llama on a laptop with 8 GB of RAM." |
| **Story cold open** | Start in the middle of the moment | "At 2 a.m. the agent deleted my database. This is why." |
| **Reveal / demo** | Something that looks impossible, shown immediately | "[screen: one sentence turns into a working website]" + "This is one prompt." |

Contrarian hooks have the highest ceiling and the most risk: they only work if the video truly
argues the point. Result-first and test hooks are the most reliable for tech.

## Every number in a hook must be real

"40 minutes", "8 GB", "a week": only if it's the creator's actual result or a verified fact. If the
script doesn't have the number yet, write `{{time it took}}` and list it under "To fill". Never
make one up because it sounds better.

## Check each hook against the four ways hooks fail

| Failure | Symptom | Fix |
|---|---|---|
| **Delay** | Greeting, context or setup before the point ("So today I want to talk about…") | Cut everything before the first interesting word |
| **Confusion** | Viewer can't tell what the video is about in 2 seconds | Name the topic plainly; one idea only |
| **Irrelevance** | Interesting, but not to *this* viewer | Name their situation ("If you're a backend dev…") or their problem |
| **No reason to stay** | Clear and relevant but nothing open | Add a gap: a contrast (A vs B), a result not yet explained, a stake |

Then three quick checks:

- **Sayable**: read it aloud. If you stumble or it takes more than ~3 seconds, shorten it.
- **Concrete**: does it contain a number, a name, a tool or a visible thing? Adjectives ("insane",
  "crazy", "game-changing") don't count.
- **Honest**: does the video actually deliver what the hook implies, early enough? A hook that
  oversells wins the first 3 seconds and loses the next 30, and platforms notice.

## Long-form: the first 30 seconds

For a YouTube video, the hook is a short sequence:

1. **Confirm the click** (0-5 s): restate the title/thumbnail promise in different words, so the
   viewer knows they're in the right place.
2. **Raise the stakes or open a gap** (5-20 s): why this matters, or the surprising thing they'll see.
3. **Show the payoff exists** (by ~30 s): a glimpse of the end result.
4. **Start**. No channel intro, no "before we begin", no subscribe request here.

## Bad hooks to never write

- "Hey guys, welcome back to my channel"
- "In today's video we're going to…"
- "AI is changing everything" (or any sentence that's true of every AI video)
- "You won't believe…" / "This is insane" with nothing specific
- A question nobody asks ("Have you ever wondered about transformers?")
- Anything that needs the previous video for context
