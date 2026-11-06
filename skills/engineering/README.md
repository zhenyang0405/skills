# Engineering

Software engineering workflows for building production-ready applications: specs, security, data safety, testing, architecture, review, release and operations.

## Skills

| Skill | Status | What it does |
|---|---|---|
| [spec-and-plan](spec-and-plan/SKILL.md) | ✅ | Testable requirements with Given/When/Then examples, then small end-to-end slices that trace to them |

## Build order

From the [software engineering roadmap](../../research/2026-11-software-engineering-skills-roadmap.md), ranked by production impact, how often agents get it wrong, and how much a written procedure helps. Two foundation skills (`verify-before-done`, `debugging`) live in the [core pack](../core/README.md) because they apply to all work.

| # | Skill | Milestone | What it prevents |
|---|---|---|---|
| 1 | `verify-before-done` (core) | 1. Build the right thing | "Done" claims without evidence; agents gaming tests |
| 2 | `spec-and-plan` | 1 | Building the wrong thing; slices too big to verify |
| 3 | `auth-and-access` | 2. Don't get breached or lose data | Anyone reading anyone's data (OWASP #1; RLS and open-bucket leaks) |
| 4 | `secure-coding` | 2 | XSS, injection, leaked secrets, bad or hallucinated dependencies, misconfiguration |
| 5 | `data-and-migrations` | 2 | Lost or corrupted data, failed migrations, untested backups |
| 6 | `test-driven-development` | 2 | Untested changes; tests that can't fail |
| 7 | `architecture-decisions` | 3. Design, review and ship | Premature microservices; tangled modules (default: modular monolith) |
| 8 | `code-review` | 3 | Bugs and over-engineering reaching main |
| 9 | `error-handling` | 3 | Fail-open errors, cascading failures, leaked stack traces (OWASP #10) |
| 10 | `release-and-rollback` | 3 | Bad deploys and config changes, the cause of most outages |
| 11 | `observability` | 3 | Problems users notice before you do |
| 12 | `api-design` | 3 | Breaking clients; inconsistent, unvalidated endpoints |
| 13 | `ci-pipeline` | 3 | Checks that only run when someone remembers |
| 14 | `debugging` (core) | 3 | Guess-and-patch fixes |
| 15 | `production-readiness` | 3 | Launching without backups, monitoring, limits or a rollback plan |
| 16 | `incident-response` | 3 | Panicked fixes and repeat outages |

The research has a "learn from" list for each skill. Study with `scripts/fetch-reference.sh`; never install or copy them.

## How they connect

`interview-me` → `spec-and-plan` → (`architecture-decisions` for new systems) → per slice: `test-driven-development`, consulting `auth-and-access`, `secure-coding`, `data-and-migrations`, `error-handling` and `api-design` when the slice touches them → `verify-before-done` → `code-review` → `ci-pipeline` → `release-and-rollback` → `observability`. Before first launch: `production-readiness`.

Each skill owns its topic. Others point to it instead of repeating its checklist.
