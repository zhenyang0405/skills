---
name: content-strategy
description: Set the user up as a content creator from zero - pick a specific angle and viewer, three content pillars, which platforms (YouTube, Shorts, TikTok, Instagram Reels) and how often, their on-camera voice, and a first 30-day plan - then save it as their creator profile. Use when the user says they want to start making content, start a YouTube/TikTok/Instagram channel, "what should my channel be about", "I don't know how to start", "which platform should I use", or asks how these platforms work. Also use to revisit the strategy after a few months of posting.
---

# Content strategy

A beginner's biggest problem isn't scripts, it's not knowing who they're talking to or what they're
known for. Every idea and script gets easier once that's decided. This skill produces a **creator
profile** (saved to `my-context`) and a **first 30-day plan** the user can actually keep.

## When to use

- The user wants to start creating content and hasn't decided what about, for whom, or where.
- They ask how YouTube, Shorts, TikTok or Instagram work, or which to start with.
- They've posted for 2-3 months and want to re-aim (bring the evidence from `content-retro`).

Do not use for: generating specific video ideas (`content-ideas`), writing a script
(`video-script`), or reviewing published videos (`content-retro`).

## Before you start

- Read `my-context`: `about-me.md`, `goals.md`, `projects.md` and, if it exists, `creator.md`
  (plus any `.private.md` overrides). Projects and goals usually contain the angle already.
- If `creator.md` is already filled in, this is a **revisit**: ask what changed, then jump to the
  step that needs it. Don't re-interview from scratch.
- If the user doesn't know how the platforms work, give them the 3-question model from
  [references/platforms.md](references/platforms.md) ("did they stop, stay, act?") in a few lines
  before asking anything. Explain more only when they ask.

## Steps

1. **Interview, one question at a time.** Use the style of the `interview-me` skill (your read +
   confidence first, one question per message, a recommendation they can accept with "yes"), but
   only cover what's still unknown from `my-context`:
   - **Why content?** Career/job offers, an audience for a future product, income, learning in
     public, or fun. This decides which platform matters most. Ask it open, no guess.
   - **What can you show that others can't?** Their projects, job experience, tools they use daily,
     a story (career switch, a hard bug). Remind them employer-confidential work is off limits.
   - **Who do you want watching?** Push to one specific person
     (see [references/tech-ai-angles.md](references/tech-ai-angles.md), "Narrow the viewer").
   - **Face, voice, or screen only?** Comfort decides what lasts.
   - **Hours per week**, honestly, and which day they could batch-film.
   - **Language and region** they'll post in.
   - Checkpoint: you can fill every line of the Positioning section of `creator.md`.

2. **Propose the angle.** Offer 2-3 options from the angles table, each as a positioning sentence:
   *"I help [specific viewer] [outcome] by [what I show], because [why me]."* Recommend one and say
   why (usually the one closest to what they already build or do). Check it against "Signs an
   angle is right" in the reference. Get an explicit choice before moving on.

3. **Set three pillars.** One for reach, one for trust, one personal, each with its format and
   three example video topics. The examples must come from the user's real projects and
   experience, not generic "top 5 AI tools".

4. **Choose platforms and cadence.** Default recommendation for a beginner with under ~8 h/week:
   - **Month 1:** short vertical videos only (30-60 s), **one master file cross-posted** to Shorts,
     TikTok and Reels, 2-3 per week. Short videos are the fastest way to learn hooks and get over
     camera nerves, and three platforms triple the feedback.
   - **From month 2:** add one YouTube long-form every 1-2 weeks on the trust pillar, and cut
     2-3 Shorts from each one.
   - Change the default when the goal says so: career/B2B audience → add LinkedIn posts of the same
     material; search-driven tutorials → start long-form earlier; under 3 h/week → 1-2 Shorts/week.
   - The cadence must fit the stated hours with ~25% slack. Estimate: a 45 s Short ≈ 1.5-3 h for a
     beginner (idea, script, film, edit, post); a 10 min tutorial ≈ 8-15 h. Show the maths.

5. **Capture their voice.** Ask for 2-3 samples: things they've written (posts, messages, docs) or
   a 60-second voice memo answering "explain what you're building to a friend", transcribed.
   From them, write: how they sound, phrases they use, words they'd never say, claims they won't
   make. If they have no samples yet, write a provisional voice and mark it "update after the
   first 5 videos". Scripts in the wrong voice are worse than none: they have to say them aloud.

6. **Write the creator profile.** Fill `skills/core/my-context/references/creator.md` (or the
   user's installed copy of `my-context`). Show the full text and **ask before writing**; put
   anything they consider personal in `creator.private.md` instead.
   - Checkpoint: no `<placeholder>` left except the "What works" sections, which stay empty until
     `content-retro` has evidence.

7. **Make the first 30-day plan.** Set up a `content/` folder in the user's working directory (ask
   where if unclear) with `ideas.md`, `scripts/` and `log.md`. Then run `content-ideas` to fill the
   backlog and lay out four weeks: what gets posted which day, which batch-filming day, and one
   learning goal per week (e.g. week 1 "post 3 times, imperfect is fine"; week 2 "try 3 different
   hook types"; week 3 "first face-on-camera video"; week 4 "first `content-retro` review").
   Save it as `content/plan.md`.

8. **Hand over.** Summarize in under 10 lines: the positioning sentence, pillars, platforms and
   cadence, and the first video to make this week. Offer `video-script` for that first video.

## Done when

- [ ] The user explicitly chose the angle and positioning sentence (quote their reply)
- [ ] `creator.md` (or its private copy) is written with the user's approval, no placeholders left
      outside "What works"
- [ ] Each pillar has three example topics drawn from the user's real work or experience
- [ ] The cadence fits their stated hours, with the time estimate shown
- [ ] `content/plan.md` exists with four weeks of dated posts and a weekly learning goal
- [ ] The user knows the first video they'll make this week

## Common rationalizations

| Excuse | Reality |
|---|---|
| "Tech and AI is specific enough." | It's a category with thousands of channels. Without a specific viewer, every script is generic. |
| "Let's be on every platform with different content." | A beginner can't sustain that. One master video cross-posted gets triple the feedback for one effort. |
| "Start long-form for more money." | Long videos take 5-10× the effort and a beginner's first ten will be rough. Learn hooks on Shorts first unless search tutorials are the plan. |
| "Daily posting is what grows channels." | A cadence they quit in week 3 grows nothing. Plan what fits their hours, with slack. |
| "I'll write the voice myself from the questions." | Inferred voices sound like an AI. Use their real words, or mark it provisional. |
| "Quote some benchmarks to motivate them." | Platform benchmarks from blogs are mostly made up. Promise them their own numbers after 2 weeks instead. |

## References

- [references/platforms.md](references/platforms.md): how YouTube, Shorts, TikTok and Reels
  distribute videos, what each metric means, cross-posting, AI/originality rules, account setup.
  Read when explaining platforms or choosing them.
- [references/tech-ai-angles.md](references/tech-ai-angles.md): angles, narrowing the viewer,
  pillars, formats and face/voice/screen choices for tech and AI creators. Read in steps 1-3.
