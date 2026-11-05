# Integrity audit

How to check a diff for changes that make checks pass without making the code right. Use it in
Step 4 of `verify-before-done`, and when reviewing work done by another agent.

## 1. Get the whole diff

```bash
git diff --stat <base>...HEAD    # what changed, committed
git status --short               # uncommitted and untracked files
git diff <base>...HEAD           # read it all; don't stop at the stat
git diff                         # plus uncommitted changes
```

`<base>` is the commit just before the work began: the PR's target, or the parent of the work's
first commit. On a feature branch that's usually `git merge-base HEAD main`. **If that equals
`HEAD`** (you're on `main`, or the work is merged), it's wrong: the diff would be empty and the
audit would pass everything. Find the real base with `git log --oneline`. Untracked files count too.

## 2. Search the added lines

These commands list only *added* lines (`^+`) that match. Every hit needs a reason.

```bash
# Tests disabled or focused
git diff <base>...HEAD | grep -nE '^\+.*(\.only\(|\.skip\(|\bxit\(|\bxdescribe\(|@pytest\.mark\.(skip|xfail)|unittest\.skip|@Disabled|@Ignore|t\.Skip\(|#\[ignore\])'

# Type, lint and analysis suppressed
git diff <base>...HEAD | grep -nE '^\+.*(@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|# type: ignore|# noqa|# pragma: no cover|//nolint|#\[allow\(|: any\b|as any\b)'

# Errors swallowed
git diff <base>...HEAD | grep -nE '^\+.*(catch\s*(\(\w*\))?\s*\{\s*\}|except(\s+\w+)?:\s*pass|except:\s*$|\.catch\(\(\)\s*=>\s*\{?\s*\}?\)|_ = err)'

# Debug output and leftovers
git diff <base>...HEAD | grep -nE '^\+.*(console\.log|debugger;|print\(|pdb\.set_trace|binding\.pry|dbg!\(|TODO|FIXME|XXX)'

# Possible secrets
git diff <base>...HEAD | grep -nEi '^\+.*(api[_-]?key|secret|password|passwd|token|private[_-]?key|BEGIN [A-Z ]*PRIVATE KEY|sk_live_|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})'
```

`print(` and `TODO` hits are often fine. The point is that each one is a decision, not an accident.

### Hardcoded answers

The strongest cheat is source code that recognizes test inputs. Find comparisons against literal
values added to **non-test** source, then check whether those values appear in the tests:

```bash
# Added source lines comparing against a literal number or string (adjust the paths to the project)
git diff <base>...HEAD -- . ':!*test*' ':!*spec*' \
  | grep -nE '^\+.*(===?|!==?|==|!=)\s*(-?[0-9][0-9.]*|"[^"]*"|'"'"'[^'"'"']*'"'"')'

# For each literal found, is it a test input or expected value?
grep -rnF -- '<literal>' <test-dir>
```

A literal that appears in both, guarding an early `return`, is almost always a hardcoded answer.
Legitimate constants (status codes, enum names) are fine: say why in the report.

## 3. Check what changed, not just how

| Look at | Red flag |
|---|---|
| Test files changed in the same diff as the fix | An expected value changed to match new output; assertions removed or loosened (`toEqual` → `toBeDefined`, exact → `assertTrue(x)`) |
| Test count | Fewer tests than the baseline, or tests no longer collected (renamed files, changed glob) |
| Snapshot / golden files | Regenerated with no stated reason |
| Config: `tsconfig`, ESLint, `pyproject`, `setup.cfg`, `jest`/`vitest`/`pytest` config, coverage thresholds, CI workflow | Rules turned off, strictness lowered, thresholds reduced, paths excluded, steps removed or set to `continue-on-error` |
| `package.json` scripts / Makefile targets | The test or lint command changed to run less |
| Source code near the fix | `if` branches matching exact test inputs (`if price == 100`), special-casing a test environment (`if (process.env.NODE_ENV === 'test')`) |
| Mocks | The function under test is mocked in its own test, or a mock now returns exactly the asserted value |
| Error handling | Failures turned into silent defaults (`return []`, `return null`) without the caller knowing |
| Scope | Files unrelated to the task changed; large reformatting mixed into a fix |
| Lockfiles | Changed without a dependency change in the manifest, or hand-edited |

## 4. Decide each finding

For every finding, do one of:

- **Fix it** (preferred): restore the test, remove the suppression, implement the real logic.
- **Justify it** in the report: what it is, why it's correct, and what the user should check.
  A test that really was wrong can be changed, with the reason stated.

Never leave a finding silent. An unexplained weakening is a NOT DONE.
