---
name: content-ideas
description: Find and rank video ideas for a tech/AI creator - mined from their own projects, real audience questions, outlier videos in their niche and verified AI news - each with a one-sentence promise, an angle, evidence and a score, saved to a backlog. Use when the user asks "what should I post", "give me video ideas", "content ideas", "what's trending in AI that I could cover", "fill my content calendar", or is stuck on what to make next for YouTube, Shorts, TikTok or Reels.
---

# Content ideas

Most "content ideas" lists are topics everyone already covered. A good idea is a **promise to a
specific viewer** that this creator can **prove on screen**, with evidence that someone wants it.
This skill produces scored ideas in a backlog (`content/ideas.md`) that `video-script` picks from.

## When to use

- The user needs ideas: a full backlog, the next video, or a check on this week's AI news.
- `content-strategy` step 7 asks for a starting backlog.

Do not use for: choosing the niche or platforms (`content-strategy`), writing the script for a chosen
idea (`video-script`), or judging posted videos (`content-retro`).

## Before you start

- Read `my-context` → `creator.md` (viewer, angle, pillars, voice) and `projects.md`. If
  `creator.md` is empty, ask three things (who's the viewer, what's the angle, which platforms) and
  suggest running `content-strategy` afterwards. Don't block on it.
- Read `content/ideas.md` and `content/log.md` if they exist, to avoid repeats and to reuse what
  worked ("What works" in `creator.md`).
- Agree the mode: **backlog** (15-20 ideas), **next video** (3 strong options, user picks one) or
  **news check** (only time-sensitive ideas from the last 7 days).

## Steps

1. **Harvest raw material from at least two wells.** Details and where to look are in
   [references/sources.md](references/sources.md). In order of value for a beginner:
   1. **The creator's own work**: what they built, broke, learned or tried this week. Ask
      "what happened this week?" and "what took longer than it should have?". Highest proof,
      no competition.
   2. **Audience questions**: real questions from the target viewer (comments, Reddit, HN,
      search autocomplete).
   3. **Outliers**: videos at 3× or more their own channel's median views, in channels serving a
      similar viewer.
   4. **News**: releases and changes from primary sources, last 1-7 days.
   - Record evidence for every item: a link, a number of upvotes/likes, or the project/commit the
     creator can show. No evidence, no idea.
   - Checkpoint: a raw list of 2× as many items as ideas needed, each with its evidence.

2. **Turn items into ideas.** Most stuck creators have a topic but no angle. For each item write:
   - **Promise**: "After this, [viewer] will [know/be able to] [specific outcome]."
   - **Angle**: what makes this version different. Lenses: show a real test instead of a summary;
     take the contrarian side you can defend; cover the second-order effect ("what this means for
     your job"); tell the failure; compare against what the viewer uses today.
   - **Format** and **platform**, from the formats table in
     [../content-strategy/references/tech-ai-angles.md](../content-strategy/references/tech-ai-angles.md).
   - **Pillar** it belongs to.

3. **Gate.** Drop any idea that fails one of these:
   - **Fits a pillar** and the viewer in `creator.md`.
   - **Hook test**: you can write three different hooks for it in a minute. If you can't, the idea is
     too vague.
   - **Swap-the-name test**: if any other AI creator could post it unchanged, it needs the
     creator's own proof or opinion added, or it goes.
   - **Credible**: the creator can actually make it (skill, access, hardware, allowed to show it).
   - **Verified** (news ideas): you opened the primary source today and the claim holds. Write the
     link and date.
   - **Not a repeat** of anything in `log.md` from the last 4 weeks, unless it's a deliberate
     follow-up to a winner.

4. **Score what's left.** Four factors, 1-5 each (max 20):

   | Factor | 5 means | 1 means |
   |---|---|---|
   | **Pull** | Evidence that many target viewers want it (popular question, 3×+ outlier, searched phrase) | Only the creator finds it interesting |
   | **Proof** | The creator can show it working on screen, with their own result | Talking only |
   | **Angle** | Clearly different from the top 3 existing videos on it (you checked) | Same as everyone's |
   | **Ease** | Can be made in one session this week with what they have | Needs new gear, skills or days |

   Then tag the **window**: `NOW` (news, worth it only in the next 1-3 days), `SEASONAL` (date
   noted), or `EVERGREEN`. Order: `NOW` ideas scoring 12+ first, then everything by score.
   Be honest. If most ideas score 14+, you're grading too kindly.

5. **Balance the mix.** For a backlog, check the top ideas spread across pillars and formats, and
   that at least a third come from the creator's own work. Swap in the next-best idea where one
   pillar dominates.

6. **Present and save.** Show a table (rank, working title, promise, format, platform, score,
   window). For the top 3, add two lines: why it should work (cite the evidence) and a hook seed.
   Ask which to keep, then add the kept ones to `content/ideas.md` in this format:

   ```markdown
   ## <Working title>
   - Promise: After this, <viewer> will <outcome>.
   - Angle: <what's different> · Pillar: <name> · Format: <format> · Platform: <where>
   - Evidence: <link / numbers / project>  (checked <date> for news)
   - Score: Pull <n> · Proof <n> · Angle <n> · Ease <n> = <total>/20 · Window: <NOW/SEASONAL/EVERGREEN>
   - Hook seed: <one line>
   - Status: idea
   ```

   Then offer `video-script` for the top pick.

## Done when

- [ ] Ideas came from at least two wells, and at least a third from the creator's own work (backlog mode)
- [ ] Every idea has a promise sentence, an angle, evidence, a score and a window
- [ ] Every news idea links a primary source checked today; none rely on screenshots or aggregators
- [ ] No idea repeats something posted in the last 4 weeks (checked against `log.md`)
- [ ] The kept ideas are saved in `content/ideas.md` with status `idea`

## Common rationalizations

| Excuse | Reality |
|---|---|
| "'Top 10 AI tools' is a safe idea." | It's the most-made video in the niche. Without the creator's own test and verdict it fails the swap-the-name test. |
| "This news is everywhere, so it must be true." | AI news spreads as screenshots of wrong benchmarks and fake leaks. Open the primary source or drop it. |
| "That outlier did 2M views, let's remake it." | Take the shape (promise, format, title pattern), not the content. Copies are weaker and platforms penalize unoriginal content. |
| "I'll skip the evidence; the idea is obviously good." | Obvious to the creator isn't proof anyone wants it. A link to one real question takes a minute. |
| "More ideas is better; give them 50." | A beginner needs 10-20 good ones they'll actually make. Long lists get ignored. |
| "Score everything 4s and 5s to be encouraging." | Inflated scores hide which idea to make first. Calibrated scores are the point. |

## References

- [references/sources.md](references/sources.md): the four wells in detail (own work, audience
  questions, outliers with the median method, verified news), where to look for tech/AI, and quick
  prompts for turning material into ideas. Read in step 1.
