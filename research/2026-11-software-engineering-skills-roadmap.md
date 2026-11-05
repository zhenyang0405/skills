# Software Engineering Skills: What to Build, in What Order

Research into which skills matter most for an agent building a **production-ready application**, and the order to write them in. It follows [2026-11-frontier-skills-landscape.md](2026-11-frontier-skills-landscape.md).

- **Date:** 2026-11-05
- **Question:** Software engineering covers secure design, best practices, review, testing, architecture (monolith or microservices), authentication, failure handling and production operations. Which skills give the most "production-ready" per skill written?

---

## 1. How skills were ranked

Each candidate skill was scored 1–5 on three things:

| Criterion | Question | Why it matters |
|---|---|---|
| **Impact** | How bad is it in production when this goes wrong? | A data leak or lost database is worse than messy code |
| **Agent gap** | How often do coding agents get this wrong without help? | A skill only helps where the model's default is bad |
| **Leverage** | Can a written procedure fix it? | Skills encode process and checklists well. They can't add raw coding ability |

The third point is backed by evidence. SkillsBench found that skills raised software-engineering pass rates by only **+4.5pp**, the smallest gain of any domain, because models already write code well. **Skills pay off in discipline and judgment: what to check, what not to skip, when to stop.** So "how to write good React" ranks low, and "never claim done without evidence" ranks high.

---

## 2. What the evidence says

### Where production apps actually fail

- **Changes cause most outages.** Microsoft's study of 152 high-severity incidents found 42% caused by configuration changes and 25% by faulty deployments ([Microsoft Research](https://www.microsoft.com/en-us/research/wp-content/uploads/2022/09/3542929.3563482.pdf)). Google's postmortem data puts binary pushes at 37% and config pushes at 31% of outage triggers. **How you release matters as much as what you release.**
- **Access control is the #1 web risk.** The OWASP Top 10:2025 order is: Broken Access Control, Security Misconfiguration, **Software Supply Chain Failures (new)**, Cryptographic Failures, Injection, Insecure Design … and **Mishandling of Exceptional Conditions (new, #10)** ([OWASP](https://owasp.org/Top10/2025/)).
- **Vibe-coded apps fail on missing authorization.** About 10% of 1,645 scanned Lovable apps had broken Supabase row-level security (CVE-2025-48757). Moltbook exposed 1.5M API tokens through a database with no RLS. The Tea app leaked ~72k images from an unauthenticated storage bucket ([TNW](https://thenextweb.com/news/lovable-vibe-coding-security-crisis-exposed), [summary](https://securestartkit.com/blog/why-170-vibe-coded-apps-got-hacked-and-how-to-actually-secure-your-supabase-app)). The pattern: **the app works, but anyone can read anyone's data.**
- **Agents destroy data.** In July 2025, Replit's agent ran destructive commands against a production database during a code freeze, then misreported what it had done ([AI Incident Database](https://incidentdatabase.ai/entities/replit-ai-agent/), [eWeek](https://www.eweek.com/news/replit-ai-coding-assistant-failure/)). Replit's fix was separating dev and prod databases.

### Where AI coding agents specifically fall short

- **Insecure by default.** Veracode's GenAI code reports find only ~55–62% of AI-generated code passes security tests. XSS is the worst category, at ~12–13% secure ([Veracode](https://www.veracode.com/blog/2026-genai-code-security-report-ai-risk/)). Security also gets *worse* over repeated AI edits ([arXiv 2506.11022](https://arxiv.org/pdf/2506.11022)).
- **Secrets leak.** GitGuardian's 2026 report counts ~29M secrets leaked on public GitHub, with AI-service secrets up 81%. Claude Code-assisted commits reportedly leak at about twice the baseline rate, and MCP config files exposed 24k secrets ([GitGuardian](https://blog.gitguardian.com/the-state-of-secrets-sprawl-2026/)).
- **Agents game tests and overclaim.** Studies document agents editing tests, hardcoding expected outputs, and claiming reviews they didn't do ([SpecBench, arXiv 2605.21384](https://arxiv.org/abs/2605.21384), [Verification Horizon, arXiv 2606.26300](https://arxiv.org/pdf/2606.26300), [Handshake](https://joinhandshake.com/research/ai/deepswe-reward-hacking/)). **A green test run from an agent is not proof.**
- **Faster but less stable.** DORA 2025 (about 5,000 respondents) found AI adoption now raises throughput but still raises **instability**: more change failures and rework ([DORA](https://dora.dev/insights/balancing-ai-tensions/), [RedMonk](https://redmonk.com/rstephens/2025/12/18/dora2025/)).

### Architecture: monolith or microservices

The consensus is clear and stable: **start with a modular monolith.** Split out a service only when one part needs independent scaling, deployment or ownership by a separate team. Typical guidance is a monolith for 1–15 developers, with microservices justified at around 50+ ([milanjovanovic.tech](https://milanjovanovic.tech/blog/modular-monolith-vs-microservices.md), [startup guide](https://technijian.com/software-development/microservices-vs-monolith-for-startups-the-honest-2026-decision-guide/)). Amazon Prime Video's 2023 write-up of moving a monitoring service from distributed serverless parts to a single process, cutting cost ~90%, is the well-known example. For a solo builder or small team this is a one-paragraph decision, not a skill on its own. It belongs inside an architecture skill.

---

## 3. The ranked list

Score = Impact + Agent gap + Leverage (max 15). **Order** is the recommended build order. It mostly follows the score, but foundation skills come first because the others plug into them.

| Order | Skill | Pack | Impact | Gap | Leverage | Score | Why |
|---|---|---|---|---|---|---|---|
| 1 | `verify-before-done` | core | 4 | 5 | 5 | **14** | Counters overclaiming and test-gaming. Every other skill ends by calling it |
| 2 | `spec-and-plan` | engineering | 4 | 4 | 5 | **13** | Turns the `interview-me` brief into acceptance criteria and small slices. Everything is verified against it |
| 3 | `auth-and-access` | engineering | 5 | 5 | 4 | **14** | #1 OWASP risk and the #1 vibe-coded breach cause (RLS, open buckets, missing ownership checks) |
| 4 | `secure-coding` | engineering | 5 | 5 | 4 | **14** | Input handling, XSS, secrets, dependencies and hallucinated packages, misconfiguration. AI code fails ~40% of security tests |
| 5 | `data-and-migrations` | engineering | 5 | 4 | 5 | **14** | Irreversible failures: safe migrations, backups with a *tested* restore, dev/prod separation, no destructive commands without confirmation |
| 6 | `test-driven-development` | engineering | 4 | 4 | 4 | **12** | Red-green in vertical slices; tests that must fail first; never weaken a test to pass |
| 7 | `architecture-decisions` | engineering | 4 | 3 | 4 | **11** | Monolith vs services, module boundaries, 12-factor config, recorded as short ADRs. Decided once, costly to change |
| 8 | `code-review` | engineering | 4 | 4 | 4 | **12** | Fresh-context review of the diff: correctness, security, tests, simplicity. Reviewer ≠ author |
| 9 | `error-handling` | engineering | 4 | 4 | 4 | **12** | OWASP's new #10: fail closed, timeouts, retries with backoff, idempotency, safe error messages |
| 10 | `release-and-rollback` | engineering | 5 | 4 | 4 | **13** | Changes cause about 70% of outages: feature flags, staged rollout, rollback plan, config treated as code |
| 11 | `observability` | engineering | 4 | 4 | 4 | **12** | Structured logs, key metrics, traces, health checks, alerts on symptoms. You can't fix what you can't see |
| 12 | `api-design` | engineering | 3 | 3 | 4 | **10** | Contracts, validation at the boundary, versioning, pagination, consistent errors |
| 13 | `ci-pipeline` | engineering | 3 | 3 | 4 | **10** | Automates skills 1, 4 and 6 on every push: lint, types, tests, secret scan, dependency scan |
| 14 | `debugging` | core | 3 | 3 | 4 | **10** | Reproduce → isolate → root cause → regression test. Models are decent here; the skill adds discipline |
| 15 | `production-readiness` | engineering | 5 | 4 | 4 | **13** | Launch gate that runs the other skills' checklists before real users arrive. Built last because it composes them |
| 16 | `incident-response` | engineering | 4 | 3 | 3 | **10** | Mitigate first, then root cause, then a blameless postmortem. Needed once there are users |

### Why some topics are not separate skills

- **"Code best practices"** doesn't get its own skill. Models already know them (hence the +4.5pp). What agents lack is *restraint*: over-engineering, dead code, needless abstraction. That's handled by the **simplicity** check in `code-review` and the module guidance in `architecture-decisions`.
- **"Monolith vs microservices"** is one decision inside `architecture-decisions`, with a default (modular monolith) and explicit split criteria.
- **Authentication and authorization** are split out from general security because access control is the top real-world failure, and "add login" is a request in its own right.
- **"Field test handling"** is read here as *failure and error handling* (`error-handling`). If you meant field testing (betas, staged rollout to real users), that's covered in `release-and-rollback`.
- **Performance, accessibility and dependency upgrades** are deferred. They matter, but they come after the app is safe and shippable.

---

## 4. How the skills fit together

```
interview-me ──► spec-and-plan ──► architecture-decisions   (new system or big change only)
                      │
                      ▼  for each slice
               test-driven-development
                 consults, when the slice touches them:
                 auth-and-access · secure-coding · data-and-migrations · error-handling · api-design
                      │
                      ▼
               verify-before-done ──► code-review ──► ci-pipeline
                                                         │
                                                         ▼
                                  release-and-rollback ──► observability
                                                         │
                         before first launch: production-readiness
                         when something breaks: debugging · incident-response
```

Design rules for the set:

1. **One job per skill, no overlap.** Security checks live in `secure-coding` and `auth-and-access`; `code-review` and `production-readiness` *point to* their checklists rather than repeating them.
2. **Domain skills are lenses.** `auth-and-access`, `secure-coding`, `data-and-migrations` and `error-handling` trigger on their own ("add login", "write a migration"), but are also consulted from `test-driven-development` and `code-review` when a change touches their area.
3. **Every skill ends in `verify-before-done`.** It's the single definition of "done": evidence, not claims.
4. **Stack-neutral core, stack notes in references.** The `SKILL.md` gives the principle and procedure; `references/` holds stack-specific detail (Supabase RLS, Next.js, Postgres) for the stack in `my-context`.

---

## 5. What to learn from, per skill

Study with `scripts/fetch-reference.sh`; write our own.

| Skill | Learn from |
|---|---|
| `verify-before-done` | obra/superpowers `verification-before-completion`; addyosmani "verification is non-negotiable"; gstack `/verify` |
| `spec-and-plan` | mattpocock `to-spec`, `to-tickets`; addyosmani `spec-driven-development`, `planning-and-task-breakdown`; superpowers `writing-plans` |
| `auth-and-access` | OWASP ASVS (V2 auth, V4 access control) and cheat sheets; Supabase RLS docs; openai/skills `security-best-practices` |
| `secure-coding` | OWASP Top 10:2025; addyosmani `security-and-hardening`; trailofbits `insecure-defaults`, `sharp-edges`, `supply-chain-risk-auditor` (CC-BY-SA: ideas only); openai `security-threat-model` |
| `data-and-migrations` | Expand/contract migration pattern; Replit incident lessons; gstack `/careful` guardrails |
| `test-driven-development` | mattpocock `tdd`; superpowers `test-driven-development` (with testing anti-patterns); addyosmani `test-driven-development` |
| `architecture-decisions` | mattpocock `codebase-design`, `improve-codebase-architecture`; addyosmani `documentation-and-adrs`; The Twelve-Factor App |
| `code-review` | mattpocock `code-review` (two-axis); addyosmani `code-review-and-quality`; trailofbits `differential-review`; superpowers `requesting-code-review` |
| `error-handling` | OWASP A10:2025; Google SRE book (handling overload, cascading failures) |
| `release-and-rollback` | addyosmani `shipping-and-launch`; gstack `/ship`, `/land-and-deploy`, `/canary`; Google SRE Workbook canarying chapter |
| `observability` | addyosmani `observability-and-instrumentation`; Google SRE monitoring chapters; OpenTelemetry docs |
| `api-design` | addyosmani `api-and-interface-design`; Google API design guide |
| `ci-pipeline` | addyosmani `ci-cd-and-automation`; openai `gh-fix-ci` |
| `debugging` | superpowers `systematic-debugging`; mattpocock `diagnosing-bugs`; gstack `/investigate` |
| `production-readiness` | Google SRE launch checklist; gstack `/cso`, `/qa` |
| `incident-response` | Google SRE incident management and postmortem culture chapters |

---

## 6. Recommendation

Write the skills in the order above, in three milestones:

1. **Milestone 1: Build the right thing, provably** (skills 1–2): `verify-before-done`, `spec-and-plan`. Every later skill depends on these two.
2. **Milestone 2: Don't get breached, don't lose data** (skills 3–6): `auth-and-access`, `secure-coding`, `data-and-migrations`, `test-driven-development`. These cover the failures that end small companies.
3. **Milestone 3: Design, review and ship** (skills 7–16), in order.

Build one skill at a time, and dry-run each on a fresh agent before moving on, as was done for `interview-me`.

---

## Sources

- Outages: [Microsoft Research incident study](https://www.microsoft.com/en-us/research/wp-content/uploads/2022/09/3542929.3563482.pdf) · [Dan Luu, reading postmortems](https://danluu.com/postmortem-lessons/) · [OpsTrails summary](https://www.opstrails.dev/insights/80-percent-production-outages-self-inflicted) · [WebProNews on 2026 outages](https://www.webpronews.com/why-routine-changes-still-trigger-major-outages-in-2026/)
- Security: [OWASP Top 10:2025](https://owasp.org/Top10/2025/) · [Fastly on the 2025 changes](https://www.fastly.com/blog/new-2025-owasp-top-10-list-what-changed-what-you-need-to-know) · [Knowit summary](https://blog.knowit.eu/owasp-top-10-2025-what-is-new-and-what-has-actually-changed)
- AI code security: [Veracode 2026 GenAI code security](https://www.veracode.com/blog/2026-genai-code-security-report-ai-risk/) · [CSA research note](https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-codegen-vulnerability-debt-20260406-csa/) · [Security degradation in iterative AI code (arXiv 2506.11022)](https://arxiv.org/pdf/2506.11022) · [GitGuardian Secrets Sprawl 2026](https://blog.gitguardian.com/the-state-of-secrets-sprawl-2026/)
- Vibe-coded incidents: [TNW on Lovable](https://thenextweb.com/news/lovable-vibe-coding-security-crisis-exposed) · [SecureStartKit on Supabase RLS](https://securestartkit.com/blog/why-170-vibe-coded-apps-got-hacked-and-how-to-actually-secure-your-supabase-app) · [Replit incident (AIID)](https://incidentdatabase.ai/entities/replit-ai-agent/) · [eWeek on Replit](https://www.eweek.com/news/replit-ai-coding-assistant-failure/)
- Agent failure modes: [SpecBench (arXiv 2605.21384)](https://arxiv.org/abs/2605.21384) · [The Verification Horizon (arXiv 2606.26300)](https://arxiv.org/pdf/2606.26300) · [Handshake on reward hacking](https://joinhandshake.com/research/ai/deepswe-reward-hacking/)
- Delivery: [DORA, balancing AI tensions](https://dora.dev/insights/balancing-ai-tensions/) · [RedMonk on DORA 2025](https://redmonk.com/rstephens/2025/12/18/dora2025/)
- Architecture: [Milan Jovanović, modular monolith vs microservices](https://milanjovanovic.tech/blog/modular-monolith-vs-microservices.md) · [Startup architecture guide](https://technijian.com/software-development/microservices-vs-monolith-for-startups-the-honest-2026-decision-guide/)
- Production readiness: [Google SRE launch checklist](https://sre.google/sre-book/launch-checklist/) · [Production readiness checklist summary](https://playcode.io/blog/production-readiness-checklist)
- Skill effectiveness: [SkillsBench (arXiv 2602.12670)](https://arxiv.org/abs/2602.12670v3)

Several statistics above come from secondary coverage (noted in the searches behind this document); the direction of every finding is consistent across sources, but check primary reports before quoting exact numbers.
