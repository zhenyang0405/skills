# Frontier Agent Skills: State of the Ecosystem (Nov 2026)

Research into which agent skills are currently leading for **startup building**, **software engineering**, and **AI engineering**. It is the groundwork for building a personal skills repository that agents can load.

- **Date:** 2026-11-04
- **Method:** web search, the GitHub search API (star counts, last push, license), and a read of each key repo's README to get its actual skill list.
- **Star counts** are a snapshot from the GitHub API on the date above. They show popularity, not quality.

---

## 1. Key findings

1. **SKILL.md is now the cross-agent standard.** Anthropic released Agent Skills as an open spec (agentskills.io) in Dec 2025. Claude Code, Codex, Gemini CLI, Cursor, Copilot, OpenCode and others now load the same `SKILL.md` folders. One repo can serve every agent you use.
2. **The best skills are workflows, not reference docs.** The most popular repos (Superpowers, Matt Pocock, Addy Osmani, gstack) all follow one loop: *interview → spec → plan/tickets → TDD in thin slices → verify with evidence → independent review → ship*. Each skill has steps, checkpoints and exit criteria.
3. **Vendors now publish official skills.** Anthropic, OpenAI, Vercel, Cloudflare, Supabase, Hugging Face, LangChain, Langfuse, Stripe and Trail of Bits each maintain skills for their own stack. For anything vendor-specific, use these rather than community copies.
4. **Evidence says: curate, keep skills focused, and don't trust self-written ones blindly.** SkillsBench (arXiv 2602.12670) reports that curated skills raised pass rates by +16.2pp on average. Skills the model wrote for itself averaged −1.3pp. Focused skills with 2–3 modules beat large documentation dumps. Gains vary a lot by domain, and 16 of 84 tasks got worse.
5. **Supply-chain risk is real.** Snyk's *ToxicSkills* audit (Feb 2026, ~4k skills from ClawHub and skills.sh) found prompt-injection problems in about 36% of skills and confirmed malicious payloads. Koi Security's *ClawHavoc* report found 341 malicious ClawHub skills. Trail of Bits later bypassed most skill scanners. **Pin, read and vendor every skill you adopt. Never auto-install from marketplaces.**

---

## 2. How the ecosystem works

| Piece | What it is | Notes |
|---|---|---|
| Spec | [agentskills.io](https://agentskills.io), [anthropics/skills/spec](https://github.com/anthropics/skills) | A folder holding `SKILL.md` (YAML frontmatter with `name` and `description`, plus instructions), with optional `scripts/`, `references/` and `assets/` |
| Progressive disclosure | Only `name` and `description` sit in context. The body loads when the skill triggers, and references load on demand | This is why short, sharp **descriptions** matter most: they decide when a skill fires |
| Installer CLI | [`vercel-labs/skills`](https://github.com/vercel-labs/skills) (★38k), run as `npx skills add owner/repo` | Works across agents. Directory at skills.sh |
| Plugin marketplaces | Claude Code `/plugin marketplace add …`, [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) (★46k), Codex marketplace | Plugins bundle skills, slash commands, subagents, hooks and MCP servers |
| Indexes | [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) (★37k, 1000+ skills), [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) (★79k), [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) (★57k) | Good for finding skills. Quality varies widely |

---

## 3. Software engineering: the frontier

### 3.1 Methodology frameworks (the core of any personal repo)

| Repo | ★ | License | What makes it frontier |
|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | 312k | MIT | The original "skills as dev methodology" framework. Skills: `brainstorming`, `writing-plans`, `executing-plans`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `subagent-driven-development` (fresh subagent per task, two-stage review: spec compliance, then quality), `dispatching-parallel-agents`, `using-git-worktrees`, `requesting-/receiving-code-review`, `finishing-a-development-branch`, `writing-skills` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 312k | MIT | "Skills for real engineers." `grill-me`/`grilling` (relentless interview before building), `grill-with-docs` (builds a domain glossary), `to-spec` → `to-tickets` (tracer-bullet tickets with blocking edges) → `implement`/`implement-spec`, `tdd`, `diagnosing-bugs`, `improve-codebase-architecture` (deep modules), `codebase-design`, `domain-modeling`, `prototype`, `research` (cited primary sources), `wayfinder` (multi-session planning), `handoff`, `retro`, `writing-for-agents`, `teach` |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 113k | MIT | 25 skills mapped to the SDLC (Define → Plan → Build → Verify → Review → Ship). Every skill has an **anti-rationalization table** (excuses agents use to skip steps, with rebuttals) and **mandatory evidence**. Includes `interview-me`, `spec-driven-development`, `constraint-driven-development`, `doubt-driven-development` (adversarial fresh-context review), `source-driven-development` (cite official docs), `context-engineering`, `security-and-hardening`, `observability-and-instrumentation`, `shipping-and-launch`, `documentation-and-adrs` |
| [garrytan/gstack](https://github.com/garrytan/gstack) | 139k | MIT | Role-based "virtual team" from YC's CEO: `/office-hours` (YC-style forcing questions), `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/autoplan`, `/review`, `/investigate`, `/qa`, `/cso` (security), `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/retro`, `/eval-plan`, plus safety guards `/careful` `/freeze` `/guard` and a `/codex` second-opinion reviewer. Heavier and more opinionated; ships its own browser tooling |

**Frontier patterns these share (worth copying into your own skills):**
- **Interview before code.** Agents ask clarifying questions one at a time until intent is clear (grill-me, interview-me, brainstorming, office-hours).
- **Spec → tickets → vertical slices.** Small, testable, independently mergeable steps.
- **TDD as the feedback loop** for agents, not only for humans.
- **Verification before completion.** "Seems right" is never accepted; the agent must show test or build output.
- **Fresh-context adversarial review.** A different subagent (or a different model) reviews the work: two-stage review, doubt-driven dev, `/codex` second opinion.
- **Parallelism with isolation.** Git worktrees plus subagent dispatch.
- **Session continuity.** Handoff documents, retros that improve the agent's own environment, memory/learn skills.
- **Safety rails.** Guards against destructive commands and limits on which directories the agent may edit.

### 3.2 Official vendor and stack skills

| Repo | ★ | Highlights |
|---|---|---|
| [anthropics/skills](https://github.com/anthropics/skills) | 187k | `skill-creator`, `mcp-builder`, `claude-api`, `webapp-testing`, `frontend-design`, `web-artifacts-builder`, `doc-coauthoring`, `docx`/`pdf`/`pptx`/`xlsx`, `brand-guidelines`, `internal-comms`. ⚠ The document skills are source-available, not open source. Check each skill's license |
| [openai/skills](https://github.com/openai/skills) | 29k | Curated for Codex: `gh-fix-ci`, `gh-address-comments`, `security-threat-model`, `security-best-practices`, `playwright`, `sentry`, `linear`, `notion-spec-to-implementation`, `cli-creator`, deploy skills (Vercel/Netlify/Render/Cloudflare), `define-goal` |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | 34k | `react-best-practices`, `composition-patterns`, `web-design-guidelines`, `react-native-guidelines`, `react-view-transitions`, `vercel-optimize`, `deploy-to-vercel` |
| [cloudflare/skills](https://github.com/cloudflare/skills) | 3k | Workers, D1, R2, KV, Durable Objects (Apache-2.0) |
| [supabase/agent-skills](https://github.com/supabase/agent-skills) | 3k | Supabase/Postgres usage (MIT) |
| Stripe | – | Published via `stripe/ai` (sources disagree on the exact path; check before use) |

### 3.3 Security and code quality

| Repo | ★ | Highlights |
|---|---|---|
| [trailofbits/skills](https://github.com/trailofbits/skills) | 8k | Professional audit workflows: `differential-review`, `static-analysis` (CodeQL/Semgrep/SARIF), `semgrep-rule-creator`, `variant-analysis`, `supply-chain-risk-auditor`, `insecure-defaults`, `sharp-edges`, `property-based-testing`, `mutation-testing`, `fp-check`, `agentic-actions-auditor` (GitHub Actions + AI), smart-contract kits. ⚠ **CC-BY-SA-4.0** (share-alike) |
| [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) | 58k | Multi-phase audit with **machine-readable findings + validators**. Design rule: the checker is never the finder. Severity requires real impact |

### 3.4 Frontend and design taste

| Repo | ★ | Highlights |
|---|---|---|
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | 102k | Design vocabulary for coding agents: critique, audit, polish, "catch AI slop" |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 145k | Design intelligence for UI/UX across platforms |
| `anthropics/skills/frontend-design` | – | Anthropic's anti-generic-UI skill |

---

## 4. AI engineering: the frontier

| Repo | ★ | What it covers |
|---|---|---|
| [muratcankoylan/Agent-Skills-for-Context-Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering) | 18k | The most complete agent-architecture set: `context-fundamentals`, `context-degradation` (lost-in-middle, poisoning), `context-compression`, `context-optimization` (caching, masking), `multi-agent-patterns`, `memory-systems`, `tool-design`, `filesystem-context`, `long-horizon-prompting`, `hosted-agents`, `harness-engineering`, `self-improvement-loops`, `evaluation`, `advanced-evaluation` (LLM-as-judge) |
| [hamelsmu/evals-skills](https://github.com/hamelsmu/evals-skills) | 2k | Practical evals from Hamel Husain's evals course: `error-analysis` (read traces, categorize failures), `generate-synthetic-data`, `write-judge-prompt`, `validate-evaluator` (TPR/TNR against human labels), `evaluate-rag`, `build-review-interface`, `eval-audit`. **Highest signal-to-size ratio in this list** |
| [huggingface/skills](https://github.com/huggingface/skills) | 11k | Model work: `huggingface-llm-trainer` / `trl-training` (SFT, DPO, GRPO; TRL or Unsloth on HF Jobs), `huggingface-community-evals` (inspect-ai, lighteval), `train-sentence-transformers` (embeddings), `huggingface-local-models` (llama.cpp/GGUF), `hf-mem` (VRAM estimates), `huggingface-best` (model selection), `huggingface-gradio`/`-spaces`, `huggingface-papers`, SageMaker deployment set |
| [langchain-ai/langchain-skills](https://github.com/langchain-ai/langchain-skills) | 1k | Official LangChain/LangGraph/Deep Agents skills: `ecosystem-primer`, `langchain-rag`, `langgraph-persistence`, `langgraph-human-in-the-loop`, `deep-agents-memory`/`-orchestration`, `eval-engineering` |
| [langfuse/skills](https://github.com/langfuse/skills) | <1k | Tracing, prompt management, evaluation on Langfuse |
| `anthropics/skills`: `claude-api`, `mcp-builder`, `skill-creator` | – | Building on the Claude API, building MCP servers, and writing and evaluating skills |
| gstack `/eval-plan` | – | Pre-register a paid eval (bars, arms, stop rules, $0 dry run) before spending |

**Frontier themes in AI engineering skills:**
- **Context engineering** has replaced "prompt engineering" as the core discipline: compaction, memory, filesystem-as-context, sub-agent isolation, and keeping tool surfaces small.
- **Eval-driven development.** Start from error analysis of real traces, then build judges, then calibrate the judges against human labels.
- **Harness engineering.** The loop around the model (metrics, logs, rollbacks, novelty gates) is now treated as the thing to optimize.
- **Long-horizon / background agents.** Writing launch briefs for agents that run for hours in sandboxes.

---

## 5. Startup building: the frontier

### 5.1 Strategy, validation and product

| Repo | ★ | Highlights |
|---|---|---|
| gstack `/office-hours`, `/plan-ceo-review` | – | YC-style idea interrogation ("find the 10-star product"). Probably the best-known founder skill today |
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | 28k | 100+ PM skills: `identify-assumptions-new`, `prioritize-assumptions`, `brainstorm-experiments-new` (pretotyping), `opportunity-solution-tree`, `interview-script` (JTBD), `summarize-interview`, `lean-canvas`, `startup-canvas`, `value-proposition`, `monetization-strategy`, `metrics-dashboard` (North Star) |
| [deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills) | 8k | Grounded in named methods: `problem-framing-canvas`, `positioning-statement` (Geoffrey Moore), `discovery-interview-prep` (Mom Test), `press-release` (Amazon Working Backwards), `tam-sam-som-calculator`, `business-health-diagnostic` (SaaS metrics), `prd-development`, `competitive-analysis-process` |
| [ferdinandobons/startup-skill](https://github.com/ferdinandobons/startup-skill) | 1k | Four deep skills: `startup-design`, `startup-competitors` (battle cards), `startup-positioning` (April Dunford), `startup-pitch` |

### 5.2 Go-to-market, sales and growth

| Repo | ★ | Highlights |
|---|---|---|
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | 58k | The leading marketing set: `cro`, `copywriting`, `ai-seo` (getting cited by LLMs), `launch`, `onboarding`, `paywalls`, `churn-prevention`, `cold-email`, `emails`, `ab-testing`, `analytics`, `attribution`, `offers`, `competitors`, `directory-submissions`, `marketing-psychology` |
| [zapier/gtm-cheat-codes](https://github.com/zapier/gtm-cheat-codes) | <1k | GTM team playbooks for coding agents |

### 5.3 Founder all-in-one bundles

| Repo | ★ | Highlights |
|---|---|---|
| [shawnpang/startup-founder-skills](https://github.com/shawnpang/startup-founder-skills) | <1k | Broadest coverage. A `startup-context` foundation skill that every other skill reads (**a great pattern to copy**), plus `pitch-deck`, `investor-research`, `data-room`, `fundraising-email`, `accelerator-application`, `mvp-scoping`, `review-mining`, `job-description`, `terms-of-service`, `contract-review`. Many are adapted from the repos above |
| [lool-ventures/founder-skills](https://github.com/lool-ventures/founder-skills) | <1k | VC-built coaching: market sizing, pitch-deck review, financial-model review, **IC (investment committee) simulation**, cap-table modelling |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | 29k | 400+ skills across engineering, PM, marketing and C-level. Broad but uneven; better to cherry-pick than install wholesale |

**Observation:** the founder space is less mature than engineering. Repos are smaller and mostly prompt templates without verification steps. Fundraising, finance and legal skills especially need your own judgment layered on top. This is where your personal repo can add the most value.

---

## 6. Risks and how to curate safely

| Risk | Evidence | Mitigation in your repo |
|---|---|---|
| Malicious skills | Snyk ToxicSkills (Feb 2026); Koi ClawHavoc (341 malicious ClawHub skills); Trail of Bits bypassed 3 of 4 skill scanners | Vendor copies at a pinned commit; read every `SKILL.md` and script; no `curl \| sh` installers |
| Prompt injection in instructions | About 36% of audited skills had injection-style flaws (Snyk) | Review descriptions and bodies for hidden instructions; run a scanner as a second check, not a replacement: [NVIDIA/SkillSpector](https://github.com/NVIDIA/SkillSpector), [snyk/agent-scan](https://github.com/snyk/agent-scan), [cisco-ai-defense/skill-scanner](https://github.com/cisco-ai-defense/skill-scanner) |
| Skills that make results worse | SkillsBench: 16 of 84 tasks regressed; self-generated skills ≈ −1.3pp; "Agent Skills Can Be Harmful" (arXiv 2608.11888) | Keep skills focused; avoid overlapping skills that fight each other; eval your own skills (`skill-creator` / Superpowers `writing-skills` include testing methods) |
| Context bloat | Every installed skill's description costs tokens and competes for triggering | Install a curated core and enable packs per project, rather than 1000 skills globally |
| Licenses | Trail of Bits is CC-BY-SA (share-alike); Anthropic's document skills are source-available; some repos have no license | Track license per vendored skill; link instead of copying where unclear |

---

## 7. Recommendations for your repository

### 7.1 Suggested starter shortlist

**Core (always on, any project)**
- Workflow: pick **one** primary methodology to avoid conflicting instructions. Either `mattpocock/skills` (lean, modular) or `obra/superpowers` (fuller pipeline); add `addyosmani/agent-skills` pieces à la carte.
- `grill-me` / `interview-me`, `tdd`, `systematic-debugging` / `diagnosing-bugs`, `verification-before-completion`, `handoff`, `research`
- `anthropics/skills/skill-creator` (to write and test your own skills)

**Software engineering pack**
- `improve-codebase-architecture`, `code-review` (two-axis), `doubt-driven-development`, `security-and-hardening`, `openai/gh-fix-ci`, `trailofbits/differential-review`, `cloudflare/security-audit-skill`
- Stack-specific official skills only for stacks you actually use (Vercel/React, Supabase, Cloudflare, Stripe)

**AI engineering pack**
- `hamelsmu/evals-skills` (all of them), context-engineering set (`context-optimization`, `multi-agent-patterns`, `memory-systems`, `tool-design`, `harness-engineering`), `claude-api`, `mcp-builder`, HF `llm-trainer` + `community-evals` when you fine-tune

**Startup pack**
- gstack `office-hours` + `plan-ceo-review` (or a slimmed-down port), a `startup-context` foundation skill (pattern from shawnpang), `identify-assumptions` + `opportunity-solution-tree` (phuryn), Mom-Test interview prep and positioning (deanpeters), `marketingskills` `launch`, `cro`, `copywriting`, `ai-seo`, `cold-email`, and the lool-ventures pitch/financial-model reviewers

### 7.2 Suggested repo design (to discuss before building)

```
skills/
  core/            # your always-on workflow skills (own or adapted)
  engineering/
  ai-engineering/
  startup/
  personal/        # life admin, learning, writing, health, finance
vendor/            # third-party skills pinned at a commit (or git submodules), with SOURCES.md
context/           # foundation files skills read: about-me.md, startup-context.md, stack.md
evals/             # small tests that prove a skill helps
README.md          # index + install instructions for each agent (Claude Code, Codex, Cursor…)
```

Design principles drawn from the research:
1. **Foundation context files** (who you are, your stack, your startup) that other skills read. This is the shawnpang `startup-context` and Matt Pocock `setup` pattern.
2. **Process with exit criteria and evidence**, plus anti-rationalization tables (Addy Osmani pattern).
3. **One methodology, not three.** Overlapping workflow skills compete with each other.
4. **Pin and record sources** (repo, commit, license) for anything third-party.
5. **Keep descriptions sharp** and bodies under ~500 lines; push detail into `references/`.
6. Make it installable as both a **Claude Code plugin marketplace** and via **`npx skills add`**, so any agent can use it.

### 7.3 Open questions for the next step
- Which agents will you link this to (Claude Code, Codex, Cursor, others)? This decides the packaging.
- Vendor (copy and pin) or reference (install from upstream)? Copying is safer and more stable; referencing gets updates automatically.
- Your main stack (languages, frameworks, cloud), so the stack-specific packs can be chosen.
- What "personal life" covers for you (e.g. learning, writing, finance, health, job search). Those weren't part of this research pass.

---

## Sources

- Ecosystem: [agentskills.io](https://agentskills.io) · [Firecrawl: Agent Skills explained](https://www.firecrawl.dev/blog/agent-skills) · [Virtual Uncle: skills.sh guide](https://virtualuncle.com/agent-skills-marketplace-skills-sh-2026/) · [Cloudflare agent skills docs](https://developers.cloudflare.com/agents/concepts/agent-skills/) · [Firecrawl: best Claude Code skills](https://www.firecrawl.dev/blog/best-claude-code-skills)
- Repos: all GitHub links in the tables above (READMEs read 2026-11-04)
- Evidence: [SkillsBench (arXiv 2602.12670)](https://arxiv.org/abs/2602.12670v3) · [HF paper page](https://huggingface.co/papers/2602.12670) · [SkillsBench review](https://evaluatingevals.substack.com/p/skillsbench-review) · [SoK: Agentic Skills (arXiv 2602.20867)](https://arxiv.org/pdf/2602.20867) · [Agent Skills Can Be Harmful (arXiv 2608.11888)](https://arxiv.org/pdf/2608.11888)
- Security: [Snyk ToxicSkills](https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub/) · [The Hacker News: 341 malicious ClawHub skills](https://thehackernews.com/2026/02/researchers-find-341-malicious-clawhub.html) · [CSA: skill scanners bypassed](https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-agent-skill-scanner-bypass-20260610-csa/) · [CSA: SKILL.md context poisoning](https://labs.cloudsecurityalliance.org/research/csa-research-note-skill-md-agent-context-poisoning-20260506/) · [Unit 42: OpenClaw supply chain](https://unit42.paloaltonetworks.com/openclaw-ai-supply-chain-risk/) · [OWASP Agentic Skills Top 10](https://github.com/OWASP/www-project-agentic-skills-top-10)
- gstack coverage: [Augment Code](https://www.augmentcode.com/learn/garry-tan-gstack-hits-89.7K-stars) · Matt Pocock install stats: [skills.sh](https://www.skills.sh/mattpocock/skills)
