# Implementation Plan: M1 — Smoke Test and Design Validation

**Branch**: `001-m1-smoke-test` | **Date**: 2026-05-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-m1-smoke-test/spec.md`

## Summary

Build a minimal, deliberately throwaway end-to-end prototype that proves
the REXX Koans architecture works in real Regina REXX before it gets baked
into thirty-plus koans. The prototype delivers: a minimal assertion library,
a minimal runner, one smoke-test koan and matching solution, a `lint_citations`
script, a `verify_solutions` script, and a GitHub Actions workflow running
all of the above on ubuntu-latest and macos-latest. The primary deliverable
is `docs/DESIGN_DECISIONS.md`: a concrete, evidence-backed answer to each
of the six open architecture questions from the project plan.

## Technical Context

**Language/Version**: REXX (Regina 3.9.x — Homebrew on macOS; apt on Ubuntu)
**Primary Dependencies**: Regina REXX interpreter only; no third-party libraries
**Storage**: Files only — `koans/`, `solutions/`, `lib/`, `docs/`
**Testing**: Custom assertion library (`lib/meditation.rexx`) + `bin/verify_solutions` + `bin/lint_citations`
**Target Platform**: macOS (primary development) + ubuntu-latest (CI)
**Project Type**: Educational CLI scripting curriculum
**Performance Goals**: Runner completes a single-koan smoke run in under 5 seconds
**Constraints**: No third-party REXX libraries; `bin/lint_citations` must be written in REXX (Constitution II)
**Scale/Scope**: 1 smoke koan, 1 solution file, minimal runner + assertion library + CI workflow

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Solution-First Development | Solution file verified by `verify_solutions` BEFORE koan is derived | ✅ Work order enforced in task sequence |
| II. No Third-Party REXX Libraries | Only Regina built-ins in `lib/`, `koans/`, `solutions/`; `lint_citations` written in REXX | ✅ No external dependencies |
| III. Every Koan Is Self-Teaching | Smoke koan has teaching comment + `Cowlishaw §N.N, p. NN` citation passing `lint_citations` | ✅ Required by FR-007 |
| IV. CI Is the Acceptance Gate | GitHub Actions runs `verify_solutions` + `lint_citations` on both platforms on every push | ✅ Required by FR-009 |
| V. Voice | FILL_ME_IN produces a distinct diagnostic message; failure states what was expected before any flavor text | ✅ Required by FR-003 |

**Post-Phase 1 re-check**: No design decisions changed the compliance posture. All gates remain green.

## Project Structure

### Documentation (this feature)

```text
specs/001-m1-smoke-test/
├── plan.md           # This file
├── research.md       # Phase 0 output
├── data-model.md     # Phase 1 output
├── quickstart.md     # Phase 1 output
├── contracts/        # Phase 1 output
│   ├── runner.md
│   ├── verify_solutions.md
│   └── lint_citations.md
└── tasks.md          # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── pilgrimage.rexx     # Minimal runner: loads koan, executes it, reports failure
└── meditation.rexx     # Minimal assertion library: assert_equal + FILL_ME_IN detection

koans/
└── 00_about_smoke.rexx # Smoke test koan: one passing assertion, one FILL_ME_IN, one failing

solutions/
└── 00_about_smoke.rexx # Solution: all FILL_ME_IN replaced; passes verify_solutions cleanly

bin/
├── verify_solutions    # REXX: runs each solutions/*.rexx through meditation.rexx; exits non-zero on any failure
└── lint_citations      # REXX: scans koans/*.rexx for well-formed Cowlishaw §N.N, p. NN citations

.github/
└── workflows/
    └── verify.yml      # CI: installs Regina, runs verify_solutions + lint_citations on ubuntu + macos

docs/
└── DESIGN_DECISIONS.md # ADR-style answers to 6 M1 architecture questions
```

**Structure Decision**: Single-project layout following PLAN.md §3 directly.
No `src/` layer — REXX scripts live at their functional paths (`lib/`, `bin/`,
`koans/`, `solutions/`). This matches the final curriculum structure so M2
can build on it without restructuring.

## Complexity Tracking

> No Constitution violations. Section left blank.
