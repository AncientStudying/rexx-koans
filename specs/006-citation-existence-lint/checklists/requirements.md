# Specification Quality Checklist: M2.4 — Mechanical Citation Existence Check

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-05-10
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- All 15 functional requirements have direct success-criteria coverage (SC-001 through SC-010 plus the byte-parity / read-only invariants in SC-006/SC-007/SC-008).
- The spec is necessarily REXX/Cowlishaw/index-aware (the curricular subject and lookup authority); these are subject-domain references, not implementation choices.
- Three clarifications resolved by the Clarifications session 2026-05-10:
  1. **Citation-detection scope** — M2.4 uses a more permissive pattern than M2.2's Rule C1 for the existence check, so in-prose parenthetical citations like `(Cowlishaw §2.3, p. 26)` are validated.
  2. **Lint file-scope** — extended to `solutions/*.rexx` in addition to `koans/*.rexx`. Station: check stays koans-only.
  3. **Multi-failure reporting** — for files with multiple unresolved citations, lint reports all in source order under a single `[FAIL] <file>` line.
- The contract-supersession precedent (M2.2 superseded M2-era; M2.4 supersedes M2.2) is documented in Out-of-band Considerations as a planning-decidable detail.
- The negative spot-checks (SC-003, SC-004) are performed manually during implementation per PLAN.md §M2.4 step 4; they are not automated tests in the CI matrix. The Acceptance Scenarios in US1 specify the user-visible failure-mode strings precisely, which makes the manual check trivially repeatable.
