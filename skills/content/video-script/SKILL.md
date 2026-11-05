---
name: video-script
description: Write a ready-to-film video script for a tech/AI creator - hooks, a beat-by-beat script with what to say and what to show on screen, title and thumbnail for YouTube, captions and on-screen text - for YouTube long-form, Shorts, TikTok or Instagram Reels, in the creator's own voice with every claim checked. Also cuts Shorts from a long video and critiques an existing script. Use when the user says "write a script", "script this idea", "turn this into a TikTok/Reel/Short", "write a hook", "title and thumbnail for this video", "review my script", or "cut Shorts from this video".
---

# Video script

A script is good when the right viewer stops, stays to the end, and gets exactly what the hook
promised, and when the creator can say it without sounding like someone else. This skill turns one
idea into a script file the creator can film from, with the evidence checks done.

## When to use

- **Write**: one idea (from `content/ideas.md` or the user) into a script for a chosen format.
- **Cut Shorts**: find standalone Shorts inside a long video's transcript.
- **Review**: critique a script the user wrote, using steps 4-8 as the checklist.

Do not use for: deciding what to make (`content-ideas`), channel direction (`content-strategy`), or
diagnosing a published video's numbers (`content-retro`).

## Before you start

- Read `my-context` → `creator.md`: viewer, angle, voice, never-say list, "What works". If it's
  empty, ask for the viewer and a voice sample and suggest `content-strategy` later; don't block.
- Get the idea with its promise, angle and evidence. If it isn't in the backlog format, write the
  one-sentence promise now: "After this, [viewer] will [outcome]." No promise, no script.
- Agree **format and length**: Short (20-60 s, cross-posted to Shorts/TikTok/Reels by default) or
  YouTube long-form (8-15 min typical), and whether it's face, voice + screen, or screen only.

## Steps

1. **Collect the proof.** List what will be on screen that proves the promise: the demo, the
   real output, the before/after, the code, the source page. Ask the creator for anything only
   they have (their result, the time it took, the error they hit).
   - Anything unknown becomes a `{{placeholder}}` listed under **To fill**. Never invent a number,
     result, quote or source to make a line stronger.
   - For claims about tools, models or news: open the primary source and note it. For code or
     commands that will appear on screen: they must have been run, or are marked `[UNTESTED]`.
   - Checkpoint: every claim the script will make has a source, the creator's own result, or a
     placeholder.

2. **Write the last line, then the first.** Decide the point the video lands on (and, for a Short,
   how the last line can loop back to the first). Then the hook can aim at it.

3. **Long-form only: package first.** Before the body, write 5+ titles and pick 2, with one
   thumbnail concept for each. Rules: title ideally under ~60 characters, front-loaded with the
   topic; thumbnail has at most 3 words and **does not repeat the title** (same promise, different
   words); a number, a name or a visible result beats an adjective. Suggest testing both with
   YouTube's A/B test feature. The script's first 30 seconds must confirm this packaging.

4. **Write five hooks of different types** from [references/hooks.md](references/hooks.md). Each
   hook = first frame + spoken line + on-screen text. Check each against the four failures (delay,
   confusion, irrelevance, no reason to stay) and the sayable/concrete/honest checks. Present the
   **best two**, with the type and one line on why each fits this idea.

5. **Draft beat by beat** with the matching skeleton in
   [references/structures.md](references/structures.md). Use a table so filming is easy:

   | Time | Say | Show |
   |---|---|---|
   | 0:00 | (spoken line) | (exact screen, shot or overlay) |

   - Every row has a **Show**. Something changes every few seconds on Shorts; a re-hook every
     60-90 s on long-form.
   - Beats connect with "but" or "so", not "and then". One idea per video.
   - Deliver the payoff explicitly, and as early as the format allows.
   - One call to action, matched to the goal in `creator.md`.

6. **Read-aloud pass** with [references/spoken-writing.md](references/spoken-writing.md): spoken
   rules, the specificity ladder, AI-tells removal, the over-correction check, and the creator's
   never-say list. Read it at speaking speed; rewrite any line that stumbles.

7. **Check length and truth.**
   - Word count ÷ 2.5 = seconds (÷ 3 for fast short-form). Over the target? Cut the weakest beat,
     don't speed up.
   - Re-read every claim against step 1. Hype that the proof doesn't support gets toned down.
   - Disclosure: if the video shows realistic AI-generated people, voices or events, note that the
     platform's AI label must be switched on. Note any sponsorship or affiliate link to disclose.
   - Screen safety: list anything to hide in the recording (API keys, emails, tokens, private tabs).

8. **Package for posting.** For short-form, per platform: caption (TikTok and YouTube: include the
   phrase people would search; Instagram: can be more personal), on-screen text for the first 2
   seconds, 3-5 relevant hashtags at most, a pinned-comment question. For long-form: description
   (first two lines carry the promise and the searched phrase), chapters, links, pinned comment.

9. **Save and hand over.** Write `content/scripts/<YYYY-MM-DD>-<slug>.md` containing, in order:
   promise, format/length, packaging (titles + thumbnails, long-form), the two hooks, the script
   table, **To fill**, filming notes (shots, screen recordings, things to hide), posting copy, and
   sources. Set the idea's status to `scripted` in `content/ideas.md`. End with the To-fill list
   and: "Film it, or change something?"

## Mode: cut Shorts from a long video

Read the transcript (with timestamps) and find 20-55 s spans that work with no context:

1. **Opens cold**: the first sentence makes sense to someone who saw nothing before it.
2. **One idea, with a turn**: a claim, then something that proves or complicates it.
3. **Ends on a line**, not a trail-off, and doesn't reference "earlier" or "later in this video".

Rank candidates and show the top five with timestamps and their first line. For each kept clip,
write a **new** hook line and on-screen text (the original line assumes context), a loop ending
if possible, and a vertical-crop note (what in the 16:9 frame matters). Save them in the long
video's script file under "Shorts".

## Mode: review an existing script

Run steps 4-8 as checks against the user's script. Return the **three changes that matter most**,
in order (hook problems first, then missing proof or payoff, then pacing and voice), each with a
rewritten line. Only list the rest if asked. Don't rewrite the whole script unless asked.

## Done when

- [ ] The script file exists in `content/scripts/` with every section listed in step 9
- [ ] Two hooks, each with first frame, spoken line and on-screen text, of different types
- [ ] Every script row has a **Show**; long-form has 2 titles + thumbnail concepts that don't repeat each other
- [ ] Every claim is sourced, the creator's own result, or a `{{placeholder}}` in To fill; on-screen code was run or marked `[UNTESTED]`
- [ ] Estimated runtime (words ÷ 2.5) is within the target length
- [ ] No phrase from the AI-tells list or the creator's never-say list remains
- [ ] The idea's status in `content/ideas.md` is `scripted`

## Common rationalizations

| Excuse | Reality |
|---|---|
| "A quick intro builds rapport." | Viewers leave in the first seconds. Rapport comes from the payoff, not a greeting. |
| "I'll add a plausible number; it's close enough." | Made-up numbers get caught in comments and kill trust. Use a placeholder and ask. |
| "The visuals can be figured out in editing." | A script without a Show column becomes a talking head. Plan the screen now. |
| "One hook is enough; it's obviously good." | The first hook is rarely the best. Five of different types, then compare. |
| "Hype gets views; tech viewers like excitement." | Tech viewers punish overselling fast. Specific results excite more than adjectives. |
| "Long-form title and thumbnail come last." | They decide whether anyone clicks. Writing them first keeps the video honest to its promise. |
| "The code worked when I wrote it." | Viewers will copy it exactly. Run it, or mark it `[UNTESTED]`. |

## References

- [references/hooks.md](references/hooks.md): the three parts of a hook, hook types with tech/AI
  examples, the four failures, long-form first 30 seconds, hooks to never write. Read in step 4.
- [references/structures.md](references/structures.md): pacing, short- and long-form skeletons,
  calls to action, making screen content watchable. Read in step 5.
- [references/spoken-writing.md](references/spoken-writing.md): writing for the ear, specificity
  ladder, AI tells, over-correction, learning the voice. Read in step 6.
