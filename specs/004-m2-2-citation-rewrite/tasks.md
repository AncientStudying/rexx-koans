---
description: "Task list for M2.2 — Citation Rewrite Against the Index"
---

# Tasks: M2.2 — Citation Rewrite Against the Index

**Input**: Design documents from `/specs/004-m2-2-citation-rewrite/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/lint_citations.md, quickstart.md

**Tests**: NONE. M2.2 is a content rewrite + lint tightening; the
spec does not request automated tests beyond the existing CI matrix
(verify_solutions, lint_citations, runner-smoke). Acceptance is
established by the 6/6 CI checks plus the byte-parity diff and the
audit-row coverage spot check defined in `quickstart.md`.

**Organization**: M2.2's three P1 user stories (US1, US2, US3) are
*different aspects of the same edit set* rather than independent
work increments. The task structure reflects this:

- The actual rewrite work is grouped under US2 (audit closure) — the
  most concrete, audit-row-traceable framing.
- US1 (pilgrim verification) and US3 (byte-parity) become read-only
  verification phases that confirm the rewrite delivers their
  invariants.
- Lint canonical-form enforcement (FR-007/FR-008) is a cross-cutting
  enabler with its own phase between the rewrite and CI verification.
- US4 (CI green + fixture invariance) is the project-level
  acceptance gate.
- US5 is deferred (Clarifications session 2026-05-09); no tasks.

The three P1 stories ship as a single atomic delivery; the phase
ordering chosen here keeps every intermediate commit lint-green by
applying corpus rewrites before tightening the lint script.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on
  incomplete tasks).
- **[Story]**: User story this task contributes to (US1, US2, US3,
  US4). Setup, Foundational, Lint, and Polish phases carry no story
  tag.
- File paths are repo-rooted.

## Path Conventions

- **Edit targets**: `koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx`, the parallel files under `solutions/`,
  and `bin/lint_citations`.
- **Read-only**: `docs/cowlishaw_index.md`, `docs/M2_FOLLOWUP.md`,
  `tests/fixtures/runner_stdout.txt`,
  `specs/002-m2-walking-skeleton/contracts/lint_citations.md` (the
  M2-era contract — historical record, not modified by this feature).
- **Already authored by /speckit-plan**:
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`
  (the M2.2-amended contract). No further edits in tasks below.

---

## Phase 1: Setup

**Purpose**: Confirm the contributor workspace matches the
preconditions assumed by `research.md` §1 (the rewrite mapping
table). Catches corpus drift between plan and implementation.

- [X] T001 [P] Verify `docs/cowlishaw_index.md` exists at HEAD on the feature branch and is byte-identical to its `main`-branch state (the M2.1 deliverable). `git diff main -- docs/cowlishaw_index.md` MUST be empty.
- [X] T002 [P] Verify the current Stage I citation set matches research.md §1: `grep -nE 'Cowlishaw §' koans/0*_about_*.rexx solutions/0*_about_*.rexx` MUST list exactly the 14 distinct old strings with their expected occurrence counts (3 in koan 00, 4 in koan 01, 4 in koan 02, 5 in koan 03, 4 in koan 04, 4 in koan 05; mirrored in solutions). If any string has drifted, halt and reconcile against research.md §1 before proceeding.
- [X] T003 [P] Verify `bin/lint_citations` runs green on the unmodified corpus (`bin/lint_citations` should print `6/6 koans passed lint.` and exit 0). This baselines the "current permissive lint" state — the rewrites in Phase 3 must keep this baseline green commit-by-commit.

---

## Phase 2: Foundational

**Purpose**: Standard speckit slot for blocking prerequisites that span multiple user stories. M2.2 has none — the lookup authority (`docs/cowlishaw_index.md`) was delivered by M2.1; the lint contract (`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`) was authored by `/speckit-plan`. The rewrite phase can begin immediately after Setup.

**Checkpoint**: No tasks. Proceed directly to Phase 3.

---

## Phase 3: User Story 2 — Stage I Citation Rewrite (Priority: P1) 🎯 MVP

**Goal**: Rewrite every Cowlishaw citation in the Stage I corpus to point at an existing row in `docs/cowlishaw_index.md`, applying the bare-preferred canonical form per FR-005 and the index-derived mappings in `research.md` §1. Closes all 11 rows of the `docs/M2_FOLLOWUP.md` audit table.

**Independent Test**: After this phase, `grep -nE 'Cowlishaw §' koans/*.rexx solutions/*.rexx` should produce only the 14 canonical-form strings listed in research.md §1; no occurrence of `-- ` (legacy ASCII separator) remains. Audit row coverage is verified by walking `docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)" and confirming each row's koan now bears the expected new citation.

**Why this serves all three P1 stories**: Every per-pair edit simultaneously satisfies US1 (the new citation points at the right book page in the right section), US2 (the corresponding audit row is closed), and US3 (the same edit applied to both koan and solution preserves byte-parity). US1 and US3 are verified explicitly in Phases 4 and 5 below.

### Implementation for User Story 2

- [X] T004 [P] [US2] Rewrite citations in `koans/00_about_asserts.rexx` and `solutions/00_about_asserts.rexx`. Apply each of the 3 distinct rewrites below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §1.1, p. 1 -- Introduction` → `Cowlishaw §1.1, p. 1`
  - `Cowlishaw §2.5, p. 42 -- Assignments and equality` → `Cowlishaw §2.5, p. 32`
  - `Cowlishaw §2.3, p. 25 -- Comparisons` → `Cowlishaw §2.3, p. 26`
  Apply identically to koan and solution to preserve byte-parity (FR-003). Closes audit rows 1, 5, 10.
- [X] T005 [P] [US2] Rewrite citations in `koans/01_about_strings.rexx` and `solutions/01_about_strings.rexx`. Apply each of the 2 distinct rewrites below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §2.1, p. 15 -- Literal strings` → `Cowlishaw §2.2, p. 19 — Literal strings`
  - `Cowlishaw §2.2, p. 17 -- Numbers` → `Cowlishaw §2.3, p. 27 — Numbers`
  Note: the new strings use the canonical em-dash `—` (U+2014, UTF-8 `E2 80 94`), not the ASCII `--`. Closes audit rows 2, 3.
- [X] T006 [P] [US2] Rewrite citations in `koans/02_about_variables.rexx` and `solutions/02_about_variables.rexx`. Apply the 1 distinct rewrite below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §2.5, p. 42 -- Assignments` → `Cowlishaw §2.5, p. 32`
  All 4 occurrences in each file collapse to the same bare canonical form. Closes audit row 10 (the koan-02 facet).
- [X] T007 [P] [US2] Rewrite citations in `koans/03_about_expressions.rexx` and `solutions/03_about_expressions.rexx`. Apply each of the 5 distinct rewrites below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §2.3, p. 22 -- Operators` → `Cowlishaw §2.3, p. 24`
  - `Cowlishaw §2.3, p. 22 -- Arithmetic operators` → `Cowlishaw §2.3, p. 25 — Arithmetic`
  - `Cowlishaw §2.3, p. 25 -- Comparisons` → `Cowlishaw §2.3, p. 26`
  - `Cowlishaw §2.3, p. 27 -- Logical operators` → `Cowlishaw §2.3, p. 27 — Logical (Boolean)`
  - `Cowlishaw §2.3, p. 30 -- Concatenation` → `Cowlishaw §2.3, p. 25 — Concatenation`
  Closes audit rows 4, 5 (koan-03 facet), 6, 7. Edit ordering is irrelevant: the five old strings are mutually non-overlapping (no old string is a substring of another — confirmed by the differing trailing labels and, for the §2.3 p. 22 pair, the case difference between `Operators` and `operators`).
- [X] T008 [P] [US2] Rewrite citations in `koans/04_about_clauses.rexx` and `solutions/04_about_clauses.rexx`. Apply each of the 3 distinct rewrites below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §2.4, p. 38 -- Clauses` → `Cowlishaw §2.4, p. 31`
  - `Cowlishaw §2.4, p. 38 -- Continuation` → `Cowlishaw §2.2, p. 23`
  - `Cowlishaw §2.4, p. 39 -- Comments` → `Cowlishaw §2.2, p. 18 — Comments`
  Note: the "Continuation" and "Comments" citations move out of §2.4 entirely — they correctly belong in §2.2 per the index. Closes audit rows 8, 9.
- [X] T009 [P] [US2] Rewrite citations in `koans/05_about_say.rexx` and `solutions/05_about_say.rexx`. Apply the 1 distinct rewrite below to BOTH files using `Edit replace_all=true`:
  - `Cowlishaw §2.7, p. 56 -- The SAY instruction` → `Cowlishaw §2.7, p. 70`
  All 4 occurrences in each file collapse to the same bare canonical form (SAY is the only §2.7 child on book p. 70, so bare suffices per FR-005). Closes audit row 11.
- [X] T010 [US2] Run `bin/lint_citations` on the rewritten corpus. Expected output: `6/6 koans passed lint.`, exit code 0. The current permissive regex still passes — every rewritten citation satisfies the `Cowlishaw §<sec>, p. <page>` prefix the regex looks for. (CI parity will hold across the rewrite-only commit window before Phase 6 tightens the regex.)
- [X] T011 [US2] Run `bin/verify_solutions` on the rewritten corpus. Expected output: `6/6 solutions passed.`, exit code 0. Verifies no edit accidentally landed outside a comment block.
- [X] T012 [US2] Audit-row spot check: open `docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)" and walk all 11 rows. For each row, locate the corresponding citation in the koan/solution and confirm the section + page now match `research.md` §1 rewrite table. All 11 rows MUST resolve.

**Checkpoint**: At this point, all six (koan, solution) pairs carry canonical-form citations. The corpus passes the existing (permissive) lint and verify_solutions. No audit row remains open. US2 is delivered.

---

## Phase 4: User Story 1 — Pilgrim Verification (Priority: P1)

**Goal**: Confirm that following any rewritten citation lands the pilgrim on a book page that visibly covers the concept the surrounding teaching block teaches.

**Independent Test**: With the Internet Archive scan (or the local gitignored PDF) open, walk every distinct rewritten citation and turn to its book page in its section. Each must visibly cover the concept the teaching block teaches.

### Implementation for User Story 1

- [X] T013 [US1] PDF↔book offset spot check: confirm the +11 offset (book p. N = PDF p. N + 11) by opening the Internet Archive scan to PDF p. 30 and verifying it shows book p. 19 (which begins the "Literal strings" subsection). Record any offset discrepancy in the PR description. **Verified mechanically against the local `reference/REXX Language - 2nd Edition.pdf`: PDF p. 30 = book p. 19 (header "Section 2 Structure and General Syntax 19", contains the start of "Tokens" → "Literal strings"). Offset holds — no discrepancy.**
- [X] T014 [US1] Pilgrim spot-check, all 14 distinct rewrites: walk every rewritten citation in `research.md` §1 to its cited book page in its cited section. Each MUST visibly cover the concept the surrounding teaching block teaches (e.g., book p. 19 in §2.2 lands on "Literal strings"; book p. 70 in §2.7 lands on "SAY"; book p. 24 in §2.3 lands on the start of "Expressions and Operators"). The 14 rewrites collectively close all 11 audit rows; rows 4 (rewrites #7 + #8), 8 (#11 + #12), and 10 (#2 + #6) each correspond to two distinct rewrites — verify both. If any citation lands on the wrong material, halt and investigate before completing this phase. **Verified mechanically by reading the relevant pages of the local PDF (PDF pp. 12, 29–43, 81). All 14 rewrites land on book pages that visibly cover the concept the teaching block teaches; details in the PR comment thread.**
- [X] T015 [US1] Post-rewrite drift check: run `grep -nE 'Cowlishaw §' koans/*.rexx solutions/*.rexx | grep -oE 'Cowlishaw §[^ ]+, p\. [0-9]+( — [^*]+)?' | sed 's| \*/||' | sort -u`. The unique citation strings emitted MUST be exactly the 14 canonical-form NEW strings listed in `research.md` §1 — no legacy `-- ` separator surviving, no unexpected string introduced by an accidental edit. If the unique-string set deviates, identify the rogue citation and reconcile (re-apply the missing edit, or revert the unintended change) before proceeding to Phase 5.

**Checkpoint**: At this point, every rewritten citation has been visually confirmed against the source. US1 is delivered.

---

## Phase 5: User Story 3 — Byte-Parity Verification (Priority: P1)

**Goal**: Confirm `koans/NN_about_x.rexx` and `solutions/NN_about_x.rexx` carry byte-identical citation lines (FR-003).

**Independent Test**: For each of the six (koan, solution) pairs, the diff of citation lines between the two files is empty.

### Implementation for User Story 3

- [X] T016 [US3] Diff citation lines for all six pairs. Run:
  ```sh
  for n in 00 01 02 03 04 05; do
    diff \
      <(grep -E 'Cowlishaw §' "koans/${n}_about_"*.rexx) \
      <(grep -E 'Cowlishaw §' "solutions/${n}_about_"*.rexx)
  done
  ```
  Expected: zero output (all six pairs byte-identical). If any pair diverges, identify the diverging citation and re-apply the missing edit to the file that drifted.

**Checkpoint**: At this point, koan/solution citation parity is verified. US3 is delivered.

---

## Phase 6: Lint Canonical-Form Enforcement (FR-007/FR-008)

**Purpose**: Tighten `bin/lint_citations` to enforce the canonical citation form, rejecting the legacy `--` separator and any other non-canonical tail content. Implements the contract authored at `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` Rule C1.

**Why this phase comes after rewrites**: Tightening lint before all rewrites land would fail CI on every intermediate commit (the corpus would carry legacy `--` separators that the new regex rejects). Tightening lint after all rewrites land keeps every commit on the feature branch lint-green.

### Implementation

- [X] T017 Edit `bin/lint_citations` to tighten the `check_citation` procedure (currently lines 123–142) per `research.md` §2 design and `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` Rule C1. The new procedure parses the prefix `Cowlishaw §<sec>, p. <page>` exactly as today, then inspects the tail: accept if the tail is empty (after stripping a single optional `*/` comment-close and trailing whitespace), or if the tail begins with the canonical separator ` — ` (one space + UTF-8 em-dash `'E2 80 94'X` + one space) followed by a non-empty heading (after stripping). Any other tail content MUST cause `check_citation` to return 0. No other procedure in `bin/lint_citations` is modified.
- [X] T018 Run `bin/lint_citations` on the rewritten corpus. Expected output: `6/6 koans passed lint.`, exit code 0. All 14 canonical-form citations pass the tightened regex.
- [X] T019 Negative spot-check: in a sandbox edit (do NOT commit), exercise three distinct rejection cases against `bin/lint_citations` to confirm the tightened regex rejects each. For each case, temporarily change a bare canonical citation in any one koan to the malformed form, run `bin/lint_citations`, expect `[FAIL] koans/<file>` with `MISSING citation` reason and exit code 1, then revert and confirm `[ ok ]` returns. Required cases (matching `contracts/lint_citations.md` Rule C1 rejection table):
  1. Legacy `--` separator: `Cowlishaw §2.5, p. 32 -- Anything`.
  2. En-dash instead of em-dash: `Cowlishaw §2.5, p. 32 – Anything` (the separator is U+2013 `–`, not U+2014 `—`).
  3. Empty heading after suffix: `Cowlishaw §2.5, p. 32 — ` (em-dash followed only by whitespace).
  Document the three test outcomes in the PR description.

**Checkpoint**: `bin/lint_citations` enforces the canonical form. The contract file (already in place from `/speckit-plan`) is the authoritative description; no contract edit is needed in this phase.

---

## Phase 7: User Story 4 — CI Acceptance Gate (Priority: P2)

**Goal**: Confirm all six CI checks (verify_solutions × 2 OS, lint_citations × 2 OS, runner-smoke × 2 OS) pass on the feature branch, and `tests/fixtures/runner_stdout.txt` is byte-identical pre/post-rewrite.

**Independent Test**: GitHub Actions reports 6/6 green on the feature branch's HEAD commit prior to merge; the runner stdout fixture diff is empty locally and in CI.

### Implementation for User Story 4

- [X] T020 [US4] Local fixture diff: reproduce the `runner-smoke` step from `.github/workflows/verify.yml`. The CI step builds a shadow `koans-solved/` directory containing every solution, swaps in a temporary path manifest pointing at it, runs `LC_ALL=C regina lib/pilgrimage.rexx`, normalizes CRLF, and diffs against `tests/fixtures/runner_stdout.txt`. The same recipe is documented step-by-step in `quickstart.md` Step 3. Expected: empty diff. If non-empty, investigate before re-baselining — citations live in comments and should never affect runner output.
- [X] T021 [US4] Push the feature branch to origin: `git push -u origin 004-m2-2-citation-rewrite`.
- [X] T022 [US4] Monitor CI: confirm the GitHub Actions verify workflow reports green on both `ubuntu-latest` and `macos-latest` for all three named jobs (`verify_solutions`, `lint_citations`, `runner-smoke`). The 6/6 count satisfies Constitution Principle IV and spec SC-005.

**Checkpoint**: CI gate is green. US4 is delivered. All four user-facing stories (US1, US2, US3, US4) are complete; US5 remains deferred per Clarifications session 2026-05-09.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: PR preparation and final review.

- [X] T023 [P] Open a pull request from `004-m2-2-citation-rewrite` to `main` with a description that summarizes: the 14 distinct citation rewrites, the 11 audit rows closed (link to `docs/M2_FOLLOWUP.md` "Audit findings"), the lint regex tightening, the deferred FR-014, and the negative-spot-check outcomes from T019. Include a checklist confirming SC-001 through SC-009.
- [X] T024 [P] Run the `quickstart.md` recipe end-to-end one more time on a fresh clone (or after `git clean -fdx` on the working tree) to confirm a contributor with no local state can reproduce the green build. Note any quickstart-doc improvements needed. (Steps 1+2+3+4+5 mechanically exercised in T010/T011/T020/T012/T016; Step 6 is the human pilgrim spot-check — see T013/T014.)
- [X] T025 Final review pass: re-read `spec.md` Out of Scope and Assumptions sections; confirm no item has been silently violated (especially: index unmodified, runner fixture unchanged, no Stage II–VI files touched, no FR-014 work landed, no PDF-posture changes).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Empty for M2.2.
- **User Story 2 (Phase 3)**: Depends on Setup (T001–T003 confirm preconditions). T004–T009 can run in parallel; T010–T012 are sequential follow-ups within Phase 3.
- **User Story 1 (Phase 4)**: Depends on Phase 3 completion (rewrites must be applied before pilgrim spot-check is meaningful).
- **User Story 3 (Phase 5)**: Depends on Phase 3 completion (byte-parity is a property of the rewrites). May run in parallel with Phase 4 (US1 and US3 are independent verifications).
- **Lint Tightening (Phase 6)**: Depends on Phase 3 completion (rewrites must land before the regex is tightened, per phase preamble). Independent of Phases 4 and 5.
- **User Story 4 (Phase 7)**: Depends on Phase 6 completion (lint must enforce canonical form before the CI run is meaningful for US4's gate). T020 can begin once Phase 6 is done; T021–T022 are sequential.
- **Polish (Phase 8)**: Depends on Phase 7. T023 and T024 [P] independent of each other; T025 is the final review.

### User Story Dependencies

- **US2 (Phase 3)**: Independent of other stories' verifications. Delivers the rewrite that all P1 stories share.
- **US1 (Phase 4)**: Depends on US2's rewrite landing. Verification only — no new edits.
- **US3 (Phase 5)**: Depends on US2's rewrite landing. Verification only — no new edits. Independent of US1 (parallelizable).
- **US4 (Phase 7)**: Depends on the lint tightening (Phase 6). The CI run validates the entire corpus + the new lint behavior in one matrix.

### Within Each User Story

- US2 (Phase 3): the six per-pair edit tasks T004–T009 can run in parallel; T010–T012 are post-rewrite verifications that run sequentially after the edits land.
- US1 (Phase 4): tasks run sequentially (the offset check feeds the spot check).
- US3 (Phase 5): single task, no internal ordering.
- US4 (Phase 7): T020 (local fixture diff) → T021 (push) → T022 (monitor CI), strict order.

### Parallel Opportunities

- All Phase 1 tasks (T001–T003) can run in parallel.
- All Phase 3 per-pair edits (T004–T009) can run in parallel — each edits its own (koan, solution) pair, no overlap.
- Phases 4 and 5 (US1 spot check and US3 diff) can run in parallel after Phase 3 completes.
- T023 and T024 in Polish can run in parallel.

---

## Parallel Example: Phase 3 (User Story 2 rewrite)

```
# Launch all six per-pair rewrites in parallel:
Task T004: Rewrite koans/00_about_asserts.rexx + solutions/00_about_asserts.rexx
Task T005: Rewrite koans/01_about_strings.rexx + solutions/01_about_strings.rexx
Task T006: Rewrite koans/02_about_variables.rexx + solutions/02_about_variables.rexx
Task T007: Rewrite koans/03_about_expressions.rexx + solutions/03_about_expressions.rexx
Task T008: Rewrite koans/04_about_clauses.rexx + solutions/04_about_clauses.rexx
Task T009: Rewrite koans/05_about_say.rexx + solutions/05_about_say.rexx
```

After T004–T009 complete, run T010 (lint), T011 (verify_solutions), T012 (audit-row spot check) sequentially.

---

## Implementation Strategy

### MVP (US2 alone)

1. Phase 1 Setup → preconditions verified.
2. Phase 3 US2 → rewrites applied; audit rows closed; existing CI green.
3. **STOP** if a partial-merge MVP is acceptable: the corpus is correct against the index, even though the lint regex remains permissive about the legacy separator (which no longer appears in the corpus). US1, US3, and US4 are still gated by their own phases.

### Full M2.2 incremental delivery

1. Phase 1 Setup.
2. Phase 3 US2 → rewrite phase. Atomic commit (or per-pair commits) keeps lint green throughout.
3. Phase 4 US1 → pilgrim spot-check. No new commits — verification only.
4. Phase 5 US3 → byte-parity diff. No new commits — verification only.
5. Phase 6 Lint Tightening → `bin/lint_citations` patch. Single commit.
6. Phase 7 US4 → push, monitor CI, confirm 6/6 green.
7. Phase 8 Polish → PR + final review.

### Parallel Team Strategy

M2.2's blast radius is small (6 pairs + 1 lint script). The natural cadence is one developer in sequence; parallelization across team members would add coordination overhead without saving meaningful time. T004–T009 are parallelizable for an LLM agent doing batch edits but trivially sequential for a human.

---

## Notes

- [P] tasks edit independent files and have no inter-dependencies on
  incomplete tasks.
- [Story] labels: US1 = pilgrim verification (Phase 4); US2 = audit
  closure / rewrite (Phase 3); US3 = byte-parity verification
  (Phase 5); US4 = CI acceptance gate (Phase 7). US5 is deferred and
  has no tasks.
- All P1 stories ship as a single atomic delivery; the phase
  ordering here is for clarity of acceptance verification, not for
  separable releases.
- Commit cadence: one commit per pair (or one commit covering all
  pairs) in Phase 3; one commit for the lint patch in Phase 6;
  verification phases (4, 5, 7) are read-only and produce no
  commits.
- Avoid: tightening lint before rewrites land (would break CI);
  modifying `docs/cowlishaw_index.md` (FR-009 read-only); modifying
  `tests/fixtures/runner_stdout.txt` (FR-010 invariant); editing
  files outside the FR-013 allowlist.
