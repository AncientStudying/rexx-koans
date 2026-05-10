# Quickstart — M2.3 Local Verification

This document is the contributor-side recipe for verifying the
M2.3 vocabulary review locally before pushing. It mirrors the CI
matrix (`verify_solutions`, `lint_citations`, `runner-smoke`) and
adds three M2.3-specific spot checks.

## Prerequisites

- macOS or Linux with Regina REXX installed
  (`brew install regina-rexx` on macOS;
  `sudo apt-get install -y regina-rexx` on Ubuntu).
- A clean working tree on branch `005-vocab-review` with the
  vocabulary substitutions applied (`koans/00–05_about_*.rexx`,
  `solutions/00–05_about_*.rexx`).
- Optional: a local copy of *The REXX Language* 2nd edition PDF
  at `reference/REXX Language - 2nd Edition.pdf` (gitignored).
  The Internet Archive scan linked from `README.md` is an
  acceptable substitute for spot checks.

## Step 1 — `bin/verify_solutions`

Confirms every solution still runs green under the assertion
machinery.

```sh
bin/verify_solutions
```

Expected: `6/6 solutions passed.`, exit code 0. M2.3 only edits
comment-block prose, so green-ness is by construction; this step
catches accidental edits outside the comment blocks.

## Step 2 — `bin/lint_citations`

Confirms every koan still carries a canonical-form citation. M2.3
does not modify `bin/lint_citations` (FR-010); it inherits the
canonical-form check delivered by M2.2.

```sh
bin/lint_citations
```

Expected: `6/6 koans passed lint.`, exit code 0. Every line should
report `[ ok ]`.

The M2.3 layered-prose blocks (in koan 00) and the targeted
re-label (in koan 01) introduce new in-prose parenthetical
Cowlishaw references. Each new parenthetical satisfies the M2.2
canonical-form check by construction (it is a
`Cowlishaw §<sec>, p. <page>` in canonical form, with or without
the optional ` — <heading>` suffix per the index row's collision
status). No lint failure expected.

## Step 3 — Runner smoke walk + fixture diff

Confirms `tests/fixtures/runner_stdout.txt` is unchanged. The
recipe mirrors the `runner-smoke` step in
`.github/workflows/verify.yml` exactly: build a shadow
`koans-solved/` directory with every solution copied in as a
koan, swap in a temporary path manifest, run the runner, restore
the manifest, normalize CRLF, and diff.

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

Expected: empty diff, exit code 0. M2.3 must not change runner
output (FR-008); the diff is the canary. Teaching prose lives in
comment blocks and is never echoed.

If the recipe in `.github/workflows/verify.yml` ever drifts from
this documented form, prefer the workflow as the source of truth
and update this step accordingly.

## Step 4 — M2.3-specific spot check: substitution-table coverage

Confirms every row in `research.md` §2 has been applied to every
file listed in its "Files affected" column.

```sh
# Negative check: none of the source strings should remain.
# Each grep should produce zero matches.
grep -nF 'no separate character literal'  koans/01_about_strings.rexx
grep -nF 'Concept: uninitialized symbols.' koans/02_about_variables.rexx solutions/02_about_variables.rexx
grep -nF 'unbound symbol NEVER_SET'        koans/02_about_variables.rexx
grep -nF 'Quoted strings are case-sensitive' koans/02_about_variables.rexx solutions/02_about_variables.rexx
grep -nF 'arithmetic, comparison,'         koans/03_about_expressions.rexx
grep -nF 'Concept: comparison.'            koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'numeric coercion'                koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'is strict and compares the literal characters' koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'is AND,'                         koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'truth values of REXX'            koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'are concatenated.'               koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'blank concatenation'             koans/03_about_expressions.rexx solutions/03_about_expressions.rexx koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'forces concatenation'            koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'boundary of one clause'          koans/04_about_clauses.rexx
grep -nF 'A comma at the end of a line continues' koans/04_about_clauses.rexx solutions/04_about_clauses.rexx
grep -nF 'opens with slash-star'           koans/04_about_clauses.rexx solutions/04_about_clauses.rexx
grep -nF 'standard output'                 koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'blank-concatenates'              koans/05_about_say.rexx
grep -nF 'Two operands separated by'       koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'The empty string has length zero' koans/05_about_say.rexx solutions/05_about_say.rexx
```

Each grep above MUST produce zero matches. If any source string
survives, the corresponding row in `research.md` §2 was not
applied (or was applied to fewer files than its "Files affected"
column lists). Re-apply and re-run.

```sh
# Positive check: every replacement should appear.
grep -nF 'no separate character type'            koans/01_about_strings.rexx
grep -nF 'Concept: uninitialized variables.'     koans/02_about_variables.rexx solutions/02_about_variables.rexx
grep -nF 'uninitialized variable NEVER_SET'      koans/02_about_variables.rexx
grep -nF 'Literal strings are case-sensitive'    koans/02_about_variables.rexx solutions/02_about_variables.rexx
grep -nF 'arithmetic, comparative,'              koans/03_about_expressions.rexx
grep -nF 'Concept: comparative operators.'       koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'normal comparison'                     koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'is a strict comparison'                koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'is And,'                               koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'Logical (Boolean) values'              koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'concatenated by abuttal'               koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'blank operator inserts'                koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'joins without a blank'                 koans/03_about_expressions.rexx solutions/03_about_expressions.rexx
grep -nF 'implies the semicolon at the end'      koans/04_about_clauses.rexx
grep -nF 'A continuation character (a comma)'    koans/04_about_clauses.rexx solutions/04_about_clauses.rexx
grep -nF 'opens with `/*` and closes with `*/`'  koans/04_about_clauses.rexx solutions/04_about_clauses.rexx
grep -nF 'default character output stream'       koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'joins by the blank operator'           koans/05_about_say.rexx
grep -nF 'Concept: the blank operator in SAY context.' koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'Two terms separated by whitespace'     koans/05_about_say.rexx solutions/05_about_say.rexx
grep -nF 'The null string has length zero'       koans/05_about_say.rexx solutions/05_about_say.rexx
```

Each grep MUST produce one or more matches in every file listed.

## Step 5 — M2.3-specific spot check: koan 00 framework-vs-REXX layering

Confirms koan 00's four concept blocks present the framework
verb and the REXX mechanism as two distinct things (FR-002 /
US3).

```sh
# Each concept block in koan 00 must mention both layers.
# `assertion verb` introduces the framework layer.
# `comparative operator` / `Logical (Boolean)` / `DATATYPE` introduces the REXX layer.
grep -c 'assertion verb'             koans/00_about_asserts.rexx
grep -c 'comparative operator'       koans/00_about_asserts.rexx
grep -c 'Logical (Boolean)'          koans/00_about_asserts.rexx
grep -c 'DATATYPE'                   koans/00_about_asserts.rexx
```

Expected: `assertion verb` ≥ 4 (one per concept block), each REXX
mechanism term ≥ 1 (in the relevant block). Solution 00 must
satisfy a similar pattern; the body wording differs but the
vocabulary terms above must appear.

## Step 6 — M2.3-specific spot check: per-substitution parity (FR-004)

Confirms that every term in the substitution table that appears
in both a koan and its matching solution carries the canonical
form on both sides.

```sh
# For each (koan, solution) pair, list any line containing a substituted-source term.
# All greps below MUST return zero hits.
for n in 00 01 02 03 04 05; do
  echo "=== ${n} ==="
  grep -nE 'Quoted strings|truth values of REXX|standard output|blank concatenation|empty string has length zero|numeric coercion|is AND,|forces concatenation|opens with slash-star|A comma at the end of a line continues|Concept: comparison\.|Concept: uninitialized symbols\.|Concept: blank concatenation' \
    "koans/${n}_about_"*.rexx "solutions/${n}_about_"*.rexx
done
```

Expected: no output for any pair. If hits surface, the substitution
was applied to one side of the pair but not the other; identify
and re-apply.

## Push and CI

When all six steps pass locally:

```sh
git push -u origin 005-vocab-review
```

GitHub Actions runs `verify.yml` on push and on PR open. The 6/6
CI matrix (`verify_solutions` × 2 OS, `lint_citations` × 2 OS,
`runner-smoke` × 2 OS) is the merge gate per Constitution
Principle IV and spec SC-005.

## Optional pilgrim spot-check (US1 acceptance)

For any single rewritten teaching block, open `docs/cowlishaw_index.md`
to the row whose §N.N + book page matches the in-prose Cowlishaw
parenthetical (or the trailing citation), and confirm the
`Vocabulary:` column actually contains the canonical term the
prose now uses. This is the user-facing acceptance test for US1
in `spec.md`; it is not mechanizable in CI but is a 30-second
spot check per substitution.

PDF↔book offset reminder for cross-referencing the source: book
p. N = PDF p. N + 11. Open the PDF to PDF p. (citation_page + 11)
to land on book p. citation_page.
