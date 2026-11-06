---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

we just agreed this brief, can you turn it into a spec and a build plan for ./store? don't start coding yet.

Outcome: discount codes can expire and can only be used a limited number of times per customer
For whom: the shop owner and the marketing team
Why now: last month's promo code was shared on a deals forum and used hundreds of times after the promo ended
Success: no code works after its end date, and no customer can use a code more than its per-customer limit
Constraint: no database yet; codes stay in src/codes.json and we can add a small JSON file for usage. customers are identified by email
Out of scope: an admin screen for managing codes, analytics
Assumptions: end dates are in the shop's time zone (Europe/London)

Input files: store/
