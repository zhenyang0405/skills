---
name: verify-before-done
description: Prove work is finished before saying so. Run the project's own checks fresh, test the actual behavior, audit the diff for weakened or gamed tests, check every requirement, and report the status with evidence. Use before saying a task is done, fixed, working or passing; before committing, pushing, merging or opening a PR; when moving to the next task; and whenever a subagent, coding agent or teammate reports success. Also use when the user asks to double-check, sanity-check or review someone's work, or asks "is it actually done?", "can I merge this?" or "is this ready to push?", even if they don't say "verify".
---

# Verify before done

**Rule: no claim of success without evidence produced after your last edit.**

"Done", "fixed", "works", "tests pass" and anything implying them are claims. Each needs output you
just produced and read. A green run before your final edit, a subagent's "success" or "it should
work" are not evidence. Agents are known to edit tests, hardcode expected outputs and claim checks
they never ran. This skill exists so this agent doesn't.

## When to use

- You're about to say a task is done, fixed, working or passing, or to move on to the next task.
- You're about to commit, push, open a PR or hand work to someone.
- A subagent, tool or other agent reports that something succeeded.

### How much to do

- **Checking your own work before you report it** (the common case): run the checks before and after
  your edits, show the behavior, read your own diff against the audit list, check the requirements,
  write the report. Skip the worktree, revert and merge steps unless they apply (a bug fix needs
  the revert check; work you're about to merge needs the merge check). Extra checks cost the
  user time without telling them anything new.
- **Reviewing someone else's work, or before a merge or push**: do every step, because you don't
  know what was run, against which base, or what the target branch looks like now.

Scale further to the size of the change (see the table in Step 3), but always write the report.

## Step 1: Find the real checks

Use the checks the project declares, because those are what CI and reviewers will run. Ad-hoc commands
can pass while the real suite fails, so don't present your own as "the tests".

- Look in this order: CI config (`.github/workflows/`, `.gitlab-ci.yml`), task runners (`package.json`
  scripts, `Makefile`, `justfile`, `pyproject.toml`, `Cargo.toml`), then the README or contributing guide.
  CI is the source of truth: if it runs it, you run it.
- Typical set: tests, type check, lint, build. Note any CI step you can't run locally, including
  tests that need secrets or services only CI provides (look for `secrets.`, `env:` and `services:` in
  the workflow). Those are **not verified**, not passing, and not something to skip or stub.
- If the project declares no checks, say so, run what you reasonably can (e.g. compile, start the
  app), and suggest adding real checks. Don't present ad-hoc commands as the project's suite.

- Check that your runtime matches CI's (Node, Python, etc. versions in the CI file, `.nvmrc`,
  `.python-version`, `engines`). If it differs, say so under "Not verified".

## Step 2: Find the base and the baseline

**The base** is the commit just before the work began: the PR's target, or the parent of the first
commit of the work. Confirm it with `git log --oneline`. If `git merge-base HEAD main` equals `HEAD`
(you're on `main`, or the work is already merged), it's the wrong base: an empty diff would make
every audit look clean. Find the real one.

**The baseline** is how the checks did on the base. You can only call a failure "pre-existing" if
it failed there.

- Your own work: run the checks once before you start editing, and keep the result (pass / fail /
  skipped per check, and the test count).
- Someone else's work, or if you didn't: run the checks on the base in a separate copy
  (`git worktree add <tmp-dir> <base>`), so the tree under review is never touched.
- A test you didn't touch that breaks after the change is a bug in the change.

**The target** (only when the work is about to be merged or pushed, or you're asked whether it can
be). If the target branch has moved on since the base (`git log <base>..<target>` isn't empty),
check what the merge would produce without touching anything:
`git merge-tree --write-tree <target> HEAD`. A clean branch can still conflict, or auto-merge into
something broken (e.g. keep a test the target skipped). Say so in the report, and don't describe the
change as fixing the target unless the merge result shows it.

## Step 3: Run everything fresh and read the output

Run the full checks after the last edit. Then read the output, not just the last line:

- Exit code, and pass / fail / **skipped** counts. Compare the test count with the baseline: a drop
  means tests were removed or no longer collected.
- "0 tests ran", "no tests found" or a suspiciously fast run means the check didn't really run.
- Warnings that turn into errors in CI (e.g. `--max-warnings 0`, `-Werror`).

Then prove the behavior itself, which checks alone don't. If there's no reproduction or scenario
written down, derive one from the requirements: the main case plus an edge case or two (zero, empty,
a different value from the ones the tests use). Say that you chose them. For a small pure function,
running it directly on those inputs is enough.

A bug fix needs a revert check: a regression test only proves something if it fails without the fix.
Do it without editing the tree under review, so you can't leave it in a changed state: put the
base's source next to the new tests in a separate worktree or temp copy, and run the tests there.
New features don't need one; their new tests just have to pass and actually exercise the feature.

| Claim | Evidence required | Not enough |
|---|---|---|
| Tests pass | Full suite output: 0 failed, skipped count stated | An earlier run; a subset; "should pass" |
| Builds | Build command exits 0 | Lint or type check passing |
| Bug fixed | The original reproduction now behaves correctly, **and** a regression test that fails without the fix (revert the fix, see it fail, restore, see it pass) | "The code changed"; a new test that was never seen failing |
| Feature works | The acceptance scenario run for real: request and response, CLI output, or a screenshot of the UI state | Unit tests alone |
| UI change | Screenshot or browser check of each changed state, including empty, error and mobile widths | "The component renders" |
| Migration / data change | Run against a copy or dev database: before and after counts, rollback tried | The migration file looks right |
| Config / deploy change | The app starts with the new config; health check passes | The config file parses |
| Dependency change | Lockfile diff read; full suite and build pass | Version bumped in the manifest |
| Docs only | Links and commands in the changed text checked | Nothing (still say what you checked) |
| Subagent says done | You read its diff and reran the checks yourself | Its report |

Don't rerun a command for reassurance if nothing changed since it last passed. Rerun after every edit.

## Step 4: Audit the diff for gaming

Read the full diff against the base from Step 2 (`git diff <base>...HEAD`, plus uncommitted changes).
Look for changes that make checks pass without making the code right. For a diff under ~50 lines,
reading it carefully against the list below is enough. For larger diffs, also run the searches in
[references/integrity-audit.md](references/integrity-audit.md). The usual suspects:

- Tests skipped, deleted, or made weaker (assertions removed, expectations changed to match buggy output)
- New tests too loose to fail when the code is wrong (`assert.ok(x < 100)` where the requirement
  says exactly 50; `toBeDefined()`; checking only that no error was thrown)
- The test command or config narrowed so some tests no longer run (a changed `test` script, glob,
  `testPathIgnorePatterns`, a file renamed out of the pattern). Run the runner's default discovery
  too, and compare the test files it finds with the base
- `.only`, `skip`, `xfail` or `@Disabled` added; snapshot files regenerated without a stated reason
- Lint, type or coverage settings loosened; `// @ts-ignore`, `eslint-disable`, `# type: ignore`, `any` added
- Special cases that match test inputs exactly (hardcoded answers)
- The code under test mocked away in its own test
- Errors swallowed (`catch {}`, bare `except: pass`) to stop a failure from surfacing
- Secrets, debug prints, `console.log`, TODOs or temporary files left in
- Files changed outside the task's scope

Each finding must either be fixed or be explained in the report with a reason the user can judge.
Weakening a test, check or config to get green hides the very failure the user needs to know about,
so don't. Pressure to be green ("CI must pass tonight") doesn't change that: a skipped or mocked test
turns a failure the user can see into one they deploy. Report the failure and what it would take
to fix. If a test is truly wrong, for example because the requirement changed, change it and say
in the report which test, what it asserted before, and why.

## Step 5: Check every requirement

Re-read what was asked: the user's request, the brief from `interview-me`, or the spec's acceptance
criteria. List each requirement and mark it **met** (with its evidence), **not met**, or **not
verified** (and why). Passing tests don't mean the requirements are met.

## Step 6: Report

Use this shape, every time:

```
**Status: DONE | DONE WITH CONCERNS | NOT DONE | BLOCKED**

Claim checked: "<the claim, quoted>". Evidence: <agrees, or where it doesn't>

| Check | Command | Result |
|---|---|---|
| Tests | `<command>` | <N passed, N failed, N skipped> (baseline: <N>) |
| Types / lint / build | `<command>` | <exit code / error count> |
| Behavior | `<what you ran>` | <what you saw> |
| Diff audit | `git diff <base>...HEAD` | <clean, or each finding> |

Requirements:
- [x] <requirement>: <evidence>
- [ ] <requirement>: <not met / not verified, and why>

Not verified: <anything you could not check, and why>. Write "nothing" only if true.
```

- **DONE** only when every check passes, the behavior was shown, the audit is clean and every
  requirement is met.
- **DONE WITH CONCERNS** when it works but something is worth the user's attention: a check CI
  runs that you couldn't run locally, or a gap that **already existed on the base** (mark it
  "pre-existing"; it doesn't count against this change, but the user should know).
- **NOT DONE** when anything fails or a requirement isn't met. Say what's left.
- **BLOCKED** when something outside the code stops you: a missing service, secret, permission or
  tool. Report it; don't stub, mock or skip around it.
- Until the report is written, don't use "done", "fixed", "works", "great" or "all set". Avoid
  "should" and "probably" about anything you could check.

## If a check fails

1. Fix the code, not the test (see Step 4).
2. Rerun just the failing check while fixing, then the **full** set before reporting.
3. Stop when the same failure survives two honest fix attempts, or after about five rounds. Report
   **NOT DONE** with what you tried, and move to systematic debugging rather than guessing again.

## Done when

- [ ] The project's declared checks ran after the last edit, and their output was read
- [ ] The base was confirmed to be the commit before the work (not `HEAD` itself)
- [ ] Any "pre-existing" failure was shown to fail on the base too
- [ ] The behavior itself was demonstrated, not just the tests
- [ ] A bug fix has a regression test that was seen failing without the fix
- [ ] The diff was audited, and every finding was fixed or explained
- [ ] Each requirement is marked met, not met or not verified
- [ ] The report uses the format above, including "Not verified"

## Common excuses

| Excuse | Reality |
|---|---|
| "It's a tiny change." | Tiny changes break builds too. Scale the checks down; still run them and report. |
| "I ran the tests earlier." | Then you have evidence about earlier code. Rerun after the last edit. |
| "The subagent said it passed." | Reports aren't evidence. Read its diff, rerun the checks. |
| "That failure was already there." | Only if you saw it fail on the base. Otherwise it's yours. |
| "The test was flaky, so I skipped it." | Then the report says a test was skipped and why. Skipping silently is hiding a failure. |
| "Tests pass, so the feature works." | Tests check what someone thought to test. Run the real scenario. |
| "The environment is missing X, so I mocked it." | That's BLOCKED, not done. Say what's missing. |
| "I'm confident." | Confidence isn't output. Run it. |
