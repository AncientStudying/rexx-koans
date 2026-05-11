# Data Model — M3 — The Path

**Feature**: `008-m3-the-path` | **Date**: 2026-05-10 | **Plan**: [plan.md](plan.md)

The M3 "data model" is mostly a set of source-file conventions
plus a small handful of runtime stem variables in the runner.
There is no persisted state; the runner re-derives every fact
from the source tree on each invocation (per PLAN §5: "no state
file is required because correctness is re-derived from the
sources on each run").

## Entities

### E1 — Stage II koan

A REXX source file under `koans/` numbered 06 through 11 that
teaches one control-flow construct from `Cowlishaw §2.7`.

**Path pattern**: `koans/<NN>_about_<topic>.rexx` where `<NN>` is
zero-padded two-digit and `<topic>` matches `[a-z_]+`.

**Required structure** (top to bottom):

| Element | Required | Notes |
|---|---|---|
| Leading comment block (`/* ... */`) | Yes | Contains the koan's filename, a `Station: <subtitle>` directive (FR-007), an optional file-level Cowlishaw citation, and an introductory paragraph. |
| `n = 0` initializer | Yes | The single counter surface visible to the pilgrim. M2.5 §8 style rule. |
| One or more teaching blocks | Yes | Each preceded by `/* Concept: <heading> ... */` block ending with at least one Cowlishaw citation. May contain a `Scripture: <key>` directive (per FR-024). |
| `CALL m '<verb>', <expected>, <actual>` lines | Yes | Single-statement assertion lines per FR-003. M2.5-cleaned shape only — no `n = n + 1;` prefix, no trailing `, n` argument. |
| `EXIT 0` | Yes | Standard koan terminator. |
| `m:` wrapper | Yes | Three-arg `(kind, arg1, arg2)`, label-based subroutine, increments `n` internally, delegates to `lib/meditation.rexx`. Carries the koan's own filename as the third argument to the meditation CALL. |

**Concrete topics**:

| File | Cowlishaw subject |
|---|---|
| `06_about_if.rexx` | IF/THEN/ELSE (§2.7, p. 54) |
| `07_about_select.rexx` | SELECT/WHEN/OTHERWISE/END (§2.7, p. 71); scripture-bound to `least_astonishment` |
| `08_about_do_loops.rexx` | DO group, controlled DO, WHILE, UNTIL, FOREVER (§2.7, p. 47) |
| `09_about_iterate_leave.rexx` | ITERATE (§2.7, p. 57), LEAVE (§2.7, p. 58) |
| `10_about_signal.rexx` | non-local transfer via SIGNAL labelname (§2.7, p. 72) |
| `11_about_interpret.rexx` | runtime evaluation via INTERPRET (§2.7, p. 55) |

**Scripture binding (entity reference)**: at most one
`Scripture: <key>` directive per teaching comment block per
E1 instance. Working list: 07 binds `least_astonishment`.

### E2 — Stage III koan

A REXX source file under `koans/` numbered 12 through 17 that
teaches one family of built-in functions from `Cowlishaw §2.9`.

Same structural requirements as E1.

**Concrete topics**:

| File | Cowlishaw subjects (built-ins) |
|---|---|
| `12_about_string_functions.rexx` | LENGTH, SUBSTR, POS, LEFT, RIGHT, COPIES, TRANSLATE; scripture-bound to `everything_is_string` |
| `13_about_word_functions.rexx` | WORD, WORDS, WORDPOS, WORDLENGTH, SUBWORD, WORDINDEX |
| `14_about_arithmetic_functions.rexx` | ABS, MAX, MIN, TRUNC, FORMAT, SIGN; scripture-bound to `numbers_are_strings_too` |
| `15_about_conversion_functions.rexx` | D2X, X2D, C2X, X2C, B2X, X2B, D2C, C2D |
| `16_about_bit_functions.rexx` | BITAND, BITOR, BITXOR |
| `17_about_misc_functions.rexx` | DATATYPE, DATE, TIME, RANDOM, ADDRESS-built-in (NOT the ADDRESS instruction) |

### E3 — Solution file

A REXX source file under `solutions/` whose filename matches a
koan in E1 or E2 byte-for-byte. Structurally identical to its
matching koan except that every `FILL_ME_IN` symbol is replaced
by the canonical answer value, and the `m:` wrapper's third
argument names the solution path (e.g.,
`'solutions/06_about_if.rexx'`).

**Invariant** (FR-002, SC-010): for any pair, `diff
koans/NN_about_*.rexx solutions/NN_about_*.rexx` returns hunks
consisting solely of `FILL_ME_IN` ↔ value substitutions and the
single-character `'koans/'` ↔ `'solutions/'` wrapper-path
substitution.

### E4 — Path manifest

The file `koans/path_to_enlightenment.rexx`. Declares the
ordered list of koan paths the runner walks.

**Post-M3 shape** (FR-009):

```rexx
/* koans/path_to_enlightenment.rexx — master ordering for the pilgrim's path.
 *
 * Contract: specs/002-m2-walking-skeleton/contracts/path_manifest.md.
 * CALL'd shared-scope from lib/pilgrimage.rexx; populates the koans. stem.
 * Stages append by incrementing koans.0 and adding a koans.<n> entry.
 */

koans.0 = 18
koans.1 = 'koans/00_about_asserts.rexx'
koans.2 = 'koans/01_about_strings.rexx'
... (16 more entries through koans/17_about_misc_functions.rexx) ...
RETURN
```

The contract format from `specs/002-m2-walking-skeleton/contracts/path_manifest.md`
is unchanged; only the count and the entry list grow.

### E5 — Scripture entry

A `(key, principle text, citation)` triple defined in
`lib/scripture.rexx`.

**Required keys** (FR-010, per PLAN §9):

| Key | Principle text | Citation |
|---|---|---|
| `humans_not_machines` | (working text per research.md §2; refinable during implementation) | (resolved against `docs/cowlishaw_index.md`) |
| `least_astonishment` | (working) | (resolved) |
| `everything_is_string` | (working) | (resolved) |
| `read_aloud` | (working) | (resolved) |
| `consistency` | (working) | (resolved) |
| `whitespace_matters_just_enough` | (working) | (resolved) |
| `numbers_are_strings_too` | (working) | (resolved) |

**Identity**: the key is the unique handle (URL-safe lowercase
with underscores; matches `[a-z_]+`).

**Lookup contract**: `CALL 'lib/scripture.rexx' 'fetch', key`
returns `<principle> '09'x <citation>` for known keys; empty
string for unknown keys. See `contracts/scripture_library.md`.

### E6 — Scripture binding

A runtime relationship from a specific failed assertion (in a
specific koan, at a specific source line N) to a specific
`Scripture: <key>` directive in that koan's source.

**Source-side declaration** (FR-024): the directive
`Scripture: <key>` on a single line inside a teaching comment
block; key matches `[a-z_]+`; key SHOULD resolve in
`lib/scripture.rexx` (an unresolved key falls back to no
emission per E5's empty-string return).

**Runtime resolution** (FR-025): on a failed koan subprocess,
the runner walks the failed koan's source backward from
line N − 1 toward line 1; the first event reached determines
the binding (a `Scripture:` directive line → bound to that key;
a `/*` line → unbound). See research.md §1 for the algorithm.

**Scope rule** (FR-024 block-scoped, Clarifications Q2): the
directive binds every `CALL m` line that follows it in source
order, up to the start of the next teaching comment block (next
`/*`) or end-of-file. A multi-assertion teaching block binds
once.

**Constraint**: at most one `Scripture:` directive per teaching
comment block (FR-024).

### E7 — Station subtitle

The `Station: <text>` directive in a koan's leading comment
block. Harvested by `lib/stations.rexx`'s `extract_subtitle`
for the station-list display.

**Required form**: `Station: <text>` on a single line inside the
leading comment block (the same comment block where the
filename and any file-level citation appear). `<text>` is
free-form prose in the pilgrim-voice register.

**Constraints** (FR-007):
- Unique across the manifest (no two koans share a subtitle).
- Conforms to the pilgrim-voice register of PLAN §11 (short,
  plain, lightly metaphorical, no plot).

**Working list for the twelve new subtitles**: see research.md
§4. PLAN §11 fixes 06 (At the Branch of the Road), 07 (Of Many
Ways), 08 (The Returning of the Path).

### E8 — Runner-smoke fixture

The file `tests/fixtures/runner_stdout.txt`. The byte-for-byte
expected stdout of `bin/pilgrimage` against the fully-solved
corpus.

**Post-M3 content**: see research.md §3 for the expected
shape. Eighteen station rows + summary + benediction. The
benediction line reads
`The pilgrim has walked the foundation, the path, and the tools. The path opens further.`
(Clarifications Q3, FR-016).

**Regeneration recipe**: see research.md §3.

**CI gate**: `runner-smoke` × {ubuntu-latest, macos-latest}
diffs the runner's stdout against this fixture; any non-CRLF
difference fails CI (FR-018, SC-008).

### E9 — Cowlishaw index

The file `docs/cowlishaw_index.md`. The M2.1 whole-book
structural index. Authority for every M3 citation.

**Read-only in M3**: M3 is a citation *consumer*, not a citation
*producer* of the index. M3 adds many citations to its koans and
solutions; every one MUST resolve to an existing index row.
Index entries are not edited in M3; if implementation discovers
an index defect, it is escalated as a one-row M2.1 amendment
in a separate commit (per the M2.4 spec's same convention).

## Relationships

| From | To | Cardinality | Constraint |
|---|---|---|---|
| Stage II/III koan (E1, E2) | Solution file (E3) | 1:1 | Filenames match byte-for-byte. |
| Path manifest (E4) | Stage I/II/III koan (E1, E2 + Stage I) | 1:18 | Eighteen ordered entries; numeric prefix is the order. |
| Stage II/III koan (E1, E2) | Cowlishaw index row (E9) | N:M | Every teaching block citation joins to one or more index rows; the M2.4 lint check enforces. |
| Stage II/III koan (E1, E2) | Scripture entry (E5) | N:0..1 (per teaching block) | At most one `Scripture:` directive per teaching block. The directive's key MUST be one of E5's known keys. |
| Scripture binding (E6) | Scripture entry (E5) | N:1 | Many bindings (across many failed assertions over time) resolve to one entry per key. |
| Scripture binding (E6) | Cowlishaw index row (E9) | N:1 | Through the entry — the entry's citation joins to one index row. |
| Stage II/III koan (E1, E2) | Station subtitle (E7) | 1:1 | Each koan declares one subtitle. |
| Runner-smoke fixture (E8) | Path manifest (E4) | 1:1 | The fixture's station-list ordering and content derives from the manifest. |

## Lifecycle / state transitions

The only lifecycle in M3 is a **per-pilgrim, per-station**
state in the runner's display:

```
[      ]  →  [ here ]  →  [  ok  ]
 (blank)     (current)    (passed)
```

A station starts blank (the manifest names it but the pilgrim
hasn't reached it). When the runner subprocess for that koan
fails, the station is marked `[ here ]`. When the koan passes,
the station becomes `[  ok  ]`. The transition is one-way per
invocation; re-running re-derives state from source.

This is the unchanged M2 model. M3 grows the manifest from 6 to
18 stations but does not introduce new lifecycle states.

## Validation rules summary

| Rule | Source | Mechanical gate |
|---|---|---|
| Every koan has a matching solution. | FR-001, FR-002 | `bin/verify_solutions` 18 of 18. |
| Every assertion line uses the M2.5 cleaned shape. | FR-003 | Greps in research.md §8; spec FR-004, FR-005. |
| Every teaching block has a Cowlishaw citation. | FR-006, FR-008 | `bin/lint_citations` (M2.2 anchor + M2.4 join). |
| Every citation resolves against the index. | FR-006 | M2.4 join. |
| Every koan has a `Station:` directive. | FR-007 | `bin/lint_citations` Station-directive check (M2.2). |
| `koans.0` matches the count of `koans.<n>` entries. | FR-009 | Manifest contract from M2 (specs/002). |
| At least 3 koans are scripture-bound. | FR-011 | Reviewer counts `Scripture:` directives across new koans. |
| Scripture-bound failure emits the FR-012 block. | FR-012, FR-025 | Quickstart probe (research.md §6 step 6). |
| Non-scripture-bound failure emits Stage I-shape output. | FR-012 | Quickstart probe (research.md §6, contrast probe). |
| Passing assertions emit no scripture. | FR-013 | Runner-smoke fixture is byte-identical on success. |
| `lib/meditation.rexx` is unchanged. | FR-019 | `git diff main -- lib/meditation.rexx`. |
| Stage I files are unchanged. | Plan Constraints | Greps in research.md §8. |

## Implementation notes (non-normative)

- The runner stem `lines.` is loaded once per failed koan
  (the runner reads `koan_path` line by line into the stem
  before scanning). Memory cost: trivial (~10 KB for the
  largest M3 koan).
- The scripture stem (if implemented as a stem in
  `lib/scripture.rexx`) is dropped on each `RETURN`; per-call
  reconstruction is cheap (seven hard-coded entries).
- The runner's emission point sits between the existing
  "indent each line of captured koan output" loop and the
  station-list `CALL`. See `lib/pilgrimage.rexx:96–101` for
  the current location of the indented-output emission.
