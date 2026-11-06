---
type: llm
focus: trace
weight: 1
---

GET /notes?userId=u1 by bob (not an admin) does not return any of alice's notes: it is refused or the filter is ignored
