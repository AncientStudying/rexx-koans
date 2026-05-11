# Implementation Plan: M3 — The Path

**Branch**: `008-m3-the-path` | **Date**: 2026-05-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification at `specs/008-m3-the-path/spec.md`

## Summary

Author the twelve Stage II + Stage III koans (`koans/06_about_if.rexx`
through `koans/17_about_misc_functions.rexx`) and their matching
solutions, in the M2.5 cleaned assertion-line shape from inception.
Add `lib/scripture.rexx` carrying the seven design-principle keys
named in PLAN §9 (`humans_not_machines`, `least_astonishment`,
`everything_is_string`, `read_aloud`, `consistency`,
`whitespace_matters_just_enough`, `numbers_are_strings_too`). Bind
at least three M3 koans to a scripture key via a new
`Scripture: <key>` directive that lives inside the test's teaching
comment block (per Clarifications session 2026-05-10 → Option A).
Extend `lib/pilgrimage.rexx` with a runner-side scripture-emission
pass that, on a failed koan subprocess, scans the failed koan's
source backward from the failed line under a block-scoped rule
(Clarifications Q2), looks the bound key up in `lib/scripture.rexx`,
and emits the two-line Bathonian block defined in FR-012 between the
meditation diagnostic and the runner's station list. `lib/meditation.rexx`
is unchanged.

Update `koans/path_to_enlightenment.rexx` to declare 18 stations.
Regenerate `tests/fixtures/runner_stdout.txt` for the eighteen-row
fully-solved walk; the closing benediction reads
`The pilgrim has walked the foundation, the path, and the tools. The path opens further.`
(Clarifications Q3).

The change is mostly additive on top of the M2 walking skeleton:
twelve new koan files, twelve new solution files, one new library
(`lib/scripture.rexx`), one extended runner (`lib/pilgrimage.rexx`),
one extended manifest (`koans/path_to_enlightenment.rexx`), one
regenerated fixture (`tests/fixtures/runner_stdout.txt`). No edits
to Stage I koans/solutions. No edits to `lib/meditation.rexx`,
`lib/stations.rexx`, `bin/pilgrimage`, `bin/verify_solutions`, or
`bin/lint_citations`.

A new runner contract at
`specs/008-m3-the-path/contracts/runner.md` supersedes M2's
runner contract and documents the post-M3 behavior (subprocess
isolation + scripture-emission pass). New library contracts at
`contracts/scripture_library.md` and a new directive contract at
`contracts/koan_directives.md` lock the user-visible interfaces.
The M2 runner contract is left in place as historical record per
project convention (M2 → M3 supersession chain).

## Technical Context

**Language/Version**: Regina REXX (ANSI X3.274 / Cowlishaw
definition). Edit targets: `lib/pilgrimage.rexx` (extended),
`lib/scripture.rexx` (new), `koans/path_to_enlightenment.rexx`
(extended); twelve new koan files, twelve new solution files; one
regenerated fixture.

**Primary Dependencies**: None new. The runner extension reuses
the same Regina built-ins already used in `lib/pilgrimage.rexx` and
`lib/stations.rexx` (`LINEIN`, `LINES`, `STREAM`, `POS`, `STRIP`,
`SUBSTR`, `LEFT`, etc.). `lib/scripture.rexx` is a small REXX
program with one entry-point `SELECT`-on-key pattern (mirroring
the dispatch idiom in `lib/stations.rexx`).

**Storage**: N/A (CLI tool; in-memory stem variables for the
scripture lookup during one runner invocation; in-memory for the
source-scan).

**Testing**: `bin/verify_solutions` (existing, unchanged scope:
now sees 18 solution files instead of 6), `bin/lint_citations`
(existing, M2.4-extended; sees 18 koan files + 18 solution files,
with M3 citations resolving against `docs/cowlishaw_index.md`),
`runner-smoke` (regenerated fixture
`tests/fixtures/runner_stdout.txt`). Six CI checks total per
Constitution Principle IV (3 named steps × 2 OS).

**Target Platform**: macOS (Homebrew Regina) and `ubuntu-latest`
(apt Regina), enforced by `.github/workflows/verify.yml`. UTF-8
byte-level matching as in prior milestones (no §-prefix or em-dash
handling needed in the runner since scripture-emission output is
ASCII; the `Cowlishaw §N.N, p. NN` substring inside the scripture
line is emitted verbatim from `lib/scripture.rexx`'s data table
and the §-prefix is byte-equivalent on both runners).

**Project Type**: Curriculum + library + tooling. Twelve new koan
files and twelve new solution files (the curriculum delivery), one
new library, one extended library, one extended manifest, one
regenerated fixture, three new contract documents, plus the
standard plan/research/quickstart/data-model artifacts.

**Performance Goals**: Per-koan subprocess runs are typically
<100 ms on Regina; the scripture scan is a backward source walk
of typically 5–30 lines on a small REXX file, well under 1 ms.
Total runner runtime for an eighteen-station fully-solved walk
remains well under 5 s on both runners. No performance work
required.

**Constraints**:
- `lib/meditation.rexx` byte-identical pre/post (FR-019, SC-013).
- `koans/00_about_asserts.rexx` through `koans/05_about_say.rexx`
  byte-identical pre/post (no Stage I edits per Assumptions).
- `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx` byte-identical pre/post.
- `lib/stations.rexx`, `bin/pilgrimage`, `bin/verify_solutions`,
  `bin/lint_citations`, `docs/cowlishaw_index.md`, the constitution
  byte-identical pre/post.
- M2.5 forward-style: zero matches for `n = n + 1;` followed by
  `CALL m`; zero matches for trailing-`n` arguments (FR-004,
  FR-005, SC-013).
- No new third-party REXX libraries (Constitution Principle II).
- Deterministic stdout on success (FR-013, Constitution Principle
  IV's byte-identity requirement).

**Scale/Scope**: Twelve new koan files (each ~50–100 lines of
REXX + teaching prose), twelve new solution files (parallel), one
new library `lib/scripture.rexx` (~50–80 lines, one entry-point
SELECT-on-key, seven keys), one extended runner adding ~30–60
lines (the scripture-scan procedure + emission), one new contract
document set (runner.md, scripture_library.md, koan_directives.md).
Estimated total diff: ~1500–2200 lines added including contracts
and quickstart, of which roughly 1200 lines are koans+solutions.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First Development | **Pass** | Every M3 koan ships with a verified passing solution. The mandated 5-step work order (draft teaching prose → write solution → derive koan via FILL_ME_IN replacement → confirm runner stops with diagnostic → confirm runner advances on correct fill) is applied per koan, twelve times. `bin/verify_solutions` runs every solution file and gates merge at 18/18 green (FR-014, SC-003). |
| II. No Third-Party REXX Libraries | **Pass** | Every new file uses only Regina built-ins. `lib/scripture.rexx` is a single-file REXX program with `PARSE ARG`, `SELECT`/`WHEN`, and string-literal data — no external dependencies. The runner extension reuses existing built-ins (`LINEIN`/`LINES`/`STREAM`/`STRIP`/`POS`/`LEFT`/`SUBSTR`). The koans teach standard built-ins (Stage III) and standard keyword instructions (Stage II) — every concept is in `Cowlishaw §2.7` or `§2.9` and ships with Regina by default. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | Every M3 koan has a per-test teaching comment block with a concept heading, 2–6 sentences of prose, and a Cowlishaw citation in the canonical form `Cowlishaw §N.N, p. NN`, optionally with a child-heading suffix per the M2.1 amendment (FR-006, FR-008). M2.4's mechanical existence check joins every citation against `docs/cowlishaw_index.md` at lint time (FR-015, SC-004). The new `Scripture: <key>` directive (FR-024) extends the same teaching-block pattern: scripture lives in the comment block alongside the citation, illuminating the principle the test turns on without competing with the diagnostic. |
| IV. CI Is the Acceptance Gate | **Pass** | All 6 CI checks (`verify_solutions` × 2 OS, `lint_citations` × 2 OS, `runner-smoke` × 2 OS) MUST be green pre-merge per spec SC-007. Cross-OS parity is preserved by construction — the new scripture-scan in the runner reads the koan source as raw bytes and emits ASCII output; the `Cowlishaw §N.N, p. NN` strings inside scripture lines are emitted verbatim from the library's data table. The runner-smoke fixture is regenerated for the 18-station walk and committed. |
| V. Voice — Diagnostic First, Pilgrimage Flavor Second | **Pass** | The two-line Bathonian block (FR-012) sits *after* the meditation diagnostic, not before — the pilgrim sees what went wrong and where, then the principle that illuminates it. Scripture-bound koans are limited (≥3 per PLAN §9; planning's working list is three) so principle text is invoked sparingly, never as decoration. New teaching-prose addresses the pilgrim in second person; humor is restrained. The "the Bathonian" framing in scripture output is the one place PLAN §9 names the role explicitly, and it appears only on principle-bound failures — never on a passing run, never on a non-bound failure. |

**Verdict**: PASS. No violations; Complexity Tracking section omitted.

## Project Structure

### Documentation (this feature)

```text
specs/008-m3-the-path/
├── plan.md                        # This file (/speckit-plan output)
├── research.md                    # Phase 0 — scripture-scan algorithm, library shape, fixture regeneration recipe, station-subtitle authoring, scripture-bound koan selection
├── data-model.md                  # Phase 1 — entities for Stage II/III koans, scripture entry, scripture binding, path manifest update
├── quickstart.md                  # Phase 1 — local verification recipe (verify_solutions 18/18, lint 18+18, runner-smoke regenerated, scripture probe)
├── contracts/
│   ├── runner.md                  # Phase 1 — supersedes specs/002-m2-walking-skeleton/contracts/runner.md; documents subprocess isolation + scripture-emission pass
│   ├── scripture_library.md       # Phase 1 — contract for lib/scripture.rexx (CALL signature, key list, return values)
│   └── koan_directives.md         # Phase 1 — contract for Scripture: directive (alongside the existing Station: directive)
├── checklists/
│   └── requirements.md            # Pre-existing (created by /speckit-specify, updated by /speckit-clarify)
├── spec.md                        # Pre-existing (created by /speckit-specify, clarified by /speckit-clarify)
└── tasks.md                       # Phase 2 — created by /speckit-tasks (NOT this command)
```

### Source Code (repository root)

```text
koans/
├── 00_about_asserts.rexx          # READ-ONLY — Stage I, unchanged
├── 01_about_strings.rexx          # READ-ONLY — Stage I, unchanged
├── 02_about_variables.rexx        # READ-ONLY — Stage I, unchanged
├── 03_about_expressions.rexx      # READ-ONLY — Stage I, unchanged
├── 04_about_clauses.rexx          # READ-ONLY — Stage I, unchanged
├── 05_about_say.rexx              # READ-ONLY — Stage I, unchanged
├── 06_about_if.rexx               # NEW — Stage II
├── 07_about_select.rexx           # NEW — Stage II, scripture-bound (least_astonishment, working selection)
├── 08_about_do_loops.rexx         # NEW — Stage II
├── 09_about_iterate_leave.rexx    # NEW — Stage II
├── 10_about_signal.rexx           # NEW — Stage II
├── 11_about_interpret.rexx        # NEW — Stage II
├── 12_about_string_functions.rexx # NEW — Stage III, scripture-bound (everything_is_string, working selection)
├── 13_about_word_functions.rexx   # NEW — Stage III
├── 14_about_arithmetic_functions.rexx # NEW — Stage III, scripture-bound (numbers_are_strings_too, working selection)
├── 15_about_conversion_functions.rexx # NEW — Stage III
├── 16_about_bit_functions.rexx    # NEW — Stage III
├── 17_about_misc_functions.rexx   # NEW — Stage III
└── path_to_enlightenment.rexx     # EXTEND — koans.0 = 18; add koans.7..koans.18

solutions/
├── 00_about_asserts.rexx          # READ-ONLY — Stage I, unchanged
├── 01_about_strings.rexx          # READ-ONLY — Stage I, unchanged
├── 02_about_variables.rexx        # READ-ONLY — Stage I, unchanged
├── 03_about_expressions.rexx      # READ-ONLY — Stage I, unchanged
├── 04_about_clauses.rexx          # READ-ONLY — Stage I, unchanged
├── 05_about_say.rexx              # READ-ONLY — Stage I, unchanged
├── 06_about_if.rexx               # NEW — solution to koans/06_about_if.rexx
├── 07_about_select.rexx           # NEW — solution; same scripture binding as koan
├── 08_about_do_loops.rexx         # NEW
├── 09_about_iterate_leave.rexx    # NEW
├── 10_about_signal.rexx           # NEW
├── 11_about_interpret.rexx        # NEW
├── 12_about_string_functions.rexx # NEW — solution; same scripture binding as koan
├── 13_about_word_functions.rexx   # NEW
├── 14_about_arithmetic_functions.rexx # NEW — solution; same scripture binding as koan
├── 15_about_conversion_functions.rexx # NEW
├── 16_about_bit_functions.rexx    # NEW
└── 17_about_misc_functions.rexx   # NEW

lib/
├── pilgrimage.rexx                # EXTEND — add scripture-scan procedure (`scripture_for_failure`) and emit the two-line block between the captured failed-koan stdout and the station-list rendering when the failed assertion is scripture-bound
├── meditation.rexx                # READ-ONLY (FR-019)
├── stations.rexx                  # READ-ONLY
└── scripture.rexx                 # NEW — keyed lookup library; SELECT/WHEN dispatch on a 'fetch <key>' verb

bin/
├── pilgrimage                     # READ-ONLY
├── verify_solutions               # READ-ONLY
└── lint_citations                 # READ-ONLY (M2.4-extended; M3 cites only flow through it as input)

tests/fixtures/
└── runner_stdout.txt              # REGENERATE — eighteen rows + new benediction (Q3)

docs/
├── cowlishaw_index.md             # READ-ONLY (M3 citations are inputs to lint, not edits to the index)
├── DESIGN_DECISIONS.md            # READ-ONLY
├── DESIGN_DECISIONS_M2.md         # READ-ONLY
└── M2_FOLLOWUP.md                 # READ-ONLY

CLAUDE.md                          # EDIT — repoint `Active feature plan:` to specs/008-m3-the-path/plan.md
```

**Structure Decision**: This feature adds twelve koan files,
twelve solution files, one new library, and extends three
existing files (the runner, the path manifest, the runner-smoke
fixture). It introduces three new contract documents — the
runner contract supersedes M2's; the scripture and directive
contracts are new because they document new interfaces. No new
top-level directories. No edits to Stage I koans/solutions, no
edits to the meditation library, no edits to the lint/verify
scripts, and no edits to the Cowlishaw index. The narrowest
source-tree footprint compatible with the milestone definition.

## Phase 0: Outline & Research

Phase 0 has no NEEDS-CLARIFICATION markers in the spec post-clarify
(Q1 was resolved during `/speckit-specify` to Option A; Q1–Q3 in
the Clarifications session 2026-05-10 locked text shape, binding
scope, and benediction wording). Research is therefore mechanical
specification work — pinning the runner-side scripture-scan
algorithm, the library dispatch shape, the runner-smoke fixture
regeneration recipe, station-subtitle authoring for koans 09–17,
the scripture-bound koan selection, and the implementation
ordering that respects Constitution Principle I.

The questions resolved in Phase 0:

1. **What is the exact algorithm for the runner's
   scripture-scan?** Per Clarifications Q2 (block-scoped binding),
   the runner walks the failed koan's source backward from
   `line N − 1` toward line 1, tracking only two events: a
   `Scripture: <key>` directive line, and a `/*` line (start of a
   teaching comment block — the boundary of binding scope). The
   first event reached determines the result: directive →
   binding (look up key, emit FR-012 block); `/*` → no binding
   (no scripture text). If neither is found by line 1, no binding.
   The scan stops at the first event in either case. This is
   O(D) where D is the source-line distance from the failed
   `CALL m` to the directive (or the prior `/*`); for the koan
   shapes M3 produces, D ≤ 30 lines and the scan is sub-millisecond.
   See `research.md` §1.

2. **What is the exact dispatch shape of `lib/scripture.rexx`?**
   Decided: a one-verb dispatcher mirroring the `lib/stations.rexx`
   pattern. Invocation: `CALL 'lib/scripture.rexx' 'fetch', key`.
   Returns (via `RESULT`) a single string of the form
   `<principle text>\t<citation>` where `\t` is a literal `'09'x`
   separator the runner splits on; the runner emits the two-line
   block by formatting the citation into line 1 and the principle
   into line 2. An unknown key returns the empty string; the
   runner treats empty as "no scripture" and emits no block (this
   covers FR-024's "key not in library" contributor-error edge
   case). See `research.md` §2.

3. **What is the runner-smoke fixture regeneration recipe?** The
   fixture is regenerated from a fully-solved walk — every koan
   filled with the canonical solution value. Recipe: copy each
   `solutions/NN_about_*.rexx` over its matching `koans/NN_about_*.rexx`
   in a temp working tree, run `regina lib/pilgrimage.rexx`, capture
   stdout, copy stdout into `tests/fixtures/runner_stdout.txt`,
   reset the working tree. The fixture content is independent of
   scripture state because the success path emits no scripture
   (FR-013); only the station-list rows, summary, and benediction
   change versus M2. See `research.md` §3 for the full recipe and
   the expected line-by-line shape.

4. **What are the station subtitles for koans 09–17?** PLAN §11
   names three (06–08); the remaining nine are authored in the
   pilgrim-voice register. Working list (refinable during
   implementation):
   - 09 about_iterate_leave → "Of Skipping and Leaving"
   - 10 about_signal → "When the Path Bends"
   - 11 about_interpret → "What is Spoken Becomes Done"
   - 12 about_string_functions → "Of Letters and Their Manipulation"
   - 13 about_word_functions → "Of Words and Their Counting"
   - 14 about_arithmetic_functions → "Of Numbers and Their Shape"
   - 15 about_conversion_functions → "Between One Form and Another"
   - 16 about_bit_functions → "Down to the Bits"
   - 17 about_misc_functions → "Of Time and Chance"
   See `research.md` §4 for rationale and alternates.

5. **Which koans are scripture-bound, and to which keys?**
   Working selection (≥3 per PLAN §10; the spec's Assumption
   names the same three):
   - 07 `about_select` ↔ `least_astonishment` — SELECT/WHEN/
     OTHERWISE behaves the way a reader expects from spoken
     English; the OTHERWISE-required-when-no-WHEN-matches rule
     is a least-astonishment win and a footgun if forgotten.
   - 12 `about_string_functions` ↔ `everything_is_string` —
     every Stage III string built-in operates on character data
     that, in REXX, is the universal data type.
   - 14 `about_arithmetic_functions` ↔ `numbers_are_strings_too`
     — arithmetic built-ins return strings of digits formatted
     under the prevailing NUMERIC settings.
   The implementation MAY add a fourth or fifth binding if a
   principle organically illuminates a koan during authoring;
   any addition is recorded in the implementation artifact and
   in `research.md` §5.

6. **What is the implementation ordering that respects
   Constitution Principle I (Solution-First)?** Per principle:
   solution before koan. Per practical reality: scripture-bound
   koans (07, 12, 14) require `lib/scripture.rexx` and the
   runner extension to be in place before their failure-mode
   tests can be probed end-to-end. Therefore: implement
   `lib/scripture.rexx` and the runner scripture-scan extension
   first, before any scripture-bound koan; then implement
   non-scripture-bound Stage II koans, then scripture-bound
   Stage II koan (07), then non-scripture-bound Stage III koans,
   then scripture-bound Stage III koans (12, 14), each with its
   solution in lockstep. The path manifest is updated as each
   koan lands. The runner-smoke fixture is regenerated last,
   once all 18 koans are in place. See `research.md` §6.

7. **Performance envelope?** Per-koan subprocess: ~50–100 ms on
   Regina; eighteen stations: <2 s. Scripture scan on failure:
   <1 ms (≤30 lines per scan). Library dispatch: O(1) `SELECT`/
   `WHEN` over seven keys. No performance work required. See
   `research.md` §7.

8. **Stage I non-modification verification.** A mechanical guard
   for SC-013 and the Stage I read-only constraint: after every
   commit on the feature branch, `git diff main -- koans/0[0-5]_*.rexx
   solutions/0[0-5]_*.rexx lib/meditation.rexx lib/stations.rexx
   bin/ docs/cowlishaw_index.md tests/fixtures/runner_stdout.txt`
   should output only the regenerated runner-smoke fixture (and
   only after that step). Any other Stage I diff is a regression.
   See `research.md` §8 for the recipe.

**Output**: `research.md` with the eight resolutions above
expanded into prose, plus the working subtitle list and the
working scripture-bound koan selection. No NEEDS-CLARIFICATION
remains.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete (scan algorithm,
library dispatch, fixture recipe, subtitle authoring, scripture
selection, implementation ordering all finalized).

1. **Data model** (`data-model.md`): formalize the entities
   already named in spec.md — Stage II koan, Stage III koan,
   Path manifest, Scripture entry, Scripture binding, Station
   subtitle, Runner-smoke fixture, Cowlishaw index — plus the
   relationships between them: a koan binds (optionally) to one
   scripture entry via a directive in a teaching comment block;
   a binding has block scope (FR-024); the path manifest enumerates
   koans in numeric order; the runner-smoke fixture is the
   serialized fully-solved walk; every citation joins against
   the index. The model has no runtime data flow beyond the
   one-shot runner invocation; "entities" are mostly source-file
   conventions and runtime stem variables in the runner.

2. **Contracts** (`contracts/`):
   - **`runner.md`**: post-M3 runner contract. Documents the
     subprocess-isolation invocation pattern (carried forward
     from M2), the captured-stdout flow, the new
     **scripture-emission pass** (between the captured failed-koan
     stdout and the station-list rendering), the FR-012 two-line
     output shape, the FR-024/FR-025 scope-resolution algorithm,
     and the unchanged exit-code semantics. Supersedes
     `specs/002-m2-walking-skeleton/contracts/runner.md`. The M2
     contract is left in place as historical record (M2 → M3
     supersession chain matches the M2 → M2.2 → M2.4
     supersession pattern in lint_citations).
   - **`scripture_library.md`**: contract for `lib/scripture.rexx`.
     Documents the CALL signature
     (`CALL 'lib/scripture.rexx' 'fetch', key`), the seven required
     keys with their principle text and citation, the empty-string
     return on unknown key, and the file-format expectations
     (Regina built-ins only; `SELECT`/`WHEN` dispatch). Includes
     a positive-case table (each key + expected `RESULT` shape)
     and a negative-case table (unknown key → empty string).
   - **`koan_directives.md`**: contract for the `Scripture:` and
     `Station:` directives. Pulls the existing `Station:` directive
     contract (currently in `lib/stations.rexx`'s docstring) into
     a single shared document and adds the new `Scripture: <key>`
     directive alongside it. Documents shape, location rules
     (must appear inside a comment block; at most one per teaching
     block), the binding-scope algorithm (block-scoped per
     FR-024), and contributor-error cases.

3. **Quickstart** (`quickstart.md`): the local verification
   recipe — `bin/verify_solutions` (18/18), `bin/lint_citations`
   (18 koans + 18 solutions all green), `bin/pilgrimage` against
   the fully-solved corpus (stdout-diff vs.
   `tests/fixtures/runner_stdout.txt`), plus M3-specific spot
   checks:
   - The scripture-on-failure probe (introduce a wrong fill into
     a scripture-bound koan; run `bin/pilgrimage`; confirm the
     two-line Bathonian block appears between the meditation
     diagnostic and the station-list output; revert) — for
     SC-006.
   - The scripture-on-non-bound probe (introduce a wrong fill
     into a non-scripture-bound koan; run; confirm no scripture
     text appears) — for SC-006.
   - The scripture-on-success probe (run the fully-solved walk;
     confirm no scripture text in stdout) — for FR-013.
   - The M2.5 forward-style grep (zero matches for
     `n = n + 1;` followed by `CALL m`; zero matches for
     trailing-`n` arguments) — for SC-013.
   - The Stage I-untouched grep — for the Stage I read-only
     constraint named in Technical Context above.

4. **Agent context update**: `CLAUDE.md`'s "Active feature plan"
   line is repointed from `specs/007-koan-line-shape/plan.md`
   to `specs/008-m3-the-path/plan.md`.

**Output**: `data-model.md`, `contracts/runner.md`,
`contracts/scripture_library.md`, `contracts/koan_directives.md`,
`quickstart.md`, updated `CLAUDE.md`.

### Post-Design Constitution Re-Check

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First | **Pass** | The implementation ordering documented in research.md §6 keeps Principle I intact: every koan ships with its solution; the koan is derived from the solution; both land in the same commit. The phase-0 dependency that scripture infrastructure precedes scripture-bound koans does not bend Principle I — it bends the *milestone* ordering of which koan ships first, which is a project planning question, not a per-koan one. |
| II. No Third-Party REXX Libraries | **Pass** | The contracts re-state and reinforce: `lib/scripture.rexx` is a REXX program using only Regina built-ins (Constitution Principle II § "MUST be written in REXX"). The runner extension uses only built-ins already in `lib/pilgrimage.rexx`'s vocabulary. Twelve koans + twelve solutions teach standard built-ins and standard keyword instructions per `Cowlishaw §2.7`/`§2.9`; no extension points are touched. |
| III. Self-Teaching Vocabulary | **Pass and reinforced** | Every M3 citation joins against the M2.1 index via M2.4's mechanical existence check at lint time. The new `Scripture:` directive extends the teaching-block pattern, not replaces it: scripture lives alongside the citation, in the same comment block where teaching prose already lives, addressed in pilgrim voice, citing the index row that warrants the principle. The koan_directives.md contract codifies the directive shape so future koan authors have a fixed reference. |
| IV. CI Is the Acceptance Gate | **Pass** | The runner.md contract preserves the exit-code semantics that drive the CI gate (subprocess RC propagated; runner stdout deterministic on success). The runner-smoke fixture is regenerated and gated by CI on both runners. The matrix `verify_solutions × {ubuntu-latest, macos-latest}`, `lint_citations × {ubuntu-latest, macos-latest}`, `runner-smoke × {ubuntu-latest, macos-latest}` totals 6 checks — all green pre-merge per spec SC-007. |
| V. Voice | **Pass** | The two-line Bathonian block appears *after* the meditation diagnostic; the diagnostic-first rule holds. Scripture is invoked sparingly (3 of 12 koans in the working selection); decorative scripture is not introduced. New teaching prose addresses the pilgrim in second person; humor restrained. The closing benediction (Q3) is plain and milestone-faithful. |

No new violations. Plan stands.

## Phase 2: Tasks (preview only — generated by /speckit-tasks)

Phase 2 is out of scope for `/speckit-plan`. The expected task
shape, derivable from the artifacts above:

- **Setup phase**: Verify baseline (M2.5-merged main; 6/6 CI
  green; runner-smoke fixture matches); spike the runner
  scripture-scan against a sandbox koan to confirm the
  block-scoped algorithm matches FR-025.

- **Foundational phase (P1, infrastructure first)**:
  1. Author `lib/scripture.rexx` with the seven keys defined in
     PLAN §9; UAT against a sandbox `CALL` invocation.
  2. Extend `lib/pilgrimage.rexx` with the `scripture_for_failure`
     procedure and the emission point between the captured
     failed-koan stdout and the station-list rendering. Confirm
     non-scripture-bound failure path is byte-identical to M2
     against an existing Stage I koan with a deliberate wrong
     fill.

- **US1 phase (P1, MVP — Stage II)**: Author six Stage II koans
  + matching solutions in numeric order (06 → 11), updating the
  path manifest as each pair lands; runner-smoke fixture
  regenerated incrementally to track. Scripture binding for 07
  (least_astonishment) lands once the `lib/scripture.rexx` and
  the runner extension are in place.

- **US2 phase (P1, Stage III)**: Author six Stage III koans +
  matching solutions in numeric order (12 → 17), same lockstep.
  Scripture bindings for 12 (everything_is_string) and 14
  (numbers_are_strings_too) land in their respective commits.

- **US3 phase (P1, scripture verification)**: Run the three
  quickstart scripture probes end-to-end; confirm SC-006.
  Negative spot-check: a non-scripture-bound failure produces
  Stage I-shape output.

- **US4 phase (P1, solutions parity)**: `bin/verify_solutions`
  reports 18 of 18; per-pair `diff` confirms only
  FILL_ME_IN-vs-value substitutions (SC-010).

- **US5 phase (P1, lint join)**: `bin/lint_citations` reports
  all-green across all 18 koan and 18 solution files (SC-004).
  Negative spot-check: introduce a fabricated citation; lint
  rejects; revert.

- **US6 phase (P2, fixture + CI)**: Final regeneration of
  `tests/fixtures/runner_stdout.txt`; push branch; observe
  GitHub Actions reports 6/6 success (SC-007). Spot-check the
  closing benediction line against the Q3 lock.

- **Polish phase**: Run all M2.5 forward-style greps (zero
  matches expected per FR-004/FR-005, SC-013); run the Stage I
  untouched grep; run the manifest verification (`koans.0 = 18`
  with eighteen entries in numeric order); final review against
  spec Out of Scope and Constitution Check.

`/speckit-tasks` produces the ordered, dependency-tracked task
list in `tasks.md`.
