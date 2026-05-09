# Implementation Plan: M2.1 — Cowlishaw Ground-Truth Index

**Branch**: `003-m2-1-cowlishaw-index` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/003-m2-1-cowlishaw-index/spec.md`

## Summary

Produce a single committed Markdown documentation file at
`docs/cowlishaw_index.md` that records the structural skeleton of M.F.
Cowlishaw's *The REXX Language* (2nd edition, 1990) — every numbered
SECTION, every named child heading inside those sections, and every
appendix entry — together with a one-line factual summary and a list
of canonical Cowlishaw vocabulary terms per row. The file is
authored by the contributor on a local machine using the gitignored
PDF in `reference/`, in three explicit passes: (1) programmatic
skeleton extraction with `pdftotext -layout`, (2) page-by-page
population of summaries and vocabulary, (3) UAT review by the
project owner. Once committed, the index becomes the authority for
all downstream Cowlishaw citations and vocabulary checks (M2.2,
M2.3, and every subsequent stage).

The deliverable is documentation, not code. M2.1 adds no new
`koans/`, `solutions/`, `lib/`, or `bin/` files, modifies no CI, and
introduces no new tests. The committed surface area is exactly one
file: `docs/cowlishaw_index.md`.

## Technical Context

**Language/Version**: N/A — Markdown documentation deliverable. The
build process uses `pdftotext` (poppler) and a small one-shot
extraction script written in any contributor-discretion language
(Bash + grep/awk recommended; see research.md). Neither the script
nor the raw extraction artifacts are committed to the repository.

**Primary Dependencies**: poppler `pdftotext` (≥ v22; tested on
`pdftotext 26.04.0` on macOS). Contributor-side only. Not a runtime
or CI dependency for the project.

**Storage**: One committed file (`docs/cowlishaw_index.md`).
Working artifacts (PDF, layout dump, extraction script,
intermediate skeleton drafts) live under `reference/` (gitignored)
or in `/tmp` and are never committed.

**Testing**: No automated tests. Acceptance is established by:

1. **Audit-table lookup** (SC-005 / spec User Story 1, scenario 3):
   for each of the eleven rows in `docs/M2_FOLLOWUP.md`'s audit
   table, the contributor can produce the audit-correct citation
   from the index alone in under one minute.
2. **Spot-check verification** (SC-006 / spec User Story 2,
   scenario 2): an external reviewer with the PDF open can verify
   any randomly chosen index row's title and page in under thirty
   seconds.
3. **Vocabulary-swap presence** (SC-007 / spec User Story 3,
   scenario 2): all four audit-flagged vocabulary swaps resolve
   against the relevant rows' vocabulary columns.
4. **UAT review pass** (SC-009): project owner reads the index
   end-to-end against the PDF; defects are corrected before commit.

**Target Platform**: GitHub-rendered Markdown + plain-text editors.
Markdown rendering must produce per-row anchor links so future PRs
can deep-link to a specific row.

**Project Type**: Documentation deliverable.

**Performance Goals**:
- Lookup time per row ≤ 1 minute (SC-005).
- Spot-check verification ≤ 30 seconds (SC-006).

**Constraints**:
- Copyright posture: structure-only — verbatim titles and short
  canonical vocabulary terms are acceptable; longer prose extracts
  from Cowlishaw are not (FR-010, FR-011, SC-008).
- Page numbers MUST be book pages, never PDF-viewer pages (FR-009).
- File order MUST follow Cowlishaw's section ordering (FR-013).
- Heading hierarchy fixed by FR-012a (with the Phase 0 empirical
  refinement recorded in §"Plan-Time Clarifications" of the spec —
  see research.md §1).
- Each row carries exactly three sub-bullets: Page, Summary,
  Vocabulary (FR-012b).
- Once committed, the index is anchored to the book, not the
  curriculum (FR-016).

**Scale/Scope**: Empirical row-count estimate from Phase 0
extraction:
- Part 1: 5 numbered sections (§1.1–§1.5).
- Part 2: 17 numbered sections (§2.1–§2.17).
- Appendices A, B, C, D: 4 top-level entries.
- Named child headings inside sections: estimated 80–120,
  concentrated in §2.7 (KEYWORD INSTRUCTIONS) and §2.9 (BUILT-IN
  FUNCTIONS), where each instruction or function is its own named
  child heading.
- **Total estimated rows: ~110–150.**

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Solution-First Development | M2.1 ships no koans; no koan/solution work order applies. | ✅ N/A — non-curriculum feature. |
| II. No Third-Party REXX Libraries | M2.1 commits no REXX code. The one-shot extraction tooling lives under `reference/` (gitignored) and may be written in any contributor-discretion language; it never enters the repository. | ✅ N/A — no committed code. |
| III. Every Koan Is Self-Teaching | M2.1 ships no koans. The index file IS the artifact that downstream koans cite, but it is not itself a teaching artifact. | ✅ N/A — non-curriculum feature. |
| IV. CI Is the Acceptance Gate | M2.1 adds no new CI checks and modifies none. Existing `verify_solutions`, `lint_citations`, and runner-smoke jobs MUST remain 6/6 green on `ubuntu-latest` and `macos-latest`. The committed `docs/cowlishaw_index.md` does not flow through any CI script. | ✅ Existing CI unaffected. (Optional `lint_citations` extension to verify citations against the index is explicitly assigned to M2.2, not M2.1; spec Out of Scope.) |
| V. Voice — Diagnostic First | The index is contributor-facing, not pilgrim-facing. No runner output, no failure messages, no scripture invocations. | ✅ N/A — non-pilgrim-facing. |

**Pre-Phase 0 gate**: All five principles green; no exceptions; no
violations to track. Proceeding to Phase 0.

**Post-Phase 1 re-check**: Phase 0 surfaced an empirical correction
to the spec's heading hierarchy (the book has one tier of numbered
sections, not two). The correction is documented in research.md §1
and recorded in the spec's `## Clarifications` section as a
plan-time clarification. No principle's compliance posture changed.
All gates remain green.

## Project Structure

### Documentation (this feature)

```text
specs/003-m2-1-cowlishaw-index/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output: PDF inspection findings + decisions
├── data-model.md        # Phase 1 output: Index row entity schema with examples
├── quickstart.md        # Phase 1 output: koan-author lookup workflow
├── contracts/
│   └── index_format.md  # Phase 1 output: canonical row format + worked example
├── checklists/
│   └── requirements.md  # /speckit-specify validation checklist
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
docs/
├── cowlishaw_index.md          # NEW — the deliverable.
├── M2_FOLLOWUP.md              # (existing) — input audit table; not modified.
├── DESIGN_DECISIONS.md         # (existing) — not modified.
├── INSTALLING.md               # (existing) — not modified.
└── PHILOSOPHY.md               # (existing) — not modified.

reference/                       # gitignored — contributor workspace.
├── REXX Language - 2nd Edition.pdf       # contributor-supplied PDF.
└── (extraction script + raw layout dump live here during build,
     are not committed, and may be deleted after the index ships).

# UNCHANGED in M2.1 (verified):
#   koans/                       — Stage I koans untouched until M2.2 / M2.3.
#   solutions/                   — Stage I solutions untouched until M2.2 / M2.3.
#   lib/                         — runner / assertion / stations untouched.
#   bin/                         — pilgrimage / verify_solutions / lint_citations untouched.
#   tests/fixtures/              — runner_stdout.txt untouched.
#   .github/workflows/verify.yml — CI untouched.
```

**Structure Decision**: Single committed file. M2.1's footprint in
the working tree is exactly `docs/cowlishaw_index.md`. The
contributor's local `reference/` workspace acquires temporary
extraction artifacts during the build; none are committed.

The deliberate non-modification of `koans/` and `solutions/` is
itself a load-bearing design decision: the spec's M2.1/M2.2/M2.3
sequencing requires that the index be authoritative *before* any
koan citation is rewritten, so that M2.2 has a stable target. M2.1
that touched koan files would entangle the two milestones.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No principle violations. No complexity requiring justification.

## Phase 0: Outline & Research

See [research.md](research.md) for the Phase 0 output. Topics
resolved:

1. **Empirical PDF heading structure** — the book has Part 1 (5
   numbered SECTIONs), Part 2 (17 numbered SECTIONs), and
   Appendices A–D. There is exactly one tier of Cowlishaw-numbered
   structure (the §X.Y level, X = Part, Y = SECTION-within-Part);
   the spec's distinction between "top-level numbered section" and
   "numbered §X.Y subsection" was over-tiered. Resolution
   integrated into the spec as a plan-time clarification.
2. **In-section heading nesting** — sections contain named child
   headings, sometimes typographically nested (e.g., Part 2 §2 →
   "Tokens" → "Literal strings"). Decision: flatten all in-section
   named headings to a single child-heading row tier in the index,
   matching the audit's existing citation format `Cowlishaw §X.Y,
   p. NN — <heading>`.
3. **Extraction tooling** — choice of language for the one-shot
   skeleton extractor. Decision: contributor-discretion (Bash +
   grep/awk recommended). Tooling is gitignored and one-shot.
4. **Vocabulary inclusion threshold** — what counts as "verbatim
   within or near the cited section" (FR-007). Decision:
   Cowlishaw-typeset terms (italics or distinct-style runs in body
   text) plus titles of in-section sub-headings. Generic English
   words excluded.
5. **Heading hierarchy in the file** — `#` for the document title;
   `#`-level Part/Appendix navigation wrappers; `##` per §X.Y row
   and per Appendix top; `###` per named child heading. (Refines
   FR-012a empirically.)
6. **Extraction script reproducibility** — script lives in
   gitignored `reference/`; not committed (consistent with spec
   Out of Scope: "Building any tool, watcher, or CI check that
   re-derives the index from the PDF").
7. **UAT defect resolution workflow** — defects are corrected
   in-place before commit; the index is never committed in
   known-incorrect state (FR-014, SC-009).

## Phase 1: Design & Contracts

### Data model

See [data-model.md](data-model.md). The single entity is the
**Index row**, with three discriminated kinds:

- `cowlishaw_section` — a §X.Y row (X = Part 1 or 2, Y = within-Part
  section number).
- `child_heading` — a named typographically distinct heading inside
  a §X.Y row.
- `appendix_entry` — an `Appendix N: TITLE` row, with optional
  `appendix_sub` rows for child headings inside the appendix.

Each row carries: identifier, verbatim title, book page, one-line
summary, and canonical vocabulary list.

### Contracts

See [contracts/index_format.md](contracts/index_format.md). The
contract is the canonical layout of `docs/cowlishaw_index.md`:
heading hierarchy, sub-bullet schema, ordering, and a worked
example showing Part 2 §2.2 with its child headings.

This is M2.1's "external interface" — it's the format that M2.2
will read against and that future stages will extend without
modifying.

### Quickstart

See [quickstart.md](quickstart.md). The workflow for a koan
author looking up a citation against the populated index, with
worked examples covering several of the audit-table topics.

### Agent context update

`CLAUDE.md` updated to point at this plan as the active feature
plan (see Phase 1 final step).
