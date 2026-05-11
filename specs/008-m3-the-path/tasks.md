# Tasks: M3 — The Path

**Feature**: `008-m3-the-path`
**Input**: Design documents in `specs/008-m3-the-path/`
**Prerequisites**: plan.md, spec.md (US1–US6), research.md, data-model.md, contracts/{runner,scripture_library,koan_directives}.md, quickstart.md

**Tests**: Not authored as separate tasks. The spec does not request unit/contract tests; verification flows through existing mechanical gates (`bin/verify_solutions`, `bin/lint_citations`, `runner-smoke`) and the quickstart probes (US3 phase tasks).

**Organization**: One phase per user story (US1–US6) plus Setup, Foundational, and Polish. Stage II infrastructure (`lib/scripture.rexx`, runner extension) is foundational because every scripture-bound koan in US1/US2 and every probe in US3 depends on it (research.md §6).

## Format

`- [ ] T### [P?] [Story?] Description with file path`

- `[P]` = parallelizable (different files, no dependency on incomplete tasks)
- `[USn]` = user-story phase task only (omitted on Setup / Foundational / Polish)

---

## Phase 1: Setup

**Purpose**: Confirm baseline and repoint agent context.

- [X] T001 Verify baseline at `main` HEAD: M2.5 merged (commit `6dc15fb` reachable), working tree clean (`git status`), and the M2 6-station runner-smoke fixture matches `bin/pilgrimage` stdout (sanity probe before any M3 edit lands)
- [X] T002 Update `CLAUDE.md` "Active feature plan" pointer from `specs/007-koan-line-shape/plan.md` to `specs/008-m3-the-path/plan.md` (plan.md §Phase 1 step 4)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Scripture library + runner emission pass. Blocks every scripture-bound koan in US1 (07), US2 (12, 14) and every US3 probe. Plan.md §Phase 2 task preview; research.md §6 macro ordering Commit A + Commit B.

**⚠️ CRITICAL**: No user story work in US1/US2/US3 can land scripture bindings or probe scripture emission until this phase completes.

- [X] T003 [P] Author `lib/scripture.rexx` per `contracts/scripture_library.md`: one-verb dispatcher (`CALL 'lib/scripture.rexx' 'fetch', key`), seven keys `humans_not_machines` / `least_astonishment` / `everything_is_string` / `read_aloud` / `consistency` / `whitespace_matters_just_enough` / `numbers_are_strings_too` (FR-010, research.md §2 working table), TAB-separated `<principle>'09'x<citation>` return, empty string on unknown key, Regina built-ins only (Constitution Principle II). **Citation hygiene**: before commit, manually resolve each of the seven scripture-library citations against `docs/cowlishaw_index.md`. The working rows are listed in research.md §2 (§1.3 p. 5; §1.4 p. 7; §2.3 p. 25; §2.11 p. 137); research flags `§2.11, p. 137` for `numbers_are_strings_too` as needing fresh verification — locate the actual `**Page:**` row for arithmetic-precision content under §2.11 and update the citation if it does not match. Record the resolved index row reference in a comment beside each scripture entry. Note that `bin/lint_citations` does NOT scan `lib/scripture.rexx` (M2.4 scope is `koans/`/`solutions/` only) — this manual verification is the only citation gate for scripture-library entries.
- [X] T004 Sanity-check `lib/scripture.rexx` via `regina -e "CALL 'lib/scripture.rexx' 'fetch', 'least_astonishment'; SAY RESULT"` (expect principle TAB citation) and `regina -e "CALL 'lib/scripture.rexx' 'fetch', 'unknown_key'; SAY RESULT"` (expect empty); confirms quickstart Probe 9
- [X] T005 Extend `lib/pilgrimage.rexx` with `scripture_for_failure: PROCEDURE` implementing the FR-024 block-scoped backward scan per research.md §1 sketch: load koan source into `lines.` stem, walk from `fail_line − 1` to 1, halt on first `Scripture: <key>` line (after stripping leading `*`) or first `/*` line; return the key on directive hit, empty string on `/*` hit or scan exhaustion
- [X] T006 Wire the emission point in `lib/pilgrimage.rexx` between the captured failed-koan stdout (current location around `lib/pilgrimage.rexx:96–101` per data-model.md "Implementation notes") and the station-list `CALL`. Three sub-steps: **(a)** Parse the captured `failed_output` line-by-line for the `Damaged at: <file>, line N` diagnostic emitted by `lib/meditation.rexx` and extract `N` as `fail_line`. If the diagnostic line is absent (the koan aborted with a SYNTAX condition before any meditation diagnostic, per contracts/runner.md §"Scripture-emission pass" emit-decision table row 4), skip the scripture pass entirely and emit nothing. **(b)** Call `scripture_for_failure(koan_path, fail_line)` from T005; if it returns the empty string, emit nothing. **(c)** On a non-empty key returned by T005: `CALL 'lib/scripture.rexx' 'fetch', key`, split `RESULT` on `'09'x` into `(principle, citation)`. If `RESULT` is the empty string (unknown key fallback), emit nothing. Otherwise emit the FR-012 two-line block — line 1 `From the Bathonian (<citation>):`, line 2 principle indented two spaces, no surrounding blank lines, no trailing punctuation.
- [X] T007 Confirm non-scripture-bound failure path is byte-identical to M2: introduce a deliberate wrong fill in any Stage I koan (e.g., `koans/00_about_asserts.rexx`), capture `bin/pilgrimage` stdout, diff against pre-T005 stdout — must be empty (Stage I files have no `Scripture:` directives so the new scan returns empty and emits nothing). Revert the wrong fill.

**Checkpoint**: Scripture library and runner emission pass are ready; US1, US2, US3 can begin.

---

## Phase 3: US1 — Pilgrim walks Stage II (control flow) (Priority: P1) 🎯 MVP

**Goal**: Six new Stage II koans (06–11) with matching solutions, authored in M2.5 cleaned shape, teaching IF/SELECT/DO/ITERATE+LEAVE/SIGNAL/INTERPRET from Cowlishaw §2.7. Koan 07 binds `Scripture: least_astonishment`. Every koan and its matching solution carry at least three teaching comment blocks and at least four assertions (SC-011 floor; applies to every solution-authoring task in this phase, not only T008).

**Independent Test**: Apply solutions 06–11 to their matching koans on a fresh checkout, run `bin/pilgrimage` — runner advances through stations 00–11 without error, stops at the first blank in `koans/12_about_string_functions.rexx`. Per-koan: solve N → runner stops at N+1.

Solutions first (Constitution Principle I — Solution-First Development; all different files, parallel):

- [X] T008 [P] [US1] Write `solutions/06_about_if.rexx` teaching IF/THEN/ELSE per Cowlishaw §2.7 (locate exact page in `docs/cowlishaw_index.md`); M2.5 cleaned shape (single `n = 0` at top, three-arg `m:` wrapper at foot passing path + `n` + `SIGL` to `lib/meditation.rexx`); station subtitle "At the Branch of the Road" (PLAN §11)
- [X] T009 [P] [US1] Write `solutions/07_about_select.rexx` teaching SELECT/WHEN/OTHERWISE/END per Cowlishaw §2.7 (`docs/cowlishaw_index.md`); include one `Scripture: least_astonishment` directive in the teaching block that turns on the OTHERWISE-required principle (FR-024, research.md §5); station subtitle "Of Many Ways"; M2.5 shape
- [X] T010 [P] [US1] Write `solutions/08_about_do_loops.rexx` teaching DO group / controlled DO / WHILE / UNTIL / FOREVER per Cowlishaw §2.7; station subtitle "The Returning of the Path"; M2.5 shape
- [X] T011 [P] [US1] Write `solutions/09_about_iterate_leave.rexx` teaching ITERATE and LEAVE per Cowlishaw §2.7 (two separate index rows); station subtitle "Of Skipping and Leaving" (research.md §4); M2.5 shape
- [X] T012 [P] [US1] Write `solutions/10_about_signal.rexx` teaching `SIGNAL labelname` non-local transfer per Cowlishaw §2.7 (NOT `SIGNAL ON` — that is Stage VI, FR-020); station subtitle "When the Path Bends"; M2.5 shape
- [X] T013 [P] [US1] Write `solutions/11_about_interpret.rexx` teaching INTERPRET (runtime string evaluation) per Cowlishaw §2.7; station subtitle "What is Spoken Becomes Done"; M2.5 shape

Derive koans from solutions (Principle I: koan = solution with answers replaced by `FILL_ME_IN`; per-pair the only diff is FILL_ME_IN ↔ value plus `'solutions/...'` ↔ `'koans/...'` in the `m:` wrapper):

- [X] T014 [P] [US1] Derive `koans/06_about_if.rexx` from `solutions/06_about_if.rexx` by replacing each canonical answer with `FILL_ME_IN`; switch the `m:` wrapper's path argument from `'solutions/06_about_if.rexx'` to `'koans/06_about_if.rexx'`; sanity-check the solution still runs green directly via `regina solutions/06_about_if.rexx` (zero output, RC 0). Runner-based stop/advance verification is deferred to T021's Stage II walk-through (the new koan must be in the manifest first, per T020)
- [X] T015 [P] [US1] Derive `koans/07_about_select.rexx` from `solutions/07_about_select.rexx` preserving the `Scripture: least_astonishment` directive byte-for-byte; switch `m:` wrapper path; sanity-check the solution via direct `regina` invocation. Runner probe deferred to T021
- [X] T016 [P] [US1] Derive `koans/08_about_do_loops.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T021
- [X] T017 [P] [US1] Derive `koans/09_about_iterate_leave.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T021
- [X] T018 [P] [US1] Derive `koans/10_about_signal.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T021
- [X] T019 [P] [US1] Derive `koans/11_about_interpret.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T021

Manifest update + Stage II walk-through:

- [X] T020 [US1] Extend `koans/path_to_enlightenment.rexx` with `koans.7` through `koans.12` naming `koans/06_about_if.rexx` … `koans/11_about_interpret.rexx`; bump `koans.0` to `12` (interim — Stage III will raise it to 18 in T034); manifest format unchanged from `specs/002-m2-walking-skeleton/contracts/path_manifest.md`
- [X] T021 [US1] Stage II walk-through: starting from a corpus where Stage I is solved and Stage II is blank, run `bin/pilgrimage` six times — solving 06 → stops at 07, solving 07 → stops at 08, …, solving 11 → stops at 12 (US1 Acceptance Scenarios 1–3). Wrong-fill probe in any Stage II koan emits meditation diagnostic naming koan, ordinal, expected vs received, source line (Scenario 4)

**Checkpoint**: US1 (MVP) functionally complete and independently testable.

---

## Phase 4: US2 — Pilgrim walks Stage III (built-in toolbox) (Priority: P1)

**Goal**: Six new Stage III koans (12–17) with matching solutions teaching `Cowlishaw §2.9` built-in families. Koan 12 binds `Scripture: everything_is_string`; koan 14 binds `Scripture: numbers_are_strings_too`. Every koan and its matching solution carry at least three teaching comment blocks and at least four assertions (SC-011 floor; applies to every solution-authoring task in this phase).

**Independent Test**: Apply solutions 06–17, run `bin/pilgrimage` — full 18-row station list all `[ ok ]`, summary `Stations walked: 18 of 18.`, closing benediction, exit 0. Per-koan: solve N → runner stops at N+1; solving 17 reaches the benediction.

Solutions (parallel — different files):

- [X] T022 [P] [US2] Write `solutions/12_about_string_functions.rexx` teaching LENGTH, SUBSTR, POS, LEFT, RIGHT, COPIES, TRANSLATE per Cowlishaw §2.9 (resolve each built-in's row in `docs/cowlishaw_index.md` with child-heading citation suffix per Principle III); include `Scripture: everything_is_string` directive in the teaching block where the principle illuminates (research.md §5); station subtitle "Of Letters and Their Manipulation"; M2.5 shape
- [X] T023 [P] [US2] Write `solutions/13_about_word_functions.rexx` teaching WORD, WORDS, WORDPOS, WORDLENGTH, SUBWORD, WORDINDEX per Cowlishaw §2.9; station subtitle "Of Words and Their Counting"; M2.5 shape
- [X] T024 [P] [US2] Write `solutions/14_about_arithmetic_functions.rexx` teaching ABS, MAX, MIN, TRUNC, FORMAT, SIGN per Cowlishaw §2.9 (default NUMERIC settings — Edge Case in spec); include `Scripture: numbers_are_strings_too` directive (research.md §5); station subtitle "Of Numbers and Their Shape"; M2.5 shape
- [X] T025 [P] [US2] Write `solutions/15_about_conversion_functions.rexx` teaching D2X, X2D, C2X, X2C, B2X, X2B, D2C, C2D per Cowlishaw §2.9; station subtitle "Between One Form and Another"; M2.5 shape
- [X] T026 [P] [US2] Write `solutions/16_about_bit_functions.rexx` teaching BITAND, BITOR, BITXOR per Cowlishaw §2.9; station subtitle "Down to the Bits"; M2.5 shape
- [X] T027 [P] [US2] Write `solutions/17_about_misc_functions.rexx` teaching DATATYPE, DATE, TIME, RANDOM, and the ADDRESS *built-in* (returns current environment name — NOT the ADDRESS instruction, FR-020); station subtitle "Of Time and Chance"; M2.5 shape

Derive koans:

- [X] T028 [P] [US2] Derive `koans/12_about_string_functions.rexx` from its solution preserving the `Scripture: everything_is_string` directive byte-for-byte; switch the `m:` wrapper's path argument to `'koans/12_about_string_functions.rexx'`; sanity-check the solution still runs green via direct `regina solutions/12_about_string_functions.rexx`. Runner-based stop/advance verification is deferred to T035's Stage III walk-through (the new koan must be in the manifest first, per T034)
- [X] T029 [P] [US2] Derive `koans/13_about_word_functions.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T035
- [X] T030 [P] [US2] Derive `koans/14_about_arithmetic_functions.rexx` from its solution preserving the `Scripture: numbers_are_strings_too` directive byte-for-byte; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T035
- [X] T031 [P] [US2] Derive `koans/15_about_conversion_functions.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T035
- [X] T032 [P] [US2] Derive `koans/16_about_bit_functions.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T035
- [X] T033 [P] [US2] Derive `koans/17_about_misc_functions.rexx` from its solution; switch `m:` wrapper path; sanity-check via direct `regina`. Runner probe deferred to T035

Manifest update + Stage III walk-through:

- [X] T034 [US2] Extend `koans/path_to_enlightenment.rexx` with `koans.13` through `koans.18` naming `koans/12_about_string_functions.rexx` … `koans/17_about_misc_functions.rexx`; set `koans.0 = 18` (FR-009)
- [X] T035 [US2] Stage III walk-through: from a Stage I+II-solved corpus, solving 12 → stops at 13, …, solving 17 → reaches the closing benediction "The pilgrim has walked the foundation, the path, and the tools. The path opens further." (US2 Acceptance Scenarios 1–4)

**Checkpoint**: All 12 M3 koans + solutions in place; manifest at 18; runner walks 18 stations.

---

## Phase 5: US3 — Scripture amplifies failure (Priority: P1)

**Goal**: Verify the scripture mechanic (foundational T003–T006) actually surfaces principle text on bound-failure and stays silent otherwise.

**Independent Test**: For each of 07, 12, 14, deliberately introduce a wrong fill on the bound assertion; capture stdout; confirm the FR-012 two-line block appears. For an unbound koan and for the fully-solved corpus, confirm no scripture text appears.

- [X] T036 [US3] Quickstart Probe 1a — wrong fill on the bound assertion in `koans/07_about_select.rexx`: confirm `bin/pilgrimage` stdout contains, between the indented meditation diagnostic and the station-list output, exactly `From the Bathonian (Cowlishaw §1.4, p. 7):` followed by `  A program should behave the way its reader expects.` (citation/text per `lib/scripture.rexx`'s `least_astonishment` row); revert
- [X] T037 [US3] Quickstart Probe 1b — same probe on `koans/12_about_string_functions.rexx` (`everything_is_string`, Cowlishaw §1.3, p. 5) and `koans/14_about_arithmetic_functions.rexx` (`numbers_are_strings_too`, Cowlishaw §2.11 row); revert each
- [X] T038 [US3] Quickstart Probe 2 — wrong fill in a non-scripture-bound koan (e.g., `koans/06_about_if.rexx`): `grep -c 'From the Bathonian' /tmp/06_out` returns 0; failure output is identical in shape to Stage I (FR-012); revert
- [X] T039 [US3] Quickstart Probe 3 — fully-solved walk emits no scripture: `grep -c 'From the Bathonian'` on `bin/pilgrimage` stdout against the fully-solved corpus returns 0 (FR-013)
- [X] T040 [US3] Quickstart Probe 4 — count Scripture-bound koans: `grep -lE '^.*Scripture: ' koans/0[6-9]*.rexx koans/1[0-7]*.rexx | wc -l` returns ≥ 3 (FR-011, SC-006); listed files match the working selection 07, 12, 14
- [X] T041 [US3] Quickstart Probe 5 — directive parity: `diff <(grep -E '^.*Scripture: ' koans/07_about_select.rexx) <(grep -E '^.*Scripture: ' solutions/07_about_select.rexx)` empty; repeat for 12 and 14

**Checkpoint**: US3 functionally complete. SC-006 satisfied.

---

## Phase 6: US4 — Solutions ship in lockstep with koans (Priority: P1)

**Goal**: 18 of 18 solutions pass `bin/verify_solutions`; the M2.5 SC-009 solution-koan parity invariant extended to Stages II–III.

**Independent Test**: `bin/verify_solutions` exits 0 with all-green report; `diff` of every new koan/solution pair shows only FILL_ME_IN ↔ value substitutions + the `'koans/...'`/`'solutions/...'` wrapper-path substitution.

- [X] T042 [US4] Run `bin/verify_solutions`; expect "18 of 18 solutions passed." (or M2 equivalent report shape) and exit 0 (FR-014, SC-003)
- [X] T043 [US4] For each of the twelve new pairs (06–17), run `diff koans/NN_about_*.rexx solutions/NN_about_*.rexx` and confirm hunks consist solely of FILL_ME_IN ↔ value substitutions plus the single `'koans/'` ↔ `'solutions/'` substitution in the `m:` wrapper's third argument (SC-010)
- [X] T044 [US4] Confirm M2.5 shape across `koans/0[6-9]*.rexx koans/1[0-7]*.rexx solutions/0[6-9]*.rexx solutions/1[0-7]*.rexx`: each file has exactly one `n = 0` initializer at top, every assertion is a single `CALL m '<verb>', <arg1>, <arg2>`, and the `m:` wrapper is three-arg and passes `n` (5th) and `SIGL` (6th) to `lib/meditation.rexx` (FR-003, Acceptance Scenario 3)

**Checkpoint**: US4 complete. SC-003, SC-010 satisfied.

---

## Phase 7: US5 — Citations resolve against the Cowlishaw index (Priority: P1)

**Goal**: Every M3 citation passes `bin/lint_citations` (M2.2 canonical form + M2.4 index-existence join).

**Independent Test**: `bin/lint_citations` reports all-green; a fabricated citation in a sandbox copy is rejected.

- [X] T045 [US5] Run `bin/lint_citations`; expect `[ ok ]` on every file under `koans/` and `solutions/` and summary line `36/36 files passed lint.` (or M2.4 equivalent); exit 0 (FR-015, SC-004)
- [X] T046 [US5] Manual spot-check: pick 3 Stage II citations and 3 Stage III citations; for each, locate the cited (§N.N, page) pair in `docs/cowlishaw_index.md` in <30 seconds and confirm the row's `**Page:**` field equals the citation's page (SC-005)
- [X] T047 [US5] Negative spot-check: copy any Stage II/III koan, edit one citation to a fabricated (§N.N, page) pair (e.g., `§99.9, p. 999`), run `bin/lint_citations`; expect the script to reject with a citation-resolves-to-no-row error (M2.4 promise); delete the sandbox copy

**Checkpoint**: US5 complete. SC-004, SC-005 satisfied.

---

## Phase 8: US6 — Path manifest, station display, runner-smoke fixture (Priority: P2)

**Goal**: Regenerate the runner-smoke fixture for the 18-station walk; 6/6 CI checks green on both runners.

**Independent Test**: Push branch; observe GitHub Actions `success` on all six matrix steps; `diff -u tests/fixtures/runner_stdout.txt <(regina lib/pilgrimage.rexx)` against fully-solved corpus returns empty.

- [X] T048 [US6] Regenerate `tests/fixtures/runner_stdout.txt` per the research.md §3 recipe (`cp solutions/NN_about_*.rexx koans/NN_about_*.rexx` for 00–17, then `regina lib/pilgrimage.rexx > tests/fixtures/runner_stdout.txt`, then `git checkout -- koans/`). Confirm the file contains 18 station rows with `[  ok  ]`, summary line `Stations walked: 18 of 18.`, and closing benediction line `The pilgrim has walked the foundation, the path, and the tools. The path opens further.` (Clarifications Q3, FR-016)
- [ ] T049 [US6] Push branch: `git push -u origin 008-m3-the-path`; observe GitHub Actions `verify` workflow — 6 checks (`verify_solutions`, `lint_citations`, `runner-smoke`, each on `ubuntu-latest` and `macos-latest`) all conclude `success` (FR-018, SC-007)

**Checkpoint**: US6 complete. Milestone exit gate green.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [X] T050 M2.5 forward-style enforcement and station-subtitle uniqueness. **(a)** Forbidden-pattern greps: `grep -rE 'n = n \+ 1; *CALL m' koans/ solutions/` returns empty AND `grep -rE "CALL m '[a-z]+', [^,]+, [^,]+, n\b" koans/ solutions/` returns empty (FR-004, FR-005, SC-013). **(b)** Subtitle uniqueness check: `grep -h 'Station:' koans/*.rexx | sed 's/^[[:space:]]*\*\{0,1\}[[:space:]]*Station:[[:space:]]*//' | sort | uniq -d` returns empty (FR-007 "Subtitles MUST be unique across the manifest").
- [X] T051 Stage I read-only verification: `git diff main -- koans/0[0-5]_*.rexx solutions/0[0-5]_*.rexx lib/meditation.rexx lib/stations.rexx bin/ docs/cowlishaw_index.md` returns empty (research.md §8; FR-019)
- [X] T052 Final acceptance pass: walk `quickstart.md` end-to-end on a fresh checkout; confirm SC-001 through SC-014 are all met; cross-reference against spec § Out of Scope (no Stage IV–VI content leaked); re-check Constitution five principles per plan.md Post-Design Re-Check table

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies; starts immediately
- **Phase 2 (Foundational)**: depends on Phase 1; BLOCKS Phase 3 koan 07, Phase 4 koans 12 + 14, and all of Phase 5
- **Phase 3 (US1)**: depends on Phase 2 (for the scripture binding in 07); non-bound koans 06, 08, 09, 10, 11 technically could start after Setup, but practical ordering keeps everything in numeric order
- **Phase 4 (US2)**: depends on Phase 2 (scripture binding in 12, 14) and Phase 3 (manifest already extended through `koans.12`); per research.md §6 implementation ordering
- **Phase 5 (US3)**: depends on Phase 3 (koan 07) and Phase 4 (koans 12, 14)
- **Phase 6 (US4)**: depends on Phase 3 and Phase 4 (all 18 solutions exist)
- **Phase 7 (US5)**: depends on Phase 3 and Phase 4 (all 18 koans + solutions exist; lint scans both)
- **Phase 8 (US6)**: depends on Phase 3, Phase 4, AND Phase 5 (fixture regeneration must happen after all scripture content is in place, though the success-path fixture is scripture-independent per research.md §3)
- **Phase 9 (Polish)**: depends on every preceding phase

### Within Each User Story

- Solutions written before their derived koans (Constitution Principle I — Solution-First)
- All Stage II solutions/koans can complete before manifest entry (T020); avoids inter-task contention on the manifest
- Per-koan stop/advance verification is part of the koan-derivation task, not a separate task
- Story-level walk-through (T021, T035) is the integration check after all per-koan derivations land

### Parallel Opportunities

- T003 (`lib/scripture.rexx`) is independent of T005/T006 (`lib/pilgrimage.rexx`); both labeled [P]
- All Stage II solutions (T008–T013) are independent files — six-way [P]
- All Stage II koan derivations (T014–T019) are independent files once each matching solution exists — six-way [P]
- Same for Stage III solutions (T022–T027) and koan derivations (T028–T033)
- T020 (manifest) and T034 (manifest + bump `koans.0`) touch the same file — sequential
- US3 probes (T036–T041) operate on different koans and different stdout captures — can run [P] if desired but cheap enough to serialize

---

## Parallel Example: US1 Stage II Solutions

```bash
# After Phase 2 completes, launch six solution-authoring tasks together:
Task: "Write solutions/06_about_if.rexx teaching IF/THEN/ELSE per Cowlishaw §2.7"
Task: "Write solutions/07_about_select.rexx with Scripture: least_astonishment directive"
Task: "Write solutions/08_about_do_loops.rexx teaching DO group/WHILE/UNTIL/FOREVER"
Task: "Write solutions/09_about_iterate_leave.rexx teaching ITERATE and LEAVE"
Task: "Write solutions/10_about_signal.rexx teaching SIGNAL labelname (NOT SIGNAL ON)"
Task: "Write solutions/11_about_interpret.rexx teaching INTERPRET"

# Then launch six koan derivations together (each depends on its matching solution):
Task: "Derive koans/06_about_if.rexx from solutions/06_about_if.rexx"
Task: "Derive koans/07_about_select.rexx preserving Scripture: directive"
# ...
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Phase 1: Setup (T001–T002)
2. Phase 2: Foundational (T003–T007) — scripture library + runner emission
3. Phase 3: US1 (T008–T021) — Stage II koans 06–11
4. **STOP and VALIDATE**: Stage II walk-through (T021); 6 new stations visible in the runner
5. Demo: a pilgrim can now solve through station 11

### Incremental Delivery (per spec priority order)

1. Setup + Foundational → infrastructure ready
2. US1 (Stage II) → 12-station walk → demo
3. US2 (Stage III) → 18-station walk → demo
4. US3 (Scripture verification) → SC-006 satisfied
5. US4 (Solutions parity) → SC-003, SC-010 satisfied
6. US5 (Citations) → SC-004, SC-005 satisfied
7. US6 (Fixture + CI) → milestone exit gate green
8. Polish → final acceptance

Stories US3, US4, US5 are largely verification phases over the content shipped in US1/US2; they can run in parallel after US2 completes. US6 must follow US3 because the fully-solved fixture is regenerated only after every koan exists.

### Per-Koan Order (Constitution Principle I)

For each of the 12 new koans:

1. Draft teaching prose + Cowlishaw citation(s) + (if scripture-bound) the `Scripture: <key>` directive
2. Write the solution file; `regina solutions/NN_about_*.rexx` returns zero output (success path)
3. Derive the koan by replacing answers with `FILL_ME_IN`; update the `m:` wrapper's path argument from `solutions/...` to `koans/...`
4. Extend the manifest to include the new koan; `bin/pilgrimage` stops at the first blank with the expected diagnostic
5. Reapply the solution value to the koan; `bin/pilgrimage` advances past it
6. For scripture-bound koans (07, 12, 14): introduce a deliberate wrong fill on the bound assertion; the FR-012 two-line block appears between the meditation diagnostic and the station-list output; revert

---

## Task summary

- **Total**: 52 tasks
- **Setup**: 2 (T001–T002)
- **Foundational**: 5 (T003–T007)
- **US1 (Stage II, P1 MVP)**: 14 (T008–T021) — 6 solutions [P], 6 koans [P], 1 manifest, 1 walk-through
- **US2 (Stage III, P1)**: 14 (T022–T035) — 6 solutions [P], 6 koans [P], 1 manifest, 1 walk-through
- **US3 (Scripture, P1)**: 6 (T036–T041)
- **US4 (Solutions parity, P1)**: 3 (T042–T044)
- **US5 (Citations, P1)**: 3 (T045–T047)
- **US6 (Fixture + CI, P2)**: 2 (T048–T049)
- **Polish**: 3 (T050–T052)
- **Parallel-marked**: 25 tasks ([P])

**Suggested MVP scope**: Phase 1 + Phase 2 + Phase 3 (US1) = 21 tasks. Delivers a 12-station path through Stage II. Stage III is the second half of the milestone (PLAN §10 names "Stages II *and* III"); shipping only Stage II would not satisfy the milestone definition but does represent a coherent intermediate demo state.

**Format validation**: every task above follows the strict checklist format: `- [ ]` checkbox, `T###` sequential ID, `[P]` only where parallel, `[USn]` only on user-story phase tasks (T008–T049), specific file path or invocation in every description.
