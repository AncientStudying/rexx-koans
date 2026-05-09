# Implementation Plan: M2.2 — Citation Rewrite Against the Index

**Branch**: `004-m2-2-citation-rewrite` | **Date**: 2026-05-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification at `specs/004-m2-2-citation-rewrite/spec.md`

## Summary

Replace every Cowlishaw citation in the Stage I koans and matching
solutions with one that references an existing row in
`docs/cowlishaw_index.md`, applying the bare-preferred canonical form
defined by Constitution Principle III (clarified 2026-05-09 in
spec.md). Tighten `bin/lint_citations` to enforce the canonical form,
rejecting the legacy `--` separator that the current permissive regex
silently accepts. Defer the optional mechanical existence-check lint
extension (FR-014) to a successor feature.

The rewrite resolves all 11 audit rows in `docs/M2_FOLLOWUP.md`
(Audit findings 2026-05-08): 9 wrong section/page pairs are
corrected, 2 already-correct rows are normalized to the canonical
form. Phase 0 lookup against the committed index produced a complete
14-row mapping with no index defects discovered; FR-009's
defect-patch escape hatch is not exercised.

Approach is mechanical and small-radius: per-distinct-citation-string
edits applied via `Edit replace_all` to the six (koan, solution)
pairs, plus one `bin/lint_citations` regex tightening, plus one lint
contract amendment. No re-derivation of the index from the PDF; no
runtime tooling changes; no scope creep into M2.3 vocabulary work.

## Technical Context

**Language/Version**: Regina REXX (ANSI X3.274 / Cowlishaw definition).
**Primary Dependencies**: None new. The work uses Regina built-ins
(`POS`, `SUBSTR`, `STRIP`, `DATATYPE`, `LINEIN`, `STREAM`, hex
literals) already in use by `bin/lint_citations`.
**Storage**: N/A (file edits only).
**Testing**: `bin/verify_solutions` (existing), `bin/lint_citations`
(updated under FR-008), `runner-smoke` (existing fixture
`tests/fixtures/runner_stdout.txt`). Six CI checks total per
Constitution Principle IV.
**Target Platform**: macOS (Homebrew Regina) and ubuntu-latest (apt
Regina), enforced by `.github/workflows/verify.yml`. No platform
divergence expected.
**Project Type**: Curriculum / training-content artifact. Edits land
in `koans/`, `solutions/`, `bin/`, and the lint contract.
**Performance Goals**: N/A — `bin/lint_citations` runs over six small
koan files in well under a second; the regex tightening adds a
constant-time tail check per citation match. No regression risk.
**Constraints**: `tests/fixtures/runner_stdout.txt` MUST remain
byte-identical (FR-010). `docs/cowlishaw_index.md` is read-only for
this feature (FR-009). M2.3 vocabulary edits are out of scope
(FR-012).
**Scale/Scope**: 6 koan files, 6 solution files, 1 lint script, 1
contract file. ~50 citation occurrences across 14 distinct strings.
Total expected diff well under 200 lines including the lint script
update.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First Development | **Pass** | M2.2 does not author new koans; the byte-parity invariant in spec FR-003 (every koan/solution citation pair byte-identical) is the equivalent guarantee for this rewrite. The standard 5-step work order is N/A here because no new tests are added. |
| II. No Third-Party REXX Libraries | **Pass** | Lint update uses only Regina built-ins. No new dependencies. The em-dash detection uses `'E2 80 94'X` hex literal (UTF-8 byte sequence), already idiomatic for byte-level matching in REXX. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | This feature *operationalizes* Principle III by (a) bringing every existing citation into the canonical form and (b) tightening `bin/lint_citations` to enforce that form going forward. Spec FR-005 / FR-006 / FR-007 / FR-008 are direct expansions of Principle III. |
| IV. CI Is the Acceptance Gate | **Pass** | All 6 CI checks (verify_solutions × 2 OS, lint_citations × 2 OS, runner-smoke × 2 OS) MUST be green pre-merge per spec SC-005. Cross-OS parity is automatic — the lint script change is a pure REXX tail check with no platform-dependent behavior. |
| V. Voice — Diagnostic First, Pilgrimage Flavor Second | **Pass** | Citation lines are tail metadata; M2.2 does not modify any voice-bearing prose, station names, scripture, or failure messages. Voice-bearing changes are M2.3's deliverable. |

**Verdict**: PASS. No violations; Complexity Tracking section omitted.

## Project Structure

### Documentation (this feature)

```text
specs/004-m2-2-citation-rewrite/
├── plan.md                       # This file (/speckit-plan output)
├── research.md                   # Phase 0 — audit-row → index-row mapping; lint regex design
├── data-model.md                 # Phase 1 — citation entities + audit coverage matrix
├── quickstart.md                 # Phase 1 — local verification recipe
├── contracts/
│   └── lint_citations.md         # Phase 1 — updated lint contract (supersedes M2 contract for FR-008)
├── checklists/
│   └── requirements.md           # Pre-existing (created by /speckit-specify)
├── spec.md                       # Pre-existing (created by /speckit-specify, clarified by /speckit-clarify)
└── tasks.md                      # Phase 2 — created by /speckit-tasks (NOT this command)
```

### Source Code (repository root)

```text
koans/
├── 00_about_asserts.rexx         # Edit: 4 citation occurrences (3 distinct strings)
├── 01_about_strings.rexx         # Edit: 4 citation occurrences (2 distinct strings)
├── 02_about_variables.rexx       # Edit: 4 citation occurrences (1 distinct string)
├── 03_about_expressions.rexx     # Edit: 5 citation occurrences (5 distinct strings)
├── 04_about_clauses.rexx         # Edit: 4 citation occurrences (3 distinct strings)
└── 05_about_say.rexx             # Edit: 4 citation occurrences (1 distinct string)

solutions/
├── 00_about_asserts.rexx         # Edit: byte-parallel to koans/00
├── 01_about_strings.rexx         # Edit: byte-parallel to koans/01
├── 02_about_variables.rexx       # Edit: byte-parallel to koans/02
├── 03_about_expressions.rexx     # Edit: byte-parallel to koans/03
├── 04_about_clauses.rexx         # Edit: byte-parallel to koans/04
└── 05_about_say.rexx             # Edit: byte-parallel to koans/05

bin/
└── lint_citations                # Edit: tighten check_citation per FR-008

docs/
├── cowlishaw_index.md            # READ-ONLY for this feature (FR-009)
├── M2_FOLLOWUP.md                # READ-ONLY (audit table is the canonical defect list)
└── DESIGN_DECISIONS_M2.md        # READ-ONLY (no new design decisions in M2.2)

tests/fixtures/
└── runner_stdout.txt             # READ-ONLY for this feature (FR-010)
```

**Structure Decision**: This feature edits in place across the existing `koans/`, `solutions/`, and `bin/` trees. No new top-level directories. The new `contracts/lint_citations.md` under this feature's spec directory supersedes the M2 contract for the FR-008 changes; the M2 contract remains the historical record of the M1/M2-era behavior. No source-code reorg is needed; M2.2 is a content rewrite plus a one-script lint tightening.

## Phase 0: Outline & Research

Phase 0 had no NEEDS-CLARIFICATION markers in the spec post-clarify, so the research is mechanical lookup work, not open research. The only research-shaped questions were:

1. **For each of the 14 distinct citation strings currently in the corpus, what is the index-supported replacement?** Answered by direct lookup in `docs/cowlishaw_index.md`.
2. **For each replacement, does (§N.N, book page) uniquely identify a row, or is the disambiguator suffix needed?** Answered by walking each parent §N.N's child rows and checking page collisions.
3. **What is the precise tightening of `check_citation` in `bin/lint_citations` to enforce FR-005/FR-007's canonical form?** Answered by reading the existing script and designing a tail check.

Findings consolidated in `research.md`. No NEEDS-CLARIFICATION remains. No index defects were discovered during lookup (FR-009's escape hatch is unused).

**Output**: `research.md` with the 14-row rewrite mapping, the audit-row coverage table, and the lint regex design.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete (mapping table finalized).

1. **Data model** (`data-model.md`): formalize the entities `Citation line`, `Distinct citation string`, `Audit row`, `Index row`, `Lint script`, `Lint contract` from spec.md "Key Entities", plus the rewrite mapping table from research.md as the canonical join.

2. **Contracts** (`contracts/lint_citations.md`): the updated `bin/lint_citations` behavior under FR-008. This file supersedes `specs/002-m2-walking-skeleton/contracts/lint_citations.md` for the citation-format check; the Station: directive check is unchanged. The update is additive: format is tightened, but every passing M2-era citation that conforms to the canonical form still passes.

3. **Quickstart** (`quickstart.md`): the local verification recipe — `bin/verify_solutions`, `bin/lint_citations`, runner walk + fixture diff — that a contributor (or reviewer) runs to confirm the rewrite locally before pushing.

4. **Agent context update**: `CLAUDE.md` `Active feature plan` line is repointed from `specs/003-m2-1-cowlishaw-index/plan.md` to `specs/004-m2-2-citation-rewrite/plan.md`.

**Output**: `data-model.md`, `contracts/lint_citations.md`, `quickstart.md`, updated `CLAUDE.md`.

### Post-Design Constitution Re-Check

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First | **Pass** | Mapping table preserves byte-parity by construction (one rewrite operation applied to both koan and matching solution per pair). |
| II. No Third-Party REXX Libraries | **Pass** | Lint regex tightening is pure-REXX additive logic (`POS`, `SUBSTR`, `STRIP`, hex literal). |
| III. Self-Teaching Citations | **Pass** | Every entry in the mapping table is grounded in an index row whose page anchors the concept the koan teaches; the bare/suffixed selection is unambiguous from the (parent §N.N, book page) collision check. |
| IV. CI Is the Acceptance Gate | **Pass** | The contract amendment makes the new lint behavior auditable; the runner stdout fixture is invariant by construction (citations live in comments). |
| V. Voice | **Pass** | No voice-bearing surface is touched. |

No new violations. Plan stands.

## Phase 2: Tasks (preview only — generated by /speckit-tasks)

Phase 2 is out of scope for `/speckit-plan`. The expected task shape, derivable from the artifacts above:

- Per-distinct-string Edit operations against (koan, solution) pairs (≈14 distinct edits across 12 files).
- One `bin/lint_citations` patch implementing the tightened `check_citation`.
- One `contracts/lint_citations.md` write.
- Local verification (verify_solutions + lint_citations + runner walk + fixture diff).
- CI verification (push branch; confirm 6/6 green).

`/speckit-tasks` produces the ordered task list in `tasks.md`.
