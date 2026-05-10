# Implementation Plan: M2.4 — Mechanical Citation Existence Check

**Branch**: `006-citation-existence-lint` | **Date**: 2026-05-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification at `specs/006-citation-existence-lint/spec.md`

## Summary

Extend `bin/lint_citations` to mechanically validate, for every
citation it finds in `koans/*.rexx` and `solutions/*.rexx`, that
the cited (§N.N, book page) pair (and the trailing child-heading
when a canonical suffix is present) corresponds to a row in
`docs/cowlishaw_index.md`. The script gains:

1. An index-row parser that walks `docs/cowlishaw_index.md`
   once at startup and builds a (§sec, page) → list-of-headings
   lookup table.
2. A second, more permissive citation-detection pattern (per
   the Clarifications session 2026-05-10) used for the existence
   check ONLY: substring `Cowlishaw §<sec>, p. <page>` optionally
   followed by ` — <heading>`, with no tail constraint. Permits
   in-prose parenthetical citations to be validated.
3. Comment-block reassembly so that suffix-headings split across
   `\n * ` line continuations (e.g., the M2.3 in-prose
   parenthetical `(Cowlishaw §2.3, p. 27 — Logical\n * (Boolean))`
   in `solutions/00_about_asserts.rexx`) are matched against the
   index correctly rather than rejected on the trailing word
   alone.
4. A new failure-mode `UNRESOLVED citation: <text> (<reason>)`
   with three sub-reasons (no §+page row; suffix mismatch with
   verbatim alternatives; suffix present but no `###` children
   at the resolved key).
5. Per-file multi-failure reporting: a file with N unresolved
   citations emits one `[FAIL]` line and N `UNRESOLVED citation:`
   reasons in source order (per FR-016).
6. File-scope expansion to also scan `solutions/*.rexx` (per
   the Clarifications session 2026-05-10). The Station: directive
   check stays koans-only.

The change is additive on top of M2.2's canonical-form check
(Rule C1, FR-007 carries forward unchanged). The post-M2.3 corpus
is expected to pass the new check on first run because every
existing citation has been verified by human review.

A new lint contract at
`specs/006-citation-existence-lint/contracts/lint_citations.md`
supersedes M2.2's contract and documents the full post-M2.4
behavior. The M2.2 contract is left in place as historical record.

## Technical Context

**Language/Version**: Regina REXX (ANSI X3.274 / Cowlishaw
definition). The edit target is `bin/lint_citations` (a REXX
script) and a new contract markdown document.
**Primary Dependencies**: None new. The lookup target is
`docs/cowlishaw_index.md`, read-only at HEAD of `main`. The
existing `bin/lint_citations` script is the foundation extended.
**Storage**: N/A (CLI tool; in-memory stem variables for the
lookup table during one invocation).
**Testing**: `bin/verify_solutions` (existing, unchanged),
`bin/lint_citations` (M2.4 — extended), `runner-smoke` (existing
fixture `tests/fixtures/runner_stdout.txt`, unchanged). Six CI
checks total per Constitution Principle IV.
**Target Platform**: macOS (Homebrew Regina) and ubuntu-latest
(apt Regina), enforced by `.github/workflows/verify.yml`. UTF-8
byte-level matching (carries forward from M2.2) for §-prefix
(U+00A7, 2 bytes UTF-8) and em-dash (U+2014, 3 bytes UTF-8).
No platform divergence expected.
**Project Type**: Build/CI tooling. Single-file script edit plus
one new contract document.
**Performance Goals**: `bin/lint_citations` runs in well under
1 second on the current corpus (12 files, ~50 distinct
citations, ~80 index rows). The index is parsed once per
invocation. No performance concern at this scale; no caching or
incremental parsing.
**Constraints**:
- `tests/fixtures/runner_stdout.txt` byte-identical pre/post
  (FR-012, SC-006).
- `docs/cowlishaw_index.md` byte-identical pre/post (FR-013,
  SC-007).
- No file under `koans/` or `solutions/` modified pre/post
  (FR-015, SC-008). Negative spot-checks (SC-003, SC-004) are
  introduce-and-revert, never committed.
- `lib/meditation.rexx` and other framework code unmodified.
- No new third-party REXX libraries (Constitution Principle II).
**Scale/Scope**: One script (`bin/lint_citations`) extended; one
new contract document. ~150–250 lines of REXX added to the
script (parser + lookup + failure-message construction).
Estimated total diff under 400 lines including the contract
document.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First Development | **Pass** | M2.4 does not author new koans; it extends a CI tool. Principle I's "5-step work order" applies to koan authoring, not tooling. The mechanical guard *strengthens* the discipline downstream — every M3+ koan that ships under M2.4 has its citations machine-validated against the index, raising the floor on Principle I's "teaching comments match code that actually passes" guarantee. |
| II. No Third-Party REXX Libraries | **Pass** | `bin/lint_citations` is a REXX script (Principle II § "MUST be written in REXX"). M2.4 extends it using Regina built-ins only — `LINEIN`, `LINES`, `STREAM`, `POS`, `SUBSTR`, `STRIP`, `DATATYPE`, stem variables. No external libraries introduced. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | Principle III mandates the canonical citation form `Cowlishaw §N.N, p. NN[ — <heading>]` in koan teaching prose. M2.2 enforced the *form* mechanically. M2.4 enforces *resolution* — every citation a contributor writes is now machine-validated against `docs/cowlishaw_index.md` at lint time, catching typos and fabricated citations before human review. The principle's "page-number accuracy is a contributor responsibility, not a CI responsibility" caveat is *partially closed* by M2.4: §-and-page accuracy is now CI-checked; page-number-against-the-physical-book accuracy remains the contributor's. |
| IV. CI Is the Acceptance Gate | **Pass** | All 6 CI checks (`verify_solutions` × 2 OS, `lint_citations` × 2 OS — now M2.4-extended, `runner-smoke` × 2 OS) MUST be green pre-merge per spec SC-005. Cross-OS parity is automatic — the lint script reads files as raw byte streams and the (§sec, page) join is platform-agnostic. |
| V. Voice — Diagnostic First, Pilgrimage Flavor Second | **Pass** | M2.4 touches only `bin/lint_citations` and a new contract document. The lint script's failure messages are diagnostic-first (file, citation text, specific reason — see Acceptance Scenarios in spec); no atmospheric language is introduced. No voice-bearing prose is touched. |

**Verdict**: PASS. No violations; Complexity Tracking section omitted.

## Project Structure

### Documentation (this feature)

```text
specs/006-citation-existence-lint/
├── plan.md                        # This file (/speckit-plan output)
├── research.md                    # Phase 0 — index-row parser, citation-detection pattern, cross-line suffix handling, contract location decision
├── data-model.md                  # Phase 1 — entities for index rows, lookup table, citations, failure modes
├── quickstart.md                  # Phase 1 — local verification recipe + negative spot-check procedure
├── contracts/
│   └── lint_citations.md          # Phase 1 — supersedes specs/004-m2-2-citation-rewrite/contracts/lint_citations.md; documents post-M2.4 behavior
├── checklists/
│   └── requirements.md            # Pre-existing (created by /speckit-specify)
├── spec.md                        # Pre-existing (created by /speckit-specify, clarified by /speckit-clarify)
└── tasks.md                       # Phase 2 — created by /speckit-tasks (NOT this command)
```

### Source Code (repository root)

```text
bin/
├── lint_citations                 # Edit: extend with index-row parser, lookup table builder, broad citation-detection pattern, comment-block reassembly, multi-failure reporting, solutions/ scope, new failure-mode reasons
└── verify_solutions               # READ-ONLY for this feature

lib/
├── meditation.rexx                # READ-ONLY (FR-011 carve-out)
├── pilgrimage.rexx                # READ-ONLY
└── stations.rexx                  # READ-ONLY

docs/
├── cowlishaw_index.md             # READ-ONLY for this feature (FR-013) — the lookup target
├── DESIGN_DECISIONS.md            # READ-ONLY
├── DESIGN_DECISIONS_M2.md         # READ-ONLY
└── M2_FOLLOWUP.md                 # READ-ONLY

tests/fixtures/
└── runner_stdout.txt              # READ-ONLY for this feature (FR-012)

koans/
├── 00_about_asserts.rexx          # READ-ONLY (FR-015) — input to lint
├── 01_about_strings.rexx          # READ-ONLY
├── 02_about_variables.rexx        # READ-ONLY
├── 03_about_expressions.rexx      # READ-ONLY
├── 04_about_clauses.rexx          # READ-ONLY
└── 05_about_say.rexx              # READ-ONLY

solutions/
├── 00_about_asserts.rexx          # READ-ONLY (FR-015) — newly in lint scope (M2.4 expansion); input to lint
├── 01_about_strings.rexx          # READ-ONLY
├── 02_about_variables.rexx        # READ-ONLY
├── 03_about_expressions.rexx      # READ-ONLY
├── 04_about_clauses.rexx          # READ-ONLY
└── 05_about_say.rexx              # READ-ONLY
```

**Structure Decision**: This feature edits exactly one source-tree
file (`bin/lint_citations`) and adds one new contract document
(`specs/006-citation-existence-lint/contracts/lint_citations.md`).
No new directories. The narrowest possible source-tree footprint
for a tooling change. The new lint contract supersedes
`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` —
older contracts remain in place as historical record per
project convention (M2-era → M2.2 → M2.4 supersession chain).

## Phase 0: Outline & Research

Phase 0 had no NEEDS-CLARIFICATION markers in the spec
post-clarify (the three Clarifications session 2026-05-10
resolutions handled the substantive design questions).
Research was therefore mechanical specification work — pinning
down the index-row parser format, the citation-detection
pattern's regex shape, the cross-line suffix handling, and the
contract supersession choice.

The questions resolved in Phase 0:

1. **What is the exact shape of `docs/cowlishaw_index.md` that
   the parser reads?** Answered by walking the file and
   formalizing the row format: `## §X.Y — <title>` parents,
   `### <child heading>` children, exactly three bullets per row
   (`**Page:** N`, `**Summary:** ...`, `**Vocabulary:** ...`).
   The parser tracks the current §X.Y context as it walks; a
   `### <heading>` line uses the most-recently-seen `## §X.Y`
   as its section. Each row's `**Page:** N` bullet provides the
   page. The (§X.Y, page) key is built from this. See
   `research.md` §1.

2. **What does the M2.4 citation-detection pattern look like
   exactly?** Per the Clarifications session 2026-05-10 (broad
   detection), the pattern is the substring `Cowlishaw §<sec>,
   p. <page>` optionally followed by ` — <heading>` (canonical
   em-dash separator + non-empty heading), with NO tail
   constraint after the page digits or heading. M2.2's strict
   Rule C1 still gates the canonical-form / "is there an anchor"
   per-file check (FR-007). See `research.md` §2.

3. **How does lint handle suffix-headings split across
   `\n * ` line continuations?** Concrete case: the M2.3
   in-prose parenthetical
   `(Cowlishaw §2.3, p. 27 — Logical\n * (Boolean))` in
   `solutions/00_about_asserts.rexx` lines 39–40. Resolution:
   lint reassembles consecutive comment-prose lines within a
   single `/*  ... */` block by replacing `\n * ` with ` `
   (single space) before running the substring scan. Citation
   matches happen against the reassembled paragraph text;
   line-number tracking points to the line where the citation
   begins. See `research.md` §3.

4. **What is the exact shape of the `UNRESOLVED citation`
   reason strings?** Three variants (per spec FR-003 / FR-004):
   - `UNRESOLVED citation: <text> (no §<sec> + p. <page> row in
     docs/cowlishaw_index.md)`
   - `UNRESOLVED citation: <text> (heading "<suffix>" does not
     match index row "<verbatim>")` — when (§sec, page) resolves
     and `###` children exist; `<verbatim>` is the
     comma-joined list of valid heading alternatives.
   - `UNRESOLVED citation: <text> (heading "<suffix>" does not
     match any §<sec>+p.<page> row; use bare form)` — when
     (§sec, page) resolves but no `###` children sit under it
     (the resolved row is a `## §X.Y` with no children at the
     same page). See `research.md` §4.

5. **Where does the M2.4 lint contract live?** Decided: a new
   file at
   `specs/006-citation-existence-lint/contracts/lint_citations.md`
   that supersedes `specs/004-m2-2-citation-rewrite/contracts/
   lint_citations.md`. The new contract documents both unchanged
   M2.2 behavior (carried forward) and new M2.4 behavior
   (additive). The M2.2 contract is left in place as historical
   record (matching the M2-era → M2.2 supersession pattern). See
   `research.md` §5.

6. **How does the script integrate the new check with M2.2's
   existing per-file logic?** Resolution: M2.2's `check_citation`
   (per-line, strict Rule C1) is unchanged. M2.4 adds a new
   `check_existence` pass that runs *after* per-file processing
   completes — it walks every file's reassembled paragraphs,
   scans for the broad pattern, looks up each match in the
   pre-built (§sec, page) → headings table, and accumulates
   `UNRESOLVED citation:` reasons for failures. The
   `[ ok ] / [FAIL]` decision is the union of M2.2's existing
   checks (canonical-form anchor + Station: directive) AND the
   new existence check. See `research.md` §6.

7. **Performance envelope?** ~80 index rows × O(1) hash insert =
   trivial. ~50 citations × O(1) lookup = trivial. Total runtime
   well under 1 s on the current corpus. No performance work
   required. See `research.md` §7.

8. **Index defects discovered while building the lookup table?**
   None expected (M2.1 + M2.2 + M2.3 all completed without
   finding defects). If implementation surfaces one (e.g., a
   row with a malformed `**Page:**` bullet), the parser MUST
   exit with a bootstrap error per FR-010; the defect is
   escalated as a one-row M2.1 amendment in a separate commit.
   See `research.md` §8.

**Output**: `research.md` with the eight resolutions above
expanded into prose, plus the rejection-case taxonomy that the
new contract codifies. No NEEDS-CLARIFICATION remains.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete (parser format, detection
pattern, cross-line handling, reason strings, contract location
all finalized).

1. **Data model** (`data-model.md`): formalize the entities
   already named in spec.md (Index row, Lookup table, Citation,
   Failure mode) plus the join relationships between them — the
   (§sec, page) join from a citation to one or more index rows,
   and the suffix-heading match from a suffixed citation to a
   `###` child within the resolved key. The model has no runtime
   data flow (it is a one-shot script); the "entities" are
   parser intermediates and lookup keys.

2. **Contract** (`contracts/lint_citations.md`): the
   post-M2.4 contract for `bin/lint_citations`. Documents:
   - File discovery (koans/*.rexx + solutions/*.rexx;
     path manifest excluded as before).
   - Index parser format expectations (`## §X.Y — <title>`
     parents with mandatory `**Page:** N`, `### <heading>`
     children with mandatory `**Page:** N`, exactly three
     bullets per row).
   - Lookup table schema ((§sec, page) → list of `### <heading>`
     texts; parent §X.Y row's key entered with no associated
     heading).
   - Per-file checks: M2.2 Rule C1 anchor (unchanged), Station:
     directive (unchanged, koans-only), M2.4 existence-check
     (new, applies to all citations matched by the broad
     pattern after comment-block reassembly).
   - The broad citation-detection pattern (substring match,
     no tail constraint).
   - Comment-block reassembly rule (`\n * ` → ` ` within
     contiguous comment lines).
   - Failure-mode taxonomy:
     - `MISSING citation` (M2.2, unchanged): file has no line
       passing M2.2 Rule C1.
     - `MISSING Station: directive` (M2.2, unchanged, koans-only).
     - `MULTIPLE Station: directives` (M2.2, unchanged,
       koans-only).
     - `UNRESOLVED citation: <text> (<reason>)` (M2.4, new):
       three sub-reasons per FR-003 / FR-004.
   - Multi-failure reporting (FR-016): one `[FAIL] <file>` per
     file, N reason lines per file in source order.
   - Bootstrap-error mode (FR-010): missing/empty/malformed
     index → script exits non-zero before any per-file
     processing.
   - Output format: `[ ok ] <file>` per file plus a one-line
     summary. The exact summary wording for the expanded scope
     is `<passed>/<total> files passed lint.` (replaces M2.2's
     `<passed>/<total> koans passed lint.`).
   - Exit codes (unchanged: 0 for full pass; 1 for any failure
     or missing/empty index).
   - Cross-platform parity rules (unchanged from M2.2 for
     em-dash; new for §-prefix in index parsing — both are
     UTF-8 byte sequences and the lint script reads as raw
     bytes).
   - Positive case table (lines that resolve under the new
     check) and negative case table (lines that fail; one row
     per sub-reason of `UNRESOLVED citation`).
   - Compatibility with the M2.2-era corpus: the post-M2.3
     corpus passes the new check on first run (US2 in spec.md).
     Pre-M2.3 partial commits on the feature branch may or may
     not pass; recovery is to complete the lint extension or
     revert.

3. **Quickstart** (`quickstart.md`): the local verification
   recipe — `bin/verify_solutions`, the new `bin/lint_citations`,
   runner-smoke fixture diff, plus M2.4-specific spot checks:
   - The negative spot-check procedure (introduce a fabricated
     citation `Cowlishaw §99.99, p. 999` into a sandbox koan;
     run lint; confirm rejection; revert; confirm green) — for
     SC-003.
   - The suffix-mismatch spot-check procedure (introduce a
     fabricated suffix `Cowlishaw §2.5, p. 32 — Bogus Heading`;
     run lint; confirm rejection; revert) — for SC-004.
   - The all-resolves-on-first-run check (lint reports `[ ok ]`
     for every koan and every solution on the rewritten branch)
     — for US2.
   - Mechanical out-of-scope checks (`git diff main`):
     index byte-identical, runner fixture byte-identical,
     no koan/solution edits committed.

4. **Agent context update**: `CLAUDE.md` `Active feature plan`
   line is repointed from `specs/005-vocab-review/plan.md` to
   `specs/006-citation-existence-lint/plan.md`.

**Output**: `data-model.md`, `contracts/lint_citations.md`,
`quickstart.md`, updated `CLAUDE.md`.

### Post-Design Constitution Re-Check

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First | **Pass** | The data model and contract are tooling-only artifacts; no koan authoring is in scope. The downstream effect is to *strengthen* Principle I in M3+ — every new koan that enters lint after M2.4 ships has its citations machine-validated against the index. |
| II. No Third-Party REXX Libraries | **Pass** | The contract restates: `bin/lint_citations` MUST be written in REXX (carries forward from M2 contract). M2.4 uses only Regina built-ins. The new index-row parser is implemented as REXX procedures (`parse_index`, `lookup_citation`, etc.); no external libraries are introduced. |
| III. Self-Teaching Vocabulary | **Pass and reinforced** | The contract documents that every citation a contributor writes — trailing canonical and in-prose parenthetical — is now machine-validated against `docs/cowlishaw_index.md`. This raises the floor on Principle III's "verified against the contributor's local copy" guarantee: the (§sec, page) part is now CI-verified, not just contributor-verified. |
| IV. CI Is the Acceptance Gate | **Pass** | The contract names the 6 CI checks (matrix verify_solutions × 2 OS, lint_citations × 2 OS, runner-smoke × 2 OS); the M2.4 lint extension preserves the exit-code semantics that drive the CI gate. The `runner_stdout.txt` fixture is byte-identical pre/post (lint behavior is tooling-only; runner output is unchanged). |
| V. Voice | **Pass** | The contract's failure-mode reason strings are diagnostic-first (cite the file, the citation text, the specific reason). No pilgrimage flavor leaks into lint output. |

No new violations. Plan stands.

## Phase 2: Tasks (preview only — generated by /speckit-tasks)

Phase 2 is out of scope for `/speckit-plan`. The expected task
shape, derivable from the artifacts above:

- **Setup phase**: Verify baseline (M2.3-merged main),
  baseline lint passes 6/6, baseline runner-smoke passes,
  index parses cleanly via a one-off sanity check.
- **Foundational phase**: Implement and unit-test (in REXX, as
  internal `PROCEDURE` calls) the index-row parser; verify it
  produces the expected lookup table on the current index.
- **US1 phase (P1, MVP)**: Extend `bin/lint_citations` with
  the lookup-table build, the broad citation-detection pattern,
  the comment-block reassembly, and the existence-check pass.
  Wire failure-mode reasons through to the per-file
  `[FAIL] <file>` + reason-line output.
- **US2 phase (P1, verification)**: Run the extended lint on
  the post-M2.3 corpus; confirm `[ ok ]` for every koan and
  every solution.
- **US3 phase (P1, contract)**: Author
  `specs/006-citation-existence-lint/contracts/lint_citations.md`
  per the Phase 1 design above; cross-reference from
  `bin/lint_citations`'s docstring header.
- **US4 phase (P2, CI gate)**: Push branch; confirm CI 6/6 green.
- **Polish phase**: Run the negative spot-checks (SC-003,
  SC-004) end-to-end via the `quickstart.md` recipe; confirm
  reject-and-revert path; final review against spec Out of
  Scope.

`/speckit-tasks` produces the ordered task list in `tasks.md`.
