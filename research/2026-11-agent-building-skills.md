# Skills for Building Agents: What AI Engineers Need (Nov 2026)

What does a coding agent (Claude Code, Codex, Cursor and others) need to know when an AI engineer asks it to **build an agent or agentic system**? Which of those needs do existing skills already meet, and which skills should the `ai-engineering` pack add?

- **Date:** 2026-11-05
- **Method:** two research passes.
  1. Best practice and failure modes for building agents, from primary sources: Anthropic, OpenAI, Google, LangChain, the MCP spec, OWASP, OTel, and evals and security practitioners.
  2. A survey of 22 skill repos. The `SKILL.md` bodies were read, not just the READMEs. Each was fetched with `scripts/fetch-reference.sh` into `.reference/`.
- **Builds on:** [2026-11-frontier-skills-landscape.md](2026-11-frontier-skills-landscape.md), section 4.
- **Confidence:** **[C]** marks well-established consensus. **[E]** marks emerging or contested views.
- **Unverified sources:** three were not re-checked this session because their sites were blocked: modelcontextprotocol.io (the MCP changelog was read from GitHub instead), cognition.ai and manus.im. Treat claims from them as unverified.

---

## 1. Key findings

1. **What goes wrong is judgment, not code.** Coding agents can already write the loop, the tool schemas and the SDK calls. The usual failures are design choices:
   - building an agent where a fixed workflow would do,
   - building many agents where one would do,
   - having no evals,
   - designing tools like API endpoints,
   - combining private data, untrusted input and an exfiltration channel,
   - unbounded loops.

   Skills should encode these **decisions and checks**, not API reference.
2. **Evals are well covered. Everything after the prototype is not.** Hamel Husain's evals skills and their successors are best in class. Security design, production reliability, vendor-neutral tracing, human-in-the-loop, and agent UX have almost no framework-neutral skill, only vendor references.
3. **Existing skills defend the wrong agent.** The security skills that exist (BridgeWard, agent-security) protect the *coding agent* from injection. No skill helps design a *secure agent for the user*: trifecta analysis per tool combination, a permission matrix, untrusted-content isolation, and injection tests in the eval set. This is the biggest gap with the highest value.
4. **Every vendor routes to its own stack.** `claude-api`, LangChain, Google `agents-cli`, Pydantic, CrewAI and Vercel each answer "how do I build an agent" with their own framework. There is room for **one provider-neutral layer** that makes the design decisions, then hands off to the vendor skill or docs for the API.
5. **Training data is stale on protocols and SDKs.** MCP's 2026-07-28 revision is stateless:
   - no `initialize` handshake and no session ID,
   - a new `server/discover` call,
   - Sampling, Roots and Logging deprecated,
   - OAuth Dynamic Client Registration replaced by Client ID Metadata Documents.

   Agent SDKs ship breaking changes every few months. Every skill in the pack needs a "check the current docs and installed version first" step. Vercel's `use-ai-sdk` does this well: read the version-matched docs in `node_modules`.
6. **Don't duplicate what's already installed.** Claude Code ships `claude-api` (agent design, evals, prompt audit and cost for Claude), `mcp-builder` (MCP server scaffolding with a 10-question eval) and `skill-creator`. This user also has `engineering:system-design`, `engineering:testing-strategy` and `security-review`. Our pack must stay provider-neutral, hand off to `claude-api` when the provider is Claude, and avoid stealing its triggers.

---

## 2. What building agents actually needs

Twelve areas. Each lists core practice and the mistakes coding agents tend to make.

### 2.1 Architecture choice
- **[C] Climb the ladder and stop at the lowest rung that works:**
  1. a single LLM call,
  2. retrieval plus tools,
  3. a fixed workflow (chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer),
  4. an autonomous agent.

  Use an agent only for open-ended tasks where you can't predict the steps and mistakes are tolerable. ([Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents))
- **[C] Start with one agent.** Split only when its tools or instructions become unmanageable. ([OpenAI: A practical guide to building agents](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf))
- **[C] Multi-agent setups pay off for broad, parallel, read-heavy work** like research, at roughly 15× the tokens of chat. Tightly coupled work with shared writes (most coding) favours a single thread. ([Anthropic: multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system))
- **[E] Coordinator plus isolated workers is now a working pattern.** Cognition has softened its 2025 "Don't build multi-agents" stance (unverified, see the header). Anthropic's long-running harness splits work into planner, generator and a separate skeptical evaluator, and agrees on "what done means" before coding. ([harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps))
- **Mistakes:**
  - role-play teams (PM/dev/QA agents) that don't share context,
  - framework abstractions nobody can see through,
  - scaffolding kept long after a better model made it unnecessary.

  MAST's failure taxonomy has 14 modes in three groups: specification, inter-agent misalignment, and verification/termination. ([arXiv 2503.13657](https://arxiv.org/abs/2503.13657))

### 2.2 Tool design (the agent-computer interface)
- **[C] Keep tools few and high-leverage, with no overlap.**
  - Build a few consolidated tools, not one per endpoint: `search_contacts`, not `list_contacts`.
  - Namespace them by service.
  - Return readable fields (names, not UUIDs).
  - Support pagination, truncation and a concise/detailed switch.
  - Make errors say how to fix the call.
- **[C] Improve tools with evals.** Write descriptions as if for a new hire. Use strict schemas. Give examples only for complex tools. Iterate by running realistic multi-step tasks and reading the transcripts. ([Anthropic: Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents))
- **[C] Large catalogues need deferred loading or tool search.** Use this at 10+ tools or about 10k tokens of definitions. Use code-mode / programmatic tool calling for chains of dependent calls. ([advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use), [code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp))
- **Mistakes:**
  - auto-wrapping an OpenAPI spec,
  - raw JSON dumps,
  - 50 tools loaded up front,
  - stack-trace errors,
  - never testing tools with the model that will use them.

### 2.3 Context engineering
- **[C] Use the smallest set of high-signal tokens.** Recall degrades as context grows ("context rot"). Pitch system prompts at the right altitude: start minimal and add rules only for failures you have seen. ([Anthropic: Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), [Chroma: context rot](https://research.trychroma.com/context-rot))
- **[C] Retrieve just in time.** Keep references and load on demand. Treat the filesystem as memory: notes, todo and progress files.
- **[C] Long runs need explicit techniques:**
  - compaction (clearing old tool results is safest),
  - structured notes,
  - sub-agents that return condensed summaries,
  - for multi-session work, an initializer that writes a feature list and progress file. ([effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents))
- **[C] Caching is an architecture constraint:**
  - a stable prefix (no timestamp at the top),
  - deterministic tool order,
  - append-only history,
  - mask tools rather than removing them,
  - keep errors visible in context. ([Manus lessons](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus), unverified)
- **Mistakes:**
  - stuffing context "just in case",
  - prefixes that break the cache,
  - summaries that drop decisions,
  - sub-agents that are under-briefed or that return their whole transcript.

### 2.4 Agent evals
- **[C] Start early with real tasks.** Use 20–50 tasks drawn from real failures, each with a reference solution and a grade two experts would agree on. A 0% pass rate usually means a broken task or grader. ([Anthropic: Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents))
- **[C] Grade the outcome**, meaning the final environment state, not what the agent says it did. Trajectory checks are a secondary signal. Don't demand one exact tool sequence.
- **[C] Error analysis comes before metrics:**
  1. Read about 100 traces.
  2. Open-code them.
  3. Cluster them into a failure taxonomy.
  4. Count.
  5. Then automate.

  Prefer graders in this order: code checks, then binary single-failure LLM judges calibrated against human labels (TPR/TNR), then humans. ([Hamel Husain: evals FAQ](https://hamel.dev/blog/posts/evals-faq/), [Shankar et al., "Who Validates the Validators?"](https://arxiv.org/abs/2404.12272))
- **[C] Keep two suites.**
  - Capability suite: low pass rate, drives improvement.
  - Regression suite: near 100%, runs in CI.
  - Run several trials per task from clean state. Use pass^k for customer-facing agents.
- **[E] Infrastructure noise is material.** Resource limits alone moved Terminal-Bench 2.0 by 6 points, so treat differences under about 3 points with suspicion. Public benchmarks (Terminal-Bench 2.0, SWE-bench Pro, τ²-bench, OSWorld-Verified, GAIA2) help choose models. They are not your product eval. ([infrastructure noise](https://www.anthropic.com/engineering/infrastructure-noise))
- **Mistakes:**
  - "helpfulness 1–10" judges,
  - no human labels,
  - grading the final message,
  - one trial per task,
  - state leaking between trials,
  - graders the agent can game.

### 2.5 Observability and tracing
- **[C] Trace every run as a tree** (agent → model calls → tool calls). Record:
  - inputs and outputs (redacted where needed),
  - tool arguments and results,
  - tokens, cache hits, cost, latency,
  - model version and stop reason.
- **[C] Make trace review a routine** that feeds the eval set.
- **[E] OTel GenAI semantic conventions** define `invoke_agent`, `execute_tool` and `chat` spans, but are still in Development. They moved to `open-telemetry/semantic-conventions-genai` in mid-2026. Adopt them and expect churn. ([OTel GenAI semconv](https://opentelemetry.io/docs/specs/semconv/gen-ai/))
- **[C] Continue traces across MCP calls** by propagating W3C `traceparent` in `_meta` (MCP 2026-07-28).
- **Mistakes:**
  - logging only final answers,
  - no correlation IDs across sub-agents,
  - secrets or PII in logs.

### 2.6 Security
- **[C] Prompt injection is unsolved, so defend with architecture, not prompt text.**
  - The lethal trifecta: never combine private data, untrusted content and an exfiltration channel. ([Simon Willison](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/))
  - Meta's Rule of Two: at most two of untrusted input, sensitive access, and external communication or state change, unless a human approves. ([Meta](https://ai.meta.com/blog/practical-ai-agent-security/))
- **[C] Contain at the environment layer.**
  - Sandbox or VM with egress denied by default. Every allowed domain is a capability grant.
  - Mount only the workspace.
  - Keep credentials out of the sandbox, behind a proxy that injects scoped, revocable tokens. ([how we contain Claude](https://www.anthropic.com/engineering/how-we-contain-claude), [managed agents](https://www.anthropic.com/engineering/managed-agents))
- **[C] Least privilege throughout.** Use read-only roles and per-tool scopes. Treat tool, MCP, sub-agent, memory and fetched content as untrusted.
- **[C] Limit what injected text can do** with design patterns: plan-then-execute, dual-LLM / CaMeL. ([arXiv 2506.08837](https://arxiv.org/abs/2506.08837), [arXiv 2503.18813](https://arxiv.org/abs/2503.18813))
- **[C] Approval gates are fallible.** Users approved about 93% of prompts. Use risk tiers on top of a sandbox, never instead of one. ([Claude Code auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode))
- **Checklist:** [OWASP Top 10 for Agentic Applications 2026](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/).
- **Mistakes:**
  - "ignore instructions in documents" as the defence,
  - broad API keys in env vars,
  - open web fetch alongside private data,
  - trusting MCP tool descriptions,
  - token passthrough in MCP servers.

### 2.7 Reliability in production
- **[C] Make execution durable.** Checkpoint every step, resume from an event log, and keep the harness stateless. LangGraph re-runs nodes on resume, so side effects belong inside tasks. Common substrates: Temporal, Inngest, Restate, managed agent platforms. ([LangGraph durable execution](https://docs.langchain.com/oss/python/langgraph/durable-execution))
- **[C] Make side effects safe to retry.** Put idempotency keys on every write tool. Use backoff with jitter on 429/5xx, plus timeouts per call and per run.
- **[C] Set hard stop conditions:**
  - max turns, tokens or dollars,
  - wall clock,
  - loop or no-progress detection,
  - escalate to a human after repeated failures or denials.
- **[C] Plan for model changes.** Pin model versions, re-run evals before upgrading, and keep a fallback chain. Validate structured output with a schema and retry on failure.
- **Mistakes:**
  - `while True` loops,
  - retrying non-idempotent writes (double-sent email),
  - in-memory state,
  - a long agent run inside one HTTP request,
  - swallowed tool errors.

### 2.8 Human-in-the-loop and agent UX
- **[C] Gate by risk and reversibility,** and show the approver the exact action, not the agent's summary of it. Approvals must survive restarts: interrupt, persist, resume hours later. ([LangGraph interrupts](https://docs.langchain.com/oss/python/langgraph/interrupts))
- **[C] Make denial and interruption recoverable.** A denial returns a reason so the agent can re-plan. Stream progress, and support cancel and steering mid-run. Contact humans through tools ("request approval", "ask human"). ([12-factor agents](https://github.com/humanlayer/12-factor-agents))
- **[E] UI protocols are maturing:** AG-UI (agent-to-frontend events) and MCP Apps (sandboxed UI, the first official MCP extension).
- **Mistakes:**
  - one approval level for everything,
  - prompts that hide consequences,
  - blocking synchronously on a human,
  - no audit trail.

### 2.9 Protocols
- **[C] MCP is the agent-to-tool standard. [E] Its details just changed.** The 2026-07-28 revision:
  - is stateless,
  - adds multi-round-trip `input_required` results,
  - moves Tasks to an extension,
  - deprecates Sampling, Roots, Logging, HTTP+SSE and Dynamic Client Registration,
  - requires servers to validate token audience (RFC 8707) and never pass tokens through.

  MCP now sits under the Linux Foundation's Agentic AI Foundation. ([changelog](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/changelog.mdx))
- **[C/E] A2A v1.0 (stable, Linux Foundation)** is for opaque agent-to-agent calls across organisation or vendor boundaries. Inside one codebase, a function or sub-agent call is simpler. ([LF announcement](https://www.linuxfoundation.org/press/a2a-protocol-surpasses-150-organizations-lands-in-major-cloud-platforms-and-sees-enterprise-production-use-in-first-year))
- **[E] Others:** Agent Skills, AGENTS.md, AG-UI, and commerce protocols (AP2, ACP, UCP).

### 2.10 Memory and RAG
- **[C] Prefer agentic retrieval.** Give the agent search tools (grep, hybrid BM25 + vector, SQL) and let it iterate, rather than doing one top-k stuffing step. Classic RAG pipelines still fit when latency or cost matters. Evaluate retrieval separately (recall@k).
- **[C] Make memory inspectable.** Use files or rows the agent reads and writes through tools. Scope it per user or tenant, record provenance, support deletion, and scan it on load. It is an attack surface.
- **[E] Self-editing memory and "sleep-time" consolidation** are promising, but evals for them are immature.
- **Mistakes:**
  - a vector DB by default,
  - no retrieval eval,
  - cross-tenant leaks,
  - writing every turn to memory.

### 2.11 Models and cost
- **[C] Find the ceiling first, then move down.** Prototype on the most capable model. Then move sub-tasks (routing, extraction, summarising) to smaller models where *your* evals show parity.
- **[C] Use native structured outputs** for anything a machine reads. Prompted JSON is not structured output.
- **[C] Cost levers, in order:**
  1. cache hit rate,
  2. tokens per tool result,
  3. number of turns,
  4. smaller models for sub-tasks,
  5. batch APIs.

  Measure cost and latency per *successful task*.
- **[E] RL fine-tuning of small models** can approach frontier quality on narrow tool use, but only after environments and graders exist. Your eval harness becomes the RL environment.

### 2.12 Other areas
- **Computer-use and browser agents** have the highest injection exposure. Prefer an API or MCP tool over a GUI. Use isolated profiles and per-site permissions, and confirm sensitive actions.
- **Voice agents:**
  - Cascade (STT → LLM → TTS) for tool-heavy, auditable flows; speech-to-speech for latency.
  - Turn detection and barge-in are the hard parts.
- **Frameworks** churn fast: OpenAI Agents SDK, Claude Agent SDK / Managed Agents, Google ADK 2.x, LangGraph, Pydantic AI, Vercel AI SDK. Always check current docs.
- **Identity and multi-tenancy:** per-user OAuth delegation, agent identity and audit logs are now first-class concerns (OWASP ASI03).

---

## 3. Existing skills, and where they fall short

From the survey of 22 repos. All the repos worth learning from are MIT or Apache-2.0. Trail of Bits (CC-BY-SA) and NeoLabHQ (GPL) were skipped.

**Verdict key:** **W** = workflow with steps and exit criteria. **R** = reference dump. **T** = thin router.

| Area | Coverage | Best existing skills (verdict) | Gap our pack could fill |
|---|---|---|---|
| Evals | **Strong** | hamelsmu / ai-evals-course `error-analysis`, `write-judge-prompt`, `validate-evaluator` (W); braintrust `eval-library` release gates (W-lite); langchain `eval-engineering` (W, tied to Harbor); `claude-api` `build-eval` (W, Claude) | Framework-neutral **agent trajectory/task evals**: sandboxed environment, outcome verifier, multi-trial, simulated user |
| MCP server building | **Strong, built in** | `mcp-builder` (W), openai `chatgpt-apps` (W) | None. Don't rebuild. Point to `mcp-builder` |
| Architecture choice | Fragmented | google `agents-cli-workflow` (W, ADK only); DenisSergeevitch `agents-best-practices` (R); `claude-api` agent design (Claude only); langchain `ecosystem-primer` (T) | A **neutral** decision workflow (ladder, single vs multi, framework) that ends in an approved spec |
| Tool design | Concepts only | murat `tool-design` (R + checklist); `mcp-builder` 10-question eval | Audit the catalogue, then run an **agent-driven tool eval** and fix descriptions from failure traces |
| Context engineering | Concepts only | murat context-* set (R); `claude-api` (Claude) | A workflow: diagnose context rot or cache misses in *this* agent → fix → measure |
| Security of the agent being built | **Missing** | Only coding-agent defence (BridgeWard, agent-security) and vendor red-team (promptfoo, W) | **Trifecta per tool combination, permission matrix, isolation patterns, egress, injection cases added to evals** |
| Reliability / durable / cost | **Missing (neutral)** | swyx `ai-engineering` (W, pipelines); Temporal (R); `claude-api` `cost-optimize` (Claude) | Budgets, stop conditions, idempotent writes, checkpoint/resume, retry classes, crash tests |
| Tracing | Vendor-only | langfuse instrumentation (W, includes a self-audit loop); Logfire, Google (R) | Neutral OTel GenAI span tree, required fields, PII masking, "fetch your own trace and audit it" |
| Human-in-the-loop | Framework-only | langgraph `interrupt()`, crewAI `human_input` (R) | Neutral approval-gate design: which actions, what the approver sees, timeouts, audit record |
| Memory / RAG | Partial | murat `memory-systems` (R), `evaluate-rag` (W), mem0 (vendor) | Fold into architecture and evals; not worth its own skill yet |
| Model selection | Vendor-siloed | `claude-api`, `openai-docs`, `huggingface-best` (leaderboards) | Compare 2–3 candidates on *your* eval: quality/cost/latency frontier |
| Agent UX | **Missing** | – | Streaming, tool-activity display, interrupt and steer, approval UI, error states |
| A2A | **Missing** | Only toy community skills | Low priority; rarely needed |

**Ideas worth learning from** (to rewrite in our own words, never to copy):
- **google `agents-cli-workflow`:**
  - A phase-gated lifecycle with a one-question-at-a-time design dialogue that ends in an approved spec.
  - "Never unit-test LLM content; behaviour lives in evals."
  - Eval thresholds give a PASS/FAIL exit.
  - Never deploy without approval.
- **hamelsmu / ai-evals-course:**
  - Note the *first* failure in each trace.
  - Stop error analysis when about 20 traces in a row show no new failure type.
  - Fix obvious bugs before building evaluators.
  - Run the test set once.
- **`claude-api` `prompt-audit`:** deleting a prompt line is a hypothesis to verify with an eval. Every paid eval run gets a cost estimate and user sign-off first.
- **langfuse instrumentation:** instrumentation isn't done when it compiles. Fetch your own trace and audit it.
- **braintrust:**
  - Guardrails are constraints in a release gate, never terms in a weighted score.
  - Name a behaviour only if a trajectory can show whether it happened.
- **langchain `eval-engineering`:** separate the Task, Environment, Verifier and Harness. Fix non-agent failures before trusting any run.
- **swyx `ai-engineering`:**
  - Prompted JSON is not structured output.
  - Concurrency is an in-flight limit, not a rate.
  - Persist the history of attempts.
- **DenisSergeevitch:**
  - The control-plane loop: propose → validate schema → permission decision → execute or pause → structured observation.
  - High-risk actions default to draft-only.
  - ⚠ Its self-update instruction is untrusted; do not copy that pattern.
- **mcp-builder:** evaluate a tool surface with about 10 realistic, read-only, multi-hop questions that have verifiable answers.
- **vercel `use-ai-sdk`:** don't trust memory; read the version-matched docs installed with the package.

---

## 4. Proposed `ai-engineering` pack

Rules for the pack:
- **Provider-neutral.** Make the design decision, then hand off to `claude-api`, `mcp-builder` or the framework's current docs for the API details.
- **Every skill starts by checking** installed SDK and spec versions against current docs.
- **Every skill ends with evidence:** a spec file, eval output, a trace or a test run.
- **Fewest skills that cover the gaps.** Each needs a description that won't fire on generic "call an LLM" tasks, which `claude-api` owns.

| # | Skill | Fires when the user says… | Produces (done when) | Priority |
|---|---|---|---|---|
| 1 | `agent-architecture` | "build an agent / agentic system / multi-agent", "should this be an agent", "which framework" | An approved `AGENT_SPEC.md` covering: rung on the ladder and why the lower rung fails; single vs multi; tools list; risk tier; state and memory; framework, with versions checked; eval plan; budgets | **P1** |
| 2 | `agent-evals` | "eval my agent", "why is my agent failing", "is it better now", "compare models" | Error-analysis taxonomy from real traces → code checks and calibrated binary judges → capability and regression suites, multi-trial from clean state, run in CI. Includes model comparison on the user's own eval | **P1** |
| 3 | `agent-security-design` | "is my agent safe", "prompt injection", "give the agent access to email/DB/web", "sandbox" | Trifecta / Rule-of-Two table per tool combination, permission matrix, isolation pattern chosen, egress policy, credential handling, and injection test cases added to the eval suite | **P1** (biggest gap) |
| 4 | `agent-tool-design` | "design tools for my agent", "agent picks the wrong tool", "too many tools", "tool descriptions" | Audited catalogue (consolidated, namespaced, concise outputs, actionable errors) plus a tool eval run, with before and after scores | **P1** |
| 5 | `agent-reliability` | "make my agent production ready", "agent loops forever", "retries", "long-running agent", "approval step" | Budgets and stop conditions, idempotent writes, checkpoint and resume, retry classes, approval gates that survive restarts, and a crash-and-resume test that passes | **P2** |
| 6 | `agent-tracing` | "trace / observe / monitor my agent", "add OpenTelemetry", "what should I log" | Span tree in OTel GenAI shape with required fields and PII masking, verified by fetching and auditing a real trace; a trace-review routine that feeds evals | **P2** |
| 7 | `context-engineering` | "agent forgets / gets worse over long runs", "context too big", "prompt caching", "compaction", "system prompt" | Diagnosis (token budget, cache hit rate, rot symptoms) → fixes (stable prefix, just-in-time retrieval, compaction, sub-agent isolation, minimal system prompt) → measured improvement on the eval | **P2** |
| 8 | `agent-ux` | "agent UI", "stream agent progress", "let users interrupt / approve" | Event stream design (plan, tool activity, partials), interrupt and steer, approval UI showing the exact action, error and empty states | **P3** |

**Deliberately not building:**
- **MCP server scaffolding:** `mcp-builder` covers it. `agent-tool-design` links to it.
- **Claude API and SDK reference:** `claude-api` covers it.
- **Framework-specific skills** (LangGraph, ADK, CrewAI…): vendors maintain these, and they go stale fast. Our skills tell the agent to read current docs.
- **A2A:** a short section in `agent-architecture` is enough until there's real demand.
- **Standalone RAG and memory:** covered by `agent-architecture` (choice), `agent-evals` (retrieval eval) and `context-engineering`.
- **Fine-tuning/RL:** belongs in a later model-training skill, after evals exist.

**Suggested build order:**
1. `agent-architecture` and `agent-evals`. Every other skill hands off to these two: the spec and the eval suite.
2. `agent-security-design`.
3. `agent-tool-design`.
4. The P2 skills.

**Overlap to manage:** `agent-architecture` vs the built-in `engineering:system-design`. Ours is specific to LLM agents, and its description should say so. `agent-evals` vs `engineering:testing-strategy`: ours covers non-deterministic behaviour, theirs covers code tests.

---

## 5. Open questions for the user

1. **Which stack do you build agents on?** For example the Claude Agent SDK, OpenAI Agents SDK, LangGraph, ADK, Vercel AI SDK, or plain API loops. `my-context/references/stack.md` is still a template. The answer decides which hand-offs each skill names first.
2. **What do you mostly build?** Internal tools, customer-facing chat agents, background or coding agents, voice? This changes P2/P3 priority. For example, `agent-ux` matters more for customer-facing work.
3. **One evals skill or two?** Hamel's split (error analysis vs building evaluators) maps to two different moments: "why is it failing" and "build the suite". One skill with phases is simpler; two trigger more precisely.

---

## Sources

- **Practice:**
  - Anthropic: [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) · [Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents) · [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) · [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) · [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) · [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) · [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) · [Infrastructure noise](https://www.anthropic.com/engineering/infrastructure-noise) · [How we contain Claude](https://www.anthropic.com/engineering/how-we-contain-claude) · [Managed agents](https://www.anthropic.com/engineering/managed-agents) · [Claude Code auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode) · [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use) · [Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
  - [OpenAI: A practical guide to building agents](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf)
  - [Google ADK docs](https://google.github.io/adk-docs/)
  - LangChain: [context engineering](https://blog.langchain.com/context-engineering-for-agents/), [durable execution](https://docs.langchain.com/oss/python/langgraph/durable-execution), [interrupts](https://docs.langchain.com/oss/python/langgraph/interrupts)
  - [12-factor agents](https://github.com/humanlayer/12-factor-agents)
  - [Chroma: context rot](https://research.trychroma.com/context-rot)
  - [Manus: context engineering lessons](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) (unverified)
  - Cognition: [Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents) (unverified)
- **Evals:** [Hamel Husain: evals FAQ](https://hamel.dev/blog/posts/evals-faq/) · [Who Validates the Validators? (arXiv 2404.12272)](https://arxiv.org/abs/2404.12272) · [MAST: Why do multi-agent LLM systems fail (arXiv 2503.13657)](https://arxiv.org/abs/2503.13657)
- **Security:** [The lethal trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) · [Meta: Agents Rule of Two](https://ai.meta.com/blog/practical-ai-agent-security/) · [Design patterns for securing LLM agents (arXiv 2506.08837)](https://arxiv.org/abs/2506.08837) · [CaMeL (arXiv 2503.18813)](https://arxiv.org/abs/2503.18813) · [OWASP Top 10 for Agentic Applications 2026](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/)
- **Protocols and telemetry:** [MCP 2026-07-28 changelog](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/changelog.mdx) · [A2A at the Linux Foundation](https://www.linuxfoundation.org/press/a2a-protocol-surpasses-150-organizations-lands-in-major-cloud-platforms-and-sees-enterprise-production-use-in-first-year) · [OTel GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
- **Skill repos surveyed:** fetched into `.reference/` on 2026-11-05; commit SHAs as reported by the fetch.

  | Repo | SHA |
  |---|---|
  | anthropics/skills | `ca45fc4` |
  | openai/skills | `49f948f` |
  | vercel/ai | `8e8033a` |
  | promptfoo/promptfoo | `e3e2bb8` |
  | muratcankoylan/Agent-Skills-for-Context-Engineering | `9ff0c99` |
  | Orchestra-Research/AI-Research-SKILLs | `773a529` |
  | huggingface/skills | `25910b3` |
  | google/agents-cli | `896e471` |
  | DenisSergeevitch/agents-best-practices | `da245f8` |
  | ai-evals-course/evals-skills | `80d5f7b` |
  | hamelsmu/evals-skills | `22418da` |
  | langchain-ai/langchain-skills | `126c384` |
  | braintrustdata/agentbehavior | `1866cff` |
  | langfuse/skills | `dd2b16c` |
  | temporalio/skill-temporal-developer | `5f5a94d` |
  | swyxio/skills | `1acf58f` |
  | pydantic/skills | `98f591c` |
  | crewAIInc/skills | `bebb6e8` |
  | bridge-mind/BridgeWard | `7775676` |
  | braintrustdata/eval-library | `04486b3` |
  | mem0ai/mem0 | `ed1f10f` |
  | 0xNyk/agent-security | `4c3afaa` |
