# Slicing work

Read this while writing the plan.

## What a good slice is

A good slice is a thin, end-to-end piece of behavior that someone can observe and check. Use INVEST
(Bill Wake) as the test:

- **Independent:** can be built and verified without waiting for unrelated slices (explicit
  "Blocked by" links are fine)
- **Negotiable:** describes the behavior, not a fixed implementation
- **Valuable:** a user, operator or developer can see or use the result
- **Estimable:** clear enough to size
- **Small:** one session of work, about three acceptance checks or fewer
- **Testable:** has a Verify line that proves it

## Ways to split a slice that's too big

Try these in order. Each keeps the slice vertical (useful on its own) while making it smaller.

| Split by | Example |
|---|---|
| Happy path first, then each failure | "Apply a valid code" → then "expired code", then "code already used" |
| One step of a workflow at a time | Sign-up: "create account" → "verify email" → "set profile" |
| One data variation at a time | Import CSV first, then Excel |
| One business rule at a time | Percentage discounts first, then fixed-amount, then stacking rules |
| One interface at a time | API first (testable by command), then the UI on top |
| Simple version, then the hard property | Works correctly first, then the performance target as its own slice |
| A spike when the unknown is the problem | A time-boxed experiment that answers one question and is then thrown away |

The splits are adapted from common story-splitting practice (e.g. Mike Cohn's SPIDR: spike, paths,
interfaces, data, rules).

## Anti-patterns

- **Horizontal slices:** "all the database tables", then "all the endpoints", then "all the screens".
  Nothing works until the last one, so nothing can be checked early.
- **Setup-only slices:** "configure the project", "add a library". Fold setup into the first slice that needs it.
- **A final "integrate everything" slice:** a sign the earlier slices weren't vertical.
- **A final "add tests" slice:** tests belong in the slice whose behavior they check.

## Migrations and wide refactors: expand, migrate, contract

When one change breaks many places at once (renaming a column, changing a shared type, moving to a
new API), a vertical slice can't stay green. Sequence it instead:

1. **Expand:** add the new form next to the old one, so nothing breaks (a new column, a new function, both versions accepted).
2. **Migrate:** move callers or data over in batches, each its own slice, each leaving everything working.
3. **Contract:** remove the old form once nothing uses it, in a slice blocked by every migrate batch.

For data migrations, include in the slices: a backup before running, a dry run on a copy, how to roll
back, and how to verify the counts afterwards.

## Ordering

1. Restructuring that makes the change easier (no behavior change)
2. The riskiest slice that its dependencies allow
3. The core happy path, end to end
4. Unwanted-behavior slices
5. Polish and the hard properties (performance, accessibility), each as its own slice

Add a checkpoint after every two or three slices: full checks green, the core flow works end to end.
