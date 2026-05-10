---
description: "Task list for M2.5 — Koan Assertion-Line Shape Cleanup"
---

# Tasks: M2.5 — Koan Assertion-Line Shape Cleanup

**Input**: Design documents from `/specs/007-koan-line-shape/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/assertion_line_shape.md, quickstart.md

**Tests**: NONE beyond the existing CI matrix (`verify_solutions`,
`lint_citations`, `runner-smoke` × 2 OS = 6 checks per
Constitution Principle IV) and the bit-identity probe specified
in `quickstart.md` Step 5. M2.5 ships a representational refactor;
acceptance is established by the 6/6 CI checks plus the
quickstart's State A (fixture byte-identity) and State B
(unsolved-state line-number identity) probes. The dispatcher
contract is unchanged, so per-procedure unit tests would test
nothing new; per spec.md "Out of Scope" no test harness is
introduced.

**Organization**: M2.5's five user stories ship as a single
atomic delivery — US1 (cleanup across the corpus, both koans
and solutions) is the substantive change; US2 (behavior
bit-identity) is the verification of US1's work; US3 (solution-
koan parity) is the diff-time invariant check; US4 (CI green)
is the project-level gate; US5 (PLAN.md §8 ratification) is the
documentation read-aloud check.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no
  dependencies on incomplete tasks).
- **[Story]**: User story this task contributes to (US1, US2,
  US3, US4, US5). Setup and Polish phases carry no story tag.
- File paths are repo-rooted.

## Path Conventions

- **Edit targets**: `koans/0[0-5]_about_*.rexx` (6 files) and
  `solutions/0[0-5]_about_*.rexx` (6 files). Twelve files
  total. The recipe is identical per file: collapse assertion
  lines per `contracts/assertion_line_shape.md` "Canonical
  Assertion-Line Shape", rewrite the `m:` wrapper per
  "Canonical `m:` Wrapper Body", keep the file's own path
  literal.
- **Read-only**: `lib/meditation.rexx` (FR-005),
  `bin/pilgrimage`, `bin/verify_solutions`, `bin/lint_citations`
  (FR-006), `tests/fixtures/runner_stdout.txt` (FR-007),
  `docs/cowlishaw_index.md` (FR-008), `PLAN.md` (FR-015 — the
  codification commit `9a5de4a` is the precondition; no further
  edits), `.specify/memory/constitution.md`,
  `.github/workflows/verify.yml`, `koans/path_to_enlightenment.rexx`
  (the manifest, no assertions).
- **Already authored by /speckit-plan**: `plan.md`,
  `research.md`, `data-model.md`,
  `contracts/assertion_line_shape.md`, `quickstart.md`,
  updated `CLAUDE.md`. No further edits unless implementation
  surfaces a divergence.
- **Spike at `stash@{0}`**: a working application of the new
  shape to `koans/00_about_asserts.rexx` only. Reference, not
  source of truth.

---

## Phase 1: Setup

**Purpose**: Confirm the contributor workspace matches the
preconditions assumed by `plan.md` Technical Context, capture
pre-edit baselines for the bit-identity probes, and validate
the corpus-shape uniformity assumption (`research.md` §6).

- [X] T001 [P] Verify upstream milestones merged at `main` HEAD: `git log main --oneline | grep -E '(M2\.2|M2\.3|M2\.4|005-vocab-review|006-citation-existence-lint)'` returns at least three matches confirming M2.2, M2.3, and M2.4 commits / merge commits are present. Spec Assumption "M2.2/M2.3/M2.4 complete and committed" baselined.
- [X] T002 [P] Verify PLAN.md v1.4 codified on the feature branch: `git log 007-koan-line-shape --oneline | grep '9a5de4a'` returns the codification commit; `grep -c "M2.5 — Koan Assertion-Line Shape Cleanup" PLAN.md` returns 1 (milestone heading present); `grep -c "Assertion lines stay single-statement" PLAN.md` returns 1 (§8 style bullet present). FR-015 baselined.
- [X] T003 [P] Verify spike at `stash@{0}` is intact: `git stash list | grep "spike: simplified assertion-line shape (M2.5 POC)"` returns one match. The spike is the reference for T008. (If absent, T008 falls back to hand-edit; see `quickstart.md` Step 2 Option B.)
- [X] T004 [P] Capture `bin/verify_solutions` baseline: `bin/verify_solutions` reports `6/6 solutions passed.`, exit 0. Baselines FR-010 / SC-005 invariance — solutions remain green at every commit on the feature branch.
- [X] T005 [P] Capture `bin/lint_citations` baseline: `bin/lint_citations` reports 12 `[ ok ]` lines and `12/12 files passed lint.`, exit 0. Baselines FR-011 / SC-006 invariance — citations are byte-identical pre/post (FR-009), so the M2.4 existence check carries through.
- [X] T006 [P] Capture `bin/pilgrimage` runner-stdout fixture baseline: `bin/pilgrimage > /tmp/runner_baseline.txt; diff -u tests/fixtures/runner_stdout.txt /tmp/runner_baseline.txt` returns empty. Baselines FR-007 / FR-012 / SC-004 invariance — the success-path output already matches the fixture, and M2.5 must preserve byte-identity.
- [X] T007 [P] Pre-grep corpus for legacy-shape uniformity (`research.md` §6 risk mitigation). Run two greps: (a) `grep -c -E '^[[:space:]]*n = n \+ 1;[[:space:]]*CALL m' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx` returns ~30+ matches summed across the 12 files; (b) `grep -E 'm: PARSE ARG kind, arg1, arg2, num' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns exactly 12. If either count is unexpected, **stop and investigate** before proceeding to Phase 3 — the recipe assumes uniform legacy shape and a divergent file needs per-file judgment.

**Checkpoint**: All preconditions verified, baselines captured, corpus shape confirmed uniform legacy. Ready to migrate.

---

## Phase 2: Foundational

**Purpose**: Standard speckit slot for blocking prerequisites
that span multiple user stories. M2.5 has none — the corpus
exists, `lib/meditation.rexx` is unchanged and ready, the
dispatcher's six-argument interface is the contract this
feature targets, and the §8 style bullet authoritative
reference is committed at `9a5de4a`. Implementation can begin
immediately after Setup.

**Checkpoint**: No tasks. Proceed directly to Phase 3.

---

## Phase 3: User Story 1 — Pilgrim sees the REXX, not the framework (Priority: P1) 🎯 MVP

**Goal**: Apply the cleaned assertion-line shape and the
3-arg `m:` wrapper across all 12 Stage I files (6 koans + 6
solutions) per `contracts/assertion_line_shape.md`. After
this phase, every assertion line in the corpus reads as
`CALL m '<verb>', <arg1>, <arg2>` and every koan-local
wrapper takes 3 args and increments `n` internally; the
pilgrim's eye lands on the REXX being taught instead of on
framework state.

**Independent Test**: After this phase, `grep -c -E '^[[:space:]]*n = n \+ 1;[[:space:]]*CALL m' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx` returns 0; `grep -E 'CALL m .*, n[[:space:]]*$' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns 0; `grep -E 'm: PARSE ARG kind, arg1, arg2$' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns 12. Mechanical confirmation that all 12 files match the post-change shape per FR-001 / FR-002 / FR-003.

**Why this serves all five user stories**: US1 is the substantive change. US2 (behavior bit-identity) is verified by running the post-change runner and dispatcher against the fixture (Phase 4). US3 (solution-koan parity) is verified by the per-pair diff (Phase 5). US4 (CI gate) is verified by pushing and observing the matrix (Phase 6). US5 (PLAN.md §8 ratification) is a documentation read confirming the §8 bullet authored at `9a5de4a` conveys the rule (Phase 7).

### Implementation for User Story 1 — Koan migrations (FR-001, FR-003)

- [X] T008 [US1] Apply spike to `koans/00_about_asserts.rexx`. Run `git stash apply stash@{0}` (or hand-edit per `contracts/assertion_line_shape.md` if the stash is unavailable; see `quickstart.md` Step 2 Option B). Confirm the file's assertion lines match the post-change shape (no `n = n + 1;` prefix, no trailing `, n`) and the wrapper is the canonical 3-arg form with the literal `'koans/00_about_asserts.rexx'` as the third CALL argument. Spot-check via `bin/pilgrimage 2>&1 | head -10`: runner advances past koan 00 (or stops at the first FILL_ME_IN with the expected line number).
- [X] T009 [P] [US1] Migrate `koans/01_about_strings.rexx` per `contracts/assertion_line_shape.md`. For every assertion line: strip `n = n + 1;` prefix and trailing `, n` argument. Replace the wrapper body with the canonical post-change shape; the wrapper's third argument is the literal `'koans/01_about_strings.rexx'`. Spot-check: `bin/pilgrimage` advances past koan 00 to koan 01 and reports the same `Damaged at:` line number for koan 01's first FILL_ME_IN as the pre-change baseline.
- [X] T010 [P] [US1] Migrate `koans/02_about_variables.rexx` per the same recipe; wrapper third arg is `'koans/02_about_variables.rexx'`.
- [X] T011 [P] [US1] Migrate `koans/03_about_expressions.rexx` per the same recipe; wrapper third arg is `'koans/03_about_expressions.rexx'`.
- [X] T012 [P] [US1] Migrate `koans/04_about_clauses.rexx` per the same recipe; wrapper third arg is `'koans/04_about_clauses.rexx'`.
- [X] T013 [P] [US1] Migrate `koans/05_about_say.rexx` per the same recipe; wrapper third arg is `'koans/05_about_say.rexx'`.

### Implementation for User Story 1 — Solution migrations (FR-002, FR-003)

- [X] T014 [P] [US1] Migrate `solutions/00_about_asserts.rexx` per the same recipe; wrapper third arg is `'solutions/00_about_asserts.rexx'`. Run `bin/verify_solutions 2>&1 | grep "00_about_asserts"`: solution 00 reports `[ ok ]`.
- [X] T015 [P] [US1] Migrate `solutions/01_about_strings.rexx`; wrapper third arg is `'solutions/01_about_strings.rexx'`. Run `bin/verify_solutions`: 6/6 still green.
- [X] T016 [P] [US1] Migrate `solutions/02_about_variables.rexx`; wrapper third arg is `'solutions/02_about_variables.rexx'`.
- [X] T017 [P] [US1] Migrate `solutions/03_about_expressions.rexx`; wrapper third arg is `'solutions/03_about_expressions.rexx'`.
- [X] T018 [P] [US1] Migrate `solutions/04_about_clauses.rexx`; wrapper third arg is `'solutions/04_about_clauses.rexx'`.
- [X] T019 [P] [US1] Migrate `solutions/05_about_say.rexx`; wrapper third arg is `'solutions/05_about_say.rexx'`.

### Verification for User Story 1

- [X] T020 [US1] Confirm corpus-wide post-edit conformance per FR-003 / FR-004 / FR-013 / FR-014. Run four greps on the post-migration tree: (a) `grep -c -E '^[[:space:]]*n = n \+ 1;[[:space:]]*CALL m' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx` returns 0 (FR-013); (b) `grep -E 'CALL m .*, n[[:space:]]*$' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns 0 (FR-014); (c) `grep -E '^m: PARSE ARG kind, arg1, arg2$' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns 12 (FR-003 wrapper signature, one per file); (d) `grep -E '^n = 0$' koans/0[0-5]_about_*.rexx solutions/0[0-5]_about_*.rexx | wc -l` returns 12 (FR-004 — the top-of-file `n = 0` initializer is present in every in-scope file). Then run `bin/verify_solutions` (must report `6/6 solutions passed.`) and `bin/lint_citations` (must report `12/12 files passed lint.`). All five checks pass = US1 mechanical-acceptance.

**Checkpoint**: After Phase 3, the corpus is structurally migrated. US1's user-visible cleanup is delivered. US2 / US3 / US4 / US5 verify the same delivery from different angles.

---

## Phase 4: User Story 2 — Runner behavior is bit-for-bit identical (Priority: P1)

**Goal**: Prove that the cleanup is purely representational — failure-message ordinals, "Damaged at: …, line N" line numbers, and runner success-path stdout all match the pre-change run byte-for-byte. The dispatcher (`lib/meditation.rexx`) is unchanged (FR-005), so this is a verification of the wrapper's plumbing, not a behavior change.

**Independent Test**: Three probes per `quickstart.md` Step 5: (a) State A — fully-solved corpus runner stdout diffed against `tests/fixtures/runner_stdout.txt` returns empty; (b) State B — unsolved-state with one FILL_ME_IN intact, the `Damaged at: <file>, line N` value matches the line number captured in T006 baseline; (c) wrong-fill probe — one wrong fill in one koan, the failure-message ordinal ("the Nth assertion of …") matches the pre-change ordinal for the same wrong fill.

### Implementation for User Story 2

- [X] T021 [US2] State A — fully-solved fixture probe. `bin/pilgrimage` runs against the `koans/` tree (NOT `solutions/`); the runner-stdout fixture represents the `koans/` tree with every FILL_ME_IN temporarily replaced by its canonical solution value (the maintainer who recorded the fixture filled the blanks for the duration of the capture). To reproduce: for the duration of this probe only, copy the canonical fills from each `solutions/NN_about_*.rexx` into the matching `koans/NN_about_*.rexx` (replacing each FILL_ME_IN with the value the matching solution carries at that position). DO NOT commit these fills — they are transient probe state. Run `bin/pilgrimage > /tmp/runner_post.txt; diff -u tests/fixtures/runner_stdout.txt /tmp/runner_post.txt`. Expected: empty diff (FR-007, FR-012, SC-004). If non-empty, an assertion-line edit introduced behavioral drift — investigate and fix before proceeding. After the probe, revert the temporary fills so `koans/` returns to its FILL_ME_IN-bearing committed state.
- [X] T022 [US2] State B — unsolved-state line-number probe. Pick `koans/00_about_asserts.rexx`'s first assertion line (the `CALL m 'eq', ...` for the `2 + 2` concept block; line 33 on `main` HEAD per the spike's UAT). Capture the pre-change line number from `git show main:koans/00_about_asserts.rexx | grep -n "n = n + 1; CALL m 'eq'" | head -1`. Confirm the post-change file's same assertion line has the same line number: `grep -n "CALL m 'eq', FILL_ME_IN, 2 + 2" koans/00_about_asserts.rexx` (expected: line 33). Then deliberately revert the FILL_ME_IN at that position (replace `4` with `FILL_ME_IN` or restore the koan-side blank as appropriate) and run `bin/pilgrimage 2>&1 | grep "Damaged at"`. Expected: `Damaged at: koans/00_about_asserts.rexx, line 33.` (the same line number the pre-change run produced for the same blank). Restore the fill (SC-010 first half).
- [X] T023 [US2] Wrong-fill probe — failure-message ordinal identity. With every FILL_ME_IN filled in the koans/, deliberately introduce one wrong fill in `koans/00_about_asserts.rexx` (e.g., change `CALL m 'eq', 4, 2 + 2` to `CALL m 'eq', 5, 2 + 2`). Run `bin/pilgrimage 2>&1 | grep -E "(damaged your karma|Damaged at)"` and capture the ordinal from the diagnostic ("the 1st assertion of …" — the first assertion is the one with `4`, so wrongness here surfaces at ordinal 1). Confirm the same ordinal would have surfaced on the pre-change corpus (mechanically: line 33 contains the first call to `m`, ordinal 1; the wrapper increments before delegation so the dispatcher sees `n=1` for the first call — identical to pre-change). Revert the wrong fill (SC-010 second half).

**Checkpoint**: After Phase 4, behavior preservation is proved end-to-end. US2 acceptance gate met.

---

## Phase 5: User Story 3 — Solution-koan parity preserved (Priority: P1)

**Goal**: Prove that for each (koan, solution) file pair, the diff shows only FILL_ME_IN ↔ value substitutions on the documented blank positions — no shape differences, no wrapper differences, no idiomatic differences. The post-cleanup koan and matching solution remain a derived pair per PLAN.md §10's standard work order.

**Independent Test**: For each of the 6 file pairs, `diff koans/NN_about_*.rexx solutions/NN_about_*.rexx` returns hunks where every changed line is either a FILL_ME_IN ↔ value substitution or part of the wrapper's third-argument literal (`'koans/...'` ↔ `'solutions/...'`). No other line differs.

### Implementation for User Story 3

- [X] T024 [US3] Run six per-pair diffs and confirm each shows only the documented blank-position substitutions plus the wrapper-path-literal difference: `for n in 00 01 02 03 04 05; do echo "--- pair $n ---"; diff "koans/${n}_about_"*.rexx "solutions/${n}_about_"*.rexx; done`. Expected: each diff hunk is either (a) a `< ` line with `FILL_ME_IN` (or `FILL_ME_IN_<m>`) and the matching `> ` line with the canonical solution value at the same column, or (b) a `< ` line `'koans/NN_about_*.rexx'` and the matching `> ` line `'solutions/NN_about_*.rexx'` (the wrapper path literal). No hunk should show shape differences in assertion lines, the wrapper signature, the increment, the `n = 0` initializer, the `EXIT 0` line, or any prose. SC-009 acceptance.

**Checkpoint**: After Phase 5, the parity invariant is verified for the entire post-cleanup corpus.

---

## Phase 6: User Story 4 — CI matrix stays green (Priority: P2)

**Goal**: Push the feature branch and confirm GitHub Actions reports `success` on all six CI checks (`verify_solutions`, `lint_citations`, `runner-smoke` × {ubuntu-latest, macos-latest}). The matrix is the project's merge gate per Constitution Principle IV.

**Independent Test**: The PR Checks UI on `https://github.com/AncientStudying/rexx-koans/pull/<N>` (or `gh pr checks <N>`) shows all six named steps green on the feature branch's HEAD commit prior to merge.

### Implementation for User Story 4

- [X] T025 [US4] Push the feature branch to origin: `git push -u origin 007-koan-line-shape`. Confirm the push succeeds and creates the upstream tracking branch.
- [X] T026 [US4] Open a draft PR (or wait for existing PR) and confirm GitHub Actions reports `success` on all six CI checks. Mechanically: `gh pr checks <N> --watch` (or check the PR Checks UI). Expected six `pass` rows: `Verify solutions / ubuntu-latest`, `Verify solutions / macos-latest`, `Lint citations / ubuntu-latest`, `Lint citations / macos-latest`, `Runner smoke / ubuntu-latest`, `Runner smoke / macos-latest`. SC-007 acceptance. If any check fails, investigate and fix before merge.

**Checkpoint**: After Phase 6, the project-level acceptance gate is met. The PR is mergeable from a CI perspective.

---

## Phase 7: User Story 5 — M3+ authoring guidance is clear and discoverable (Priority: P2)

**Goal**: Confirm that `PLAN.md` §8's "Assertion lines stay single-statement" bullet (committed at `9a5de4a`) conveys the rule and the forbidden pattern in under 60 seconds of unaided reading. The bullet is the authoritative forward reference for M3+ koan authors; if a reader cannot extract the rule from it, the codification has failed.

**Independent Test**: A reviewer reads `PLAN.md` §8 unaided (no consultation of M2.5's spec, plan, contract, or any other document). In under 60 seconds, they can name (a) the canonical assertion-line shape for new koans, and (b) the forbidden pattern.

### Implementation for User Story 5

- [X] T027 [US5] Open `PLAN.md`, navigate to §8 "Voice and Style Guidelines", locate the "Assertion lines stay single-statement" bullet. Read it unaided. Confirm in under 60 seconds you can verbally state: (a) the canonical shape `CALL m '<verb>', expected, actual` (single statement, no inline ordinal counter, no per-line bookkeeping); (b) the forbidden pattern `n = n + 1; CALL m '...', ..., n` (and that it is "forbidden in new koans and solutions from M2.5 onward"); (c) why the rule exists ("the pilgrim's eye should land on the REXX being taught, not on framework state"). If any of the three are not nameable from the bullet alone, propose a §8-bullet edit; otherwise SC-011 acceptance.

**Checkpoint**: After Phase 7, the documentation gate is met. The §8 bullet is the authoritative forward reference for M3+.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final sanity checks on diff scope, end-to-end re-runs of the CI scripts, and post-merge spike cleanup readiness.

- [X] T028 [P] Run final diff-scope sanity check per FR-017 + FR-009 + FR-016. Three checks:
    - **(a) [FR-017]** `git diff main -- ':!specs/' ':!koans/' ':!solutions/'` returns empty output — nothing outside the spec, koans, and solutions directories has been modified by this feature. Equivalent narrower form: `git diff main -- lib/ bin/ docs/cowlishaw_index.md tests/fixtures/runner_stdout.txt .github/` returns empty. (PLAN.md and CLAUDE.md were modified, but those edits live on the feature branch in the codification commit `9a5de4a` and the `[Spec Kit] Add implementation plan` commit — they are the spec-directory-and-codification artifacts of this feature, not unintended out-of-scope edits.)
    - **(b) [FR-009]** `git diff main -- koans/ solutions/ | grep -E '^[+-].*(Cowlishaw|Station:)' | wc -l` returns 0 — no Cowlishaw citation or Station: directive line is added or removed by this feature. The cleanup is supposed to touch assertion lines and the `m:` wrapper only; this check confirms no citation or station-directive byte drifted in either direction.
    - **(c) [FR-016]** `git diff --name-status main -- koans/ solutions/ | grep -v '^M' | wc -l` returns 0 — only `M` (modify) status entries are present in `koans/` and `solutions/`; no `A` (add), `D` (delete), `R` (rename), or `C` (copy) status entries. The feature edits in place; it does not add, remove, or rename files in either tree.

  If any of the three checks fails, investigate before pushing.
- [X] T029 [P] Final end-to-end re-run of the three CI scripts on the feature branch HEAD: `bin/verify_solutions` (expected `6/6 solutions passed.`), `bin/lint_citations` (expected `12/12 files passed lint.`), `bin/pilgrimage` (expected stdout byte-identical to `tests/fixtures/runner_stdout.txt`). All three pass = local mirror of the CI matrix is green.
- [X] T030 Drop `stash@{0}` as the post-merge cleanup step. Mechanically: after the PR merges to `main`, run `git stash drop stash@{0}` (or the matching index if other stashes were added in the interim — verify via `git stash list` first). The spike has fulfilled its purpose; keeping it would risk future contributors confusing it with the canonical implementation. **Note**: this task is the *post-merge readiness flag*, not the drop itself — the actual drop happens after the merge lands. Mark this task complete when the spike-drop is queued in the contributor's notes.

**Checkpoint**: After Phase 8, M2.5 is fully delivered and post-merge cleanup is queued.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately. T001–T007 all [P].
- **Foundational (Phase 2)**: No tasks. Skip directly to Phase 3.
- **User Story 1 (Phase 3)**: Depends on Setup. T008 (spike replay or hand-edit of koan 00) is independent of T009–T019 (other 11 file migrations) — all 12 can in principle run in parallel. T020 (corpus-wide verification) depends on all 12 migrations being complete.
- **User Story 2 (Phase 4)**: Depends on US1 complete (post-migration corpus). T021 / T022 / T023 are sequential among themselves (T022 and T023 each modify-and-revert the working tree, so they should run sequentially to avoid stepping on each other; T021 reads only).
- **User Story 3 (Phase 5)**: Depends on US1 complete. T024 reads the post-migration corpus; can run in parallel with T021 / T028 (different surfaces).
- **User Story 4 (Phase 6)**: Depends on US1 + US2 + US3 all green. T025 (push) precedes T026 (CI verification).
- **User Story 5 (Phase 7)**: Depends only on PLAN.md being committed at `9a5de4a` (precondition, established in Setup T002). Can run any time after Setup; conventionally placed after CI for delivery-completeness narrative.
- **Polish (Phase 8)**: Depends on US1–US5 complete. T028 / T029 [P]; T030 is post-merge.

### User Story Dependencies

- **US1 (P1, MVP)**: Foundation of all others. The substantive change. No upstream story dependencies; depends on Setup.
- **US2 (P1)**: Depends on US1 (verifies the post-cleanup corpus). Independently testable via `bin/pilgrimage` against the post-migration files.
- **US3 (P1)**: Depends on US1 (diffs the post-cleanup pairs). Independently testable via per-pair `diff`.
- **US4 (P2)**: Depends on US1 + US2 + US3 (CI exercises all three). Independently testable via the GitHub Actions matrix.
- **US5 (P2)**: Independent of US1–US4 — verifies a documentation read against `PLAN.md` §8, which exists at `9a5de4a` regardless of whether the migration has happened. Could be run any time after Setup.

### Within Each User Story

- **US1 (Phase 3)**: T008 first if using spike-apply; otherwise T008–T019 in parallel. T020 last (corpus-wide verification).
- **US2 (Phase 4)**: T021 first (read-only fixture diff); T022 and T023 sequential after.
- **US3 (Phase 5)**: T024 (single per-pair-diff loop).
- **US4 (Phase 6)**: T025 then T026.
- **US5 (Phase 7)**: T027.
- **Polish (Phase 8)**: T028 and T029 [P]; T030 post-merge.

### Parallel Opportunities

- All Setup tasks (T001–T007) are [P] — independent reads / baselines.
- All US1 file-migration tasks (T008–T019) are [P] — different files, no interdependency. Twelve-way parallel in principle. In practice the contributor likely commits per-pair (koan NN + solution NN together) for cleanest review history.
- T024 (US3 parity diff) [P] with T021 (US2 fixture diff) and T028 (Polish diff scope) — three different read-only checks against the post-migration corpus.
- T028 / T029 [P] within Polish.

---

## Parallel Example: User Story 1 (file migrations)

```bash
# Launch all 12 file migrations together (different files, identical recipe per file):
Task: "Apply spike to koans/00_about_asserts.rexx (or hand-edit per contracts/assertion_line_shape.md)"
Task: "Migrate koans/01_about_strings.rexx per contracts/assertion_line_shape.md"
Task: "Migrate koans/02_about_variables.rexx per contracts/assertion_line_shape.md"
Task: "Migrate koans/03_about_expressions.rexx per contracts/assertion_line_shape.md"
Task: "Migrate koans/04_about_clauses.rexx per contracts/assertion_line_shape.md"
Task: "Migrate koans/05_about_say.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/00_about_asserts.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/01_about_strings.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/02_about_variables.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/03_about_expressions.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/04_about_clauses.rexx per contracts/assertion_line_shape.md"
Task: "Migrate solutions/05_about_say.rexx per contracts/assertion_line_shape.md"

# Then T020 sequentially (corpus-wide grep verification).
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T007).
2. Skip Phase 2 (no foundational work).
3. Complete Phase 3: User Story 1 (T008–T020).
4. **STOP and VALIDATE**: At T020, the corpus is mechanically conformant per FR-001 / FR-002 / FR-003 / FR-013 / FR-014 and `verify_solutions` + `lint_citations` are green. US1 is independently shippable as a viable MVP — even without US2 / US3 / US4 / US5 verification, the user-visible cleanup is delivered.
5. The remaining stories (US2, US3, US4, US5) verify the same delivery from different angles; they are not separable shipments.

### Incremental Delivery

M2.5 ships as one atomic delivery (one PR), not as separable increments. The "incremental" shape would be:

1. Complete Setup → preconditions baselined.
2. Complete US1 → corpus migrated (the substantive value).
3. Complete US2 → behavior bit-identity proved.
4. Complete US3 → solution-koan parity confirmed.
5. Complete US4 → CI matrix green.
6. Complete US5 → §8 ratification confirmed.
7. Complete Polish → diff-scope clean, end-to-end run green.
8. Merge → the spike at `stash@{0}` is dropped post-merge.

Each step builds on the prior; no step is shippable without the prior steps complete.

### Parallel Team Strategy

With multiple developers (or LLM workers):

1. One developer completes Phase 1 (Setup) — baselines must be captured before edits begin.
2. Once Phase 1 is done, file migrations (T008–T019) can be parallelized:
   - Developer A: koans 00–02
   - Developer B: koans 03–05
   - Developer C: solutions 00–02
   - Developer D: solutions 03–05
3. T020 requires all migrations complete — one developer runs the corpus-wide verification.
4. Verification phases (US2, US3) can be run in parallel by separate developers.
5. CI phase (US4) is single-stream (one push, one CI run).
6. US5 (doc read) can be done by anyone, any time after Setup.

In practice for this 12-file scope, single-developer sequential execution is fine — the per-file work is small and the parallel coordination overhead is not worth it.

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks.
- [Story] label maps task to specific user story for traceability.
- Each user story is independently testable per the spec's user-story acceptance scenarios.
- Per-pair commits (koan NN + solution NN together) preserve the SC-009 parity invariant at every commit on the branch — recommended granularity but not mandated.
- After every file migration, spot-check via `bin/pilgrimage` is wise but not strictly required; T020 is the canonical post-migration verification.
- The runner stdout fixture (T021) is the bit-identity ground truth; if T021 fails, the cleanup has introduced behavioral drift somewhere — investigate before all else.
- T030 (spike drop) is a post-merge cleanup; the spike is preserved through the PR review window in case a reviewer wants to compare against it.
- Avoid: bulk regex replacement across files (the per-file path literal in the wrapper is hard to template safely); committing US1 without US3 verified (the parity invariant is the project's project-wide read-aloud invariant).
