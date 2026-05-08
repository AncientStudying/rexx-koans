---

description: "Tasks for M2 — Walking Skeleton"
---

# Tasks: M2 — Walking Skeleton

**Input**: Design documents from `/specs/002-m2-walking-skeleton/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Beyond `bin/verify_solutions`, `bin/lint_citations`, and the
CI runner-smoke fixture (FR-014, FR-017) the spec does not request a
separate unit-test layer. No standalone unit-test tasks are generated.
The acceptance gates ARE the tests.

**Organization**: Tasks are grouped by user story so each story can be
implemented and validated independently. Within US1, work follows
six vertical slices in curriculum order (Decision 8, research.md):
solution → koan, koan-by-koan, 00 through 05.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Single-project layout (per plan.md §Project Structure). REXX sources
live at `lib/`, `bin/`, `koans/`, `solutions/`. Fixtures at
`tests/fixtures/`. CI under `.github/workflows/`. No `src/` layer.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Clear M1 throwaway artifacts and establish M2 directory layout.

- [ ] T001 Remove M1 throwaway prototype files: delete `koans/00_about_smoke.rexx` and `solutions/00_about_smoke.rexx` (per spec Assumptions; PLAN.md §10)
- [ ] T002 [P] Create the `tests/fixtures/` directory at the repository root (placeholder, real fixture content arrives in T028)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The expanded assertion vocabulary, path manifest, launcher,
extended verify/lint, and a minimal walking runner. These MUST be
complete before any Stage I content can be written or walked.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 Expand assertion library `lib/meditation.rexx` to a four-kind dispatcher (`'eq'`, `'neq'`, `'true'`, `'datatype'`) per contracts/meditation.md, preserving the M1 FILL_ME_IN literal-string detection (ADR-004) and the `CALL kind, arg1, arg2, koan_file, n, line` signature (Decision 1, research.md)
- [ ] T004 [P] Create the path manifest `koans/path_to_enlightenment.rexx` populating `koans.0 = 6` and `koans.1`–`koans.6` with the Stage I files in curriculum order (Decision 5, research.md; contracts/path_manifest.md)
- [ ] T005 [P] Create the POSIX shell launcher `bin/pilgrimage` per contracts/pilgrimage_launcher.md (locate `regina`, resolve repo root, `LC_ALL=C`, `exec regina lib/pilgrimage.rexx "$@"`); set executable bit
- [ ] T006 Implement runner skeleton `lib/pilgrimage.rexx` per contracts/runner.md core behavior (steps 1–3): `CALL` the manifest, validate it is non-empty, walk each koan via `regina <path>` subprocess capturing stdout+stderr to a temp file, stop on first non-zero RC and emit the captured stdout, exit 0 on full pass, exit non-zero on failure with the koan's RC. Banner / station list / benediction are deferred to later phases. Depends on T003, T004
- [ ] T007 [P] Audit and update `bin/verify_solutions` to handle the four-kind dispatcher signature: confirm subprocess + RC-based pass/fail logic still works with the new `CALL m kind, arg1, arg2, n` koan-side pattern; update only if the M1 implementation hard-coded smoke paths or single-kind assumptions (contracts/verify_solutions.md)
- [ ] T008 [P] Extend `bin/lint_citations` to also verify each koan has exactly one `Station: <text>` directive in its leading comment block, in addition to the existing `Cowlishaw §N.N, p. NN` citation check (Decision 2, research.md; contracts/lint_citations.md). Failure reasons must be specific (`MISSING Station: directive`, `MULTIPLE Station: directives`)

**Checkpoint**: Foundation ready — assertion dispatcher, manifest,
launcher, minimal runner, extended lint and verify all present.
Stage I content can now be written.

---

## Phase 3: User Story 1 - Walk the Foundation Stage end-to-end (Priority: P1) 🎯 MVP

**Goal**: Six Stage I koans (`00_about_asserts` through `05_about_say`)
each shipping with a passing solution, teaching comments with
citations, a `Station:` subtitle, and at least one `FILL_ME_IN`. A
pilgrim with Regina installed can walk the full path on macOS using
only README guidance and the koan teaching prose.

**Independent Test**: On a fresh clone with Regina installed, running
`./bin/pilgrimage` halts at the first FILL_ME_IN; replacing the blank
with the value the teaching block names lets the runner advance; with
all six koans solved the runner exits zero and prints the closing
benediction. `regina bin/verify_solutions` reports 6/6 passing.
`regina bin/lint_citations` reports 6/6 passing.

Six vertical slices in curriculum order; within each slice the
solution is written and verified BEFORE the koan derives `FILL_ME_IN`
blanks (Constitution Principle I).

### Slice 1 — `00_about_asserts` (Meta: how the koans work)

- [ ] T009 [P] [US1] Create `solutions/00_about_asserts.rexx` exercising every assertion kind (`'eq'`, `'neq'`, `'true'`, `'datatype'`); confirm it passes via `regina bin/verify_solutions`
- [ ] T010 [P] [US1] Create `koans/00_about_asserts.rexx` by deriving FILL_ME_INs from `solutions/00_about_asserts.rexx`; include `Station: <subtitle>` directive and one `Cowlishaw §N.N, p. NN`-cited teaching block per concept group (FR-011); verify with `regina bin/lint_citations`. Depends on T009

### Slice 2 — `01_about_strings` (§2.1, §2.2 — everything is a string)

- [ ] T011 [P] [US1] Create `solutions/01_about_strings.rexx` (string literals, length, single vs double quote, all values are strings); pass `verify_solutions`
- [ ] T012 [P] [US1] Create `koans/01_about_strings.rexx` with FILL_ME_INs, `Station:` directive, teaching blocks per concept group with Cowlishaw §2.1 / §2.2 citations; pass `lint_citations`. Depends on T011

### Slice 3 — `02_about_variables` (§2.5 — assignment, uninitialized symbols, case)

- [ ] T013 [P] [US1] Create `solutions/02_about_variables.rexx` (assignment, uninitialized symbol equals its uppercase name, `UPPER`/case behavior); pass `verify_solutions`
- [ ] T014 [P] [US1] Create `koans/02_about_variables.rexx` with FILL_ME_INs, `Station:` directive, Cowlishaw §2.5 citations; pass `lint_citations`. Depends on T013

### Slice 4 — `03_about_expressions` (§2.3 — arithmetic, comparison, logical, concatenation)

- [ ] T015 [P] [US1] Create `solutions/03_about_expressions.rexx` (arithmetic operators, comparison `=`/`\=`/`==`, logical `&`/`|`/`\`, concatenation by abuttal vs. by blank); pass `verify_solutions`
- [ ] T016 [P] [US1] Create `koans/03_about_expressions.rexx` with FILL_ME_INs, `Station:` directive, Cowlishaw §2.3 citations covering each concept group; pass `lint_citations`. Depends on T015

### Slice 5 — `04_about_clauses` (§2.4 — clauses, comments, continuation, semicolons)

- [ ] T017 [P] [US1] Create `solutions/04_about_clauses.rexx` (clause-as-line, semicolon separator, comma continuation, `/* ... */` comments); pass `verify_solutions`
- [ ] T018 [P] [US1] Create `koans/04_about_clauses.rexx` with FILL_ME_INs, `Station:` directive, Cowlishaw §2.4 citations; pass `lint_citations`. Depends on T017

### Slice 6 — `05_about_say` (§2.7 — output and expression evaluation)

- [ ] T019 [P] [US1] Create `solutions/05_about_say.rexx` (`SAY` expression evaluation; concatenation in `SAY` context); pass `verify_solutions`
- [ ] T020 [P] [US1] Create `koans/05_about_say.rexx` with FILL_ME_INs, `Station:` directive, Cowlishaw §2.7 citations; pass `lint_citations`. Depends on T019

### Runner enrichment + onboarding

- [ ] T021 [US1] Extend `lib/pilgrimage.rexx`: on full-pass loop completion (every station green) print the closing benediction `The pilgrim has walked the foundation. The path opens further.` and exit 0 (FR-004; Decision 6, research.md)
- [ ] T022 [US1] Write/update `README.md` per Decision 7, research.md — four sections: What this is / Install Regina / Walk the path / Read further. Include the Internet Archive link to *The REXX Language* 2nd edition (FR-016)
- [ ] T023 [US1] Manually validate quickstart.md Steps 1–4 on a fresh checkout: `./bin/pilgrimage` stops at koan 00; with all six koans hand-solved using only teaching comments, `./bin/pilgrimage` exits 0 and prints the benediction (US1 acceptance scenarios 1–3)

**Checkpoint**: Stage I curriculum is walkable end-to-end. The MVP
pilgrim experience works on macOS. `verify_solutions` is 6/6 green
and `lint_citations` is 6/6 green.

---

## Phase 4: User Story 2 - Resume at the first unsolved koan (Priority: P2)

**Goal**: A re-run of the runner with koans 00–02 already solved
advances past them silently and stops at the first FILL_ME_IN in koan
03 (or wherever the next blank lives), with no persisted state file.

**Independent Test**: Solve koans 00–02 to passing state, leave 03
with an unfilled `FILL_ME_IN`, run `./bin/pilgrimage`. The runner
must report its first failure inside koan 03 (not earlier), exit
non-zero, and never have emitted FILL_ME_IN diagnostics for koans
00–02. A second invocation with no source changes must produce
identical stdout (state re-derived from sources each run).

Resume is a property of the walk-and-discover runner already built in
Phase 2; this phase is validation only — no new implementation should
be required. If a defect is uncovered, it gets fixed inside
`lib/pilgrimage.rexx`.

- [ ] T024 [US2] Validate resume behavior end-to-end: solve koans 00–02 in working tree, leave 03 with one FILL_ME_IN, run `./bin/pilgrimage`, confirm the runner reports its first failure inside `koans/03_about_expressions.rexx`, exits non-zero, and emitted no FILL_ME_IN diagnostics for koans 00–02. Re-run with no source changes; stdout must be byte-identical to the first invocation (US2 acceptance scenarios 1–3; FR-002; SC-004)

**Checkpoint**: Resume works as a natural property of the runner;
the pilgrim's mid-pilgrimage re-run experience is verified.

---

## Phase 5: User Story 3 - Station display shows progress (Priority: P3)

**Goal**: The pilgrim sees a fixed-pitch station list with `[  ok  ]`,
`[ here ]`, and blank markers, plus a "Stations walked: X of Y" summary
line, every time the runner runs. Output is monochrome (no ANSI), ASCII
only, LF line endings, deterministic across macOS and Ubuntu.

**Independent Test**: Run `./bin/pilgrimage` against a partially solved
state — six `[  ok  ]` markers on full pass; `[ here ]` against the
failing koan and blanks for those not-yet-walked on partial fail. The
summary line names the failure topic on a damaged run and is silent
about damage on a clean run. `./bin/pilgrimage | od -c | grep -c '\\033'`
must return 0 (no ANSI escapes).

- [ ] T025 [P] [US3] Implement station-display module `lib/stations.rexx` per contracts/stations.md: `extract_subtitle(koan_path)` (line-by-line scan of the leading comment block for `Station: <text>`, 50-line safety bound, returns empty string if absent) and `render(station_records, total)` (fixed-pitch list with `[  ok  ]` / `[ here ]` / blank markers, topic column padded to max-width across the manifest, subtitle column, summary line with optional `Karma damaged at: <topic>.` clause). ASCII-only, LF, spaces (no tabs), no ANSI
- [ ] T026 [US3] Wire station-display calls into `lib/pilgrimage.rexx` per contracts/runner.md: print the `THE PATH OF REXX` banner, accumulate `(seq, topic, subtitle, status)` records as the walk proceeds, after stop or completion render via `lib/stations.rexx`, then on failure emit the captured koan stdout indented to align with the station list, then the summary line. Subtitles are extracted from each koan file at render time (Decision 2, research.md). Depends on T025
- [ ] T027 [US3] Confirm monochrome output: `./bin/pilgrimage | od -c | grep -c '\\033'` returns 0 in both passing and failing cases (US3 acceptance scenario 3; FR-008)

**Checkpoint**: The runner's full pilgrim-facing output — banner +
station list + diagnostic + summary + (on full pass) benediction —
matches contracts/runner.md exactly.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Lock the cross-platform contract (FR-014, FR-017, SC-006)
and verify edge cases.

- [ ] T028 Capture the runner stdout for a fully-solved Stage I walk into `tests/fixtures/runner_stdout.txt` per the procedure in quickstart.md "CI parity check" (build a `koans-solved/` working dir from `solutions/`, mirror the manifest with rewritten paths, `LC_ALL=C regina lib/pilgrimage.rexx > runner-out.txt`, `tr -d '\r' < runner-out.txt > tests/fixtures/runner_stdout.txt`, restore the original manifest). Verify ASCII-only, LF, no volatile values (Decision 4, research.md)
- [ ] T029 Extend `.github/workflows/verify.yml` per contracts/ci_workflow.md: matrix `[ubuntu-latest, macos-latest]` with `fail-fast: false`; install Regina (apt on Ubuntu, brew on macOS); steps for `verify_solutions`, `lint_citations`, and the new runner-smoke + fingerprint step (build solved curriculum, run `LC_ALL=C regina lib/pilgrimage.rexx`, normalize line endings, `diff -u tests/fixtures/runner_stdout.txt`). Mismatch is hard fail. Depends on T028
- [ ] T030 [P] Validate edge cases per spec Edge Cases: empty `koans/` (runner exits 1 with "The path is empty" sentence); missing koan referenced by manifest (runner exits 1 naming the missing station); syntax error inside a koan (runner surfaces Regina diagnostic and stops, runner itself does not crash); missing solution file (`bin/verify_solutions` fails loudly); missing citation in a koan (`bin/lint_citations` fails loudly); missing `Station:` directive (`bin/lint_citations` fails loudly)
- [ ] T031 Run the full quickstart.md walkthrough end-to-end on a clean macOS clone, including the optional "CI parity check" section, and confirm SC-001 (under sixty minutes), SC-002 (under one second on fully solved), and SC-006 (fixture matches both platforms via the CI run)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup. BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational. The MVP slice.
- **User Story 2 (Phase 4)**: Depends on Foundational. Validation-only; the runner already provides resume by virtue of walk-and-discover (Decision 3, research.md).
- **User Story 3 (Phase 5)**: Depends on Foundational. Adds the station display layer; integrates with the runner from Phase 2.
- **Polish (Phase 6)**: Depends on US1 + US3 being complete (the fixture captures the full enriched runner output).

### Within User Story 1 (slice ordering)

- Constitution Principle I requires solution-first within each slice: `solutions/NN_*` is written and passes `verify_solutions` BEFORE the corresponding `koans/NN_*` derives FILL_ME_IN blanks.
- Slices are independent of each other — slice 2 does not depend on slice 1.
- T021 (closing benediction) and T022 (README) are runner/docs polish for US1; they may be done after the six slices are in.
- T023 is the manual integration check; runs last in US1.

### Parallel Opportunities

- **Phase 2**: T004, T005, T007, T008 marked [P] — different files, no shared edits. T003 must precede T006. T006 depends on T003 + T004.
- **Phase 3**: All six solution tasks (T009, T011, T013, T015, T017, T019) can run in parallel. All six koan tasks (T010, T012, T014, T016, T018, T020) can run in parallel after their respective solutions land. Within a slice, the koan task depends on the solution task.
- **Phase 5**: T025 and T026 are sequential (T026 wires T025). T027 is verification.
- **Phase 6**: T030 (edge-case validation) is independent of T028/T029.

---

## Parallel Example: User Story 1 solutions (Slice authoring kickoff)

```bash
# Once Phase 2 (Foundational) is complete, the six solution files can be
# authored in parallel — they each exercise the assertion library, and
# none depends on the others.
Task: "Create solutions/00_about_asserts.rexx (T009)"
Task: "Create solutions/01_about_strings.rexx (T011)"
Task: "Create solutions/02_about_variables.rexx (T013)"
Task: "Create solutions/03_about_expressions.rexx (T015)"
Task: "Create solutions/04_about_clauses.rexx (T017)"
Task: "Create solutions/05_about_say.rexx (T019)"

# Confirm green:
regina bin/verify_solutions    # 6/6 solutions passed.

# Then derive FILL_ME_IN blanks and teaching comments — all six koans
# can be authored in parallel:
Task: "Create koans/00_about_asserts.rexx (T010)"
Task: "Create koans/01_about_strings.rexx (T012)"
Task: "Create koans/02_about_variables.rexx (T014)"
Task: "Create koans/03_about_expressions.rexx (T016)"
Task: "Create koans/04_about_clauses.rexx (T018)"
Task: "Create koans/05_about_say.rexx (T020)"

regina bin/lint_citations      # 6/6 koans passed lint.
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1: Setup (T001–T002).
2. Phase 2: Foundational (T003–T008). **CRITICAL** — blocks all stories.
3. Phase 3: User Story 1 (T009–T023). Stage I walks end-to-end.
4. **STOP and VALIDATE**: A pilgrim on macOS can walk all six koans following only the README and teaching comments. SC-001 + SC-002 verifiable.
5. This is the demoable MVP — the central deliverable of M2.

### Incremental Delivery

1. Setup + Foundational → Foundation ready. Lint and verify pass on an empty Stage I.
2. + US1 → MVP. The Stage I curriculum exists and is walkable on macOS. Demo-ready.
3. + US2 → Confirmed: resume works. (No code change expected; validation only.)
4. + US3 → The station display ships. Pilgrim sees progress at every run.
5. + Polish (Phase 6) → CI matrix locked, fixture committed, edge cases verified, SC-003 + SC-006 green.

### Solution-first Discipline (Constitution Principle I)

Within every koan slice, the loop is: write the solution → verify with
`bin/verify_solutions` → derive FILL_ME_INs in the matching koan →
verify the matching koan with `bin/lint_citations` and (once T021 lands)
walk it through the runner. NEVER author a koan whose solution does not
yet pass.

---

## Notes

- [P] = different files, no dependencies on incomplete tasks.
- [Story] label maps each task to its user story (US1, US2, US3) for traceability against spec.md.
- Tests, in this project, are the acceptance gates: `bin/verify_solutions` (six solutions, zero failures), `bin/lint_citations` (six koans, zero missing citations or `Station:` directives), and the CI runner-smoke fixture (byte-identical stdout across `ubuntu-latest` and `macos-latest`).
- Commit after each task or each slice; Spec Kit's after_tasks hook may auto-commit.
- The `koans/path_to_enlightenment.rexx` manifest is the single source of truth for runner walk order — adding a koan in a future stage means appending one line and bumping `koans.0`.
