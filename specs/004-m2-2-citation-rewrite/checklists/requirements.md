# Specification Quality Checklist: M2.2 — Citation Rewrite Against the Index

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-05-09
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

## Validation Notes

- **REXX-script and CI references are intentional, not implementation
  leakage.** `bin/lint_citations`, `verify_solutions`, `runner-smoke`,
  `tests/fixtures/runner_stdout.txt`, and the GitHub Actions workflow
  are explicitly named in Constitution Principle II (REXX) and
  Principle IV (CI as the acceptance gate) and are project-level
  contracts, not language- or framework-internals. The spec treats
  them as named system surfaces (the same way it treats
  `docs/cowlishaw_index.md` and `docs/M2_FOLLOWUP.md`).
- **Em-dash separator (FR-007) is a content rule, not a tooling
  rule.** It is grounded in Constitution Principle III's canonical
  citation form, which is normative for the curriculum independent
  of the lint mechanism that enforces it.
- **FR-014 is intentionally optional.** PLAN.md §M2.2 records the
  existence-check lint extension as "Optionally extend
  `bin/lint_citations`"; the spec exposes the option as a P3 user
  story and a normative-MAY requirement. Acceptance criteria gate
  on the rewrite (US1–US4), not on the optional extension.
- **No [NEEDS CLARIFICATION] markers were needed.** PLAN.md §M2.2,
  the M2.1 spec's Sync Impact Report, the constitution, and the
  audit table in `docs/M2_FOLLOWUP.md` together resolve every
  scope decision (canonical citation form, separator, lint
  responsibility, edit target, audit-row coverage, M2.3 boundary).
- **Items marked incomplete would require spec updates before
  `/speckit-clarify` or `/speckit-plan`.** All items currently pass.
