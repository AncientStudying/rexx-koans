# Feature Specification: M1 — Smoke Test and Design Validation

**Feature Branch**: `001-m1-smoke-test`
**Created**: 2026-05-07
**Status**: Draft
**Input**: User description: "M1 — Smoke Test and Design Validation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - End-to-End Smoke Run (Priority: P1)

A contributor working on the project runs the smoke-test koan through the
runner for the first time. The runner stops at the FILL_ME_IN placeholder
with a clear diagnostic message. The contributor fills it in and re-runs;
the runner advances past all assertions and exits cleanly with a success
message.

**Why this priority**: This is the central proof-of-concept for M1. If the
runner cannot execute a koan, detect a blank, and advance on a correct fill,
the entire curriculum architecture is unvalidated and M2 cannot begin.

**Independent Test**: Can be fully tested by running `bin/pilgrimage` on a
fresh clone with the smoke koan in place — no other koans, no other
infrastructure required.

**Acceptance Scenarios**:

1. **Given** the smoke koan contains a FILL_ME_IN symbol, **When** the
   contributor runs the pilgrimage runner, **Then** the runner exits non-zero,
   prints the koan filename and line number of the failure, and displays a
   message explaining that FILL_ME_IN awaits their contribution.

2. **Given** the smoke koan has all FILL_ME_IN symbols replaced with correct
   values, **When** the contributor runs the pilgrimage runner, **Then** the
   runner exits zero and prints a success message indicating the koan passed.

3. **Given** the smoke koan solution file, **When** `bin/verify_solutions` is
   run, **Then** the script exits zero, confirming the solution passes all
   assertions.

4. **Given** the smoke koan file, **When** `bin/lint_citations` is run,
   **Then** the script exits zero, confirming the koan contains a
   well-formed `Cowlishaw §N.N, p. NN` citation.

---

### User Story 2 - Design Decisions Recorded (Priority: P2)

A contributor picks up M2 work after M1 completes. They read
`docs/DESIGN_DECISIONS.md` and find concrete, evidence-backed answers to
all six open architecture questions from the project plan — enough to begin
M2 without re-investigating those questions.

**Why this priority**: M1's primary deliverable is knowledge, not code. If
the design decisions are not recorded, subsequent milestones build on
unverified assumptions and risk costly rework.

**Independent Test**: Can be verified by reading `docs/DESIGN_DECISIONS.md`
and confirming each of the six questions from the project plan has a written
answer with brief rationale derived from working prototype evidence.

**Acceptance Scenarios**:

1. **Given** the completed M1 prototype, **When** a contributor reads
   `docs/DESIGN_DECISIONS.md`, **Then** they find a documented answer (with
   rationale) for each of the following questions:
   - How koans are loaded by the runner (INTERPRET vs. CALL vs. subprocess)
   - Whether PROCEDURE EXPOSE can maintain shared assertion state without
     leaking runner internals into the koan namespace
   - Whether SIGNAL ON SYNTAX traps cleanly and allows the runner to report
     and continue (or exit gracefully) on a koan syntax error
   - Whether FILL_ME_IN detection reliably distinguishes "not filled in" from
     "filled in with the wrong value" in all assertion contexts
   - Whether the Ubuntu apt Regina and macOS Homebrew Regina behave
     equivalently for the operations the project depends on
   - Whether REXX can scan files and match the citation pattern comfortably,
     or whether a non-REXX lint_citations implementation is warranted

2. **Given** a design question whose answer is "it depends" or uncertain,
   **When** the contributor reads the document, **Then** the uncertainty is
   documented alongside the decision made under that uncertainty and its
   rationale.

---

### User Story 3 - CI Green on Both Platforms (Priority: P3)

A contributor pushes M1 work to the remote repository. GitHub Actions runs
the CI workflow and both jobs (ubuntu-latest and macos-latest) pass for
both `verify_solutions` and `lint_citations`.

**Why this priority**: CI is the acceptance gate per the project constitution.
Cross-platform parity between macOS and Ubuntu is a first-class requirement,
and M1 is the first opportunity to confirm it holds for the core tools.

**Independent Test**: Can be verified by inspecting the GitHub Actions run
triggered by the M1 branch push.

**Acceptance Scenarios**:

1. **Given** the M1 implementation is pushed to the remote, **When** the
   GitHub Actions workflow runs, **Then** both the ubuntu-latest and
   macos-latest jobs complete with a green status for `verify_solutions`.

2. **Given** the M1 implementation is pushed to the remote, **When** the
   GitHub Actions workflow runs, **Then** both the ubuntu-latest and
   macos-latest jobs complete with a green status for `lint_citations`.

3. **Given** any behavioral divergence between Ubuntu and macOS Regina is
   discovered during M1, **When** CI runs, **Then** the divergence is
   documented in `docs/DESIGN_DECISIONS.md` and the workflow accommodates
   or documents the difference.

---

### Edge Cases

- What if Regina on Linux behaves differently from macOS for a tested
  behavior? The divergence must be documented in `docs/DESIGN_DECISIONS.md`
  with a decision on which behavior the project standardizes on.
- What if SIGNAL ON SYNTAX does not trap cleanly in Regina? The prototype
  must document this finding and propose an alternative error-recovery
  strategy for M2 to adopt.
- What if a design question cannot be answered definitively with the prototype
  alone? The uncertainty and the decision made under that uncertainty must
  both appear in `docs/DESIGN_DECISIONS.md`.
- What if `lint_citations` is significantly awkward to write in REXX? This
  triggers the language-choice decision for that script; the answer must be
  recorded as a design decision with rationale before switching to a non-REXX
  implementation.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a minimal runner (`lib/pilgrimage.rexx`)
  that loads and executes at least one koan file.
- **FR-002**: The runner MUST stop at the first failing assertion and display
  the koan filename, line number, and a failure message.
- **FR-003**: The assertion library (`lib/meditation.rexx`) MUST detect
  FILL_ME_IN symbols and produce a distinct message distinguishing "not filled
  in" from "filled in with the wrong value".
- **FR-004**: The system MUST provide a `bin/lint_citations` script that scans
  `koans/*.rexx` files and validates that each contains a `Cowlishaw §N.N, p. NN`
  citation.
- **FR-005**: The system MUST provide a `bin/verify_solutions` script that runs
  each file in `solutions/` through the assertion machinery and requires all
  assertions to pass.
- **FR-006**: The smoke-test koan (`koans/00_about_smoke.rexx`) MUST exercise
  at least one passing assertion, one failing assertion, and one FILL_ME_IN
  blank.
- **FR-007**: The smoke-test koan MUST have a well-formed `Cowlishaw §N.N, p. NN`
  citation that passes `bin/lint_citations`.
- **FR-008**: A matching solution (`solutions/00_about_smoke.rexx`) MUST exist
  and run clean under `bin/verify_solutions`.
- **FR-009**: The CI workflow (`.github/workflows/verify.yml`) MUST run
  `verify_solutions` and `lint_citations` on both `ubuntu-latest` and
  `macos-latest` on every push and pull request to `main`.
- **FR-010**: `docs/DESIGN_DECISIONS.md` MUST contain a written, evidence-backed
  answer for each of the six design questions defined in the project plan for M1.

### Key Entities

- **Runner** (`lib/pilgrimage.rexx`): Executes koans in order, stops at first
  failure, reports filename and line number.
- **Assertion Library** (`lib/meditation.rexx`): Provides at minimum
  `assert_equal`; detects and distinguishes FILL_ME_IN from incorrect values.
- **Smoke Koan** (`koans/00_about_smoke.rexx`): Single throwaway koan containing
  passing, failing, and FILL_ME_IN assertions, with a valid Cowlishaw citation.
- **Smoke Solution** (`solutions/00_about_smoke.rexx`): The koan with all
  FILL_ME_IN values resolved; passes verify_solutions with zero failures.
- **Design Decisions** (`docs/DESIGN_DECISIONS.md`): ADR-style document
  recording answers to all six M1 architecture questions with rationale derived
  from the prototype.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A contributor can run the pilgrimage runner on a fresh macOS clone,
  encounter a FILL_ME_IN failure, fill it in, and see a passing run — all within
  five minutes, with no steps beyond those documented in `README.md`.
- **SC-002**: All six design questions from the project plan have written,
  evidence-backed answers in `docs/DESIGN_DECISIONS.md` before M1 is closed.
- **SC-003**: The CI workflow passes on both ubuntu-latest and macos-latest for
  both `verify_solutions` and `lint_citations` with zero failures.
- **SC-004**: The runner exits non-zero on a koan with FILL_ME_IN and exits zero
  on the fully resolved solution — confirmed on both macOS and Ubuntu.

## Assumptions

- M1 deliverables are explicitly throwaway: the prototype's source files may be
  partially salvaged into M2 or fully discarded; either outcome is acceptable.
- Regina REXX is available via Homebrew on macOS and via
  `sudo apt-get install -y regina-rexx` on Ubuntu; no other installation
  method is in scope for M1.
- M1 does not need to implement the full station display (`lib/stations.rexx`),
  the scripture mechanic (`lib/scripture.rexx`), or any koan beyond the single
  smoke-test koan.
- The six design questions listed in the project plan are the complete and
  definitive scope for `docs/DESIGN_DECISIONS.md`; no additional questions
  are required by M1.
- The smoke koan (`00_about_smoke.rexx`) is not part of the final curriculum
  and does not need a teaching comment written to the same standard as
  production koans.
- `bin/pilgrimage` (the shell launcher) is not required for M1; the runner may
  be invoked directly as `regina lib/pilgrimage.rexx` for smoke-test purposes.
