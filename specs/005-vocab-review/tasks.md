---
description: "Task list for M2.3 — Vocabulary Review Against the Index"
---

# Tasks: M2.3 — Vocabulary Review Against the Index

**Input**: Design documents from `/specs/005-vocab-review/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/teaching_prose.md, quickstart.md

**Tests**: NONE. M2.3 is a content rewrite of teaching prose; the
spec does not request automated tests beyond the existing CI matrix
(verify_solutions, lint_citations, runner-smoke). Acceptance is
established by the 6/6 CI checks plus the M2.3-specific
quickstart spot checks (substitution-table coverage, koan-00
layering, per-substitution parity).

**Organization**: M2.3's three P1 user stories (US1, US2, US3) are
*different framings of the same edit set* rather than independent
work increments — exactly the same situation as M2.2:

- The actual rewrite work is grouped under US1 (comprehensive
  vocabulary discipline) — the most encompassing framing, into
  which US2 (UAT-5 subset) and US3 (koan-00 layering) both
  collapse.
- US2 and US3 become read-only verification phases that confirm
  the rewrite delivers their invariants.
- US4 (CI green + fixture invariance) is the project-level
  acceptance gate.

The three P1 stories ship as a single atomic delivery; the phase
ordering chosen here keeps every intermediate commit
runner-stdout-fixture-green by editing only `/* ... */` comment
blocks.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on
  incomplete tasks).
- **[Story]**: User story this task contributes to (US1, US2, US3,
  US4). Setup, Foundational, and Polish phases carry no story tag.
- File paths are repo-rooted.

## Path Conventions

- **Edit targets**: `koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx` and the parallel files under
  `solutions/`.
- **Read-only**: `docs/cowlishaw_index.md` (FR-007),
  `tests/fixtures/runner_stdout.txt` (FR-008), `bin/lint_citations`
  (FR-010), `lib/meditation.rexx` and other framework code (FR-011),
  every existing `Cowlishaw §N.N, p. NN[ — <heading>]` trailing
  citation line in koans/solutions (FR-006). New in-prose
  parenthetical Cowlishaw references inside prose body text are
  permitted per `research.md` §5.
- **Already authored by /speckit-plan**:
  `specs/005-vocab-review/contracts/teaching_prose.md` (Rules T1–T5,
  the editorial contract). No further edits in tasks below.

---

## Phase 1: Setup

**Purpose**: Confirm the contributor workspace matches the
preconditions assumed by `research.md` §2 (the substitution table)
and §3 / §4 (the layered-prose / re-label proposals). Catches
corpus drift between plan and implementation.

- [ ] T001 [P] Verify `docs/cowlishaw_index.md` exists at HEAD on the feature branch and is byte-identical to its `main`-branch state (the M2.1 deliverable). `git diff main -- docs/cowlishaw_index.md` MUST be empty. (FR-007 read-only invariant baselined.)
- [ ] T002 [P] Verify the substitution-table source strings (`research.md` §2 column "Source string") are still present in their listed files. Run the negative greps from `quickstart.md` Step 4; expect EVERY grep to return at least one match (the source strings exist pre-feature). If any source string has drifted, halt and reconcile against the corpus before proceeding.
- [ ] T003 [P] Verify the koan-00 source blocks (`research.md` §3.0–§3.3) match the current `koans/00_about_asserts.rexx` lines 19–28 (equality), 32–37 (difference), 40–46 (truth), 50–56 (type) byte-for-byte. If any block has drifted, halt and reconcile.
- [ ] T004 [P] Verify the koan-01 source block (`research.md` §4.1, koan 01 lines 33–40 and solution 01 lines 29–36) matches the current files. If drifted, halt and reconcile.
- [ ] T005 [P] Verify `bin/lint_citations` runs green on the unmodified corpus (`bin/lint_citations` should print `6/6 koans passed lint.` and exit 0). This baselines the M2.2-tightened canonical-form check; the rewrites in Phase 3 must keep it green commit-by-commit.
- [ ] T006 [P] Verify `bin/verify_solutions` runs green on the unmodified corpus (`6/6 solutions passed.`, exit 0). Baselines the runtime-correctness check.
- [ ] T007 [P] Capture the runner-stdout-fixture diff baseline by running `quickstart.md` Step 3 against the unmodified corpus. Expected: empty diff. This establishes the FR-008 invariance baseline; Phase 3 must keep it empty.

---

## Phase 2: Foundational

**Purpose**: Standard speckit slot for blocking prerequisites that span multiple user stories. M2.3 has none — the lookup authority (`docs/cowlishaw_index.md`) was delivered by M2.1; the canonical citation form (M2.2) is in place; the editorial contract (`contracts/teaching_prose.md`) was authored by `/speckit-plan`. The rewrite phase can begin immediately after Setup.

**Checkpoint**: No tasks. Proceed directly to Phase 3.

---

## Phase 3: User Story 1 — Comprehensive Vocabulary Discipline (Priority: P1) 🎯 MVP

**Goal**: Apply every substitution in `research.md` §2 (bulk vocabulary work), the framework-vs-REXX layered prose in `research.md` §3 (koan 00 + matching solution), and the targeted re-label in `research.md` §4 (koan 01 numbers block + matching solution). After this phase, every technical term in Stage I prose either appears in the relevant `docs/cowlishaw_index.md` row's `Vocabulary:` column or is explicitly framed as koan-framework vocabulary (FR-001), and koan 00 carries the framework-vs-REXX layering at every concept block (FR-002).

**Independent Test**: After this phase, the negative greps in `quickstart.md` Step 4 produce zero matches and the positive greps produce ≥ 1 match in every file listed; koan 00 contains `assertion verb` ≥ 4 times and references each REXX mechanism term (`comparative operator`, `Logical (Boolean)`, `DATATYPE`) at least once; the per-(koan, solution)-pair grep in `quickstart.md` Step 6 returns zero hits.

**Why this serves all three P1 stories**: Every substitution and rewrite under this phase simultaneously satisfies US1 (comprehensive vocabulary discipline), US2 (UAT-5 closure — every UAT row maps to a §2 substitution and/or the §3 layering per `data-model.md` UAT join table), and US3 (koan-00 framework-vs-REXX layering). US2 and US3 are verified explicitly in Phases 4 and 5 below.

### Implementation for User Story 1 — Bulk substitution table (research.md §2)

- [ ] T008 [P] [US1] Apply the row-1 substitution from `research.md` §2 to `koans/01_about_strings.rexx` only (per the per-substitution-parity check; the source-term does not appear in `solutions/01_about_strings.rexx`):
  - `REXX has no separate character literal.` → `REXX has no separate character type.`
  Use `Edit` (single occurrence). Anchor: line 13 of the unmodified file.
- [ ] T009 [P] [US1] Apply the row-2, row-3, row-4 substitutions to BOTH `koans/02_about_variables.rexx` and `solutions/02_about_variables.rexx`. Use `Edit replace_all=true` for each:
  - Row 2: `Concept: uninitialized symbols.` → `Concept: uninitialized variables.` (both files)
  - Row 3: `the unbound symbol NEVER_SET` → `the uninitialized variable NEVER_SET` (koan only — phrase does not appear in solution)
  - Row 4: `Quoted strings are case-sensitive` → `Literal strings are case-sensitive` (both files)
- [ ] T010 [P] [US1] Apply the row-5 through row-13 substitutions across `koans/03_about_expressions.rexx` and `solutions/03_about_expressions.rexx`. Use `Edit replace_all=true` for each (apply to both files except where noted koan-only):
  - Row 5: `arithmetic, comparison,` → `arithmetic, comparative,` (koan only — solution has terse header)
  - Row 6: `Concept: comparison.` → `Concept: comparative operators.` (both files)
  - Row 7: `compares with numeric coercion` → `performs a normal comparison` (both files)
  - Row 8: `is strict and compares the literal characters` → `is a strict comparison and compares strings character-by-character without padding` (both files)
  - Row 9: `& is AND, | is OR, \ is NOT` → `& is And, | is Inclusive or, \ is Logical not` (both files)
  - Row 10: `The truth values of REXX are the strings '0' (false) and '1' (true).` → `The Logical (Boolean) values are the strings '0' (false) and '1' (true).` (both files)
  - Row 11: `Two values written next to each other with no operator between them are concatenated.` → `Two terms written next to each other with no operator between them are concatenated by abuttal.` (both files)
  - Row 12: `the result has exactly one blank inserted (blank concatenation).` → `the blank operator inserts exactly one blank in the result.` (both files)
  - Row 13: `The || operator forces concatenation regardless of whitespace.` → `The || operator joins without a blank, regardless of whitespace.` (both files)
- [ ] T011 [P] [US1] Apply the row-14 through row-16 substitutions across `koans/04_about_clauses.rexx` and `solutions/04_about_clauses.rexx`. Use `Edit replace_all=true` for each:
  - Row 14: `what marks the boundary of one clause and how a clause may be stretched across more than one line.` → `what implies the semicolon at the end of a clause and how a continuation character carries a clause across more than one line.` (koan only — solution has terse header)
  - Row 15: `A comma at the end of a line continues the clause onto the next line.` → `A continuation character (a comma) at the end of a line continues the clause onto the next line.` (both files)
  - Row 16: `A REXX comment opens with slash-star and closes with star-slash.` → `A REXX comment opens with `/*` and closes with `*/`.` (both files)
- [ ] T012 [P] [US1] Apply the row-17 through row-22 substitutions across `koans/05_about_say.rexx` and `solutions/05_about_say.rexx`. Use `Edit replace_all=true` for each:
  - Row 17: `emits the result to standard output.` → `emits the result to the default character output stream.` (koan only — solution has terse header)
  - Row 18: `emits the resulting string to standard output followed by` → `emits the resulting string to the default character output stream followed by` (both files)
  - Row 19: `blank-concatenates` → `joins by the blank operator` (koan only — phrase does not appear in solution)
  - Row 20: `Concept: blank concatenation in SAY context.` → `Concept: the blank operator in SAY context.` (both files)
  - Row 21: `Two operands separated by whitespace concatenate with exactly one blank between them.` → `Two terms separated by whitespace are joined by the blank operator with exactly one blank between them.` (both files)
  - Row 22: `The empty string has length zero` → `The null string has length zero` (both files)

### Implementation for User Story 1 — Koan 00 framework-vs-REXX layering (research.md §3)

- [ ] T013 [US1] Rewrite the four concept blocks in `koans/00_about_asserts.rexx` per `research.md` §3.0–§3.3. Replace each block (equality lines 19–28, difference lines 32–37, truth lines 40–46, type lines 50–56) with the **Layered (proposed)** prose verbatim from §3. Each rewrite preserves the existing trailing `Cowlishaw §N.N, p. NN` citation line verbatim (FR-006) and adds the new in-prose parenthetical Cowlishaw references shown in the proposed prose (permitted per `research.md` §5). Use `Edit` per block, providing enough surrounding context to make `old_string` unique (the four blocks share the `Cowlishaw §2.5, p. 32` trailing citation in three of four cases; include the concept heading and surrounding lines so each `Edit` is unambiguous).
- [ ] T014 [US1] Apply the per-substitution-parity solution-side updates in `solutions/00_about_asserts.rexx` per `research.md` §3.4. The solution's pre-feature divergent prose (terse file header, "pilgrim's first instrument" framing, "mirror of `eq`" framing, conventional-empty-string note) is preserved. Apply ONLY the vocabulary-term substitutions inside the diverging prose:
  - Equality block (solution lines 12–17): rewrite the `compared as REXX strings, with numeric coercion when both look like numbers` clause to use Cowlishaw normal-comparison vocabulary, mirroring the koan-side layered prose's REXX-mechanism paragraph in style (the "pilgrim's first instrument" opening is preserved). Add the in-prose `(Cowlishaw §2.3, p. 26)` parenthetical for the comparative operator.
  - Difference block (solution lines 24–27): no vocabulary terms in scope; preserve the block verbatim.
  - Truth block (solution lines 33–37): substitute `the REXX boolean 1` → `the Logical (Boolean) value '1'` and `Comparisons` → `comparative operators`. Add the in-prose `(Cowlishaw §2.3, p. 26)` and `(Cowlishaw §2.3, p. 27 — Logical (Boolean))` parentheticals matching the koan-side layered prose.
  - Type block (solution lines 44–47): substitute `whole number` → `Whole`, `any number` → `Number`, `alphanumeric` → `Alphanumeric`. Add the in-prose `(Cowlishaw §2.9, p. 91)` parenthetical for DATATYPE matching the koan-side layered prose.
  Use `Edit` per block.

### Implementation for User Story 1 — Koan 01 targeted re-label (research.md §4)

- [ ] T015 [US1] Rewrite the numbers concept block in `koans/01_about_strings.rexx` (lines 33–40) per `research.md` §4.1. Replace with the **Re-labeled (proposed)** prose verbatim. Preserves the existing trailing `Cowlishaw §2.3, p. 27 — Numbers` citation line (FR-006); adds the in-prose `(Cowlishaw §2.9, p. 91)` parenthetical for DATATYPE (permitted per `research.md` §5). Use `Edit`.
- [ ] T016 [US1] Rewrite the numbers concept block in `solutions/01_about_strings.rexx` (lines 29–36) per `research.md` §4.1's solution-side proposal. Same canonical re-labeled prose as T015 but preserving the solution's pre-feature `'42' and '3.14' are numbers, 'pilgrim' is not` extension (which becomes `'42' and '3.14' are Numbers, 'pilgrim' is not`). Use `Edit`.

### Local verification for User Story 1

- [ ] T017 [US1] Run `bin/lint_citations` on the rewritten corpus. Expected output: `6/6 koans passed lint.`, exit code 0. The M2.2-tightened canonical-form check still passes — every existing trailing citation is unchanged (FR-006), and every new in-prose parenthetical is in canonical form (per `research.md` §5).
- [ ] T018 [US1] Run `bin/verify_solutions` on the rewritten corpus. Expected output: `6/6 solutions passed.`, exit code 0. Catches any edit that accidentally landed outside a comment block.
- [ ] T019 [US1] Run the runner-stdout-fixture diff per `quickstart.md` Step 3. Expected: empty diff. Comments are never echoed; this is the FR-008 invariance canary.
- [ ] T020 [US1] Substitution-table coverage spot check: run the negative greps from `quickstart.md` Step 4 (each MUST return zero matches) and the positive greps (each MUST return ≥ 1 match in every file listed). If any negative grep returns a hit, the substitution was missed for that file; re-apply.

**Checkpoint**: At this point, every Stage I (koan, solution) pair carries Cowlishaw-canonical vocabulary throughout, koan 00 carries the framework-vs-REXX layering at every concept block, and koan 01's numbers block carries the targeted re-label. The corpus passes the M2.2-tightened lint, the verify_solutions check, and the runner fixture diff. US1 is delivered.

---

## Phase 4: User Story 2 — UAT-5 Closure Verification (Priority: P1)

**Goal**: Confirm that each of the five UAT-flagged terminology candidates recorded in PLAN.md §M2.3 is closed by the rewrite landed in Phase 3.

**Independent Test**: Walk PLAN.md §M2.3's five named candidates top to bottom. For each candidate, locate the corresponding term in the post-rewrite corpus and confirm the substitution (or, for item 5, the koan-00 layering) is in place per the `data-model.md` UAT join table.

### Implementation for User Story 2

- [ ] T021 [US2] UAT-1 ("Literal string" vs "string literal"): confirm `koans/01_about_strings.rexx` and `solutions/01_about_strings.rexx` reference the construct as `literal string(s)` (matching the §2.2 Literal strings vocab). Cross-check: the legacy phrasings "Quoted strings" (closed by §2 row 4) and "string literal" do not appear anywhere in `koans/` or `solutions/`. Run `grep -nF 'string literal' koans/*.rexx solutions/*.rexx`; expect zero matches. Run `grep -nF 'Quoted strings' koans/*.rexx solutions/*.rexx`; expect zero matches.
- [ ] T022 [US2] UAT-2 ("Symbol" vs "identifier" / "variable name"): confirm `koans/02_about_variables.rexx` and `solutions/02_about_variables.rexx` distinguish *symbol* (syntactic) from *variable* (bound) per Cowlishaw §2.5; the concept heading reads `uninitialized variables` (§2 row 2) and the koan body references `the uninitialized variable NEVER_SET` (§2 row 3). Run `grep -nFE 'identifier|variable name' koans/*.rexx solutions/*.rexx`; expect zero matches in technical-naming roles. (`identifier` may appear in pilgrim voice; verify any hit is voice-bearing, not construct-naming.)
- [ ] T023 [US2] UAT-3 ("Comparative" vs "Comparisons"): confirm `koans/03_about_expressions.rexx` and `solutions/03_about_expressions.rexx` use `comparative` for the family naming and `comparative operators` for the individual operators (closed by §2 rows 5, 6). Run `grep -nF 'Comparisons' koans/*.rexx solutions/*.rexx`; expect zero matches in technical-naming roles. The trailing citations `Cowlishaw §2.3, p. 26` and `Cowlishaw §2.3, p. 27 — Logical (Boolean)` are unchanged (FR-006).
- [ ] T024 [US2] UAT-4 ("Logical (Boolean)" vs "boolean"): confirm `koans/03_about_expressions.rexx` line "The Logical (Boolean) values are the strings '0' (false) and '1' (true)." (closed by §2 row 10) and koan 00's truth block (closed by `research.md` §3.2 layering) name the family with the parenthesized clarifier preserved. Run `grep -nFE 'boolean|Boolean' koans/*.rexx solutions/*.rexx`; verify every hit is in canonical `Logical (Boolean)` form, not bare lowercase `boolean`.
- [ ] T025 [US2] UAT-5 (the "assertion" framing in koan 00): confirm koan 00's four concept blocks (and the matching four solution blocks) present the framework verb and the REXX mechanism as two distinct things per FR-002 / `research.md` §3. Read `koans/00_about_asserts.rexx` and `solutions/00_about_asserts.rexx` cover to cover; classify every technical-term appearance as framework or REXX vocabulary; confirm no term is silently presented as both or as neither.

**Checkpoint**: At this point, every UAT-flagged terminology gap is verified closed. US2 is delivered.

---

## Phase 5: User Story 3 — Koan-00 Layering Verification (Priority: P1)

**Goal**: Confirm that `koans/00_about_asserts.rexx` and `solutions/00_about_asserts.rexx` carry the full framework-vs-REXX layering pattern (FR-002) at every concept block, with no ambiguous cases.

**Independent Test**: Run the koan-00 layering greps from `quickstart.md` Step 5 against the post-rewrite corpus; confirm `assertion verb` ≥ 4 (one per concept block) and each REXX mechanism term (`comparative operator`, `Logical (Boolean)`, `DATATYPE`) ≥ 1 in koan 00.

### Implementation for User Story 3

- [ ] T026 [US3] Koan-00 layering grep check: from `quickstart.md` Step 5, run:
  ```sh
  grep -c 'assertion verb'             koans/00_about_asserts.rexx
  grep -c 'comparative operator'       koans/00_about_asserts.rexx
  grep -c 'Logical (Boolean)'          koans/00_about_asserts.rexx
  grep -c 'DATATYPE'                   koans/00_about_asserts.rexx
  ```
  Expected: `assertion verb` ≥ 4; each REXX mechanism term ≥ 1. If any count is short, the corresponding concept block's layered prose was not fully applied; identify and re-apply.
- [ ] T027 [US3] Solution-00 layering grep check: same greps against `solutions/00_about_asserts.rexx`. Expected: each term ≥ 1 (the solution's wording differs, so `assertion verb` may be lower than 4, but the REXX mechanism terms must all appear since they were applied per `research.md` §3.4).
- [ ] T028 [US3] Pilgrim-voice preservation check: confirm `koans/00_about_asserts.rexx` file header still opens with `Welcome, pilgrim. Before you walk the path of REXX you must learn the four kinds of assertion.` (the FR-012 voice carve-out — pilgrim-voice flourishes, station taglines, and the `four kinds of assertion` framing are preserved verbatim). Run `grep -nF 'Welcome, pilgrim' koans/00_about_asserts.rexx`; expect one match.
- [ ] T029 [US3] SC-010 reviewer walk: read `koans/00_about_asserts.rexx` cover-to-cover (file header + every concept block) and then `solutions/00_about_asserts.rexx` the same way. For each technical term in the prose, classify it as either *framework vocabulary* (the assertion verbs `eq`/`neq`/`true`/`datatype`, the umbrella term *assertion*, the per-test pass/fail mechanic, `FILL_ME_IN`) or *REXX vocabulary* (Cowlishaw-canonical: comparative operator, Logical (Boolean), DATATYPE, etc.). Confirm every term is unambiguously one or the other (no term in both classifications, no term in neither). Target: under 60 seconds per file. If any term resists classification, the layered prose in `research.md` §3 was not fully applied or contains a residual ambiguity; identify and re-apply at T013/T014. Mechanizes SC-010.

**Checkpoint**: At this point, koan-00's layering is verified complete and pilgrim voice is preserved. US3 is delivered.

---

## Phase 6: User Story 4 — CI Acceptance Gate (Priority: P2)

**Goal**: Confirm all six CI checks (`verify_solutions` × 2 OS, `lint_citations` × 2 OS, `runner-smoke` × 2 OS) pass on the feature branch, `tests/fixtures/runner_stdout.txt` is byte-identical pre/post-rewrite, and citation lines are byte-identical pre/post (no M2.2 work re-opened).

**Independent Test**: GitHub Actions reports 6/6 green on the feature branch's HEAD commit prior to merge; the runner stdout fixture diff is empty locally and in CI; `git diff main -- koans/ solutions/ | grep -E '^\+.*Cowlishaw §|^-.*Cowlishaw §'` shows only ADDED in-prose parentheticals (no MODIFIED or REMOVED trailing citation lines).

### Implementation for User Story 4

- [ ] T030 [US4] Per-substitution parity spot check: from `quickstart.md` Step 6, run:
  ```sh
  for n in 00 01 02 03 04 05; do
    echo "=== ${n} ==="
    grep -nE 'Quoted strings|truth values of REXX|standard output|blank concatenation|empty string has length zero|numeric coercion|is AND,|forces concatenation|opens with slash-star|A comma at the end of a line continues|Concept: comparison\.|Concept: uninitialized symbols\.|Concept: blank concatenation' \
      "koans/${n}_about_"*.rexx "solutions/${n}_about_"*.rexx
  done
  ```
  Expected: no output for any pair. Hits indicate a substitution applied to one side of the pair but not the other; identify and re-apply.
- [ ] T031 [US4] Citation-line read-only spot check: confirm FR-006 holds. Run `git diff main -- koans/ solutions/ | grep -E '^\+.*Cowlishaw §' | sort -u` and `git diff main -- koans/ solutions/ | grep -E '^-.*Cowlishaw §' | sort -u`. Every `+` line must be a NEW in-prose parenthetical reference (not a modified pre-feature trailing citation); every `-` line must be empty (no removed citations). If a pre-feature trailing citation line appears in the `-` output, FR-006 was violated; identify and revert. (Mechanizes SC-007.)
- [ ] T032 [US4] SC-008 / SC-009 mechanical check: confirm `docs/cowlishaw_index.md` and `bin/lint_citations` are byte-identical between the feature branch HEAD and `main`. Run:
  ```sh
  git diff main -- docs/cowlishaw_index.md bin/lint_citations
  ```
  Expected: empty diff. If non-empty, FR-007 (index unmodified) or FR-010 (lint script unmodified) was violated; identify and revert the unintended change. Mechanizes SC-008 and SC-009.
- [ ] T033 [US4] Push the feature branch to origin: `git push -u origin 005-vocab-review`.
- [ ] T034 [US4] Monitor CI: confirm the GitHub Actions verify workflow reports green on both `ubuntu-latest` and `macos-latest` for all three named jobs (`verify_solutions`, `lint_citations`, `runner-smoke`). The 6/6 count satisfies Constitution Principle IV and spec SC-005.

**Checkpoint**: CI gate is green. US4 is delivered. All four user-facing stories (US1, US2, US3, US4) are complete.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: PR preparation and final review.

- [ ] T035 [P] Open a pull request from `005-vocab-review` to `main` with a description that summarizes: the 22 distinct vocabulary substitutions (link to `research.md` §2), the 4 koan-00 framework-vs-REXX layered concept blocks (link to `research.md` §3), the 1 koan-01 + solution-01 targeted re-label (link to `research.md` §4), the FR-004 spec revision to per-substitution parity (link to spec.md Clarifications session 2026-05-09 third bullet), and the 5 UAT-flagged candidates closed (link to `data-model.md` UAT join table). Include a checklist confirming SC-001 through SC-010.
- [ ] T036 [P] Run the `quickstart.md` recipe end-to-end one more time on a fresh clone (or after `git clean -fdx` on the working tree) to confirm a contributor with no local state can reproduce the green build. Note any quickstart-doc improvements needed. (Steps 1+2+3+4+5+6 mechanically exercised in T017/T018/T019/T020/T026/T030.)
- [ ] T037 Final review pass: re-read `spec.md` Out of Scope and Assumptions sections; confirm no item has been silently violated. Specifically: index unmodified (FR-007, SC-008), runner fixture unchanged (FR-008, SC-006), no Stage II–VI files touched, no `bin/lint_citations` change (FR-010, SC-009), no `lib/meditation.rexx` change (FR-011), no pre-feature trailing citation lines modified (FR-006), no PDF-posture changes, no FR-014 (M2.2 deferred lint extension) work landed, voice prose preserved (FR-012, T028).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Empty for M2.3.
- **User Story 1 (Phase 3)**: Depends on Setup (T001–T007 baseline preconditions). Within Phase 3: T008–T012 (per-pair bulk substitutions) can run in parallel; T013–T016 (koan 00 layering + koan 01 re-label) can run in parallel with T008–T012 since they edit different files (or the same file in different blocks — see "Within Each User Story" below); T017–T020 (verification) are sequential follow-ups within the phase.
- **User Story 2 (Phase 4)**: Depends on Phase 3 completion (UAT closure is a property of the rewrites). T021–T025 are read-only verifications; can run in parallel.
- **User Story 3 (Phase 5)**: Depends on Phase 3 completion. T026–T028 are read-only grep checks; T029 is a manual reviewer cover-to-cover walk for SC-010. All parallelizable. May run in parallel with Phase 4 (US2 and US3 are independent verifications).
- **User Story 4 (Phase 6)**: Depends on Phase 3 completion. T030, T031, T032 (local spot checks: per-substitution parity, citation read-only, index/lint git-diff) can begin once Phase 3 is done and run in parallel; T033–T034 (push + monitor) are sequential.
- **Polish (Phase 7)**: Depends on Phase 6. T035 and T036 [P] independent of each other; T037 is the final review.

### User Story Dependencies

- **US1 (Phase 3)**: Independent of other stories' verifications. Delivers the rewrite that all P1 stories share.
- **US2 (Phase 4)**: Depends on US1's rewrite landing. Verification only — no new edits.
- **US3 (Phase 5)**: Depends on US1's rewrite landing. Verification only — no new edits. Independent of US2 (parallelizable).
- **US4 (Phase 6)**: Depends on US1's rewrite landing. The CI run validates the entire corpus in one matrix.

### Within Each User Story

- US1 (Phase 3): T008, T009, T010, T011, T012 (per-pair bulk substitutions) all parallelizable — each edits its own (koan, solution) pair, no overlap. T013, T014 (koan 00 layering) and T015, T016 (koan 01 re-label) are also parallelizable with the bulk-substitution tasks because:
  - T013 / T014 edit koan 00 / solution 00; the only bulk substitution that touches koan 00 is none (koan 00's vocab work is fully captured by the layering rewrites in §3 — the substitution table in §2 has no row for koan 00).
  - T015 edits koan 01's *numbers* concept block; T008 edits koan 01's *single quotes* concept block (different blocks, no conflict). T016 edits solution 01's numbers block; no other task edits solution 01.
  After T008–T016 complete, T017 (lint), T018 (verify_solutions), T019 (runner-smoke fixture diff), T020 (substitution-table greps) run sequentially.
- US2 (Phase 4): T021–T025 independent verifications; parallelizable.
- US3 (Phase 5): T026, T027, T028 independent grep checks plus T029 manual reviewer walk; all parallelizable.
- US4 (Phase 6): T030 (parity spot check), T031 (citation read-only spot check), and T032 (index/lint git-diff) all parallelizable; T033 (push) → T034 (monitor CI) strict order.

### Parallel Opportunities

- All Phase 1 tasks (T001–T007) can run in parallel.
- All Phase 3 per-pair edits (T008–T016) can run in parallel — each edits its own (koan, solution) pair or its own concept block within a file, no overlap.
- Phases 4 and 5 (US2 spot checks and US3 spot checks) can run in parallel after Phase 3 completes.
- T030, T031, T032 in Phase 6 can run in parallel.
- T035, T036 in Polish can run in parallel.

---

## Parallel Example: Phase 3 (User Story 1 rewrite)

```
# Launch all per-pair edits in parallel:
Task T008: koans/01_about_strings.rexx (single quotes block)
Task T009: koans/02_about_variables.rexx + solutions/02_about_variables.rexx
Task T010: koans/03_about_expressions.rexx + solutions/03_about_expressions.rexx
Task T011: koans/04_about_clauses.rexx + solutions/04_about_clauses.rexx
Task T012: koans/05_about_say.rexx + solutions/05_about_say.rexx
Task T013: koans/00_about_asserts.rexx (4-block layering)
Task T014: solutions/00_about_asserts.rexx (4-block layering)
Task T015: koans/01_about_strings.rexx (numbers block re-label)
Task T016: solutions/01_about_strings.rexx (numbers block re-label)
```

After T008–T016 complete, run T017 (lint), T018 (verify_solutions),
T019 (runner-smoke), T020 (substitution-table greps) sequentially.

---

## Implementation Strategy

### MVP (US1 alone)

1. Phase 1 Setup → preconditions verified.
2. Phase 3 US1 → all rewrites applied; substitution-table coverage and koan-00 layering verified locally.
3. **STOP** if a partial-merge MVP is acceptable: every Stage I koan and solution carries Cowlishaw-canonical vocabulary and koan 00's framework-vs-REXX layering is in place. US2, US3, and US4 are still gated by their own phases but the corpus is correct.

### Full M2.3 incremental delivery

1. Phase 1 Setup.
2. Phase 3 US1 → rewrite phase. Atomic commit (or per-pair / per-block commits) keeps lint and verify_solutions green throughout.
3. Phase 4 US2 → UAT-5 spot check. No new commits — verification only.
4. Phase 5 US3 → koan-00 layering spot check. No new commits — verification only.
5. Phase 6 US4 → push, monitor CI, confirm 6/6 green.
6. Phase 7 Polish → PR + final review.

### Parallel Team Strategy

M2.3's blast radius is small (12 files, no tooling). The natural cadence is one developer in sequence; parallelization across team members would add coordination overhead without saving meaningful time. T008–T016 are parallelizable for an LLM agent doing batch edits but trivially sequential for a human.

---

## Notes

- [P] tasks edit independent files (or independent blocks within a file) and have no inter-dependencies on incomplete tasks.
- [Story] labels: US1 = comprehensive vocabulary discipline (Phase 3 — the actual edit work); US2 = UAT-5 closure verification (Phase 4); US3 = koan-00 layering verification (Phase 5); US4 = CI acceptance gate (Phase 6).
- All P1 stories ship as a single atomic delivery; the phase ordering here is for clarity of acceptance verification, not for separable releases.
- Commit cadence: one commit per pair (or one commit covering all pairs) in Phase 3; verification phases (4, 5, 6) are read-only and produce no commits.
- Avoid: modifying any pre-feature trailing citation line (FR-006); modifying `docs/cowlishaw_index.md` (FR-007); modifying `tests/fixtures/runner_stdout.txt` (FR-008); modifying `bin/lint_citations` (FR-010); editing `lib/meditation.rexx` or any other framework code (FR-011); editing files outside the FR-011 allowlist; touching pilgrim-voice prose (FR-012, T028).
