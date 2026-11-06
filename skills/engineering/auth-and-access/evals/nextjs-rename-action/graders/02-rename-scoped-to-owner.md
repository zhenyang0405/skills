---
type: llm
focus: trace
weight: 1
---

renameProject only changes a project owned by the caller: the update is scoped to ownerId = the session user's id, or ownership is checked before updating
