# Spec and plan template

Copy into the project's spec location (default `docs/specs/<feature>.md`). Delete sections that would
be empty for a small change, but always keep Out of scope, Requirements, Examples and the slices.

```markdown
# <Feature name>

Size: Small | Medium | Large · Status: Draft, awaiting approval · Date: <YYYY-MM-DD>

## Outcome
<Who has the problem, what it is, the outcome we want, and why now. 2–4 lines.>

## Scope
- In: <...>
- Out: <...>

## Requirements
- R1. When <trigger>, the <system> shall <response>.
- R2. If <unwanted condition>, then the <system> shall <response>.
- ...

## Acceptance examples
- R1.a Given <concrete state> When <action> Then <observable result>
- R2.a Given ... When ... Then ...

## Decisions and constraints
- <Decision>: <one line of why>
- Security / data: <what this touches: login, permissions, personal data, payments, migrations>
- Ask first: <changes that need approval: new dependencies, schema changes, deleting data, CI changes>

## Assumptions, risks and open questions
- Assumption: <...>
- Risk: <...> (mitigation: <...>)
- Question: <...>

## Plan

### S1: <what a user can now do or observe>
- Covers: R1 (R1.a)
- Blocked by: none
- Size: S
- Verify: <tests for R1.a pass; manual check>
- Notes: <risk, test seam>

### S2: ...

### Checkpoint after S2
- Full checks green; <core flow> works end to end

## Traceability
| Requirement | Slices |
|---|---|
| R1 | S1 |
| R2 | S2 |
```
