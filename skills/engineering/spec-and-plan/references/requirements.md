# Writing requirements and acceptance examples

Read this while writing the spec's Requirements and Acceptance examples sections.

## EARS patterns

EARS (Easy Approach to Requirements Syntax; Mavin et al., Rolls-Royce, 2009) gives every requirement
the same shape, so missing triggers, states and error cases become visible. Pick the pattern that fits
and name the system consistently.

| Pattern | Template | Example |
|---|---|---|
| Ubiquitous (always true) | The `<system>` shall `<response>`. | The checkout shall show prices in the store's currency. |
| Event-driven | When `<trigger>`, the `<system>` shall `<response>`. | When a customer applies a valid code, the checkout shall show the discounted total. |
| State-driven | While `<state>`, the `<system>` shall `<response>`. | While the cart is empty, the checkout shall disable the Pay button. |
| Unwanted behavior | If `<unwanted condition>`, then the `<system>` shall `<response>`. | If the payment provider times out, then the checkout shall keep the order unpaid and show "Payment didn't go through, you weren't charged". |
| Optional feature | Where `<feature is included>`, the `<system>` shall `<response>`. | Where gift wrapping is enabled, the checkout shall offer it for each item. |

Patterns combine: `While <state>, when <trigger>, the <system> shall <response>.`

EARS fixes the *shape* of a requirement, not whether it's the right requirement. A grammatical
requirement can still describe the wrong behavior, which is why each one needs an example the user
can read and correct.

## What makes a requirement good

Based on the characteristics in ISO/IEC/IEEE 29148. Check each requirement:

- **Necessary:** traceable to the outcome or a constraint. If nothing breaks without it, cut it.
- **Singular:** one behavior. "and" joining two behaviors means two requirements.
- **Unambiguous:** one reading. Replace "fast", "secure", "easy", "appropriate", "etc." with a number,
  a named rule, or an open question.
- **Verifiable:** you can say how to test it. If you can't, it isn't a requirement yet.
- **Feasible:** possible within the stated constraints. Flag it as a risk if unsure.
- **Free of implementation detail**, unless the detail is itself a constraint (e.g. "must use the
  existing Postgres database").

## Unwanted behavior: the checklist

Go through these for every feature and write an `If …, then …` requirement for each that applies:

- Invalid input: wrong type, wrong format, out of range, too long, empty, missing
- Boundaries: zero, one, maximum, just over the maximum, negative, rounding
- Permissions: not logged in, wrong role, someone else's data (this one causes real breaches)
- Failures: network down, dependency timeout, partial failure halfway through
- Repetition: double submit, retry, duplicate record, concurrent edits to the same thing
- Data: very large datasets, unexpected characters (Unicode, emoji), time zones and daylight saving
- State: acting on something deleted, expired, already used or already paid

## Acceptance examples (Given / When / Then)

From behavior-driven development (Gherkin). Each example is a concrete scenario that becomes a test.

```
R3.a  Given a cart with one item at $40.00
      And the code SAVE10 (10% off)
      When the customer applies SAVE10
      Then the total shows $36.00
R3.b  Given the code EXPIRED1 that ended yesterday
      When the customer applies it
      Then the total stays $40.00
      And the message says "This code has expired"
```

Rules:

- **Concrete values**, never "some amount" or "a user". Concrete values are what make an example
  testable and expose disagreements ("wait, is it $36.00 or $36?").
- **One behavior per example.** Several Thens are fine if they describe one outcome.
- **Describe what's observable**, not how it's implemented: the screen, the response, the record, the
  email, not the function called.
- Tag each with its requirement (`R3.a`), so slices and tests can point to it.
- Cover the happy path first, then each unwanted-behavior requirement.
