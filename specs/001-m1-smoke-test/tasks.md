# Tasks: M1 — Smoke Test and Design Validation

**Input**: Design documents from `specs/001-m1-smoke-test/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no blocking dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths in every description

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the directory structure required by all subsequent phases.

- [X] T001 Create directory structure: `lib/`, `koans/`, `solutions/`, `bin/`, `docs/`, `.github/workflows/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core assertion library that MUST exist before any koan, solution, or verification script can be implemented.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 Write `lib/meditation.rexx` — define `assert_equal` subroutine with FILL_ME_IN detection: emit `"This koan awaits your contribution. Replace the FILL_ME_IN symbol with the value the pilgrim must learn."` when either argument equals `"FILL_ME_IN"`, else emit `"The [Nth] assertion of [koan_file] has damaged your karma. The pilgrim expected '[expected]' but received '[actual]'."` on mismatch; exit 0 on pass, non-zero on any failure

**Checkpoint**: Assertion library ready — user story implementation can begin.

---

## Phase 3: User Story 1 — End-to-End Smoke Run (Priority: P1) 🎯 MVP

**Goal**: A contributor can run the smoke koan, encounter a FILL_ME_IN failure, fill it in, and see a passing run — all four acceptance scenarios from `spec.md §US1` verified locally.

**Independent Test**: `regina lib/pilgrimage.rexx` (FILL_ME_IN → fix → pass), `bin/verify_solutions`, `bin/lint_citations` — no external infrastructure required.

### Implementation (Solution-First per Constitution I)

- [X] T003 [US1] Write `solutions/00_about_smoke.rexx` — all assertions pass, no FILL_ME_IN symbols, includes one valid `Cowlishaw §N.N, p. NN` citation in a comment; this is the authoritative answer file from which the koan is derived
- [X] T004 [US1] Derive `koans/00_about_smoke.rexx` from `solutions/00_about_smoke.rexx` — add a teaching comment block above an assertion, replace one correct value with the uninitialized symbol `FILL_ME_IN`, add one assertion that deliberately fails with an incorrect value; retain the valid Cowlishaw citation from the solution
- [X] T005 [US1] Write `lib/pilgrimage.rexx` — subprocess runner: build koan list (M1: `koans/00_about_smoke.rexx` only), execute each koan via `ADDRESS SYSTEM/COMMAND "regina <koan>"`, capture exit code and stdout, stop at first non-zero exit and print `contracts/runner.md` output format (banner, `[ here ]`/`[  ok  ]` status, failure message, step count); exit 0 on full pass
- [X] T006 [P] [US1] Write `bin/verify_solutions` — REXX script per `contracts/verify_solutions.md`: scan `solutions/*.rexx`, run each via `ADDRESS SYSTEM/COMMAND "regina <solution>"`, print `[verify] <file> ... PASS/FAIL` per file, exit non-zero if any fail or if `solutions/` is empty; make executable
- [X] T007 [P] [US1] Write `bin/lint_citations` — REXX script per `contracts/lint_citations.md`: scan `koans/*.rexx` line by line using `LINEIN`, check each line for `Cowlishaw §` followed by a section number, `, p. `, and one or more digits using REXX string functions (`POS`, `DATATYPE`, `SUBSTR`), print `[lint] <file> ... OK/MISSING` per file, exit non-zero if any koan is missing a citation or if `koans/` is empty; make executable

**Checkpoint**: User Story 1 fully functional — verify all four acceptance scenarios from `spec.md §US1` before proceeding.

---

## Phase 4: User Story 2 — Design Decisions Recorded (Priority: P2)

**Goal**: `docs/DESIGN_DECISIONS.md` contains evidence-backed answers to all six M1 architecture questions, sufficient for M2 to begin without re-investigation.

**Independent Test**: Read `docs/DESIGN_DECISIONS.md` and confirm all six questions from `research.md` have a written answer with rationale and concrete prototype evidence.

### Implementation

- [X] T008 [US2] Write `docs/DESIGN_DECISIONS.md` — six ADR-style records covering every question from `specs/001-m1-smoke-test/research.md`: koan-loading strategy, shared assertion state, SIGNAL ON SYNTAX behavior, FILL_ME_IN detection, cross-platform Regina parity, lint_citations in REXX; each record must include question, decision, rationale, evidence (cite specific prototype run results observed in Phase 3), and alternatives considered; populate evidence fields after the Phase 3 prototype is running

**Checkpoint**: M2 can begin without re-investigating any of the six architecture questions.

---

## Phase 5: User Story 3 — CI Green on Both Platforms (Priority: P3)

**Goal**: GitHub Actions runs `verify_solutions` and `lint_citations` on both `ubuntu-latest` and `macos-latest` on every push/PR, and both jobs pass green.

**Independent Test**: Push the branch to the remote and inspect the GitHub Actions run — both matrix jobs complete with green status for both scripts.

### Implementation

- [X] T009 [US3] Write `.github/workflows/verify.yml` — GitHub Actions workflow: trigger on `push` and `pull_request` targeting `main`; matrix strategy `os: [ubuntu-latest, macos-latest]`; steps: checkout, install Regina (`sudo apt-get install -y regina-rexx` on ubuntu / `brew install regina-rexx` on macos, detected via `matrix.os`), run `regina bin/verify_solutions`, run `regina bin/lint_citations`; fail the job on any non-zero exit

**Checkpoint**: Both CI jobs pass green — M1 acceptance criterion SC-003 satisfied.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final documentation and end-to-end validation before closing M1.

- [X] T010 [P] Update `README.md` — add local prerequisites (`brew install regina-rexx` on macOS / `sudo apt-get install -y regina-rexx` on Ubuntu), five-step smoke walkthrough matching `specs/001-m1-smoke-test/quickstart.md`, and CI badge
- [X] T011 Validate `specs/001-m1-smoke-test/quickstart.md` walkthrough end-to-end on macOS — fresh repo state: run `regina lib/pilgrimage.rexx` (confirm FILL_ME_IN failure and exit code 1), fill in koan, re-run (confirm pass and exit code 0), run `bin/verify_solutions` (confirm `[verify] All solutions pass.`), run `bin/lint_citations` (confirm `[lint] All citations valid.`); SC-001 satisfied

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (directories must exist)
- **User Story 1 (Phase 3)**: Depends on Phase 2 (meditation.rexx must exist)
- **User Story 2 (Phase 4)**: Depends on Phase 3 completion (prototype evidence required for `DESIGN_DECISIONS.md`)
- **User Story 3 (Phase 5)**: Depends on Phase 3 completion (scripts must exist before CI can run them); can run in parallel with Phase 4
- **Polish (Phase 6)**: Depends on Phases 4 and 5 complete

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational — no dependency on US2 or US3
- **US2 (P2)**: Depends on US1 prototype run evidence — fill evidence fields after Phase 3
- **US3 (P3)**: Can start in parallel with US2 after Phase 3 (different file)

### Within US1 (Critical Path)

```
T001 (dirs) → T002 (meditation.rexx) → T003 (solution) → T004 (koan) → T005 (runner)
                                      ↘
                                       T006 (verify_solutions)  ← parallel with T007
                                       T007 (lint_citations)    ← parallel with T006
```

Note: T006 and T007 can be *written* before T003–T005 finish (different files), but cannot be *fully tested* until solution and koan files exist.

---

## Parallel Opportunities

### Phase 3 (US1)

```
# T006 and T007 can be written simultaneously after Phase 2:
Task: "Write bin/verify_solutions (T006)"   — bin/verify_solutions
Task: "Write bin/lint_citations (T007)"     — bin/lint_citations
```

### Phase 4 + Phase 5

```
# After Phase 3 completes, T008 and T009 can proceed in parallel:
Task: "Write docs/DESIGN_DECISIONS.md (T008)"         — docs/DESIGN_DECISIONS.md
Task: "Write .github/workflows/verify.yml (T009)"     — .github/workflows/verify.yml
```

### Phase 6

```
# T010 and T011 can proceed in parallel:
Task: "Update README.md (T010)"
Task: "Validate quickstart.md walkthrough (T011)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002)
3. Complete Phase 3: User Story 1 (T003–T007)
4. **STOP and VALIDATE**: Run all four acceptance scenarios from `spec.md §US1`
5. Proceed to US2 + US3 in parallel, then Polish

### Incremental Delivery

1. T001 + T002 → Directory structure and assertion library ready
2. T003 → Solution verified (Constitution I gate passed)
3. T004 → Koan derived from solution (smoke test in place)
4. T005 → Runner exercising koan (core E2E path working)
5. T006 + T007 → Full verification suite operational **(MVP!)**
6. T008 + T009 → Design decisions documented and CI wired (parallel)
7. T010 + T011 → Final polish and walkthrough validation

---

## Notes

- **Constitution I (Solution-First)**: T003 (`solutions/00_about_smoke.rexx`) MUST be written and passing before T004 (`koans/00_about_smoke.rexx`) is derived from it.
- **Constitution II (No Third-Party REXX)**: T006 and T007 MUST use only Regina built-ins — no external REXX libraries.
- **Evidence timing**: T008 evidence fields are populated AFTER the Phase 3 prototype runs — write the structure first, fill evidence from actual run results.
- [P] = task touches different files than others in its phase, no blocking dependencies
- [US1/US2/US3] = traceability to user story in `spec.md`
