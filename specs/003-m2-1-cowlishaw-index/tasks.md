---
description: "Task list for M2.1 — Cowlishaw Ground-Truth Index"
---

# Tasks: M2.1 — Cowlishaw Ground-Truth Index

**Input**: Design documents from `/specs/003-m2-1-cowlishaw-index/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/index_format.md, quickstart.md

**Tests**: NONE. This is a documentation deliverable; the spec
explicitly does not request automated tests. Acceptance is
established by lookup, spot-check, and UAT review (plan.md §"Testing").

**Organization**: Tasks are grouped by user story (all P1) so that
each story's contribution to the deliverable is independently
testable. The three user stories correspond to the spec's three
explicit build passes:

- **US1** (Pass 2a — populate Summaries) → koan-author lookup works.
- **US3** (Pass 2b — populate Vocabulary) → M2.3 has its term list.
- **US2** (Pass 3 — UAT review) → defects are fixed before commit.

The deliverable is exactly one committed file: `docs/cowlishaw_index.md`.
No other repository file is created or modified by M2.1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files OR independent
  contributor activity, no dependencies on incomplete tasks).
- **[Story]**: Which user story this task belongs to (US1, US2, US3).
- File paths are absolute or repo-rooted.

## Path Conventions

- **Committed file**: `docs/cowlishaw_index.md` (the only artifact that
  ships).
- **Working artifacts** (gitignored, contributor-side only):
  `reference/REXX Language - 2nd Edition.pdf` (existing) and
  `reference/m2.1-build/` (created in Phase 1).
- **Existing untouched**: `koans/`, `solutions/`, `lib/`, `bin/`,
  `tests/`, `.github/workflows/`. M2.1 does not modify these.

---

## Phase 1: Setup

**Purpose**: Confirm the contributor workspace has the inputs and
tooling required to run Pass 1, and create the gitignored working
subdirectory for intermediate artifacts.

- [X] T001 [P] Confirm `reference/REXX Language - 2nd Edition.pdf` exists and `reference/` is gitignored (verify with `git check-ignore reference/`); the PDF MUST NOT enter the staging area at any point.
- [X] T002 [P] Confirm `pdftotext` (poppler) is installed and is ≥ v22 (`pdftotext -v`).
- [X] T003 Create gitignored working subdirectory `reference/m2.1-build/` for the layout dump, extraction script, and skeleton drafts. Create `reference/m2.1-build/NOTES.md` to capture pagination offset, extraction patterns, and UAT defect log; record the `pdftotext -v` output observed in T002 as the file's first entry.

---

## Phase 2: Foundational (Pass 1 — Skeleton Extraction)

**Purpose**: Produce the skeleton of `docs/cowlishaw_index.md` —
every row's verbatim title and correct book page in the contract's
heading hierarchy, with empty Summary/Vocabulary bullets ready for
Pass 2 population. This phase BLOCKS all three user stories: no
populate or review work can begin until the skeleton is in the file.

**⚠️ CRITICAL**: No US1 / US2 / US3 work can begin until Phase 2
completes.

- [X] T004 Run `pdftotext -layout "reference/REXX Language - 2nd Edition.pdf" reference/m2.1-build/layout.txt` to produce the line-oriented layout dump. The dump MUST stay in `reference/m2.1-build/`; never staged for commit (FR-011, SC-008).
- [X] T005 Verify the PDF↔book page offset of +11 by spot-checking three known book pages from `docs/M2_FOLLOWUP.md` audit table (e.g., book p. 19 should be PDF p. 30 and contain "Literal strings"). Record the observed offset in `reference/m2.1-build/NOTES.md`. If offset differs, halt and raise the discrepancy — do not proceed with a wrong offset.
- [X] T006 In `reference/m2.1-build/layout.txt`, identify the typographic signature of `SECTION N: TITLE` headings (Cowlishaw renders them ALL CAPS preceded by literal "SECTION "). Record the grep pattern in `reference/m2.1-build/NOTES.md`.
- [X] T007 In `reference/m2.1-build/layout.txt`, identify the typographic signature of named typographically distinct child headings inside `§X.Y` SECTIONs (mixed-case headings that introduce a new sub-topic, distinguished from list-item labels and figure captions per spec edge case "Heading-rank confusion"). Record the grep pattern in `reference/m2.1-build/NOTES.md`.
- [X] T008 Author one-shot extraction script at `reference/m2.1-build/extract.sh` (Bash + grep/awk per research.md §3) that emits skeleton rows from `layout.txt`: one line per `§X.Y` SECTION, one line per child heading inside a SECTION, one line per Appendix entry, each line carrying verbatim title and computed book page (PDF page minus offset). The script lives only under `reference/m2.1-build/` and is never committed (research.md §6).
- [X] T009 Run `reference/m2.1-build/extract.sh > reference/m2.1-build/skeleton.txt`. Sanity-check row counts against research.md §1 estimates: 5 Part-1 SECTIONs, 17 Part-2 SECTIONs, 4 Appendices, ~80–120 child headings (concentrated in §2.7 and §2.9). Investigate any large discrepancy before proceeding.
- [X] T010 Create `docs/cowlishaw_index.md` with the top-of-file boilerplate exactly as specified in `specs/003-m2-1-cowlishaw-index/contracts/index_format.md` §"Top-of-file boilerplate" — `# Cowlishaw Ground-Truth Index` title, the contributor-facing preamble naming the source PDF, the +11 PDF↔book offset, the `Cowlishaw §X.Y, p. NN — <heading>` citation format, and the layout pointer.
- [X] T011 Append `# Part 1 — Background` navigation wrapper, then for each Part-1 SECTION (§1.1 through §1.5) and each of its child headings, append a `## §X.Y — Title in Mixed Case` (or `### Verbatim Child Heading`) heading followed by three bullets — `**Page:** NN`, `**Summary:** TODO`, `**Vocabulary:** TODO` — in `docs/cowlishaw_index.md`. Titles, pages, and ordering come from `reference/m2.1-build/skeleton.txt`. SECTION headings use headline case; child headings preserve Cowlishaw verbatim (per contracts/index_format.md §"§X.Y SECTION rendering" / §"Child-heading rendering").
- [X] T012 Append `# Part 2 — REXX Language Definition` wrapper, then SECTION rows §2.1 through §2.17 plus their child-heading rows, in book order, with the same heading + three-bullet pattern as T011 in `docs/cowlishaw_index.md`. Most child rows live under §2.7 (one per keyword instruction) and §2.9 (one per built-in function); enumerate per data-model.md §"Volume".
- [X] T013 Append `# Appendices` wrapper, then `## Appendix A: REXX Syntax Diagrams`, `## Appendix B: A Sample REXX Program`, `## Appendix C: Language Changes since First Edition`, `## Appendix D: Glossary`, each followed by the three-bullet pattern with `Page` populated and `Summary` / `Vocabulary` as `TODO`, in `docs/cowlishaw_index.md`. Per data-model.md §"appendix_sub", the second edition has no appendix sub-headings to add.

**Checkpoint**: Skeleton committed on the working branch (NOT main).
Every row carries verbatim title + correct book page. Summary and
Vocabulary bullets contain `TODO`. The file conforms to
contracts/index_format.md §"Heading hierarchy" and §"Per-row content
schema" (modulo the TODO placeholder content). User-story phases can
now begin.

---

## Phase 3: User Story 1 — Koan author looks up a citation (Priority: P1) 🎯 MVP

**Goal**: Each of the eleven audit-table topics in
`docs/M2_FOLLOWUP.md` resolves to a single index row whose verbatim
title + correct book page can be transcribed into a
`Cowlishaw §X.Y, p. NN — <heading>` citation that survives audit. A
factually accurate one-line `Summary` confirms the right row without
re-opening the PDF.

**Independent Test**: Open `docs/cowlishaw_index.md`, search for each
of the eleven audit-table topics (literal strings, comments, implied
semicolons / continuation, assignment, arithmetic, comparative,
logical / boolean, concatenation, numbers, SAY instruction,
INTERPRET). Each must resolve to a single row whose Summary confirms
match in well under one minute (SC-005), and whose title + page
produces the audit-correct citation per quickstart.md §"Worked
examples for the M2 audit topics".

### Implementation for User Story 1 (Pass 2a — populate Summary bullets)

For each task: open the PDF at the row's `Page` value, read the page,
write a one-line factual paraphrase into the row's `Summary` bullet
(replacing the `TODO`). Summaries are the index author's words — no
verbatim Cowlishaw prose runs beyond the heading title itself
(FR-010, SC-008). Confirm the summary is sufficient to identify the
row from a topic search alone.

- [X] T014 [US1] Replace `Summary: TODO` with a one-line factual paraphrase for every Part 1 row (§1.1 SECTION + child rows through §1.5 SECTION + child rows) in `docs/cowlishaw_index.md`, sourced by reading the corresponding PDF page.
- [X] T015 [US1] Replace `Summary: TODO` for every Part 2 §2.1 (CHARACTERS AND ENCODINGS) through §2.6 (COMMANDS TO EXTERNAL ENVIRONMENTS) SECTION row and child-heading row in `docs/cowlishaw_index.md`, sourced by reading the corresponding PDF pages.
- [X] T016 [US1] Replace `Summary: TODO` for §2.7 (KEYWORD INSTRUCTIONS) SECTION row and each per-instruction child-heading row (ADDRESS, ARG, CALL, DO, DROP, EXIT, IF, INTERPRET, ITERATE, LEAVE, NOP, NUMERIC, OPTIONS, PARSE, PROCEDURE, PULL, PUSH, QUEUE, RETURN, SAY, SELECT, SIGNAL, TRACE, UPPER) in `docs/cowlishaw_index.md`. Each instruction's summary is a one-line description of what the instruction does.
- [X] T017 [US1] Replace `Summary: TODO` for §2.8 (FUNCTION CALLS) SECTION row, §2.9 (BUILT-IN FUNCTIONS) SECTION row, and each per-function child-heading row (~60 functions enumerated in data-model.md §"Volume") in `docs/cowlishaw_index.md`. Each function's summary is a one-line description of what the function returns.
- [X] T018 [US1] Replace `Summary: TODO` for Part 2 §2.10 (PARSING…) through §2.17 (ERROR NUMBERS AND MESSAGES) SECTION rows and child-heading rows in `docs/cowlishaw_index.md`, sourced by reading the corresponding PDF pages.
- [X] T019 [US1] Replace `Summary: TODO` for Appendix A, B, C, D rows in `docs/cowlishaw_index.md`, sourced by reading the corresponding PDF pages.
- [X] T020 [US1] Self-test US1: walk the eleven audit topics in `docs/M2_FOLLOWUP.md` and the worked-examples table in `quickstart.md` §"Worked examples for the M2 audit topics". For each, perform the 60-second lookup workflow (quickstart.md §"The 60-second lookup workflow"); confirm each yields the audit-correct citation. Record any row whose Summary fails the "identify without re-opening the PDF" test and revise that Summary in place.

**Checkpoint**: US1 functionally complete. The index supports correct
citation lookup for every audit-table topic. Vocabulary bullets are
still `TODO`; the file is not yet committable (SC-004 requires
non-empty Vocabulary).

---

## Phase 4: User Story 3 — Vocabulary review against canonical Cowlishaw terms (Priority: P1)

**Goal**: Every row's Vocabulary bullet lists the canonical Cowlishaw
terms tied to the row's topic, drawn from typographically marked
terms, child-heading titles, and Glossary entries (research.md §4).
The four audit-flagged vocabulary swaps each have their canonical
replacement present in the appropriate row.

**Independent Test**: For any row, the listed terms appear verbatim
in or near the cited PDF page (SC-007 spot-check). Specifically, the
audit-flagged swaps resolve cleanly: "literal string" appears in the
§2.2 → Literal strings row; "symbol" appears in the §2.5 SECTION row
and/or §2.2 → Symbols child row; "Comparative" appears in the §2.3 →
Comparative child row; "Logical (Boolean)" appears in the §2.3 →
Logical (Boolean) child row.

### Implementation for User Story 3 (Pass 2b — populate Vocabulary bullets)

For each task: for each row in scope, identify canonical terms per
research.md §4 (typographically marked + child-heading titles +
Appendix D Glossary entries used in the section). Generic English
words are excluded. Replace `Vocabulary: TODO` with a comma-separated
list of those terms. Every term must appear verbatim in or near the
cited PDF page (FR-007).

- [X] T021 [US3] Replace `Vocabulary: TODO` for every Part 1 row (§1.1 SECTION + child rows through §1.5 SECTION + child rows) in `docs/cowlishaw_index.md`, applying the inclusion threshold from research.md §4.
- [X] T022 [US3] Replace `Vocabulary: TODO` for Part 2 §2.1 through §2.6 SECTION rows and child-heading rows in `docs/cowlishaw_index.md`. Among these, ensure §2.2 → Literal strings includes "literal string", §2.2 → Symbols includes "symbol" / "compound symbol" / "stem", §2.3 → Comparative includes "Comparative", §2.3 → Logical (Boolean) includes "Logical (Boolean)", and §2.5 SECTION row includes "symbol" / "variable" — these support SC-007.
- [X] T023 [US3] Replace `Vocabulary: TODO` for §2.7 SECTION row and per-keyword-instruction child-heading rows in `docs/cowlishaw_index.md`. Each instruction row's vocabulary is the instruction name itself plus any typographically marked operands or sub-keywords introduced on its page.
- [X] T024 [US3] Replace `Vocabulary: TODO` for §2.8 SECTION row, §2.9 SECTION row, and per-built-in-function child-heading rows in `docs/cowlishaw_index.md`. Each function row's vocabulary is the function name plus any typographically marked argument or return-shape terms introduced on its page.
- [X] T025 [US3] Replace `Vocabulary: TODO` for Part 2 §2.10 through §2.17 SECTION rows and child-heading rows in `docs/cowlishaw_index.md`.
- [X] T026 [US3] Replace `Vocabulary: TODO` for Appendix A, B, C, D rows in `docs/cowlishaw_index.md`. For Appendix D (Glossary), the Vocabulary entry summarizes the categories of terms catalogued; cross-reference Appendix D's term inventory against the Vocabulary lines on §X.Y rows for consistency, and revise any §X.Y row whose Vocabulary contradicts the Glossary's canonical form.
- [X] T027 [US3] Self-test US3: locate each of the four audit-flagged vocabulary swaps from `docs/M2_FOLLOWUP.md` in their target rows — "string literal" → "literal string" present on §2.2 → Literal strings; "variable name" / "identifier" → "symbol" present on §2.5 SECTION row (and/or §2.2 → Symbols); "Comparisons" → "Comparative" present on §2.3 → Comparative; "Logical operators" → "Logical (Boolean)" present on §2.3 → Logical (Boolean). Each must be findable by full-text search of `docs/cowlishaw_index.md` against the canonical form (SC-007).

**Checkpoint**: US3 functionally complete. Every row has a
non-empty canonical Vocabulary list (SC-004 satisfied). The file is
content-complete; the UAT gate (US2) is the last barrier to commit.

---

## Phase 5: User Story 2 — Project owner UAT review (Priority: P1)

**Goal**: The project owner reads the populated index end-to-end
against the PDF and confirms that every row's title, page, summary,
and vocabulary matches the source. Defects are corrected in-place on
the working branch before merge; the index is never committed in a
known-incorrect state (FR-014, SC-009).

**Independent Test**: An external reviewer with the PDF open can
verify any randomly chosen row's title and page in under thirty
seconds (SC-006), because titles are verbatim and pages are book
pages. Owner-recorded defects are all resolved before the branch
merges.

### Implementation for User Story 2 (Pass 3 — UAT review and fixes)

For each review task: read the rows in scope sequentially against
the PDF; record any defect (wrong title, wrong page, summary that
misses the row's content, vocabulary term that doesn't appear
verbatim in or near the page, ordering errors, schema violations) to
`reference/m2.1-build/NOTES.md` under a "UAT defects" heading. The
fix-application task (T033) consolidates the defect log into edits.

- [X] T028 [P] [US2] Read all Part 1 rows (§1.1 SECTION + child rows through §1.5) in `docs/cowlishaw_index.md` against the PDF; log any defects (title, page, summary accuracy, vocabulary verbatim presence) to `reference/m2.1-build/NOTES.md`.
- [X] T029 [P] [US2] Read all Part 2 §2.1 through §2.6 SECTION rows and child rows in `docs/cowlishaw_index.md` against the PDF; log defects.
- [X] T030 [P] [US2] Read §2.7 (KEYWORD INSTRUCTIONS) SECTION row + per-instruction child rows, and §2.8 + §2.9 SECTION rows + per-built-in-function child rows, in `docs/cowlishaw_index.md` against the PDF; log defects. (This is the heaviest UAT slice — every keyword and every built-in function is its own row.)
- [X] T031 [P] [US2] Read all Part 2 §2.10 through §2.17 SECTION rows and child rows in `docs/cowlishaw_index.md` against the PDF; log defects.
- [X] T032 [P] [US2] Read all Appendix A through D rows in `docs/cowlishaw_index.md` against the PDF; log defects.
- [X] T033 [US2] Apply every UAT defect from `reference/m2.1-build/NOTES.md` "UAT defects" log to `docs/cowlishaw_index.md` in-place on the working branch. Do not commit any partial defect-resolution state to main (FR-014: index never committed in known-incorrect state).
- [X] T034 [US2] Owner re-spot-checks the corrected rows (sampling rows whose defects were highest-impact, plus three randomly chosen rows). When every spot-check passes the SC-006 thirty-second criterion, owner signals UAT-accepted in `reference/m2.1-build/NOTES.md`.

**Checkpoint**: US2 complete. Index is UAT-accepted. The file is
ready for commit and downstream M2.2 / M2.3 consumption.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final mechanical conformance checks and the commit /
merge that ships M2.1.

- [X] T035 Format conformance: confirm every `##` and `###` heading in `docs/cowlishaw_index.md` is followed by exactly three Markdown bullets in the order `**Page:** NN`, `**Summary:** …`, `**Vocabulary:** …` with bolded labels, and no additional bullets, no prose paragraphs between heading and bullets, and no prose between bullets (FR-012b, contracts/index_format.md §"Per-row content schema"). Use grep over the file.
- [X] T036 Ordering conformance: confirm rows appear in document order §1.1 → §1.5, §2.1 → §2.17, then Appendix A → D; within each parent SECTION / appendix, child-heading rows appear in book order (FR-013, contracts/index_format.md §"Heading hierarchy"). Verify by reading the headings list with `grep -n '^##' docs/cowlishaw_index.md`.
- [X] T037 Copyright posture: confirm `docs/cowlishaw_index.md` contains no verbatim Cowlishaw prose runs beyond section/subsection titles and short canonical terms (SC-008, FR-010). Spot-check a sample of summaries against the cited PDF page to confirm paraphrase, not copy.
- [X] T038 Reference-workspace hygiene: confirm `git status` shows no `reference/*` additions and `git check-ignore reference/m2.1-build/extract.sh` returns success — the PDF, layout dump, extraction script, and skeleton draft remain unstaged and gitignored (FR-011, SC-008).
- [X] T039 CI sanity check: run `bin/verify_solutions`, `bin/lint_citations`, and the runner smoke locally; confirm all 6/6 still green. The docs-only change introduces no source-code or CI surface, but the project's Constitution Principle IV requires the existing acceptance gate to remain green.
- [X] T040 Commit `docs/cowlishaw_index.md` on branch `003-m2-1-cowlishaw-index` (single-file commit, UAT-accepted state); open PR for merge to `main` per the project's standard workflow. The merge commit becomes the first commit of the index on main; from this point the index is the authority for all downstream Cowlishaw citations and vocabulary checks (FR-015).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. Can start immediately.
- **Phase 2 (Foundational / Pass 1)**: Depends on Phase 1 completion. **BLOCKS all user stories** — no row population or review can begin without the skeleton in place.
- **Phase 3 (US1 / Pass 2a Summaries)**: Depends on Phase 2.
- **Phase 4 (US3 / Pass 2b Vocabulary)**: Depends on Phase 2. Independent of US1 — can run in parallel with Phase 3 if a second contributor is available, since US1 writes only `Summary:` bullets and US3 writes only `Vocabulary:` bullets in the same row.
- **Phase 5 (US2 / Pass 3 UAT)**: Depends on Phase 3 AND Phase 4 (UAT reviews fully populated rows).
- **Phase 6 (Polish & commit)**: Depends on Phase 5.

### User Story Dependencies

- **US1 (P1, MVP)**: Independent of US2/US3 in deliverable terms — produces working citation lookup for the 11 audit topics. Not committable alone (SC-004 requires non-empty Vocabulary).
- **US3 (P1)**: Independent of US1/US2 in deliverable terms — produces working canonical-vocabulary list for M2.3. Not committable alone (Summary bullets must be populated).
- **US2 (P1)**: Logically gates commit. Reviews US1 and US3 outputs together; cannot start until both are complete.

### Within Each User Story

- Tasks within US1 and US3 each edit `docs/cowlishaw_index.md` (the
  same single file) and so must run sequentially per contributor;
  page-range splits are by reading workload, not by parallelism.
- Tasks within US2 (T028–T032) are independent reading activities and
  marked [P] — multiple reviewers, or a single reviewer over multiple
  sessions, can split the read; T033 consolidates fixes; T034 spot-checks.

### Parallel Opportunities

- **Phase 1**: T001 (PDF check) and T002 (pdftotext check) are independent verifications, both [P].
- **Phase 5 UAT reads**: T028 / T029 / T030 / T031 / T032 are independent read+log activities on disjoint row ranges, all [P]. (T033 fix-application and T034 sign-off remain sequential.)
- **Cross-phase**: With two contributors, US1 (Phase 3) and US3 (Phase 4) can run concurrently — US1 fills `Summary:` bullets, US3 fills `Vocabulary:` bullets, on the same rows in the same file. Coordinate via small commits to avoid merge friction.

---

## Parallel Example: Phase 5 UAT reads

```bash
# With two reviewers (or one reviewer over two sessions),
# split the UAT read by row range. Each task only logs to
# reference/m2.1-build/NOTES.md; no file contention on
# docs/cowlishaw_index.md.

Reviewer A: T028 (Part 1) + T029 (Part 2 §2.1–§2.6)
Reviewer B: T030 (§2.7 + §2.8 + §2.9) + T031 (§2.10–§2.17) + T032 (Appendices)

# Then sequentially:
T033 (apply all logged fixes)
T034 (re-spot-check + UAT-accepted signal)
```

---

## Implementation Strategy

### MVP First (User Story 1 only — citation lookup demo)

1. Complete Phase 1 (Setup).
2. Complete Phase 2 (Foundational / Pass 1 skeleton). CRITICAL — blocks all stories.
3. Complete Phase 3 (US1 / Pass 2a Summaries).
4. **STOP and VALIDATE**: walk the 11 audit topics per quickstart.md
   §"Worked examples"; each must yield the audit-correct citation in
   under one minute.
5. Demo: the index supports correct lookup for the failure mode that
   motivated M2.1. Not yet committable (Vocabulary still TODO).

### Full Delivery (committable artifact)

1. Phase 1 → Phase 2 → Phase 3 (US1) → Phase 4 (US3).
2. Phase 5 (US2 / Pass 3 UAT review).
3. Phase 6 (mechanical checks + commit + merge).
4. Index lands on `main`; M2.2 and M2.3 unblock.

### Parallel-Contributor Strategy

With two contributors:

1. Both complete Phases 1 and 2 together (skeleton extraction is
   single-author work — handoff occurs at end of Phase 2).
2. Contributor A: Phase 3 (US1 — Summaries).
3. Contributor B: Phase 4 (US3 — Vocabulary).
4. Both done → Phase 5 (UAT, with [P] read tasks split between
   them).
5. Either contributor: Phase 6 (commit and merge).

---

## Notes

- [P] tasks within a phase can run in parallel; [P] across phases
  is governed by phase dependencies above.
- [Story] label maps task to specific user story for traceability.
- Page numbers throughout are **book pages** (printed-edition
  pagination preserved in the Internet Archive scan), never
  PDF-viewer pages (FR-009).
- The repository commits exactly one file: `docs/cowlishaw_index.md`.
  The PDF, layout dump, extraction script, skeleton draft, and UAT
  notes all live under gitignored `reference/` and never enter the
  staging area (FR-011, SC-008).
- The index, once committed, is anchored to the book — not the
  curriculum. Post-commit edits are permitted only to correct
  misrepresentation of Cowlishaw, not to accommodate koan changes
  (FR-016).
- No new tests, no new CI, no new koans, no new solutions, no new
  `lib/` or `bin/` files. M2.1's footprint in the working tree is
  exactly `docs/cowlishaw_index.md`.
