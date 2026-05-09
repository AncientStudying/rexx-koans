# Quickstart — M2.2 Local Verification

This document is the contributor-side recipe for verifying the M2.2
citation rewrite locally before pushing. It mirrors the CI matrix
(verify_solutions, lint_citations, runner-smoke) and adds two
M2.2-specific spot checks.

## Prerequisites

- macOS or Linux with Regina REXX installed
  (`brew install regina-rexx` on macOS; `sudo apt-get install -y regina-rexx` on Ubuntu).
- A clean working tree on branch `004-m2-2-citation-rewrite` with the
  rewrite applied (`koans/`, `solutions/`, `bin/lint_citations`,
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`).
- Optional: a local copy of *The REXX Language* 2nd edition PDF at
  `reference/REXX Language - 2nd Edition.pdf` (gitignored). The
  Internet Archive scan linked from `README.md` is an acceptable
  substitute for spot checks.

## Step 1 — `bin/verify_solutions`

Confirms every solution still runs green under the assertion machinery.

```sh
bin/verify_solutions
```

Expected: `6/6 solutions passed.`, exit code 0. M2.2 does not touch
runtime code paths, so green-ness is by construction; this step
catches accidental edits outside the comment blocks.

## Step 2 — `bin/lint_citations`

Confirms every koan carries a canonical-form citation.

```sh
bin/lint_citations
```

Expected: `6/6 koans passed lint.`, exit code 0. Every line should
report `[ ok ]`.

### Negative spot-check (optional but recommended)

Verify the tightened regex actually rejects non-canonical forms.
In a sandbox copy of any koan, temporarily change one citation to
each of these and re-run lint:

| Sandbox edit | Expected lint result |
|---|---|
| `Cowlishaw §2.5, p. 32 -- Foo` (legacy `--`) | `[FAIL]` with `MISSING citation` |
| `Cowlishaw §2.5, p. 32—Foo` (no spaces) | `[FAIL]` with `MISSING citation` |
| `Cowlishaw §2.5, p. 32 garbage` | `[FAIL]` with `MISSING citation` |

Then revert the sandbox edit; lint should return `[ ok ]`.

## Step 3 — Runner smoke walk + fixture diff

Confirms `tests/fixtures/runner_stdout.txt` is unchanged. The recipe
below mirrors the `runner-smoke` step in
`.github/workflows/verify.yml` exactly: build a shadow
`koans-solved/` directory with every solution copied in as a koan,
swap in a temporary path manifest, run the runner, restore the
manifest, normalize CRLF, and diff.

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

Expected: empty diff, exit code 0. M2.2 must not change runner
output (FR-010); the diff is the canary.

If the recipe in `.github/workflows/verify.yml` ever drifts from this
documented form, prefer the workflow as the source of truth and
update this step accordingly.

## Step 4 — M2.2-specific spot check: audit-row coverage

Confirms every `docs/M2_FOLLOWUP.md` audit row is closed by a
canonical-form citation in the corpus.

For each of the 11 audit rows (`docs/M2_FOLLOWUP.md` "Audit findings
(2026-05-08)" table), find the corresponding citation in the koan
or solution and verify:

| Audit row | New citation expected (per `research.md` §1) | File(s) |
|---|---|---|
| 1 | `Cowlishaw §1.1, p. 1` | `00_about_asserts.rexx` |
| 2 | `Cowlishaw §2.2, p. 19 — Literal strings` | `01_about_strings.rexx` |
| 3 | `Cowlishaw §2.3, p. 27 — Numbers` | `01_about_strings.rexx` |
| 4 (general) | `Cowlishaw §2.3, p. 24` | `03_about_expressions.rexx` |
| 4 (Arithmetic) | `Cowlishaw §2.3, p. 25 — Arithmetic` | `03_about_expressions.rexx` |
| 5 | `Cowlishaw §2.3, p. 26` | `00_about_asserts.rexx`, `03_about_expressions.rexx` |
| 6 | `Cowlishaw §2.3, p. 27 — Logical (Boolean)` | `03_about_expressions.rexx` |
| 7 | `Cowlishaw §2.3, p. 25 — Concatenation` | `03_about_expressions.rexx` |
| 8 (Clauses) | `Cowlishaw §2.4, p. 31` | `04_about_clauses.rexx` |
| 8 (Continuation) | `Cowlishaw §2.2, p. 23` | `04_about_clauses.rexx` |
| 9 | `Cowlishaw §2.2, p. 18 — Comments` | `04_about_clauses.rexx` |
| 10 | `Cowlishaw §2.5, p. 32` | `00_about_asserts.rexx`, `02_about_variables.rexx` |
| 11 | `Cowlishaw §2.7, p. 70` | `05_about_say.rexx` |

```sh
grep -nE 'Cowlishaw §' koans/*.rexx solutions/*.rexx
```

The output should contain only the 14 distinct canonical-form
strings listed in `research.md` §1 rewrite table; no occurrence of
`-- ` (legacy ASCII separator) should remain.

## Step 5 — M2.2-specific spot check: koan/solution byte-parity

Confirms `koans/NN_about_x.rexx` and `solutions/NN_about_x.rexx`
have byte-identical citation lines (FR-003, SC-003).

```sh
for n in 00 01 02 03 04 05; do
  diff \
    <(grep -E 'Cowlishaw §' "koans/${n}_about_"*.rexx) \
    <(grep -E 'Cowlishaw §' "solutions/${n}_about_"*.rexx)
done
```

Expected: no output (empty diffs across all six pairs).

## Step 6 — Index-row spot check (optional, against the PDF)

For any single citation, confirm the cited book page in the cited
section visibly covers the concept the surrounding teaching block
teaches. The Internet Archive scan is sufficient.

PDF↔book offset reminder: book p. N = PDF p. N + 11. Open the PDF
to PDF p. (citation_page + 11) to land on book p. citation_page.

This is the user-facing acceptance test for US1 in `spec.md`; it is
not mechanizable in CI but is a 30-second spot check per citation.

## Push and CI

When all six steps pass locally:

```sh
git push -u origin 004-m2-2-citation-rewrite
```

GitHub Actions runs verify.yml on push and on PR open. The 6/6 CI
matrix (verify_solutions × 2 OS, lint_citations × 2 OS,
runner-smoke × 2 OS) is the merge gate per Constitution Principle IV
and spec SC-005.
