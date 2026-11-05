# AI engineering

Building with LLMs: context engineering, agent architecture, evals, RAG, fine-tuning and model APIs.

## Skills

_None yet._

## Planned: our own agent-building skills

See the [agent-building research](../../research/2026-11-agent-building-skills.md) for why each exists and what to learn from. All are provider-neutral and hand off to `claude-api`, `mcp-builder` or current framework docs for API details.

| Priority | Skill | Job |
|---|---|---|
| P1 | `agent-architecture` | Decide workflow vs agent vs multi-agent and framework; end in an approved spec |
| P1 | `agent-evals` | Error analysis on traces, calibrated graders, capability and regression suites, model comparison |
| P1 | `agent-security-design` | Lethal-trifecta analysis, permission matrix, sandbox and egress, injection tests |
| P1 | `agent-tool-design` | Audit and eval the agent's tool catalogue |
| P2 | `agent-reliability` | Budgets, stop conditions, idempotent writes, durable resume, approval gates |
| P2 | `agent-tracing` | Vendor-neutral OTel GenAI traces, verified by auditing a real trace |
| P2 | `context-engineering` | Diagnose and fix context rot, cache misses and long-run drift |
| P3 | `agent-ux` | Streaming, interrupt and steer, approval UI |

Study with `scripts/fetch-reference.sh`; never install or copy them. Main sources: [hamelsmu/evals-skills](https://github.com/hamelsmu/evals-skills), [ai-evals-course/evals-skills](https://github.com/ai-evals-course/evals-skills), [muratcankoylan/Agent-Skills-for-Context-Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering), [google/agents-cli](https://github.com/google/agents-cli), [braintrustdata/eval-library](https://github.com/braintrustdata/eval-library), [langfuse/skills](https://github.com/langfuse/skills), [langchain-ai/langchain-skills](https://github.com/langchain-ai/langchain-skills), [anthropics/skills](https://github.com/anthropics/skills).

Later, model work (fine-tuning, RL, embeddings): [huggingface/skills](https://github.com/huggingface/skills).
