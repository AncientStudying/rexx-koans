# Quickstart: M2 Walking Skeleton — Walking Stage I

**Branch**: `002-m2-walking-skeleton` | **Date**: 2026-05-08
**Audience**: A pilgrim on macOS validating the M2 release end-to-end.

This walkthrough covers the user-facing experience that User Story 1
of the spec mandates. It is also the manual test plan a contributor
runs locally before relying on CI.

---

## Prerequisites

Install Regina REXX:

```sh
brew install regina-rexx       # macOS
# or
sudo apt-get install -y regina-rexx   # Ubuntu
```

Verify:

```sh
regina --version
```

Clone (if needed) and check out the M2 branch:

```sh
git clone <repo-url> rexx-koans
cd rexx-koans
git checkout 002-m2-walking-skeleton
```

---

## Step 1: First run — encounter the path

```sh
./bin/pilgrimage
```

Expected output (approximate):

```
THE PATH OF REXX

  [ here ] 00 about_asserts        The First Truths
  [      ] 01 about_strings
  [      ] 02 about_variables
  [      ] 03 about_expressions
  [      ] 04 about_clauses
  [      ] 05 about_say

  This koan awaits your contribution. Replace the FILL_ME_IN symbol
  with the value the pilgrim must learn.

  Damaged at: koans/00_about_asserts.rexx, line <L>.

  Stations walked: 0 of 6.  Karma damaged at: about_asserts.
```

Exit code: non-zero.

---

## Step 2: Walk koan 00 — about_asserts

Open `koans/00_about_asserts.rexx`. Each concept group has a teaching
comment block. Read the block, find the `FILL_ME_IN` blank in the
following assertion(s), and replace it with the value the comment
teaches.

Re-run:

```sh
./bin/pilgrimage
```

When all assertions in `00_about_asserts.rexx` pass, the runner
advances to koan 01:

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts        The First Truths
  [ here ] 01 about_strings        Of the Word Made String
  [      ] 02 about_variables
  ...
```

---

## Step 3: Walk koans 01 through 05

Repeat for each koan: read the teaching block, fix the `FILL_ME_IN`(s),
re-run. The runner stops at the first failing assertion in the first
unsolved koan (the resume mechanic — User Story 2).

---

## Step 4: Closing benediction

When every assertion in every Stage I koan passes:

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts        The First Truths
  [  ok  ] 01 about_strings        Of the Word Made String
  [  ok  ] 02 about_variables      The Naming of Things
  [  ok  ] 03 about_expressions    Of Operators and Their Powers
  [  ok  ] 04 about_clauses        The Shape of an Instruction
  [  ok  ] 05 about_say            The Pilgrim Speaks

  Stations walked: 6 of 6.

  The pilgrim has walked the foundation. The path opens further.
```

Exit code: 0.

---

## Validating the spec acceptance scenarios

| Spec Acceptance | How to confirm |
|---|---|
| US1 #1 — first-run FILL_ME_IN failure | Step 1 |
| US1 #2 — fill-in advances past assertion | Step 2 |
| US1 #3 — fully solved walk + benediction | Step 4 |
| US1 #4 — every assertion has a teaching block + citation | `regina bin/lint_citations` exits 0; manual reading of any koan |
| US1 #5 — solutions verified | `regina bin/verify_solutions` exits 0 |
| US2 #1 — resume at first unsolved koan | Solve 00–02, leave 03 with FILL_ME_IN, re-run; failure surfaces in 03 |
| US2 #2 — fully solved walk | Step 4 |
| US2 #3 — same behavior on repeated runs | Run twice, compare stdout |
| US3 #1 — six [ ok ] markers on full pass | Step 4 |
| US3 #2 — [ here ] for in-progress koan | Step 1 |
| US3 #3 — monochrome output | `./bin/pilgrimage \| od -c \| grep -c '\\033'` returns 0 |

## CI parity check (optional, for contributors)

To verify locally what CI will check:

```sh
regina bin/verify_solutions          # 6/6 solutions passed.
regina bin/lint_citations            # 6/6 koans passed lint.
# Reproduce the CI runner-smoke step:
mkdir -p /tmp/koans-solved && cp solutions/*.rexx /tmp/koans-solved/
sed 's|koans/|/tmp/koans-solved/|g' koans/path_to_enlightenment.rexx > /tmp/koans-solved/path_to_enlightenment.rexx
cp koans/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx.bak
cp /tmp/koans-solved/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx
LC_ALL=C regina lib/pilgrimage.rexx > /tmp/runner-out.txt
mv koans/path_to_enlightenment.rexx.bak koans/path_to_enlightenment.rexx
tr -d '\r' < /tmp/runner-out.txt | diff -u tests/fixtures/runner_stdout.txt -
```

The final `diff` should produce no output.
