# Implementation Plan: M2.5 — Koan Assertion-Line Shape Cleanup

**Branch**: `007-koan-line-shape` | **Date**: 2026-05-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification at `specs/007-koan-line-shape/spec.md`

## Summary

Collapse every Stage I assertion line from the legacy two-statement
shape

```rexx
n = n + 1; CALL m 'eq', 4, 2 + 2, n
```

to the single-statement shape

```rexx
CALL m 'eq', 4, 2 + 2
```

by hoisting the assertion-ordinal counter `n` into the koan-local
`m:` wrapper at the foot of every koan and solution file. The
wrapper, which already shares the caller's variable pool because it
is defined without `PROCEDURE`, gains one line — the in-wrapper
`n = n + 1` increment immediately after `PARSE ARG`. Twelve files
change (`koans/0[0-5]_about_*.rexx` plus
`solutions/0[0-5]_about_*.rexx`); no library, no script, no
fixture, and no PLAN.md, constitution, or workflow file is touched.
`lib/meditation.rexx`'s six-argument external interface is
unchanged — the dispatcher still receives `n` and `SIGL` as the
fifth and sixth arguments, sourced inside the wrapper rather than
on the caller's line.

The change is purely representational. Behavior is bit-identical
pre- and post-cleanup: failure-message ordinals match, "Damaged
at: …, line N" line numbers match (the cleanup edits one line in
place per assertion, never adds or removes lines above the
assertion), runner stdout fixture matches byte-for-byte, and the
six CI checks remain green by construction.

PLAN.md authority: §M2.5 (committed at `9a5de4a` on this branch);
the §8 style bullet codifies the new shape as a forward
requirement for M3+. The codification is a precondition for this
feature, not a deliverable. A working spike on
`koans/00_about_asserts.rexx` is preserved at `stash@{0}`; it is
a reference, not the source of truth.

## Technical Context

**Language/Version**: Regina REXX (ANSI X3.274 / Cowlishaw
definition). The edit targets are 12 koan and solution `.rexx`
files. No Regina-version-sensitive features are exercised; the
`SIGL`-set-on-label-call semantic this feature relies on is
documented as part of the M1 design decisions and was UAT'd in
the spike.
**Primary Dependencies**: None new. The dispatcher
`lib/meditation.rexx` is the only existing dependency referenced
by the wrapper, and its interface is unchanged. Constitution
Principle II forbids third-party REXX libraries; this feature
introduces none.
**Storage**: N/A.
**Testing**: `bin/pilgrimage` (end-to-end runner — both unsolved
and fully-solved corpus paths), `bin/verify_solutions` (the 6
solution files run green), `bin/lint_citations` (M2.4 — citations
unchanged, all-green carries forward), `runner-smoke` (the
`tests/fixtures/runner_stdout.txt` fixture diff). Six CI checks
total per Constitution Principle IV (verify_solutions ×
{ubuntu-latest, macos-latest}, lint_citations × {…}, runner-smoke
× {…}).
**Target Platform**: macOS (Homebrew Regina) and ubuntu-latest
(apt Regina) per `.github/workflows/verify.yml`. No platform
divergence expected: the cleanup is text-level edits to existing
REXX files and exercises only language features that already
underpin the rest of the corpus. UTF-8 byte-level encoding for
em-dashes and §-prefixes in citation lines is preserved by FR-009
(citations byte-identical pre/post).
**Project Type**: REXX learning curriculum / CLI tool. In-repo
edits to existing files; no new components.
**Performance Goals**: N/A. The cleanup has zero runtime cost
delta — same number of REXX clauses executed per assertion (the
inline `n = n + 1` becomes the wrapper-internal `n = n + 1`); the
wrapper takes one extra clause but trades for one fewer clause on
the caller's line.
**Constraints**:
- `lib/meditation.rexx` MUST NOT be modified (FR-005).
- `bin/pilgrimage`, `bin/verify_solutions`, `bin/lint_citations`
  MUST NOT be modified (FR-006).
- `tests/fixtures/runner_stdout.txt` MUST be byte-identical
  pre/post (FR-007, SC-004). The runner success-path output is
  unchanged because the cleanup neither adds nor removes
  assertions, neither shifts ordinals nor relocates files.
- `docs/cowlishaw_index.md` MUST be byte-identical pre/post
  (FR-008).
- The `Station:` directive line and every Cowlishaw citation in
  each in-scope file MUST be byte-identical pre/post (FR-009).
  Constitution Principle III is preserved by construction —
  teaching prose is untouched.
- Solution-koan parity holds: the post-cleanup koan and the
  matching post-cleanup solution differ only in the FILL_ME_IN ↔
  value substitutions on the documented blank positions
  (SC-009).
**Scale/Scope**: 12 files; ~30+ assertion lines; ~50–70 line
changes total (each assertion line replaces one line; each
wrapper replaces 4 lines with 5 lines, net +1 per file × 12 = +12
line additions; net change including assertion-line collapses is
within ~50–70 lines). Atomic delivery in one PR.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First Development | **Pass** | The Stage I koans and matching solutions already exist; M2.5 refactors both in lockstep, never authoring new koans or solutions. The 5-step work order ("solution first, koan derived from solution") applied at original authoring time and is not in scope here. The cleanup *preserves* Principle I's downstream guarantee — `bin/verify_solutions` remains 6/6 green at every commit on the feature branch (FR-010). |
| II. No Third-Party REXX Libraries | **Pass** | No library is introduced. The wrapper continues to call only `lib/meditation.rexx`, which is itself written in Regina built-ins. The in-wrapper `n = n + 1` increment uses only assignment and arithmetic — primitive language features, not library calls. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | FR-009 enforces byte-identity on the `Station:` directive and every Cowlishaw citation in every in-scope file. Teaching prose is untouched (FR-001 / FR-002 limit edits to assertion-line-only). The cleanup *strengthens* Principle III's pedagogy — the pilgrim's eye lands on the REXX being taught instead of on framework state, lifting the signal-to-noise ratio of every concept block. |
| IV. CI Is the Acceptance Gate | **Pass** | All six CI checks (verify_solutions × 2 OS, lint_citations × 2 OS, runner-smoke × 2 OS) MUST be green pre-merge per spec SC-007. Cross-OS parity is automatic — the cleanup is text-level edits that exercise no platform-divergent Regina semantic. The runner stdout fixture (FR-007) is byte-identical pre/post by construction. |
| V. Voice — Diagnostic First, Pilgrimage Flavor Second | **Pass** | No prose is modified. The pilgrim voice and pilgrimage flavor are preserved bit-for-bit. The cleanup is mechanical and silent in user-visible output — the only place the pilgrim notices it is in the source they read (US1), and that is the entire point. Failure messages and ordinals are unchanged because the dispatcher is unchanged. |

**Verdict**: PASS. No violations. Complexity Tracking section omitted.

## Project Structure

### Documentation (this feature)

```text
specs/007-koan-line-shape/
├── plan.md                        # This file (/speckit-plan output)
├── research.md                    # Phase 0 — design decisions (wrapper-shared scope, n=0 retention, per-file path literals, SIGL semantics, validation procedure, forward-enforcement choice)
├── data-model.md                  # Phase 1 — entities for the assertion line, the m: wrapper, the ordinal n, the Stage I corpus
├── quickstart.md                  # Phase 1 — implementation walkthrough + local verification recipe + spike-apply path
├── contracts/
│   └── assertion_line_shape.md    # Phase 1 — the canonical post-change assertion-line shape and m: wrapper body, with positive/negative case tables
├── checklists/
│   └── requirements.md            # Pre-existing (created by /speckit-specify)
├── spec.md                        # Pre-existing (created by /speckit-specify; no /speckit-clarify edits)
└── tasks.md                       # Phase 2 — created by /speckit-tasks (NOT this command)
```

### Source Code (repository root)

```text
koans/
├── 00_about_asserts.rexx          # Edit: collapse 5 assertion lines; rewrite m: wrapper to 3-arg form with internal n increment
├── 01_about_strings.rexx          # Edit: same recipe
├── 02_about_variables.rexx        # Edit: same recipe
├── 03_about_expressions.rexx      # Edit: same recipe
├── 04_about_clauses.rexx          # Edit: same recipe
├── 05_about_say.rexx              # Edit: same recipe
└── path_to_enlightenment.rexx     # READ-ONLY (manifest, no assertions)

solutions/
├── 00_about_asserts.rexx          # Edit: same recipe (in lockstep with koan 00)
├── 01_about_strings.rexx          # Edit: same recipe
├── 02_about_variables.rexx        # Edit: same recipe
├── 03_about_expressions.rexx      # Edit: same recipe
├── 04_about_clauses.rexx          # Edit: same recipe
└── 05_about_say.rexx              # Edit: same recipe

lib/
├── meditation.rexx                # READ-ONLY (FR-005)
├── pilgrimage.rexx                # READ-ONLY
└── stations.rexx                  # READ-ONLY

bin/
├── pilgrimage                     # READ-ONLY (FR-006)
├── verify_solutions               # READ-ONLY (FR-006)
└── lint_citations                 # READ-ONLY (FR-006)

tests/fixtures/
└── runner_stdout.txt              # READ-ONLY (FR-007) — fixture is the byte-identity target

docs/
├── cowlishaw_index.md             # READ-ONLY (FR-008)
├── DESIGN_DECISIONS.md            # READ-ONLY
├── DESIGN_DECISIONS_M2.md         # READ-ONLY
└── M2_FOLLOWUP.md                 # READ-ONLY

PLAN.md                            # READ-ONLY for this feature (codified in commit 9a5de4a; FR-015 gates on its content)
.specify/memory/constitution.md    # READ-ONLY
.github/workflows/verify.yml       # READ-ONLY
```

**Structure Decision**: This feature edits exactly twelve files,
all under `koans/` or `solutions/`, in lockstep. The narrowest
possible source-tree footprint for a corpus-wide refactor. No new
files, no new directories, no rename. The 12-file diff is uniform
in shape (each file gets the same recipe applied) which keeps
review burden linear and small.

## Phase 0: Outline & Research

Phase 0 had no NEEDS-CLARIFICATION markers in the spec
post-`/speckit-clarify` (the clarify pass found no critical
ambiguities). Research was therefore mechanical specification
work — pinning down the wrapper-shared-scope mechanic, the
choice to retain the top-of-file `n = 0` initializer, the SIGL
semantics under in-wrapper assignment, the validation procedure,
and the forward-enforcement strategy.

The questions resolved in Phase 0:

1. **How does the koan-local `m:` wrapper see the caller's `n`?**
   Answered by inspecting the wrapper definition: `m:` is a
   label-based subroutine declared without `PROCEDURE`, so it
   shares the caller's variable pool. The wrapper can read and
   write `n` directly. No `EXPOSE` is required (`EXPOSE` only
   matters when `PROCEDURE` is present). See `research.md` §1.

2. **Should `n = 0` stay at the top of each file, or be removed
   and lazily initialized in the wrapper?** Decided: stay at the
   top. REXX raises NOVALUE on uninitialized-symbol arithmetic,
   so `n + 1` inside the wrapper would error on the first call
   without it. Alternative — `IF SYMBOL('n') = 'LIT' THEN n = 0`
   inside the wrapper — was rejected: the SYMBOL guard adds magic
   to the wrapper, hides initialization from the pilgrim's
   reading order, and saves only one visible line. The
   top-of-file `n = 0` is more honest. See `research.md` §2.

3. **How does the wrapper preserve `SIGL` semantics for the
   "Damaged at: …, line N" diagnostic?** Resolved: REXX sets
   `SIGL` at the call site of every label-based CALL or function
   call, *before* transferring control. So when the koan
   executes `CALL m 'eq', ...`, `SIGL` is set to that line's
   line number. Inside `m:`, the in-wrapper `n = n + 1` is a
   plain assignment and does not perturb `SIGL`. The external
   `CALL 'lib/meditation.rexx' ...` evaluates its argument list
   *before* transferring control, so the value passed for the
   sixth argument is the koan's `CALL m` line — not the wrapper's
   external-CALL line. UAT'd via the spike at `stash@{0}`; runner
   stdout matched the pre-change line numbers exactly. See
   `research.md` §3.

4. **Should the wrapper share a per-file path literal, or compute
   the path at runtime via `PARSE SOURCE` or similar?** Decided:
   per-file string literal (e.g., `'koans/00_about_asserts.rexx'`
   in koan 00, `'solutions/00_about_asserts.rexx'` in solution
   00). Alternative — `PARSE SOURCE` to resolve the running
   file's path — was rejected: `PARSE SOURCE` returns
   platform-variable strings (full path on macOS, sometimes
   shorter on Linux) and would require post-processing inside
   the wrapper, which complicates rather than simplifies. The
   literal stays. See `research.md` §4.

5. **What is the validation procedure that proves bit-identity?**
   Resolved: a two-state probe using `bin/pilgrimage`. State A —
   unsolved corpus (every koan retains at least one
   `FILL_ME_IN`): runner stops at the first blank and prints
   `Damaged at: <file>, line N`. The line number must match the
   pre-change run. State B — fully-solved corpus (every
   `FILL_ME_IN` filled): runner walks the full path and prints
   the success summary. Stdout must be byte-identical to
   `tests/fixtures/runner_stdout.txt`. Probe both states on
   `main` HEAD (pre-change baseline) and on the feature branch
   HEAD (post-change), diffing. See `research.md` §5.

6. **Should implementation start by replaying the spike via
   `git stash apply stash@{0}`, or hand-edit every file from the
   spec's wrapper template?** Decided: replay the spike for
   koan 00 only, then hand-edit koans 01–05 + all six
   solutions/ files from the spec's wrapper template and the
   FR-001 / FR-002 line-shape rule. Replaying gives the spike's
   already-validated work back; hand-editing the remaining
   eleven files lets a fresh attentive read catch any
   pre-existing shape divergence (the assumption that all 12
   files use the legacy shape uniformly is not yet
   independently verified — only koan 00 has been UAT'd).
   Bulk sed/awk was considered and rejected: the per-file path
   literal in the wrapper is hard to template safely, and a
   regex on assertion lines would risk unintended matches in
   teaching prose. See `research.md` §6.

7. **Forward enforcement: lint check or review-only?** Decided:
   review-only, gated by the §8 PLAN.md style bullet. M2.5 does
   not extend `bin/lint_citations` or add a new lint script.
   Rationale: contributor regression is hypothetical until
   M3 ships and reintroduces (or doesn't) the legacy pattern.
   If regression occurs, a successor feature can add a
   "n_pattern_lint" check; the spec's Out of Scope section
   defers this explicitly. See `research.md` §7.

8. **Solution-koan edit ordering: lockstep within one PR, or
   incremental?** Decided: lockstep, both trees in one PR.
   Rationale: SC-009 (solution-koan parity invariant) holds at
   every commit on the feature branch. Splitting into "koans
   first, then solutions" would leave the corpus in a divergent
   state visible in `git log`, violate the parity invariant on
   intermediate commits, and risk a CI failure window where
   `verify_solutions` (running the *old* solutions against the
   *new* dispatcher contract) might surface unexpected
   interactions. The dispatcher contract is unchanged so this
   risk is theoretical, but lockstep eliminates it. See
   `research.md` §8.

**Output**: `research.md` with the eight resolutions above
expanded into prose. No NEEDS-CLARIFICATION remains.

## Phase 1: Design & Contracts

**Prerequisites**: `research.md` complete (wrapper-shared-scope
mechanic, n-initializer retention, SIGL semantics, per-file
path-literal choice, validation procedure, implementation order,
forward-enforcement choice, edit-ordering choice all
finalized).

1. **Data model** (`data-model.md`): formalize the four entities
   already named in spec.md:
   - **Assertion line** — pre-change vs post-change syntactic
     shape, with examples for each of the four meditation verbs
     (`eq`, `neq`, `true`, `datatype`).
   - **Koan-local `m:` wrapper** — pre-change vs post-change
     signature and body, with the per-file path-literal field.
   - **Assertion ordinal `n`** — REXX symbol; lifecycle
     (initialized at top, incremented in wrapper, never written
     by koan body); invariant (monotonic, equals call count at
     delegation time).
   - **Stage I corpus** — file-set entity, twelve members,
     uniform shape pre- and post-cleanup.
   The model has no runtime data flow; entities are
   source-textual and the relationships among them are
   compile-time (the wrapper is the unit producer of the ordinal
   on behalf of the assertion lines).

2. **Contract** (`contracts/assertion_line_shape.md`): the
   post-M2.5 contract for the assertion-line shape and the
   koan-local `m:` wrapper body. Documents:
   - The canonical assertion-line syntactic shape (`CALL m
     '<verb>', <arg1>, <arg2>` — with the optional caveat for
     the `true` verb whose `<arg2>` is conventionally `''`).
   - The canonical `m:` wrapper body (per FR-003, with the
     per-file path literal).
   - The required top-of-file `n = 0` initializer.
   - The forbidden legacy patterns (`n = n + 1; CALL m`,
     trailing-`n` argument).
   - Positive case table (lines that conform under the new
     contract) and negative case table (lines that don't
     conform).
   - Cross-platform parity: no Regina divergence — assertion
     lines use only the same primitive REXX features that the
     pre-change shape uses (CALL, label, string literal,
     numeric arg, expression).
   - What carries forward unchanged: every other source
     element of the file (file header comment, concept
     comment blocks, citation lines, Station: directive line,
     `EXIT 0`).
   - The contract's authority: PLAN.md §8 (the style bullet)
     and PLAN.md §M2.5 (the milestone definition). The
     contract elaborates the syntactic detail; the authority
     resolves judgment calls.

3. **Quickstart** (`quickstart.md`): the contributor-side
   implementation walkthrough plus local verification recipe.
   Steps:
   - Verify upstream prerequisites (M2.2, M2.3, M2.4 merged at
     `main` HEAD; PLAN.md v1.4 codified at the feature branch
     HEAD; spike at `stash@{0}`).
   - Apply the spike to koan 00: `git stash apply stash@{0}`;
     inspect; spot-check via `bin/pilgrimage`.
   - Migrate koans 01–05 by hand from the wrapper template
     and the FR-001 line-shape rule; spot-check each via
     `bin/pilgrimage`.
   - Migrate solutions 00–05 in lockstep with koans;
     `bin/verify_solutions` after each batch to confirm
     parity.
   - Run the bit-identity probe: unsolved corpus + solved
     corpus, both pre- and post-change, line-number and stdout
     diff.
   - Run `bin/verify_solutions` and `bin/lint_citations`;
     confirm 6/6 + all-green.
   - Push branch; observe CI matrix green.
   - Drop `stash@{0}` after merge.
   The recipe is end-to-end; a contributor with no prior
   familiarity with M2.5 should be able to land the work from
   the quickstart alone (cross-checked against the contract for
   the line-shape rule).

4. **Agent context update**: `CLAUDE.md` `Active feature plan`
   line is repointed from `specs/006-citation-existence-lint/plan.md`
   to `specs/007-koan-line-shape/plan.md`.

**Output**: `data-model.md`, `contracts/assertion_line_shape.md`,
`quickstart.md`, updated `CLAUDE.md`.

### Post-Design Constitution Re-Check

| Principle | Status | Notes |
|---|---|---|
| I. Solution-First | **Pass** | The data model and contract are textual artifacts; no koan authoring is in scope. The downstream effect *strengthens* Principle I — the cleaner shape removes ~330+ characters of boilerplate from the pilgrim's reading load across Stage I (SC-008), making the "teaching comments match code that actually passes" guarantee more legible. |
| II. No Third-Party REXX Libraries | **Pass** | The contract restates: assertion lines and the wrapper use only Regina built-ins (`PARSE ARG`, `CALL`, label, assignment, arithmetic, string literal). No external libraries are introduced. |
| III. Every Koan Is Self-Teaching | **Pass and reinforced** | The contract explicitly carves out FR-009 byte-identity for citations, Station: directives, and teaching prose. The data model documents the assertion-line entity as a pure REXX-mechanic surface, distinct from the prose-bearing surface that Principle III governs. |
| IV. CI Is the Acceptance Gate | **Pass** | The contract's positive-case table aligns with the runner stdout fixture; the runner-smoke check confirms byte-identity. The 6 CI checks remain the gate. |
| V. Voice | **Pass** | The contract is technical, not voice-bearing. No pilgrimage flavor leaks into koan/solution syntax; the pilgrim voice in failure messages comes from `lib/meditation.rexx` (untouched, FR-005). |

No new violations. Plan stands.

## Phase 2: Tasks (preview only — generated by /speckit-tasks)

Phase 2 is out of scope for `/speckit-plan`. The expected task
shape, derivable from the artifacts above:

- **Setup phase**: Verify baseline — M2.4-merged main is at HEAD;
  PLAN.md v1.4 with §M2.5 + §8 codified on the branch; the spike
  at `stash@{0}` is intact; baseline `bin/verify_solutions` 6/6
  green and baseline `bin/lint_citations` all-green and baseline
  `bin/pilgrimage` stdout matches the fixture.
- **US1 phase (P1, MVP) — koans**: Apply spike to koan 00 (or
  reproduce by hand from the wrapper template and FR-001 line
  rule); migrate koans 01–05 by hand; spot-check each via
  `bin/pilgrimage` after each file.
- **US3 phase (P1, parity) — solutions**: Migrate solutions
  00–05 in lockstep; `bin/verify_solutions` after each file
  to confirm 6/6 carries through every commit on the branch.
- **US2 phase (P1, behavior parity)**: Run the bit-identity
  probe (unsolved corpus pre/post, solved corpus pre/post)
  per the quickstart's recipe. Confirm line numbers and stdout
  match.
- **US5 phase (P2, doc ratification)**: Read PLAN.md §8 unaided;
  confirm the rule and the forbidden pattern are nameable in
  under 60 seconds.
- **US4 phase (P2, CI gate)**: Push branch; confirm CI 6/6
  green on both OS jobs.
- **Polish phase**: Final review against spec Out of Scope and
  the contract's negative-case table. Confirm `git diff main --
  ':!specs/' ':!koans/' ':!solutions/'` returns no output
  (FR-017). Drop `stash@{0}` after merge readiness is
  established.

`/speckit-tasks` produces the ordered task list in `tasks.md`.
