# interview-me: evaluation log

Each round runs the skill's test cases (`skills/core/interview-me/evals/`) once with the skill and once without it, using the `skill-creator` loop. Run outputs live in `.workspace/` (not committed).

| Round | Date | Cases | With skill | Without | Time (with / without) | Tokens (with / without) |
|---|---|---|---|---|---|---|
| 1 | 2026-11-06 | vague build request, startup grill, clear task, "don't ask me questions" | 20/20 (100%) | 15/20 (75%) | 37 s / 35 s | 89k / 85k |

## Round 1 findings

- **The gap is in the interview itself.** On "build me a dashboard", the reply without the skill asked six questions at once, mostly about technology choices (data source, stack, live updates), each with a menu of options. With the skill, it gave its read and confidence, then asked one open question about what the dashboard is for, anchored in a real past situation.
- **It stays out of the way.** On a clear coding task and on "don't ask me questions, just make it", the skill runs did the work directly. They listed assumptions where the user had opted out of questions, exactly like the runs without the skill.
- **Cheap.** About 3 s and 5% more tokens per reply.

## Caveats

- The interview checks encode the skill's own method (one question per message, read and confidence first, open intent questions), so they show the method is followed, not that it beats batched questions for every user. The method is grounded in elicitation practice (The Mom Test, BABOK), but the user's own review is the real test.
- Not yet tested: multi-turn behavior (pushing on vague answers, the brief, the explicit-yes gate), and whether the description triggers the skill on its own.
