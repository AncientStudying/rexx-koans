# Implementation Plan: M2 — Walking Skeleton

**Branch**: `002-m2-walking-skeleton` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/002-m2-walking-skeleton/spec.md`

## Summary

Build the production walking skeleton of the REXX Koans pilgrimage:
the Stage I curriculum (six koans, `00_about_asserts` → `05_about_say`)
running through a production runner, an expanded assertion library, a
station-display module, a path manifest, and a POSIX shell launcher.
The end-to-end pilgrim experience must work on macOS and be locked in
CI on both `ubuntu-latest` and `macos-latest`, including a runner-smoke
step that asserts a byte-identical stdout fingerprint against a
committed reference fixture (FR-017, SC-006). Built directly on M1's
design decisions (subprocess loading, FILL_ME_IN detection, REXX-only
tooling); no architecture is re-derived.

## Technical Context

**Language/Version**: REXX (Regina 3.9.x — Homebrew on macOS; apt on Ubuntu)
**Primary Dependencies**: Regina REXX interpreter only; no third-party libraries
**Storage**: Files only — `koans/`, `solutions/`, `lib/`, `bin/`, `tests/fixtures/`
**Testing**: `bin/verify_solutions` (REXX), `bin/lint_citations` (REXX), runner smoke step (Bash + Regina) with a committed stdout fixture
**Target Platform**: macOS (primary development) + ubuntu-latest (CI)
**Project Type**: Educational CLI scripting curriculum
**Performance Goals**: Fully solved Stage I walks in under 1 second on a development laptop (SC-002)
**Constraints**: No third-party REXX libraries (Constitution II); citation lint and solution verification must be REXX (ADR-006); cross-platform stdout byte-equivalence (SC-006, FR-017)
**Scale/Scope**: 6 Stage I koans + 6 matching solutions; 1 runner; 1 assertion library (4 assertion kinds); 1 station-display module; 1 path manifest; 1 launcher; 1 CI fixture

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|---|---|---|
| I. Solution-First Development | All 6 solution files written and verified by `verify_solutions` BEFORE the corresponding koan derives FILL_ME_IN blanks. | ✅ Enforced by tasks ordering (Phase 2). |
| II. No Third-Party REXX Libraries | Only Regina built-ins in `lib/`, `koans/`, `solutions/`. `verify_solutions` and `lint_citations` remain REXX (per ADR-006). | ✅ Documented exception: `bin/pilgrimage` is POSIX shell per `PLAN.md` §3 — bootstrap/launcher is the technical impossibility for REXX (it must locate and invoke `regina` itself). Documented in research.md. |
| III. Every Koan Is Self-Teaching | Each Stage I koan has teaching comment block before the first assertion of each concept group, with concept heading + 2–6 sentences of prose + `Cowlishaw §N.N, p. NN` citation. `lint_citations` enforces format. | ✅ FR-011 + spec clarification (per concept group). |
| IV. CI Is the Acceptance Gate | `.github/workflows/verify.yml` runs `verify_solutions`, `lint_citations`, AND the runner smoke step on both `ubuntu-latest` and `macos-latest`. | ✅ FR-014 + FR-017. |
| V. Voice — Diagnostic First | All assertion library messages name the expected/actual values BEFORE any pilgrim-voice flavor; closing benediction is a single short paragraph in plain style. | ✅ Existing `lib/meditation.rexx` pattern preserved and extended. |

**Pre-Phase 0 gate**: All five principles green. One documented exception under Principle II (the launcher), justified in Complexity Tracking. Proceeding to Phase 0.

**Post-Phase 1 re-check**: No design decisions changed the compliance posture. All gates remain green.

## Project Structure

### Documentation (this feature)

```text
specs/002-m2-walking-skeleton/
├── plan.md           # This file (/speckit-plan output)
├── research.md       # Phase 0 output: M2 design decisions
├── data-model.md     # Phase 1 output: entities and invariants
├── quickstart.md     # Phase 1 output: pilgrim walkthrough
├── contracts/        # Phase 1 output: per-component contracts
│   ├── runner.md
│   ├── meditation.md
│   ├── stations.md
│   ├── path_manifest.md
│   ├── pilgrimage_launcher.md
│   ├── verify_solutions.md
│   ├── lint_citations.md
│   └── ci_workflow.md
├── checklists/
│   └── requirements.md   # /speckit-specify validation checklist
└── tasks.md          # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── pilgrimage.rexx        # Production runner: reads path_to_enlightenment.rexx, walks koans by subprocess, prints station display + benediction
├── meditation.rexx        # Assertion library: assert | assert_equal | assert_not_equal | assert_datatype, with FILL_ME_IN detection
└── stations.rexx          # Station-display module: extracts subtitles from koan headers, renders the fixed-pitch list

koans/
├── path_to_enlightenment.rexx   # Master ordering manifest (data file consumed by the runner)
├── 00_about_asserts.rexx        # Meta — how the koans work; introduces the assertion vocabulary
├── 01_about_strings.rexx        # §2.1, §2.2 — everything is a string
├── 02_about_variables.rexx      # §2.5 — assignment, uninitialized symbols, case
├── 03_about_expressions.rexx    # §2.3 — arithmetic, comparison, logical, concatenation
├── 04_about_clauses.rexx        # §2.4 — clauses, comments, continuation, semicolons
└── 05_about_say.rexx            # §2.7 (SAY) — output, expression evaluation in context

solutions/
├── 00_about_asserts.rexx        # Each: same as koan with FILL_ME_IN values resolved
├── 01_about_strings.rexx
├── 02_about_variables.rexx
├── 03_about_expressions.rexx
├── 04_about_clauses.rexx
└── 05_about_say.rexx

bin/
├── pilgrimage             # POSIX shell launcher: locates and invokes `regina lib/pilgrimage.rexx`
├── verify_solutions       # (Inherited from M1) — extended to handle the new dispatcher kinds
└── lint_citations         # (Inherited from M1) — unchanged

tests/
└── fixtures/
    └── runner_stdout.txt  # Committed reference for FR-017: byte-identical fully-solved Stage I walk

.github/
└── workflows/
    └── verify.yml         # Extended: adds runner smoke step alongside verify_solutions + lint_citations

docs/
├── DESIGN_DECISIONS.md    # (Inherited from M1) — preserved as historical record
└── (no new files in M2)

# DELETED in M2 (M1 throwaway prototype, per spec Assumptions):
#   koans/00_about_smoke.rexx
#   solutions/00_about_smoke.rexx
```

**Structure Decision**: Single-project layout, mirroring `PLAN.md` §3
exactly. No `src/` layer — REXX scripts live at their functional paths
(`lib/`, `bin/`, `koans/`, `solutions/`). M1's structure is preserved
and extended, not restructured: existing `lib/pilgrimage.rexx`,
`lib/meditation.rexx`, `bin/verify_solutions`, `bin/lint_citations`,
and `.github/workflows/verify.yml` are evolved in place. New additions:
`lib/stations.rexx`, `koans/path_to_enlightenment.rexx`,
`bin/pilgrimage`, `tests/fixtures/runner_stdout.txt`. The M1 smoke koan
and its solution are deleted (spec Assumptions, `PLAN.md` §10).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| `bin/pilgrimage` written in POSIX shell, not REXX (Principle II exception) | The launcher must locate the `regina` interpreter and invoke `lib/pilgrimage.rexx` through it. A REXX launcher would already need Regina to run, defeating the purpose. `PLAN.md` §3 explicitly designates this file as "POSIX shell launcher (macOS/Linux)." | A REXX launcher is recursive: it cannot start without the very interpreter it is meant to start. A standalone binary is out of scope (no compilation toolchain in the project). Contributor instructions saying "just run `regina lib/pilgrimage.rexx` yourself" violate the README onboarding promise (FR-016). The shell launcher is the smallest possible bootstrap, with no logic beyond locating and exec'ing `regina`. |
