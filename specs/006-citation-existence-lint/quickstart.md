# Quickstart — M2.4 Local Verification

This document is the contributor-side recipe for verifying the
M2.4 mechanical citation existence check locally before pushing.
It mirrors the CI matrix (`verify_solutions`, `lint_citations`,
`runner-smoke`) and adds three M2.4-specific spot checks (the
two negative spot-checks for SC-003 / SC-004 plus the
all-resolves-on-first-run check for US2).

## Prerequisites

- macOS or Linux with Regina REXX installed
  (`brew install regina-rexx` on macOS;
  `sudo apt-get install -y regina-rexx` on Ubuntu).
- A clean working tree on branch `006-citation-existence-lint`
  with the M2.4 lint extension applied to `bin/lint_citations`.
- `docs/cowlishaw_index.md` present at HEAD (M2.1 deliverable;
  byte-identical to `main`).

## Step 1 — `bin/verify_solutions`

Confirms every solution still runs green under the assertion
machinery. M2.4 doesn't touch koans, solutions, or framework
code, so green-ness is by construction.

```sh
bin/verify_solutions
```

Expected: `6/6 solutions passed.`, exit code 0.

## Step 2 — `bin/lint_citations` (M2.4-extended)

Confirms every koan and every solution carries citations that
resolve to a row in `docs/cowlishaw_index.md`.

```sh
bin/lint_citations
```

Expected:

```
[ ok ] koans/00_about_asserts.rexx
[ ok ] koans/01_about_strings.rexx
[ ok ] koans/02_about_variables.rexx
[ ok ] koans/03_about_expressions.rexx
[ ok ] koans/04_about_clauses.rexx
[ ok ] koans/05_about_say.rexx
[ ok ] solutions/00_about_asserts.rexx
[ ok ] solutions/01_about_strings.rexx
[ ok ] solutions/02_about_variables.rexx
[ ok ] solutions/03_about_expressions.rexx
[ ok ] solutions/04_about_clauses.rexx
[ ok ] solutions/05_about_say.rexx

12/12 files passed lint.
```

Exit code 0.

## Step 3 — Runner smoke walk + fixture diff

Confirms `tests/fixtures/runner_stdout.txt` is unchanged. The
recipe mirrors the `runner-smoke` step in
`.github/workflows/verify.yml`. M2.4 must not change runner
output (FR-012); the diff is the canary. Lint behavior is
tooling-only and the runner ignores it.

```sh
set -euo pipefail
rm -rf koans-solved
mkdir koans-solved
cp solutions/*.rexx koans-solved/
sed 's|koans/|koans-solved/|g' koans/path_to_enlightenment.rexx > koans-solved/path_to_enlightenment.rexx
cp koans/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx.bak
cp koans-solved/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx
LC_ALL=C regina lib/pilgrimage.rexx > runner-out.txt
mv koans/path_to_enlightenment.rexx.bak koans/path_to_enlightenment.rexx
tr -d '\r' < runner-out.txt > runner-out.normalized
diff -u tests/fixtures/runner_stdout.txt runner-out.normalized
```

Expected: empty diff, exit code 0.

## Step 4 — M2.4-specific spot check: negative §+page (SC-003)

Confirms a fabricated citation is rejected with reason variant
1 (no row).

```sh
# Introduce a fabricated citation in a sandbox koan. Use a
# dedicated comment block so the original prose is unaffected
# and easy to revert.
cat >> koans/05_about_say.rexx.sandbox <<'SANDBOX'
SANDBOX
# Backup the file first.
cp koans/05_about_say.rexx koans/05_about_say.rexx.bak

# Inject the fabricated citation as a temporary line in a
# top-of-file comment.
sed -i.tmp '1 a\
 * SANDBOX: Cowlishaw §99.99, p. 999\
' koans/05_about_say.rexx

# Run lint and expect a [FAIL] line for koans/05_about_say.rexx
# with the variant-1 reason.
bin/lint_citations
echo "(expect exit code != 0)"

# Revert the sandbox edit.
mv koans/05_about_say.rexx.bak koans/05_about_say.rexx
rm -f koans/05_about_say.rexx.tmp koans/05_about_say.rexx.sandbox

# Confirm green again.
bin/lint_citations
```

Expected during the rejection step:

```
... (other files [ ok ] lines) ...
[FAIL] koans/05_about_say.rexx
  UNRESOLVED citation: Cowlishaw §99.99, p. 999 (no §99.99 + p. 999 row in docs/cowlishaw_index.md)
... (other files) ...

11/12 files passed lint.
```

Exit code 1.

After revert, expected: `12/12 files passed lint.`, exit code 0.

## Step 5 — M2.4-specific spot check: suffix mismatch (SC-004)

Confirms a fabricated suffix at a valid (§sec, page) is rejected
with reason variant 2 (heading mismatch with verbatim
alternatives).

```sh
# Backup the target file.
cp koans/02_about_variables.rexx koans/02_about_variables.rexx.bak

# Inject a fabricated suffix at a valid (§sec, page) — §2.5 has
# children at p.32 (Assignments etc.); 'Bogus Heading' won't
# match.
sed -i.tmp '1 a\
 * SANDBOX: Cowlishaw §2.5, p. 32 — Bogus Heading\
' koans/02_about_variables.rexx

# Run lint and expect a [FAIL] line for koans/02_about_variables.rexx
# with the variant-2 reason listing the valid alternatives.
bin/lint_citations
echo "(expect exit code != 0)"

# Revert.
mv koans/02_about_variables.rexx.bak koans/02_about_variables.rexx
rm -f koans/02_about_variables.rexx.tmp

# Confirm green again.
bin/lint_citations
```

Expected during the rejection step:

```
... (other files [ ok ]) ...
[FAIL] koans/02_about_variables.rexx
  UNRESOLVED citation: Cowlishaw §2.5, p. 32 — Bogus Heading (heading "Bogus Heading" does not match index row "<comma-joined verbatim children at §2.5+p.32>")
... (other files) ...

11/12 files passed lint.
```

The exact `<comma-joined ...>` content depends on which `###`
children sit at (§2.5, p.32) in the current index. Examples
typical for §2.5: `"Assignments"`, etc. The reason text
literally lists every verbatim alternative.

Exit code 1.

After revert: `12/12 files passed lint.`, exit code 0.

## Step 6 — M2.4-specific spot check: bootstrap error (FR-010)

Confirms lint exits non-zero when `docs/cowlishaw_index.md` is
missing or empty.

```sh
# Backup the index.
cp docs/cowlishaw_index.md docs/cowlishaw_index.md.bak

# Empty the index temporarily.
: > docs/cowlishaw_index.md

# Run lint and expect a bootstrap error.
bin/lint_citations
echo "(expect exit code != 0; expect [BOOTSTRAP] line)"

# Revert.
mv docs/cowlishaw_index.md.bak docs/cowlishaw_index.md

# Confirm green again.
bin/lint_citations
```

Expected during the rejection step:

```
[BOOTSTRAP] cannot build lookup table: docs/cowlishaw_index.md is empty
```

Exit code 1.

After revert: `12/12 files passed lint.`, exit code 0.

## Step 7 — Mechanical out-of-scope checks

Confirms FR-012 (runner fixture unchanged), FR-013 (index
unchanged), and FR-015 (no koan/solution edits committed).

```sh
git diff main -- tests/fixtures/runner_stdout.txt
echo "(expect empty)"

git diff main -- docs/cowlishaw_index.md
echo "(expect empty)"

git diff main -- koans/ solutions/
echo "(expect empty)"
```

Each should emit no output. If any does, an out-of-scope file
was modified; revert before commit.

## Push and CI

When all seven steps pass locally:

```sh
git push -u origin 006-citation-existence-lint
```

GitHub Actions runs `verify.yml` on push and on PR open. The
matrix (`verify_solutions` × 2 OS, `lint_citations` × 2 OS,
`runner-smoke` × 2 OS = 6 named checks; reported by GitHub as
2 jobs in the PR Checks UI) is the merge gate per Constitution
Principle IV and spec SC-005.

## Optional: parser sanity walk

A one-off verification that `bin/lint_citations`'s index parser
agrees with the human-readable index. Pick three known rows
that share or diverge in (§sec, page) and check lookup outcomes
manually. (Not mechanizable in CI; useful during implementation
to catch parser bugs before the per-file scan reveals them
indirectly.)

For example:

- (§2.2, p. 19) — multiple `###` children share this key
  (`Literal strings`, `Hexadecimal Strings`, `Binary Strings`,
  ...). Confirm the lookup table at this key has all of them.
- (§2.5, p. 32) — primarily a `## §2.5` parent row with `###`
  children (`Assignments`, etc.). Confirm `has_parent = 1` and
  the heading list is non-empty.
- (§2.9, p. 91) — `### DATATYPE` child of §2.9. Confirm the key
  resolves and contains exactly `DATATYPE`.

If the lookup-table values diverge from the index file's
human-readable structure, the parser has a bug and the
implementation halts.
