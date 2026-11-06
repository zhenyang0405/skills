# spec-and-plan: evaluation log

Each round runs the skill's test cases (`skills/engineering/spec-and-plan/evals/`) once with the skill and once without it, using the `skill-creator` loop. Run outputs live in `.workspace/` (not committed).

| Round | Date | Cases | With skill | Without | Time (with / without) | Tokens (with / without) |
|---|---|---|---|---|---|---|
| 1 | 2026-11-06 | brief to spec and plan, vague feature, small change | 15/15 (100%) | 13/15 (82%*) | 86 s / 62 s | 95k / 88k |

\* Mean of per-case pass rates.

## Round 1 findings

- **Plans the agent can verify slice by slice.** Without the skill, the plan began with building blocks (a date helper, then a usage store) that deliver nothing checkable on their own. With the skill, every slice was an observable behavior ("codes stop working after their end date") with the requirements it covers, a Verify line and a traceability table.
- **Numbered requirements.** Without the skill, rules lived in prose sections with only the tests numbered. With the skill, R1–R15 each held one EARS-style behavior, with examples tagged R1.a, R1.b and so on.
- **Intent before mechanics.** On "let's build a referral program", the skill run asked what it's for and how success is measured. The no-skill run asked seven mechanics questions and offered to start building on "go with the defaults", with no spec.
- **No over-planning.** A one-line wording change got no spec in either configuration.
- **Both specs were strong on content.** Both had London summer and winter boundaries, retries, simultaneous orders, and the observation that only the end date would have stopped last month's incident.

## Cost

About 60 s and 14k more tokens for a full spec and plan, spent once per feature before building.

## Open items

- The requirement-numbering check is somewhat strict, since the no-skill spec traced numbered tests to success criteria instead.
- Not yet tested: a large multi-capability request (capability map), and an existing spec system in the repo (follow its format).
