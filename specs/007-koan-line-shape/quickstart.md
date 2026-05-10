# Quickstart — M2.5 Local Implementation & Verification

This document is the contributor-side recipe for implementing
M2.5 (assertion-line-shape cleanup across the Stage I corpus)
and verifying it locally before pushing. It mirrors the spec's
acceptance gates and the contract's positive/negative case
tables, and adds the bit-identity probe procedure that proves
behavior preservation.

## Prerequisites

- macOS or Linux with Regina REXX installed
  (`brew install regina-rexx` on macOS;
  `sudo apt-get install -y regina-rexx` on Ubuntu).
- A clean working tree on branch `007-koan-line-shape`.
- `main` HEAD includes M2.4 merged (the citation-existence
  lint extension); the feature branch was created from a
  post-M2.4 `main`.
- `PLAN.md` v1.4 with §M2.5 milestone and §8 "Assertion lines
  stay single-statement" style bullet codified at commit
  `9a5de4a` on the feature branch (FR-015 precondition).
- Optional: the working spike at `stash@{0}` is intact (run
  `git stash list` to confirm; the message includes "spike:
  simplified assertion-line shape (M2.5 POC)…").

## Step 0 — Confirm baseline (pre-edit)

Before any edit, run the three CI scripts and capture the
fixture-equivalent output. These outputs are the bit-identity
target for Step 5.

```sh
bin/verify_solutions
```

Expected: `6/6 solutions passed.`, exit code 0.

```sh
bin/lint_citations
```

Expected: 12 `[ ok ]` lines (6 koans + 6 solutions), summary
line ending `12/12 files passed lint.`, exit code 0.

```sh
bin/pilgrimage > /tmp/runner_baseline.txt
diff -u tests/fixtures/runner_stdout.txt /tmp/runner_baseline.txt
```

Expected: empty diff (the baseline runner output already
matches the fixture).

## Step 1 — Pre-grep the corpus for shape uniformity

The implementation assumes every Stage I file uses the legacy
`n = n + 1; ... , n` shape uniformly. Confirm before edits
begin:

```sh
# Every assertion line should match the legacy shape:
grep -c -E '^[[:space:]]*n = n \+ 1;[[:space:]]*CALL m' \
    koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx

# Every wrapper should be the 4-arg legacy form:
grep -E 'm: PARSE ARG kind, arg1, arg2, num' \
    koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l
```

Expected:

- The first grep returns ~30+ matches across the 12 files
  (sum of per-file assertion-line counts; tasks.md captures
  the exact per-file counts).
- The second grep returns 12 (one match per file — the
  legacy wrapper signature).

If either grep returns an unexpected count, **stop and
investigate**. The recipe assumes uniform legacy shape; a
divergent file needs per-file judgment, not bulk apply.

## Step 2 — Apply the spike to koan 00

The spike at `stash@{0}` is a working application of the new
shape to `koans/00_about_asserts.rexx` only. Two equivalent
ways to bring it into the working tree:

**Option A — `git stash apply`**:

```sh
git stash apply stash@{0}
git status                       # confirm only koans/00_about_asserts.rexx is modified
```

**Option B — hand-edit from the contract**:

Open `koans/00_about_asserts.rexx`. Apply the recipe:

- For every assertion line, replace
  `n = n + 1; CALL m '<verb>', <arg1>, <arg2>, n`
  with `CALL m '<verb>', <arg1>, <arg2>`.
- Replace the wrapper body with the canonical post-change
  shape from `contracts/assertion_line_shape.md`. The
  wrapper's third argument stays `'koans/00_about_asserts.rexx'`.

Either option produces the same final file shape.

Verify with `bin/pilgrimage`:

```sh
bin/pilgrimage 2>&1 | head -20
```

Expected: koan 00 reports `[ ok ]` (because solutions/ still
has the old shape and koan 00's blanks are still
FILL_ME_IN, the runner stops at the first blank in koan 00 —
or, if you've also applied the matching solution-side fills,
it advances to koan 01, which still uses the legacy shape and
should also work because we haven't touched it). Either
outcome is acceptable for Step 2; the bit-identity probe
runs in Step 5 against the full migrated corpus.

## Step 3 — Migrate koans 01–05

For each of `koans/01_about_strings.rexx`,
`koans/02_about_variables.rexx`,
`koans/03_about_expressions.rexx`,
`koans/04_about_clauses.rexx`,
`koans/05_about_say.rexx`:

1. Open the file.
2. Apply the line-shape recipe per
   `contracts/assertion_line_shape.md`:
   - Strip `n = n + 1;` prefix and trailing `, n` argument
     from every assertion line.
3. Replace the wrapper body per the canonical post-change
   shape, keeping the file's own `koan_path` literal in the
   wrapper's third argument.
4. Save.
5. Spot-check via `bin/pilgrimage` after each file to
   confirm no syntax error and that the runner advances
   correctly.

Per-file commit recommended (not required) — gives the
cleanest `git log` story for review.

## Step 4 — Migrate solutions 00–05 in lockstep

For each of `solutions/00_about_asserts.rexx` through
`solutions/05_about_say.rexx`:

1. Apply the same recipe (line-shape + wrapper). The
   wrapper's third argument is the solution's own relative
   path (e.g., `'solutions/00_about_asserts.rexx'`, not the
   koan's path).
2. Save.
3. Run `bin/verify_solutions` after each batch to confirm
   the corresponding solution still passes:
   ```sh
   bin/verify_solutions
   ```
   Expected: every solution edited so far reports `[ ok ]`,
   along with every solution not yet edited (which still
   uses the legacy shape and passes by construction).

Per-pair commit recommended (koan NN + solution NN in one
commit) — preserves the SC-009 parity invariant at every
commit on the branch.

## Step 5 — Bit-identity probe (full corpus)

After all 12 files are migrated, run the two-state probe.

**State A — fully-solved corpus**:

```sh
bin/pilgrimage > /tmp/runner_post.txt
diff -u tests/fixtures/runner_stdout.txt /tmp/runner_post.txt
```

Expected: empty diff. If non-empty, an assertion-line edit
introduced a behavioral change; investigate.

**State B — unsolved corpus probe**:

Pick one koan, deliberately revert one FILL_ME_IN to the
unsolved state (e.g., in `koans/00_about_asserts.rexx`,
change `CALL m 'eq', 4, 2 + 2` back to
`CALL m 'eq', FILL_ME_IN, 2 + 2`), then run:

```sh
bin/pilgrimage 2>&1 | grep "Damaged at"
```

Expected: the `Damaged at: <file>, line N` diagnostic names
the same line number that the pre-change corpus would have
named for the same blank. To verify the line number,
compare against `git stash show stash@{0}`'s post-stash
state, or check out `main` HEAD into a worktree and run the
same probe (with the equivalent FILL_ME_IN reintroduced).

After the probe, restore the fill so the corpus is in the
fully-solved state again.

## Step 6 — CI script run-through

```sh
bin/verify_solutions
bin/lint_citations
```

Expected:

- `bin/verify_solutions` reports `6/6 solutions passed.`
  (FR-010, SC-005).
- `bin/lint_citations` reports 12 `[ ok ]` lines and
  `12/12 files passed lint.` (FR-011, SC-006).

If either fails, investigate before pushing.

## Step 7 — Diff-scope sanity

Confirm that no out-of-scope file has been modified:

```sh
git diff main -- ':!specs/' ':!koans/' ':!solutions/'
```

Expected: empty output (FR-017, SC corollary).

```sh
git diff main -- lib/ bin/ docs/cowlishaw_index.md tests/fixtures/runner_stdout.txt PLAN.md .specify/ .github/
```

Expected: empty output (modulo any PLAN.md / .specify/
changes that landed in the codification commit `9a5de4a` on
this branch — those are intentional, not violations of
FR-017's intent).

## Step 8 — Push and confirm CI

```sh
git push -u origin 007-koan-line-shape
```

Then in the GitHub UI (or via `gh pr checks`), confirm:

- `Verify solutions / ubuntu-latest`: success
- `Verify solutions / macos-latest`: success
- `Lint citations / ubuntu-latest`: success
- `Lint citations / macos-latest`: success
- `Runner smoke / ubuntu-latest`: success
- `Runner smoke / macos-latest`: success

All six checks green = SC-007 passes.

## Step 9 — PLAN.md §8 ratification

Open `PLAN.md`, locate the §8 "Assertion lines stay
single-statement" bullet (added in commit `9a5de4a`). Read
it unaided. Confirm in under 60 seconds you can name:

1. The canonical assertion-line shape: `CALL m '<verb>', expected, actual`
2. The forbidden legacy pattern: `n = n + 1; ... , n`

If both are nameable from the bullet alone, US5 / SC-011
passes.

## Step 10 — Drop the spike (after merge)

After the PR merges to `main`:

```sh
git stash drop stash@{0}
```

The spike has fulfilled its purpose; keeping it would risk
future contributors confusing it with the canonical
implementation.

## Acceptance Summary

| Step | Acceptance |
|------|-----------|
| Step 0 | Baseline captured: 6/6, 12/12, fixture-matching runner output |
| Step 1 | Corpus shape is uniform legacy (12 wrappers + ~30+ assertion lines match) |
| Step 2 | Koan 00 migrated; spike or hand-edit equivalent |
| Step 3 | Koans 01–05 migrated |
| Step 4 | Solutions 00–05 migrated; verify_solutions remains 6/6 at every commit |
| Step 5 | State A: empty diff against fixture. State B: line numbers preserved |
| Step 6 | verify_solutions 6/6, lint_citations 12/12 |
| Step 7 | Out-of-scope diff is empty |
| Step 8 | All 6 CI checks green on the feature branch HEAD |
| Step 9 | PLAN.md §8 conveys the rule unaided in <60s |
| Step 10 | Spike dropped post-merge |

If every acceptance row passes, M2.5 is ready to merge.
