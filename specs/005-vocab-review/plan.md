# Implementation Plan: M2.3 — Vocabulary Review Against the Index

**Branch**: `005-vocab-review` | **Date**: 2026-05-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification at `specs/005-vocab-review/spec.md`

## Summary

Walk every teaching comment block in `koans/00_about_asserts.rexx`
through `koans/05_about_say.rexx` (and the byte-parallel files under
`solutions/`) and substitute any technical term that does not match
the canonical Cowlishaw vocabulary recorded in
`docs/cowlishaw_index.md`. Per the Clarifications session 2026-05-09:
the walk is **comprehensive** (FR-001 governs; the 5 UAT-flagged
candidates in PLAN.md §M2.3 are an illustrative subset, not a
ceiling), and **establish-once + targeted re-label** is the
framework-vs-REXX framing strategy (full layering in koan 00 per
FR-002; targeted re-label in koans 01–05 only at conflation points
per FR-002a).

The rewrite is content-only — koan/solution comment blocks. No
runtime code paths, no lint behavior, no fixture content, no index
content is modified by this feature. Phase 0 walked every teaching
block in the corpus against the index and produced a substitution
table covering ~21 distinct vocabulary substitutions plus 4 koan-00
framework-vs-REXX layering rewrites and 3 targeted koan-01-through-05
re-labels. No index defects were discovered; FR-007's defect-patch
escape hatch is not exercised.

Approach is mechanical and small-radius: per-distinct-term `Edit
replace_all` operations against the six (koan, solution) pairs for
the bulk substitutions, plus a small number of full-block rewrites
for koan 00's framework-vs-REXX layering and koan 01–05's targeted
re-labels (where a one-string substitution cannot capture the
restructuring). No `bin/`, `lib/`, `tests/`, or `docs/` files are
touched.

## Technical Context

**Language/Version**: Regina REXX (ANSI X3.274 / Cowlishaw
definition). The edit target is REXX comment text, not REXX code.
**Primary Dependencies**: None new. The lookup authority is
`docs/cowlishaw_index.md`, read-only at HEAD of `main`.
**Storage**: N/A (file edits only).
**Testing**: `bin/verify_solutions` (existing), `bin/lint_citations`
(existing — unmodified by this feature, FR-010), `runner-smoke`
(existing fixture `tests/fixtures/runner_stdout.txt`). Six CI checks
total per Constitution Principle IV.
**Target Platform**: macOS (Homebrew Regina) and ubuntu-latest (apt
Regina), enforced by `.github/workflows/verify.yml`. No platform
divergence expected — comment-text edits cannot diverge by interpreter.
**Project Type**: Curriculum / training-content artifact. Edits land
in `koans/` and `solutions/` only.
**Performance Goals**: N/A.
**Constraints**:
- `tests/fixtures/runner_stdout.txt` byte-identical pre/post (FR-008).
- `docs/cowlishaw_index.md` read-only (FR-007).
- Citation lines unmodified (FR-006); per the FR-006 interpretation
  in `research.md` §3, *adding* new in-prose parenthetical Cowlishaw
  references for the framework-vs-REXX layering is permitted —
  *modifying* existing trailing citation lines is not.
- `bin/lint_citations` unmodified (FR-010).
- `lib/meditation.rexx` and other framework code unmodified (FR-011).
**Scale/Scope**: 6 koan files, 6 solution files. ~24 teaching
comment blocks across Stage I; ~21 distinct vocabulary substitutions
applied bulk via `Edit replace_all`; 4 koan-00 framework-vs-REXX
layering rewrites; 3 koan-01-through-05 targeted re-labels. Total
expected diff well under 250 lines.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First Development | **Pass** | M2.3 does not author new koans; FR-004's per-substitution-parity invariant (every vocabulary substitution applied identically to koan and matching solution wherever the source-term appears, per the Clarifications session 2026-05-09 revision) is the equivalent guarantee for the rewrite. The standard 5-step work order is N/A here because no new tests or assertions are added. |
| II. No Third-Party REXX Libraries | **Pass** | No code touched. The edit target is REXX comment text. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | This feature *operationalizes* Principle III's self-teaching guarantee at the vocabulary layer: the pilgrim now reads the same nouns Cowlishaw writes when consulting the cited book page. The framework-vs-REXX layering in FR-002 makes Principle III's self-teaching rigorous for koan 00, the entry point of the curriculum. |
| IV. CI Is the Acceptance Gate | **Pass** | All 6 CI checks (verify_solutions × 2 OS, lint_citations × 2 OS, runner-smoke × 2 OS) MUST be green pre-merge per spec SC-005. Cross-OS parity is automatic — comment-text edits have no platform-dependent behavior. |
| V. Voice — Diagnostic First, Pilgrimage Flavor Second | **Pass** | FR-012 carves voice-bearing prose out of scope. The pilgrim, the path, the Bathonian, and the pilgrimage flavor are preserved verbatim. M2.3 substitutes technical nouns; it does not edit voice. |

**Verdict**: PASS. No violations; Complexity Tracking section omitted.

## Project Structure

### Documentation (this feature)

```text
specs/005-vocab-review/
├── plan.md                        # This file (/speckit-plan output)
├── research.md                    # Phase 0 — lookup discipline + substitution table + framework-vs-REXX layering pattern
├── data-model.md                  # Phase 1 — content entities + index-vocabulary join
├── quickstart.md                  # Phase 1 — local verification recipe
├── contracts/
│   └── teaching_prose.md          # Phase 1 — editorial contract for Stage I teaching prose (carries forward to M3+)
├── checklists/
│   └── requirements.md            # Pre-existing (created by /speckit-specify)
├── spec.md                        # Pre-existing (created by /speckit-specify, clarified by /speckit-clarify)
└── tasks.md                       # Phase 2 — created by /speckit-tasks (NOT this command)
```

### Source Code (repository root)

```text
koans/
├── 00_about_asserts.rexx          # Edit: full framework-vs-REXX layering (FR-002), per-block restructuring of all 4 concept blocks
├── 01_about_strings.rexx          # Edit: 1 targeted re-label (datatype block, per FR-002a) + bulk vocab substitutions
├── 02_about_variables.rexx        # Edit: bulk vocab substitutions (uninitialized variable, literal strings, etc.)
├── 03_about_expressions.rexx      # Edit: 1 targeted re-label (logical-operators block, per FR-002a) + bulk vocab substitutions (Comparative, Logical (Boolean), blank operator, abuttal)
├── 04_about_clauses.rexx          # Edit: bulk vocab substitutions (continuation character, implied semicolon)
└── 05_about_say.rexx              # Edit: bulk vocab substitutions (default character output stream, blank operator, null string)

solutions/
├── 00_about_asserts.rexx          # Edit: byte-parallel to koans/00 (every change applied identically)
├── 01_about_strings.rexx          # Edit: byte-parallel to koans/01
├── 02_about_variables.rexx        # Edit: byte-parallel to koans/02
├── 03_about_expressions.rexx      # Edit: byte-parallel to koans/03
├── 04_about_clauses.rexx          # Edit: byte-parallel to koans/04
└── 05_about_say.rexx              # Edit: byte-parallel to koans/05

bin/
├── lint_citations                 # READ-ONLY for this feature (FR-010)
└── verify_solutions               # READ-ONLY

lib/
├── meditation.rexx                # READ-ONLY (FR-011 carve-out)
├── pilgrimage.rexx                # READ-ONLY
└── stations.rexx                  # READ-ONLY

docs/
├── cowlishaw_index.md             # READ-ONLY for this feature (FR-007)
├── M2_FOLLOWUP.md                 # READ-ONLY (Task 3 is what this feature implements)
├── DESIGN_DECISIONS.md            # READ-ONLY
└── DESIGN_DECISIONS_M2.md         # READ-ONLY

tests/fixtures/
└── runner_stdout.txt              # READ-ONLY for this feature (FR-008)
```

**Structure Decision**: This feature edits in place across the existing `koans/` and `solutions/` trees only. No new top-level directories, no `bin/` or `lib/` changes, no contract or fixture changes. The new `contracts/teaching_prose.md` under this feature's spec directory is an *editorial* contract — it documents the substitution rules and the framework-vs-REXX layering pattern as a reference for M3+ koan authoring; it is not enforced by tooling. The narrowest possible source-tree footprint for the actual content work: 12 file edits.

## Phase 0: Outline & Research

Phase 0 had no NEEDS-CLARIFICATION markers in the spec post-clarify (Q1 and Q2 resolved both substantive ambiguities). Research was therefore mechanical lookup work, not open research. The questions:

1. **What is the lookup discipline that decides whether a koan term is a vocabulary mismatch?** Answered by formalizing the construct-naming rule: a term that *names* a REXX construct (subject/object identifier) MUST use Cowlishaw's vocab term; general English used to *describe* a construct is unconstrained. See `research.md` §1.
2. **For each Stage I koan teaching block, which technical terms need substitution?** Answered by walking every teaching block against the relevant index row's `Vocabulary:` column. The substitution table — ~21 distinct substitutions, scoped per-koan — is in `research.md` §2.
3. **What does the framework-vs-REXX layering look like in koan 00 (FR-002)?** Answered by drafting per-concept-block layered prose for all four concept blocks (equality, difference, truth, type). See `research.md` §3.
4. **Which sentences in koans 01–05 specifically conflate framework and REXX (FR-002a)?** Answered by walking each koan and identifying the sentences that name a framework verb in the same breath as a REXX construct. Three targeted re-labels surfaced. See `research.md` §4.
5. **Does adding new in-prose parenthetical Cowlishaw citations (for the framework-vs-REXX layering) violate FR-006's "citation lines MUST NOT be modified"?** Answered: no — FR-006 prohibits *modifying* existing citation lines, not *adding* new in-prose references. The interpretation and its rationale are recorded in `research.md` §5; the existing trailing citations on each block are preserved verbatim.
6. **Are any index defects surfaced by the lookup?** Walked the relevant index rows; none discovered. FR-007's defect-patch escape hatch is not exercised. See `research.md` §6.

**Output**: `research.md` with the lookup discipline, the substitution table, the koan-00 layered-prose proposal, the koan-01-through-05 targeted re-labels, the FR-006 interpretation, and the index-defect pass result. No NEEDS-CLARIFICATION remains.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete (substitution table and layering proposals finalized).

1. **Data model** (`data-model.md`): formalize the entities `Teaching comment block`, `Technical term`, `Index vocabulary entry`, `UAT-flagged candidate`, `Framework verb`, plus the join between a teaching block's terms and the relevant index row's vocabulary.

2. **Contracts** (`contracts/teaching_prose.md`): the editorial contract for Stage I teaching prose — lookup discipline (Rule T1), framework-vs-REXX layering pattern with worked example (Rule T2), targeted re-label pattern for non-koan-00 conflations (Rule T3), citation-line read-only invariant (Rule T4), koan/solution byte-parity invariant (Rule T5). This document is NOT enforced by tooling; it is the authoring reference for M3+ koan contributors.

3. **Quickstart** (`quickstart.md`): the local verification recipe — `bin/verify_solutions`, `bin/lint_citations`, runner-smoke fixture diff, plus M2.3-specific spot checks for the substitution-table coverage and koan/solution teaching-prose byte-parity.

4. **Agent context update**: `CLAUDE.md` `Active feature plan` line is repointed from `specs/004-m2-2-citation-rewrite/plan.md` to `specs/005-vocab-review/plan.md`.

**Output**: `data-model.md`, `contracts/teaching_prose.md`, `quickstart.md`, updated `CLAUDE.md`.

### Post-Design Constitution Re-Check

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First | **Pass** | The substitution table and the layered-prose proposals preserve per-substitution parity by construction (each substitution applied identically to both koan and matching solution wherever the source-term appears, per the FR-004 revision in the spec's Clarifications session 2026-05-09). |
| II. No Third-Party REXX Libraries | **Pass** | No code, no lint script, no library files touched. |
| III. Self-Teaching Vocabulary | **Pass and reinforced** | Every substitution in the table is grounded in an index row's `Vocabulary:` column; the layered-prose proposal in koan 00 makes the framework-vs-REXX distinction explicit at the entry point of the curriculum. |
| IV. CI Is the Acceptance Gate | **Pass** | The runner stdout fixture is invariant by construction (teaching prose lives in comments and is never echoed); `bin/lint_citations` is unmodified, so its 6/6 green status carries through unchanged. |
| V. Voice | **Pass** | The substitution table touches technical nouns only; pilgrim-voice flourishes (`Welcome, pilgrim`, `the four kinds of assertion`, station taglines) are preserved verbatim per FR-012. |

No new violations. Plan stands.

## Phase 2: Tasks (preview only — generated by /speckit-tasks)

Phase 2 is out of scope for `/speckit-plan`. The expected task shape, derivable from the artifacts above:

- Per-distinct-term `Edit replace_all` operations against (koan, solution) pairs (≈21 distinct substitutions across 12 files; see `research.md` §2 substitution table).
- Per-concept-block full-block edits in `koans/00_about_asserts.rexx` and matching solution to apply the framework-vs-REXX layered prose (4 concept blocks; see `research.md` §3).
- Per-targeted-re-label edits in koans 01, 03 (and matching solutions) to address the conflation sentences identified in `research.md` §4 (3 targeted edits).
- Local verification (`bin/verify_solutions` + `bin/lint_citations` + runner-smoke fixture diff + the M2.3-specific spot checks in `quickstart.md`).
- CI verification (push branch; confirm 6/6 green).

`/speckit-tasks` produces the ordered task list in `tasks.md`.
