---
description: "Task list for M2.4 — Mechanical Citation Existence Check"
---

# Tasks: M2.4 — Mechanical Citation Existence Check

**Input**: Design documents from `/specs/006-citation-existence-lint/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/lint_citations.md, quickstart.md

**Tests**: NONE (beyond the existing CI matrix and the manual
negative spot-checks specified in `quickstart.md` Steps 4–6).
M2.4 ships a tooling extension; acceptance is established by the
6/6 CI checks plus the M2.4-specific quickstart spot checks
(SC-003, SC-004, FR-010 bootstrap-error). The script is a single
REXX file; per-procedure unit tests would require a test harness
not currently in the repo and are explicitly out of scope per
spec.md "Out of Scope" (no rewriting of `bin/verify_solutions`
or other CI scripts).

**Organization**: M2.4's four user stories ship as a single
atomic delivery — the substantive change is the `bin/lint_citations`
extension (US1). US2 (positive corpus pass) and US3 (contract
documentation) collapse into US1's delivery: US2 is verified by
running the extended lint, and US3's contract was authored by
`/speckit-plan` at `contracts/lint_citations.md` already; US3's
tasks are alignment / cross-reference verification.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks).
- **[Story]**: User story this task contributes to (US1, US2, US3, US4). Setup and Polish phases carry no story tag.
- File paths are repo-rooted.

## Path Conventions

- **Edit targets**: `bin/lint_citations` (the REXX script). One source-tree file.
- **Read-only**: `docs/cowlishaw_index.md` (FR-013), `koans/*.rexx` (FR-015), `solutions/*.rexx` (FR-015), `tests/fixtures/runner_stdout.txt` (FR-012), `lib/meditation.rexx` and other framework code (FR-011), `bin/verify_solutions` (out of scope), `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` (predecessor contract; preserved as historical record).
- **Already authored by /speckit-plan**: `specs/006-citation-existence-lint/contracts/lint_citations.md` (the M2.4 lint contract), `data-model.md`, `research.md`, `quickstart.md`. No further edits unless implementation surfaces a divergence.

---

## Phase 1: Setup

**Purpose**: Confirm the contributor workspace matches the
preconditions assumed by `research.md` §1 (the index format)
and §6 (the integration phase ordering — M2.2 lint behavior is
the foundation). Catches drift between plan and implementation.

- [X] T001 [P] Verify `bin/lint_citations` runs green on main's corpus pre-extension. Run `bin/lint_citations` and confirm `6/6 koans passed lint.` exit 0. Baselines M2.2's unchanged behavior; the M2.4 extension MUST preserve this for koans (and add the same green status for the 6 solutions).
- [X] T002 [P] Verify `bin/verify_solutions` runs green pre-extension. Confirm `6/6 solutions passed.`, exit 0. Baselines runtime correctness; M2.4 doesn't touch solutions or framework code, so this is invariant by construction.
- [X] T003 [P] Capture the runner-stdout-fixture diff baseline by running `quickstart.md` Step 3 against the unmodified corpus. Expected: empty diff. Baselines FR-012 invariance.
- [X] T004 [P] Verify `docs/cowlishaw_index.md` exists at HEAD and is byte-identical to main: `git diff main -- docs/cowlishaw_index.md` MUST be empty (FR-013 read-only invariant baselined).
- [X] T005 [P] Verify the M2.4 contract authored by `/speckit-plan` exists at `specs/006-citation-existence-lint/contracts/lint_citations.md` and the M2.2 contract at `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` is unmodified (`git diff main -- specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` MUST be empty — historical record preserved).
- [X] T006 [P] One-off parser sanity walk per `quickstart.md` "Optional: parser sanity walk". Read `docs/cowlishaw_index.md` and pick three known rows whose (§sec, page) keys + heading lists are easy to verify by eye: (§2.2, p. 19) — multiple `###` children including `Literal strings`; (§2.5, p. 32) — parent §2.5 row with `###` children; (§2.9, p. 91) — `### DATATYPE` child. Note the expected lookup-table shape for each (per `data-model.md` "Lookup table" schema). T010 will verify the implementation matches.

---

## Phase 2: Foundational

**Purpose**: Standard speckit slot for blocking prerequisites
that span multiple user stories. M2.4 has none — M2.1
(`docs/cowlishaw_index.md`) and M2.2 (the canonical-form check
in `bin/lint_citations`) are both committed at HEAD of main; the
contract authored by `/speckit-plan` is in place. Implementation
can begin immediately after Setup.

**Checkpoint**: No tasks. Proceed directly to Phase 3.

---

## Phase 3: User Story 1 — Mechanical existence enforcement at lint time (Priority: P1) 🎯 MVP

**Goal**: Extend `bin/lint_citations` to (a) parse `docs/cowlishaw_index.md` once at startup and build a `(§sec, page)` → headings lookup table per `data-model.md` "Lookup table", (b) reassemble comment-block paragraphs across `\n * ` line continuations per `research.md` §3, (c) extract every citation matching the broad detection pattern per `research.md` §2, (d) validate each extracted citation against the lookup table and accumulate `UNRESOLVED citation:` reasons per the three sub-reason variants in `research.md` §4, (e) emit per-file `[FAIL] <file>` plus one reason per offending citation in source order (FR-016), (f) extend file scope to also scan `solutions/*.rexx` (Q2 clarification). After this phase, every citation in `koans/` and `solutions/` is mechanically validated against `docs/cowlishaw_index.md`.

**Independent Test**: After this phase, run `bin/lint_citations` on the post-M2.3 corpus. Expected: `12/12 files passed lint.`, exit 0. Then introduce a fabricated `Cowlishaw §99.99, p. 999` into a sandbox koan; expected: `[FAIL]` line with `UNRESOLVED citation: ... (no §99.99 + p. 999 row in docs/cowlishaw_index.md)`, exit non-zero. Revert; expected: green again.

**Why this serves all four user stories**: US1 is the substantive change. US2 (corpus passes) is the positive verification of the same delivery. US3 (contract) was authored by `/speckit-plan`; US3's remaining tasks (Phase 5) are cross-references against this implementation. US4 (CI) is the project-level gate; US4's tasks (Phase 6) verify the same delivery in CI.

### Implementation for User Story 1 — Index parser (research.md §1, contract "Index parser")

- [X] T007 [US1] Add to `bin/lint_citations` a new `parse_index` procedure that reads `docs/cowlishaw_index.md` line by line, tracks `cur_section` (most-recent `## §X.Y` parent), and emits the lookup table. Use REXX stem variables per the schema in `contracts/lint_citations.md` "Lookup table": `table.<sec>.<page>.0` (heading count), `table.<sec>.<page>.<k>` (verbatim heading text), `table.<sec>.<page>.has_parent` (parent flag). Skip `# Part …` and `# Appendix …` top-level headings (reset `cur_section`). Use Regina built-ins only: `LINEIN`, `LINES`, `STREAM`, `POS`, `SUBSTR`, `STRIP`, `DATATYPE` (Constitution Principle II).
- [X] T008 [US1] Wire bootstrap-error mode in `bin/lint_citations` per FR-010 / contract "Bootstrap-error mode". On missing or empty `docs/cowlishaw_index.md`, or on parse failure (malformed `**Page:**` bullet, malformed heading line, orphan `### <heading>` without a preceding `## §X.Y`), print `[BOOTSTRAP] cannot build lookup table: docs/cowlishaw_index.md <reason>` to stderr and exit 1 BEFORE any per-file processing. Use the exact reason strings listed in the contract.
- [X] T009 [US1] Add `parse_index` invocation at the very start of the main flow in `bin/lint_citations` (before the file-discovery loop). On bootstrap success, the lookup table is in scope for the file-processing phase; on failure, the script has already exited per T008.
- [X] T010 [US1] After T007–T009 land, run a one-shot script-internal verification: `parse_index` against the current `docs/cowlishaw_index.md` MUST produce a table where the three rows from T006 (parser sanity walk) match the expected schema. If any of (§2.2, p. 19), (§2.5, p. 32), (§2.9, p. 91) doesn't have the expected `has_parent` flag and heading list, the parser has a bug; reconcile against `research.md` §1 and `data-model.md`.

### Implementation for User Story 1 — Citation detection + reassembly (research.md §2, §3; contract "Comment-block reassembly", "Broad citation-detection pattern")

- [X] T011 [US1] Add to `bin/lint_citations` a new `reassemble_paragraphs` procedure that takes a file path and returns a list of paragraph records (start_line, end_line, text). Per `contracts/lint_citations.md` "Comment-block reassembly": within each `/* ... */` block, group consecutive prose lines (those starting with ` * <content>`) into paragraphs separated by blank-decoration lines (` *` alone or with whitespace). Strip leading ` * ` decoration; join lines with single spaces. The closing ` */` ends the block.
- [X] T012 [US1] Add to `bin/lint_citations` a new `extract_citations` procedure that takes a reassembled paragraph text and returns a list of citation records (verbatim_text, section, page, suffix, paragraph_offset). Implement the broad pattern per `contracts/lint_citations.md` "Broad citation-detection pattern": find each `Cowlishaw §<sec>, p. <page>` substring (`is_section` predicate carries forward from M2.2's existing helper), then optionally match ` — <heading>` where the suffix terminates at the first of `)`, `*/`, end-of-paragraph, or the next `Cowlishaw §` marker. Preserve byte-level UTF-8 matching for the em-dash separator (`' E28094'x ' '`).
- [X] T013 [US1] In the per-file loop of `bin/lint_citations`, after the existing per-line `check_citation` / `check_station` scan (M2.2 — leave unchanged), call `reassemble_paragraphs(file)` then `extract_citations(paragraph)` for each paragraph. Track each extracted citation's source line_no by mapping `paragraph_offset` back through the paragraph's start_line plus per-line content lengths.

### Implementation for User Story 1 — Existence check + multi-failure reporting (research.md §4, §6; contract "Per-citation existence check", "Multi-failure reporting")

- [X] T014 [US1] In `bin/lint_citations`, after T013's citation extraction, look up each citation in the table. Emit the three `UNRESOLVED citation:` reason variants per `contracts/lint_citations.md` "Per-citation existence check": variant 1 (no §+page row) when both `table.<sec>.<page>.has_parent = 0` and `table.<sec>.<page>.0 = 0`; variant 2 (suffix mismatch with verbatim alternatives) when key resolves with `### children` but suffix doesn't match any verbatim; variant 3 (suffix at parent-only key) when key resolves but heading list is empty. Reason strings MUST be byte-identical to the contract's "Failure-mode taxonomy" table.
- [X] T015 [US1] Wire multi-failure reporting per FR-016 / `contracts/lint_citations.md` "Multi-failure reporting". A file with N unresolved citations emits `[FAIL] <file>` once and N `UNRESOLVED citation: ...` reason lines in source order (line-number ascending; for citations sharing a line, paragraph_offset ascending). Pre-existing M2.2 modes (`MISSING citation`, `MISSING / MULTIPLE Station:`) are emitted before the M2.4 modes when both apply.

### Implementation for User Story 1 — File-scope expansion + summary wording (FR-006, FR-009)

- [X] T016 [US1] Extend the file-discovery loop in `bin/lint_citations` to list both `koans/*.rexx` AND `solutions/*.rexx` (lexicographic order; koans first, then solutions). Continue to exclude `koans/path_to_enlightenment.rexx`. The Station: directive check (M2.2) applies to koans only — guard the call so solution files don't run it (per FR-008 / contract).
- [X] T017 [US1] Update the success-path summary line in `bin/lint_citations` from `<passed>/<total> koans passed lint.` to `<passed>/<total> files passed lint.` per `contracts/lint_citations.md` "Output format" / FR-009. Adjust the empty-corpus check accordingly (`koans/ and solutions/ are both empty -- nothing to lint` per the contract).
- [X] T018 [US1] Update the docstring header in `bin/lint_citations` to point at the new M2.4 contract: change the `Contract:` reference from `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` to `specs/006-citation-existence-lint/contracts/lint_citations.md`.

### Local verification for User Story 1

- [X] T019 [US1] Run `bin/lint_citations` on the rewritten corpus (post-T007–T018). Expected: `[ ok ]` for every file in koans/ and every file in solutions/, summary `12/12 files passed lint.`, exit 0. If any file fails, identify the citation that didn't resolve and trace through the parser → table → lookup chain.
- [X] T020 [US1] Run `bin/verify_solutions`. Expected: `6/6 solutions passed.`, exit 0. Catches accidental edits to solutions or framework code.
- [X] T021 [US1] Run the runner-stdout-fixture diff per `quickstart.md` Step 3. Expected: empty diff. M2.4 lint behavior is tooling-only; the runner output is invariant.

**Checkpoint**: At this point, `bin/lint_citations` mechanically validates every citation in `koans/` and `solutions/` against `docs/cowlishaw_index.md`; the post-M2.3 corpus passes with `12/12 files passed lint.`; M2.2's strict Rule C1 anchor check + Station: directive check + canonical-form rejections are all preserved; the runner stdout fixture is unchanged. US1 is delivered.

---

## Phase 4: User Story 2 — Stage I corpus passes the new check on first run (Priority: P1)

**Goal**: Confirm that the post-M2.3 corpus (committed at HEAD of main) plus the M2.4 lint extension produces `12/12 files passed lint.` on first run, with no [FAIL] lines for any koan or solution.

**Independent Test**: Run `bin/lint_citations` on a clean checkout of `006-citation-existence-lint` after Phase 3 lands; confirm 12/12 green.

### Implementation for User Story 2

- [X] T022 [US2] Confirm the corpus-wide green from T019 by re-running `bin/lint_citations` and capturing the output. Save the output for comparison: every line is `[ ok ] <file>`; the summary is `12/12 files passed lint.`; exit code is 0.
- [X] T023 [US2] Spot-check three specific citation kinds in the corpus to confirm the broad detection + lookup chain handles them correctly:
  1. **Trailing canonical citation** — `solutions/05_about_say.rexx` has `* Cowlishaw §2.7, p. 70` (bare). Confirm it resolves (key `(2.7, 70)` has `has_parent = 1`).
  2. **In-prose parenthetical, bare** — `solutions/00_about_asserts.rexx` has `* (Cowlishaw §2.3, p. 26):` after M2.3. Confirm it resolves under broad detection.
  3. **In-prose parenthetical, suffixed, cross-line** — `solutions/00_about_asserts.rexx` lines 39–40 have `(Cowlishaw §2.3, p. 27 — Logical\n * (Boolean))`. After comment-block reassembly, the suffix is `Logical (Boolean)`; confirm it matches the index's `### Logical (Boolean)` child at (§2.3, p. 27) verbatim. This is the canary for the cross-line reassembly logic.
- [X] T024 [US2] Spot-check that no Stage II–VI files exist and no M3+ koans were inadvertently scanned. `ls koans/` MUST list exactly the 6 Stage I koans plus `path_to_enlightenment.rexx`; `ls solutions/` MUST list exactly the 6 Stage I solutions. The M2.4 file-scope is the entire current corpus, but no future-stage files should appear.

**Checkpoint**: At this point, the corpus-wide green is verified end-to-end and the cross-line reassembly logic is verified on the canonical example. US2 is delivered.

---

## Phase 5: User Story 3 — The new lint behavior is documented in a contract (Priority: P1)

**Goal**: Confirm that `specs/006-citation-existence-lint/contracts/lint_citations.md` (authored by `/speckit-plan`) accurately documents the implemented script behavior, that it supersedes the M2.2 contract, and that `bin/lint_citations`'s docstring header references it correctly.

**Independent Test**: Walk the contract end to end against the implemented script; confirm every named rule, failure mode, output format, and exit code matches the script's actual behavior.

### Implementation for User Story 3

- [X] T025 [US3] Verify `bin/lint_citations` line 4 `Contract:` reference is `specs/006-citation-existence-lint/contracts/lint_citations.md` (T018 should have updated this; T025 is the explicit verification).
- [X] T026 [US3] Walk `contracts/lint_citations.md` "Acceptance cases (positive)" table end to end. For each row, construct the example citation in a sandbox file (or find an equivalent in the existing corpus per T023's spot-checks), run lint, and confirm it passes. Revert any sandbox edits.
- [X] T027 [US3] Walk `contracts/lint_citations.md` "Rejection cases (negative)" table end to end. For each row, construct the example citation in a sandbox file, run lint, and confirm the rejection produces the exact reason string named in the contract. Revert any sandbox edits.
- [X] T028 [US3] Verify the M2.2 contract is unmodified: `git diff main -- specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` MUST be empty. The supersession pattern preserves predecessor contracts as historical record per `research.md` §5.
- [X] T029 [US3] If T026 or T027 surfaces a divergence between contract and implementation, decide which is correct: if the implementation is correct, amend the contract (M2.4 is the authoritative reference); if the contract is correct, fix the implementation. Either way, re-run T019 to confirm green.

**Checkpoint**: At this point, the M2.4 contract accurately describes the implemented script behavior; the predecessor M2.2 contract is preserved; future contributors have a self-contained reference. US3 is delivered.

---

## Phase 6: User Story 4 — CI acceptance gate (Priority: P2)

**Goal**: Confirm that the CI matrix (`verify_solutions` × 2 OS, `lint_citations` × 2 OS, `runner-smoke` × 2 OS = 6 named checks; reported by GitHub as 2 jobs in the PR Checks UI) is green on the feature branch's HEAD prior to merge. Mechanically verify the negative spot-checks (SC-003, SC-004) and the bootstrap-error path (FR-010).

**Independent Test**: GitHub Actions reports green on both `ubuntu-latest` and `macos-latest` for all three workflow steps; locally, the three negative spot-check procedures from `quickstart.md` Steps 4–6 produce the expected reject-and-revert behavior.

### Implementation for User Story 4

- [X] T030 [US4] Negative spot-check 1 (SC-003, FR-003): per `quickstart.md` Step 4, introduce a fabricated citation `Cowlishaw §99.99, p. 999` into a sandbox edit of `koans/05_about_say.rexx`, run `bin/lint_citations`, confirm `[FAIL] koans/05_about_say.rexx` with reason `UNRESOLVED citation: Cowlishaw §99.99, p. 999 (no §99.99 + p. 999 row in docs/cowlishaw_index.md)`, exit 1. Revert; confirm `12/12 files passed lint.`, exit 0.
- [X] T031 [US4] Negative spot-check 2 (SC-004, FR-004): per `quickstart.md` Step 5, introduce a fabricated suffix `Cowlishaw §2.5, p. 32 — Bogus Heading` into a sandbox edit of `koans/02_about_variables.rexx`, run `bin/lint_citations`, confirm `[FAIL]` with reason `UNRESOLVED citation: Cowlishaw §2.5, p. 32 — Bogus Heading (heading "Bogus Heading" does not match index row "<verbatim CSV of valid §2.5+p.32 children>")`. Revert; confirm green.
- [X] T032 [US4] Bootstrap-error spot-check (FR-010): per `quickstart.md` Step 6, empty `docs/cowlishaw_index.md` (`: > docs/cowlishaw_index.md` after backup), run lint, confirm `[BOOTSTRAP] cannot build lookup table: docs/cowlishaw_index.md is empty`, exit 1. Revert; confirm green.
- [X] T033 [US4] Multi-failure-reporting spot-check (FR-016): per `data-model.md` "Multi-failure reporting" and `contracts/lint_citations.md` "Failure path (example)", introduce TWO unresolved citations in a single sandbox file (e.g., a fabricated §99.99 plus a fabricated suffix at §2.5, p. 32, both in `koans/03_about_expressions.rexx`). Run lint; confirm `[FAIL] koans/03_about_expressions.rexx` is emitted ONCE with TWO `UNRESOLVED citation:` reason lines underneath in source order. Revert; confirm green.
- [X] T034 [US4] Mechanical out-of-scope checks per `quickstart.md` Step 7: `git diff main -- docs/cowlishaw_index.md` (FR-013, SC-007) MUST be empty; `git diff main -- tests/fixtures/runner_stdout.txt` (FR-012, SC-006) MUST be empty; `git diff main -- koans/ solutions/` (FR-015, SC-008) MUST be empty. If any is non-empty, the corresponding read-only invariant was violated; identify and revert before continuing.
- [ ] T035 [US4] Push the feature branch to origin: `git push -u origin 006-citation-existence-lint`.
- [ ] T036 [US4] Monitor CI: confirm the GitHub Actions `verify` workflow reports `success` on both `ubuntu-latest` and `macos-latest`. The 6 named steps (`Verify solutions`, `Lint citations`, `Runner smoke (fully-solved walk against committed fingerprint)`) MUST all pass on each OS. The 6/6 count satisfies Constitution Principle IV and spec SC-005.

**Checkpoint**: CI gate is green; all four user-facing stories (US1, US2, US3, US4) are complete.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: PR preparation and final review.

- [ ] T037 [P] Open a pull request from `006-citation-existence-lint` to `main` with a description that summarizes: the index parser (link to `research.md` §1), the broad citation-detection pattern (link to `research.md` §2), the cross-line comment-block reassembly (link to `research.md` §3), the three `UNRESOLVED citation` reason variants (link to `research.md` §4), the new lint contract location (link to `contracts/lint_citations.md`), the post-M2.3 corpus passing on first run (link to `data-model.md`), and the four user stories' closures (US1–US4). Include a checklist confirming SC-001 through SC-010.
- [ ] T038 [P] Run the `quickstart.md` recipe end-to-end one more time on a fresh checkout (or after `git clean -fdx` on the working tree) to confirm a contributor with no local state can reproduce the green build. Steps 1+2+3 are mechanically exercised in T019/T020/T021; Steps 4+5+6 are exercised in T030/T031/T032; Step 7 (out-of-scope checks) is exercised in T034. Note any quickstart-doc improvements needed.
- [X] T039 Final review pass: re-read `spec.md` Out of Scope and Assumptions sections; confirm no item has been silently violated. Specifically: `docs/cowlishaw_index.md` unmodified (FR-013, SC-007), runner fixture unchanged (FR-012, SC-006), no `koans/` or `solutions/` files modified (FR-015, SC-008), no Stage II–VI files touched, no `lib/meditation.rexx` change (FR-011), no `bin/verify_solutions` change, no PDF-posture changes, no koan/solution prose touched (Constitution Principle V), the M2.2 contract preserved as historical record (T028). Then re-read `contracts/lint_citations.md` "Constraints" section; confirm every constraint holds in the implementation.
- [X] T040 [P] Optional Rule C1 regression check: confirm M2.2's strict canonical-form anchor check (FR-007) still rejects legacy non-canonical citations. Introduce a sandbox edit to `koans/05_about_say.rexx` that adds a citation with the legacy ASCII separator `Cowlishaw §2.7, p. 70 -- Default character output stream`. Run `bin/lint_citations`; expected: the file gets `MISSING citation` (the broad M2.4 pattern requires canonical em-dash for suffix detection AND M2.2 Rule C1 still rejects `--` separators), NOT `UNRESOLVED citation`. Then add a second sandbox citation that removes the original trailing canonical citation while keeping the `--` one — expected: `[FAIL]` with `MISSING citation`. Revert; confirm green. Mechanizes the structural guarantee that T013 left `check_citation` unchanged.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Empty for M2.4.
- **User Story 1 (Phase 3)**: Depends on Setup (T001–T006 baselines and parser sanity walk). Within Phase 3: T007–T010 (parser + bootstrap) → T011–T013 (reassembly + extraction) → T014–T015 (existence check + multi-failure) → T016–T018 (file scope + summary + docstring) → T019–T021 (local verification). Each block depends on the previous one because they all edit `bin/lint_citations` sequentially.
- **User Story 2 (Phase 4)**: Depends on Phase 3 completion. T022–T024 are read-only verifications.
- **User Story 3 (Phase 5)**: Depends on Phase 3 completion. T025 verifies T018's docstring update; T026–T028 walk the contract against the implementation; T029 reconciles divergences if any.
- **User Story 4 (Phase 6)**: Depends on Phase 3 completion. T030–T034 (local spot-checks) can run in parallel; T035 (push) depends on T030–T034 + T028 (out-of-scope verified clean); T036 (monitor CI) depends on T035.
- **Polish (Phase 7)**: Depends on Phase 6. T037 + T038 [P] independent of each other; T039 is the final review.

### User Story Dependencies

- **US1 (Phase 3)**: Independent. Delivers the implementation.
- **US2 (Phase 4)**: Depends on US1's implementation landing. Verification only — no new edits.
- **US3 (Phase 5)**: Depends on US1's implementation landing (the contract was authored by `/speckit-plan`; US3's tasks verify alignment). May run in parallel with US2.
- **US4 (Phase 6)**: Depends on US1's implementation landing. The CI run validates the full delivery in one matrix.

### Within Each User Story

- US1 (Phase 3): tasks are largely sequential because they all edit `bin/lint_citations`. T007 (parser) and T008 (bootstrap) are tightly coupled (the bootstrap calls the parser); land them together. T011 (reassembly) is independent of T007–T010 in principle but practically follows them to keep diff context coherent. T012 (extraction) depends on T011's paragraph records. T013 wires them together. T014–T015 are sequential (the lookup logic emits the reasons that multi-failure reporting accumulates). T016–T018 are independent text edits but all to `bin/lint_citations`. T019–T021 are the local verification gate — sequential within the verification itself.
- US2 (Phase 4): T022, T023, T024 independent verifications; parallelizable.
- US3 (Phase 5): T025 independent text verification; T026, T027 parallelizable (different contract sections); T028 independent git-diff check; T029 conditional on T026/T027 outcomes.
- US4 (Phase 6): T030, T031, T032, T033, T034 independent local spot-checks (parallelizable); T035 (push) → T036 (monitor CI) strict order.

### Parallel Opportunities

- All Phase 1 tasks (T001–T006) can run in parallel.
- US3 (Phase 5) and US4 (Phase 6) tasks can interleave once Phase 3 lands — US3's contract walk and US4's negative spot-checks are independent of each other.
- T030–T034 in Phase 6 can run in parallel.
- T037, T038 in Polish can run in parallel.

---

## Parallel Example: Phase 1 (Setup baselines)

```
# All baselines run in parallel:
Task T001: bin/lint_citations baseline (6/6 koans pass)
Task T002: bin/verify_solutions baseline (6/6 solutions pass)
Task T003: runner-stdout-fixture diff baseline (empty)
Task T004: docs/cowlishaw_index.md byte-identical to main
Task T005: M2.4 contract present + M2.2 contract unmodified
Task T006: parser sanity walk (note expected lookup-table shape for 3 known rows)
```

---

## Implementation Strategy

### MVP (US1 alone)

1. Phase 1 Setup → preconditions verified.
2. Phase 3 US1 → `bin/lint_citations` extended end-to-end. Local verification (T019–T021) confirms `12/12 files passed lint.`, `6/6 solutions passed.`, runner-stdout fixture unchanged.
3. **STOP** if a partial-merge MVP is acceptable: every citation in the corpus is mechanically validated; M2.2's checks are preserved; the contract documents the new behavior. US2, US3, and US4 are still gated by their own phases but the implementation is correct.

### Full M2.4 incremental delivery

1. Phase 1 Setup.
2. Phase 3 US1 → implementation. Atomic commit (or per-block commits) keeps lint and verify_solutions green throughout.
3. Phase 4 US2 → corpus-wide pass verification. No new commits — verification only.
4. Phase 5 US3 → contract-vs-implementation alignment. Possibly minor commits if T029 surfaces divergences and they're contract-side fixes.
5. Phase 6 US4 → negative spot-checks + push + monitor CI. The negative spot-checks (T030–T033) are introduce-and-revert; they don't commit edits.
6. Phase 7 Polish → PR + final review.

### Parallel Team Strategy

M2.4's blast radius is small (one script, one contract document already authored). The natural cadence is one developer in sequence; parallelization across team members would add coordination overhead without saving meaningful time. T030–T034 are parallelizable for an LLM agent doing batch verification but trivially sequential for a human.

---

## Notes

- [P] tasks edit independent files (or independent verification surfaces) and have no inter-dependencies on incomplete tasks.
- [Story] labels: US1 = mechanical existence enforcement (Phase 3 — the actual implementation work); US2 = corpus-wide pass verification (Phase 4); US3 = contract-implementation alignment (Phase 5); US4 = CI acceptance gate + negative spot-checks (Phase 6).
- All four user stories ship as a single atomic delivery; the phase ordering here is for clarity of acceptance verification, not for separable releases.
- Commit cadence: one commit per logical block in Phase 3 (parser, reassembly, extraction, lookup, file-scope) is reasonable; verification phases (4, 5, 6) are read-only and produce no commits except for any T029 contract-side fixes.
- Avoid: modifying any file under `koans/` or `solutions/` (FR-015); modifying `docs/cowlishaw_index.md` (FR-013); modifying `tests/fixtures/runner_stdout.txt` (FR-012); modifying `bin/verify_solutions` or any other CI script outside `bin/lint_citations` itself; modifying `lib/meditation.rexx` or any framework code (FR-011); modifying the M2.2 contract at `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` (preserved as historical record per `research.md` §5).
