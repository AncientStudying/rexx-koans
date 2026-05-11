# Quickstart — M3 — The Path

**Feature**: `008-m3-the-path` | **Date**: 2026-05-10 | **Plan**: [plan.md](plan.md)

Local verification recipe for M3 — The Path. Run these checks
on the feature branch's HEAD prior to merge. All commands run
from the repository root.

## Prerequisites

- Regina REXX installed: `brew install regina-rexx` (macOS) or
  `sudo apt-get install -y regina-rexx` (Ubuntu/Debian).
- Verify: `regina --version`.
- Working directory clean (`git status`); on branch
  `008-m3-the-path`.

## Acceptance gates (the order CI runs them)

### 1. `verify_solutions` — 18 of 18 green (FR-014, SC-003)

```sh
bin/verify_solutions
```

Expected output: `18 of 18 solutions passed.` (or the
equivalent all-green report shape used by M2's
`bin/verify_solutions`). Exit code 0.

### 2. `lint_citations` — all-green across 18 koans + 18 solutions (FR-015, SC-004)

```sh
bin/lint_citations
```

Expected: `[ ok ]` for every file under `koans/` and
`solutions/`; the summary line matches M2.4's
`<passed>/<total> files passed lint.` shape with the totals
both at 36. Exit code 0.

### 3. `runner-smoke` — fully-solved walk byte-identical to fixture (FR-017, SC-008)

Generate the runner's stdout against the fully-solved corpus
(temporarily replace each koan with its solution; reset after):

```sh
# Stash any local changes first; this recipe writes to koans/.
for n in 06 07 08 09 10 11 12 13 14 15 16 17; do
  cp solutions/${n}_about_*.rexx koans/${n}_about_*.rexx
done
regina lib/pilgrimage.rexx > /tmp/m3.out
diff -u tests/fixtures/runner_stdout.txt /tmp/m3.out
git checkout -- koans/
```

Expected `diff` output: empty (modulo CRLF normalization on
Windows; macOS and Linux should be byte-identical).

(Note: the fixture is regenerated and committed by the
"Fixture regeneration" step in implementation; once committed,
this diff is the verification step.)

## M3-specific spot checks

### Probe 1: Scripture emission on a bound failure (SC-006)

Pick a scripture-bound koan (working selection: `07_about_select`
binding `least_astonishment`). Introduce a deliberate wrong
fill on one bound assertion. Run the runner. Confirm the
two-line Bathonian block appears between the indented
meditation diagnostic and the summary line. Revert.

```sh
# Snapshot the koan.
cp koans/07_about_select.rexx /tmp/07_orig.rexx
# Edit one CALL m 'eq' line so its expected and actual disagree.
# (Specific line depends on koan content — choose any assertion
# that is in the scripture-bound block.)
${EDITOR:-vi} koans/07_about_select.rexx
# Run the runner.
regina lib/pilgrimage.rexx
# Expected: in the failure-output band, two new lines:
#   From the Bathonian (Cowlishaw §1.4, p. 7):
#     A program should behave the way its reader expects.
# (The exact citation and text reflect the scripture entry for
#  least_astonishment in lib/scripture.rexx.)
# Revert.
cp /tmp/07_orig.rexx koans/07_about_select.rexx
```

Confirm the runner's exit code on the deliberate failure is the
koan's RC (≥2 — `lib/meditation.rexx`'s `fail_mismatch`).

### Probe 2: No scripture emission on an unbound failure (SC-006)

Pick a non-scripture-bound koan (e.g., `06_about_if` —
unbound in the working selection). Introduce a wrong fill.
Run. Confirm no scripture text appears.

```sh
cp koans/06_about_if.rexx /tmp/06_orig.rexx
${EDITOR:-vi} koans/06_about_if.rexx   # introduce wrong fill
regina lib/pilgrimage.rexx > /tmp/06_out
grep -c 'From the Bathonian' /tmp/06_out
# Expected: 0
cp /tmp/06_orig.rexx koans/06_about_if.rexx
```

### Probe 3: No scripture emission on a passing run (FR-013)

Run the fully-solved walk. Confirm no scripture text in stdout.

```sh
for n in 06 07 08 09 10 11 12 13 14 15 16 17; do
  cp solutions/${n}_about_*.rexx koans/${n}_about_*.rexx
done
regina lib/pilgrimage.rexx > /tmp/full.out
grep -c 'From the Bathonian' /tmp/full.out
# Expected: 0
git checkout -- koans/
```

### Probe 4: Scripture-bound koans count ≥ 3 (FR-011, SC-006)

Confirm at least three M3 koans have a `Scripture:` directive:

```sh
grep -l '^.*Scripture:' koans/0[6-9]_*.rexx koans/1[0-7]_*.rexx | wc -l
# Expected: 3 (or more, if the implementation adds a fourth/fifth
# binding per spec Assumptions).
```

Spot-check the bound koans match the working selection:

```sh
grep -E '^.*Scripture: ' koans/0[6-9]_*.rexx koans/1[0-7]_*.rexx
# Expected lines (working selection):
#   koans/07_about_select.rexx: * Scripture: least_astonishment
#   koans/12_about_string_functions.rexx: * Scripture: everything_is_string
#   koans/14_about_arithmetic_functions.rexx: * Scripture: numbers_are_strings_too
```

### Probe 5: Scripture directive parity in solutions (FR-002, SC-010)

Each scripture-bound koan's matching solution carries the same
directive verbatim:

```sh
diff <(grep -E '^.*Scripture: ' koans/07_about_select.rexx) \
     <(grep -E '^.*Scripture: ' solutions/07_about_select.rexx)
# Expected: empty diff. Repeat for 12 and 14.
```

### Probe 6: M2.5 forward-style — zero matches (FR-004, FR-005, SC-013)

```sh
grep -rE 'n = n \+ 1; *CALL m' koans/ solutions/
grep -rE "CALL m '[a-z]+', [^,]+, [^,]+, n\b" koans/ solutions/
# Both expected: empty.
```

### Probe 7: Stage I files unchanged (Plan Constraints)

```sh
git diff main -- koans/0[0-5]_*.rexx solutions/0[0-5]_*.rexx \
                 lib/meditation.rexx lib/stations.rexx \
                 bin/ docs/cowlishaw_index.md
# Expected: empty.
```

The runner-smoke fixture diff vs. main is the *one* file outside
the new koans/solutions and lib/scripture.rexx that legitimately
changes:

```sh
git diff --stat main -- tests/fixtures/runner_stdout.txt
# Expected: a file change reflecting the 6→18 row expansion.
```

### Probe 8: Path manifest correctness (FR-009)

```sh
grep '^koans\.0 ' koans/path_to_enlightenment.rexx
# Expected: koans.0 = 18

grep -c "^koans\.[0-9]\+ = 'koans/" koans/path_to_enlightenment.rexx
# Expected: 18
```

### Probe 9: Scripture library lookup sanity (FR-010)

```sh
regina -e "CALL 'lib/scripture.rexx' 'fetch', 'least_astonishment'; SAY RESULT"
# Expected: "<principle text>" + TAB + "<citation>"
# e.g.: "A program should behave the way its reader expects.	Cowlishaw §1.4, p. 7"

regina -e "CALL 'lib/scripture.rexx' 'fetch', 'unknown_key'; SAY RESULT"
# Expected: empty line (the empty-string fallback for unknown keys).
```

## CI verification (FR-018, SC-007)

Push the feature branch:

```sh
git push origin 008-m3-the-path
```

Then watch GitHub Actions: 6 checks on the feature branch HEAD
must report `success`:

| Step | Runner | Check |
|---|---|---|
| `verify_solutions` | ubuntu-latest | 18 of 18 |
| `verify_solutions` | macos-latest | 18 of 18 |
| `lint_citations` | ubuntu-latest | all-green |
| `lint_citations` | macos-latest | all-green |
| `runner-smoke` | ubuntu-latest | byte-identical to fixture |
| `runner-smoke` | macos-latest | byte-identical to fixture |

A red check on any of these is a merge blocker.

## Implementation hints (non-normative)

- **Implementation order** (per research.md §6):
  1. `lib/scripture.rexx` first.
  2. `lib/pilgrimage.rexx` extension second; UAT against a
     deliberate Stage I wrong fill (output unchanged from M2).
  3. Stage II koans + solutions (06 → 11), in numeric order,
     each with manifest update.
  4. Stage III koans + solutions (12 → 17), in numeric order,
     each with manifest update.
  5. Final fixture regeneration commit.
- **Per-koan order** (per Constitution Principle I):
  teaching prose first → solution second → koan derived from
  solution → confirm runner stops on FILL_ME_IN → confirm
  runner advances on solution value → for scripture-bound koans,
  confirm the FR-012 block appears on a deliberate wrong fill.
- **Citations**: every Cowlishaw citation in every M3 koan and
  solution MUST resolve against `docs/cowlishaw_index.md`.
  M2.4's lint join enforces.
- **Voice**: every teaching block addresses the pilgrim in
  second person; humor is restrained; failure messages are
  diagnostic-first.
