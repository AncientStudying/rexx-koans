# Feature Specification: M2.5 — Koan Assertion-Line Shape Cleanup

**Feature Branch**: `007-koan-line-shape`
**Created**: 2026-05-10
**Status**: Draft
**Input**: User description: "M2.5— Koan Assertion-Line Shape Cleanup"

## Background

Every assertion line in the Stage I koans and matching solutions
currently inlines an assertion-ordinal counter alongside the call to
the koan-local meditation wrapper:

```rexx
n = n + 1; CALL m 'eq', 4, 2 + 2, n
```

The bookkeeping fragments — `n = n + 1;` at the head of the line and
the trailing `, n` argument — are pure framework mechanics with no
pedagogical content. They exist so that `lib/meditation.rexx` can
report failures by 1-based ordinal ("the 5th assertion …") and so
that the koan-local `m:` wrapper can pass `SIGL` (the source line
number of the call) and `n` together to the dispatcher. Both needs
are real; the encoding chosen forces the pilgrim's eye to parse
framework state on every line they were meant to focus on as REXX.
On a representative line the REXX-being-taught (`2 + 2`) occupies
about a fifth of the visible characters; the rest is repeated
boilerplate the pilgrim has already internalized by koan 00 and must
read past on every assertion thereafter.

The fix is mechanical and local. The koan-local `m:` wrapper at the
foot of every koan is a label-based subroutine without `PROCEDURE`,
so it shares the caller's variable pool and can read and increment
`n` itself. Hoisting the counter into the wrapper collapses each
assertion line to:

```rexx
CALL m 'eq', 4, 2 + 2
```

— the verb, the expected, the actual, nothing else. The `n = 0`
initializer at the top of each koan stays in place; it remains the
only counter surface visible above the fold. `lib/meditation.rexx`'s
external interface is unchanged: it still receives the ordinal and
the line number as the 5th and 6th arguments, just sourced inside
the wrapper rather than on the caller's line. `SIGL` continues to
resolve to the koan's `CALL m` line because label-based CALLs set
`SIGL` at the call site; the in-wrapper increment does not perturb
it.

PLAN.md authority: §M2.5 (added 2026-05-10 at v1.4; codified in
commit `9a5de4a`). The forward style requirement — that M3+ koans
use the cleaned shape from inception, and that the legacy pattern
`n = n + 1; ... , n` is forbidden — is recorded as a §8 style
bullet in the same commit. The codification commits ship with the
spec on this branch; this feature implements the migration.

Schedule: depends on M2.2 (citation rewrite,
`specs/004-m2-2-citation-rewrite/`), M2.3 (vocab review,
`specs/005-vocab-review/`), and M2.4 (citation existence lint,
`specs/006-citation-existence-lint/`) being committed at HEAD of
`main`, because all three feature trees edit Stage I koans and
solutions on overlapping surfaces; landing M2.5 before any of them
would force rework. Independent of M2.4 in semantic surface (M2.4
edits the lint script; M2.5 edits the koans) but the file-write
ordering matters for review burden. Should land before M3 begins so
the new shape is the only shape M3+ koan authors are exposed to.

A working spike of the new shape applied to `koans/00_about_asserts.rexx`
exists on this branch's stash (`stash@{0}`, message: "spike:
simplified assertion-line shape (M2.5 POC); per-line ordinal moved
into m: wrapper"). The spike was UAT'd end-to-end against
`bin/pilgrimage` and `bin/verify_solutions` before being stashed; it
demonstrates the mechanic is sound and the implementation will
reproduce its shape across all 12 in-scope files. The spike is a
reference, not the source of truth — the spec governs.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pilgrim sees the REXX, not the framework (Priority: P1) 🎯 MVP

A pilgrim opens `koans/00_about_asserts.rexx` for the first time.
Each assertion line shows only the assertion verb and its
arguments; the counter bookkeeping is gone. Their eye lands on
`'eq', 4, 2 + 2` rather than on `n = n + 1; ... , n`. The same
visual relief carries through all six Stage I koans: 00, 01, 02,
03, 04, 05. The same shape appears in the parallel `solutions/`
files, so a pilgrim who consults the solution after solving sees
the same idiom they just edited.

**Why this priority**: The visual cleanup is the entire user-facing
value of the feature. Without it, the work is unmotivated. P1
because Stage I is the pilgrim's first exposure to the koan
framework and the cognitive-load cost of the legacy shape compounds
across every assertion (~30+ assertions across the six koans).

**Independent Test**: After the feature lands, open every
`koans/0[0-5]_about_*.rexx` and `solutions/0[0-5]_about_*.rexx`
file. Confirm: (a) zero lines match the substring `n = n + 1;
CALL m`; (b) zero `CALL m` lines pass a trailing argument that
references `n`; (c) every `m:` wrapper at the foot of the file
takes exactly three positional arguments (`kind, arg1, arg2`) and
contains an internal `n = n + 1` increment before delegating. A
single grep + visual scan of 12 files takes under five minutes
and verifies the user-visible deliverable end to end.

**Acceptance Scenarios**:

1. **Given** a pilgrim reading `koans/00_about_asserts.rexx`,
   **When** they look at any assertion line, **Then** the line
   begins with `CALL m '<verb>',` and ends with the second
   argument (no trailing `, n`); no `n = n + 1;` prefix
   precedes any `CALL m` on the line.
2. **Given** a pilgrim reading the matching
   `solutions/00_about_asserts.rexx`, **When** they look at any
   assertion line, **Then** it follows the same shape as the
   koan; the diff between koan and solution shows only the
   FILL_ME_IN → value substitutions, not idiomatic differences.
3. **Given** the same observations performed for koans 01–05
   and solutions 01–05, **When** a contributor greps the
   corpus, **Then** zero matches return for the legacy
   substring patterns.

---

### User Story 2 - Runner behavior is bit-for-bit identical (Priority: P1)

A pilgrim or maintainer running `bin/pilgrimage` on the success
path (every koan solved) sees stdout byte-identical to the
pre-change run. A pilgrim or maintainer running `bin/pilgrimage`
on a failure path (any koan with a deliberate `FILL_ME_IN`
remaining, or any koan with a wrong fill) sees the same `Damaged
at: <file>, line N` line numbers and the same "the Nth assertion
of …" ordinals as the pre-change run. The cleanup is purely
representational; no diagnostic, message, ordinal, or line number
shifts.

**Why this priority**: The runner output is the project's
public-facing artifact. A cleanup that silently changes ordinals
or line numbers would break the runner stdout fixture
(`tests/fixtures/runner_stdout.txt`), break CI, and degrade the
pilgrim's debug experience by misnaming the line they need to
edit. P1 because it is the acceptance gate: any deviation here
fails the feature regardless of how clean the source looks.

**Independent Test**: Run `bin/pilgrimage` against the post-feature
corpus on a clean checkout; diff stdout against
`tests/fixtures/runner_stdout.txt`. Then introduce a deliberate
wrong fill into one assertion of one koan and run again; record
the failure message and the `Damaged at: <file>, line N` value;
revert; apply the same wrong fill against the *pre-change* corpus
(by checking out `main`); confirm both runs produce the same
ordinal in the failure message and the same `line N`. (The pre-
and post-change line numbers must match because the cleanup
changes only the *contents* of assertion lines, not their order
or their position; line numbers shift if and only if the prose
above the assertion shifts, which this feature does not touch.)

**Acceptance Scenarios**:

1. **Given** the post-feature corpus with all FILL_ME_IN values
   filled, **When** `bin/pilgrimage` runs, **Then** stdout is
   byte-identical to `tests/fixtures/runner_stdout.txt` (modulo
   CRLF normalization).
2. **Given** the post-feature corpus with one FILL_ME_IN
   remaining, **When** `bin/pilgrimage` runs, **Then** the
   "Damaged at: …, line N" diagnostic names the same line
   number as the pre-change corpus would have for the same
   blank.
3. **Given** the post-feature corpus with one wrong fill that
   triggers a meditation failure, **When** `bin/pilgrimage`
   runs, **Then** the "the Nth assertion of …" ordinal in the
   failure message matches the pre-change corpus's ordinal for
   the same wrong fill.

---

### User Story 3 - Solution-koan parity preserved (Priority: P1)

A pilgrim who finishes a koan and consults the matching solution
file (whether to verify their answer or to learn the canonical
fill) sees a file that differs from the koan only in the
FILL_ME_IN substitutions. The wrapper shape, the assertion-line
shape, the comment blocks, and the file ordering are identical
between `koans/NN_about_*.rexx` and `solutions/NN_about_*.rexx`.

**Why this priority**: Solution-koan parity is a long-standing
project invariant (PLAN.md §10 standard work order: "the koan is
derived from the solution by replacing values with FILL_ME_IN").
A cleanup that lands in `koans/` but not `solutions/` would
introduce a divergence the pilgrim notices on the first solution
consultation. P1 because both trees ship together as one atomic
delivery.

**Independent Test**: For each Stage I file pair, run
`diff koans/NN_about_*.rexx solutions/NN_about_*.rexx`. Confirm
the diff shows only FILL_ME_IN-vs-value substitutions on the
two-or-three blanks per koan; no shape differences, no wrapper
differences, no idiomatic differences anywhere else.

**Acceptance Scenarios**:

1. **Given** any Stage I file pair (koan 00–05 ↔ solution 00–05),
   **When** the contributor diffs them, **Then** the only
   differences are the FILL_ME_IN-vs-value substitutions on the
   2–3 unsolved-line positions documented in each koan's
   teaching prose.

---

### User Story 4 - CI matrix stays green (Priority: P2)

The CI workflow (`.github/workflows/verify.yml`) runs
`verify_solutions`, `lint_citations`, and the runner-smoke test on
both `ubuntu-latest` and `macos-latest`. M2.5's surface is
`koans/00–05_about_*.rexx` and `solutions/00–05_about_*.rexx`
only; no script, library, fixture, index, or workflow file is
touched. The CI matrix MUST remain green on the feature branch's
HEAD prior to merge, including the new (M2.4-introduced) citation
existence check, which is unaffected because no citation prose
moves and no koan or solution citation surface changes.

**Why this priority**: P2 because it's the project-level
acceptance gate, automatic given the P1 deliverables, and the CI
matrix exists. CI green is a *consequence* of US1 + US2 + US3
landing correctly, not a separable user-facing story; it ships in
the same atomic delivery. Mirrors the
`specs/006-citation-existence-lint/spec.md` US4 framing.

**Independent Test**: Push the feature branch; observe GitHub
Actions reports `success` on both `ubuntu-latest` and
`macos-latest` for all three workflow steps (`Verify solutions`,
`Lint citations`, `Runner smoke`).

**Acceptance Scenarios**:

1. **Given** the M2.5 changes pushed to
   `origin/007-koan-line-shape`, **When** GitHub Actions runs the
   `verify` workflow, **Then** both matrix jobs (ubuntu-latest,
   macos-latest) complete with conclusion `success` across all
   three steps within each job.

---

### User Story 5 - M3+ authoring guidance is clear and discoverable (Priority: P2)

A future koan author writing `koans/06_about_if.rexx` and the
matching solution opens `PLAN.md`, finds the §8 style bullet
("Assertion lines stay single-statement"), and authors every
assertion as `CALL m '<verb>', expected, actual` from the start.
They do not introduce the legacy `n = n + 1; ... , n` pattern.
They do not need to consult M2.5's spec or implementation to know
the rule; the §8 bullet states it.

**Why this priority**: P2 because the documentation already shipped
with the M2.5-codification commit; this user story validates that
the doc actually conveys the rule rather than authoring new doc.
The ratification is a quick review pass during M2.5 implementation,
not separate work.

**Independent Test**: A reviewer opens PLAN.md §8, reads the
"Assertion lines stay single-statement" bullet, and answers two
questions in under 60 seconds without consulting any other source:
(a) what is the canonical assertion-line shape for new koans?
(b) what pattern is forbidden? If both answers come correctly from
the bullet alone, the guidance is sufficient.

**Acceptance Scenarios**:

1. **Given** PLAN.md at the feature branch HEAD, **When** a
   reviewer reads §8 unaided, **Then** they can name both the
   canonical shape (`CALL m '<verb>', expected, actual`) and
   the forbidden pattern (`n = n + 1; ... , n`).
2. **Given** the same PLAN.md, **When** a reviewer searches for
   the M3+ forward requirement, **Then** they find it stated
   verbatim in the §8 bullet without needing to read M2.5's
   procedure section in §10.

---

### Edge Cases

- **A koan calls `m` from inside a `DO` loop or a `SELECT` branch.**
  The wrapper still increments `n` correctly because `n` lives in
  the koan's variable pool (the wrapper has no `PROCEDURE`
  declaration, so it shares scope). The ordinal advances per
  invocation regardless of control structure. Stage I koans 00–05
  do not currently exercise this pattern; the design supports it
  for M3+.
- **A pilgrim deletes the top-of-file `n = 0` initializer.**
  The first call to `m` raises a NOVALUE condition on the
  expression `n + 1` inside the wrapper. Same failure mode as the
  pre-change shape (where the first per-line `n = n + 1` would
  also raise NOVALUE if `n = 0` were missing). No regression; the
  guard remains "set `n` at the top".
- **A pilgrim assigns `n` mid-koan (e.g., `n = 5`).** The next
  ordinal jumps. Treated as user error; not handled specially.
  Same behavior as today.
- **A contributor copies an assertion line from an external
  source that uses the legacy shape.** The `n = n + 1;` prefix
  would double-increment (the wrapper's increment fires too); the
  trailing `, n` argument would be ignored by the wrapper's
  three-arg PARSE ARG (REXX silently drops extra positional args).
  Output: the failure ordinal would skip ahead one. The forward
  guard against this is review-time, not runtime: PLAN.md §8 names
  the forbidden pattern, and a grep for `n = n + 1;` followed by
  `CALL m` is the mechanical check (zero matches expected; see
  FR-013).
- **A koan defines its own helper subroutine that also uses `n`.**
  Forbidden in Stage I by convention. PLAN.md §8 reserves `n` as
  the koan's assertion-counter name. M3+ koans needing a counter
  for teaching purposes use a different name.
- **Solutions and koans diverge in shape during implementation.**
  Implementation order is "edit koan → derive solution from koan
  via FILL_ME_IN replacement" (PLAN.md §10 standard work order).
  Both trees land in the same commit; CI catches divergence
  immediately because `verify_solutions` runs on the solutions
  side and the runner runs on the koans side, and a shape
  divergence breaks at least one.
- **The `m:` wrapper's koan-path string literal must be updated
  per file.** Each koan's wrapper passes its own filename as a
  string to `lib/meditation.rexx`. The cleanup edits do not change
  the wrapper's third argument (the koan filename); the path
  literal stays correct for each file. Mechanical: grep for
  `'koans/NN_about_*.rexx'` inside each koan's `m:` wrapper
  matches the file's own path.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each assertion line in `koans/00_about_asserts.rexx`,
  `koans/01_about_strings.rexx`, `koans/02_about_variables.rexx`,
  `koans/03_about_expressions.rexx`, `koans/04_about_clauses.rexx`,
  and `koans/05_about_say.rexx` MUST be a single-statement call
  of shape `CALL m '<verb>', <arg1>, <arg2>`. The `n = n + 1;`
  prefix and the trailing `, n` argument MUST be removed.
- **FR-002**: Each assertion line in
  `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx` MUST follow the same shape as
  FR-001.
- **FR-003**: Each koan-local `m:` wrapper (in `koans/` AND
  `solutions/`) MUST take exactly three positional arguments
  (`kind, arg1, arg2`), increment `n` internally before delegating,
  and pass `n` to `lib/meditation.rexx` as the 5th argument and
  `SIGL` as the 6th. The wrapper body MUST be:
  ```rexx
  m: PARSE ARG kind, arg1, arg2
     n = n + 1
     CALL 'lib/meditation.rexx' kind, arg1, arg2, '<koan_path>', n, SIGL
     IF RESULT \= 0 THEN EXIT RESULT
     RETURN
  ```
  where `<koan_path>` is the file's own relative path (e.g.,
  `koans/00_about_asserts.rexx` for koan 00, or
  `solutions/00_about_asserts.rexx` for solution 00).
- **FR-004**: A single `n = 0` initializer MUST appear at the top
  of each in-scope file (above the first concept block). No other
  counter surface MUST be visible to the pilgrim within the file.
- **FR-005**: `lib/meditation.rexx` MUST NOT be modified by this
  feature. Its external interface (six positional arguments,
  return codes 0/1/2, diagnostic strings) carries forward
  unchanged.
- **FR-006**: `bin/pilgrimage`, `bin/verify_solutions`, and
  `bin/lint_citations` MUST NOT be modified by this feature.
- **FR-007**: The runner stdout fixture
  `tests/fixtures/runner_stdout.txt` MUST be byte-identical
  before and after this feature's changes.
- **FR-008**: `docs/cowlishaw_index.md` MUST be byte-identical
  before and after this feature's changes.
- **FR-009**: The `Station:` directive line and every Cowlishaw
  citation in each in-scope file MUST be byte-identical before
  and after this feature's changes. The cleanup touches assertion
  lines and the wrapper; it does not touch teaching prose,
  station directives, or citations.
- **FR-010**: `bin/verify_solutions` MUST report 6/6 green on
  the feature branch's HEAD prior to merge.
- **FR-011**: `bin/lint_citations` MUST report all-green on the
  feature branch's HEAD prior to merge (the feature does not
  introduce, remove, or modify any citation; the M2.4 existence
  check carries through unchanged).
- **FR-012**: `bin/pilgrimage` MUST exit 0 on the post-feature
  fully-filled corpus, and stdout MUST equal
  `tests/fixtures/runner_stdout.txt` byte-for-byte.
- **FR-013**: A grep for the substring `n = n + 1;` followed
  (with optional whitespace) by `CALL m` across `koans/*.rexx`
  and `solutions/*.rexx` MUST return zero matches on the feature
  branch's HEAD.
- **FR-014**: A grep for `CALL m` lines passing a trailing `n`
  argument across `koans/*.rexx` and `solutions/*.rexx` MUST
  return zero matches on the feature branch's HEAD. (Mechanical
  pattern: any `CALL m` line whose final positional argument is
  the bare token `n`.)
- **FR-015**: `PLAN.md` §M2.5 (the milestone definition) and
  the §8 "Assertion lines stay single-statement" style bullet
  MUST be present at HEAD of the feature branch and unchanged
  from the codification commit (`9a5de4a`). The codification is
  a precondition for this feature, not a deliverable; this FR
  documents the gate.
- **FR-016**: No new file MUST be added under `koans/` or
  `solutions/`. The feature edits in place; it does not introduce
  new koans, new solutions, new helper files, or new shared
  libraries.
- **FR-017**: No file outside `koans/00–05_about_*.rexx`,
  `solutions/00–05_about_*.rexx`, and the spec/plan/tasks
  artifacts under `specs/007-koan-line-shape/` MUST be modified
  by this feature. Mechanically:
  `git diff main -- ':!specs/' ':!koans/' ':!solutions/'`
  returns no output on the feature branch's HEAD prior to merge.

### Key Entities

- **Assertion line**: a single line of REXX in a koan or solution
  file that invokes the koan-local meditation wrapper. Pre-change
  shape: `n = n + 1; CALL m '<verb>', <arg1>, <arg2>, n`.
  Post-change shape: `CALL m '<verb>', <arg1>, <arg2>`. The unit
  of edit.
- **Koan-local `m:` wrapper**: a label-based subroutine at the
  foot of every koan and solution file, defined without
  `PROCEDURE`, that delegates to `lib/meditation.rexx` and exits
  on non-zero return code. Pre-change signature: 4 args
  (`kind, arg1, arg2, num`). Post-change signature: 3 args
  (`kind, arg1, arg2`), with `n` incremented internally before
  delegation.
- **Assertion ordinal `n`**: the 1-based count of assertions
  within a single koan or solution file. Initialized to 0 at the
  top of each file. Incremented by the `m:` wrapper before each
  delegation. Used by `lib/meditation.rexx` to phrase failure
  messages ("the 5th assertion of …"). Post-change, the pilgrim
  encounters `n` only at the `n = 0` top-of-file line; the
  wrapper-internal increment is below the EXIT line and visually
  out of the way.
- **Stage I corpus**: the set of 12 files
  `koans/0[0-5]_about_*.rexx` and
  `solutions/0[0-5]_about_*.rexx`, comprising the entire scope of
  this feature.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of assertion lines in the Stage I koans
  (`koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx`) match the post-change shape
  `CALL m '<verb>', <arg1>, <arg2>` and contain no `n = n + 1;`
  prefix and no trailing `, n` argument.
- **SC-002**: 100% of assertion lines in the Stage I solutions
  (`solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx`) similarly match the
  post-change shape.
- **SC-003**: Every koan-local `m:` wrapper in `koans/` and
  `solutions/` (12 wrappers total) takes exactly three positional
  arguments and contains an internal `n = n + 1` increment line
  immediately following the `PARSE ARG` line. Mechanically: 12
  files × 1 wrapper each = 12 wrappers, all conformant.
- **SC-004**: `bin/pilgrimage` run against the post-feature
  fully-filled corpus produces stdout byte-identical to
  `tests/fixtures/runner_stdout.txt` (modulo CRLF
  normalization). Mechanically: `bin/pilgrimage > /tmp/out;
  diff -u tests/fixtures/runner_stdout.txt /tmp/out` returns
  empty.
- **SC-005**: `bin/verify_solutions` reports `6/6 solutions
  passed.` on the feature branch's HEAD prior to merge.
- **SC-006**: `bin/lint_citations` reports all-green (the same
  per-file `[ ok ]` count and summary as on `main` HEAD prior
  to this feature) on the feature branch's HEAD prior to merge.
- **SC-007**: All 6 CI workflow checks (the matrix
  `verify_solutions` × {ubuntu-latest, macos-latest},
  `lint_citations` × {ubuntu-latest, macos-latest},
  `runner-smoke` × {ubuntu-latest, macos-latest}, counted as
  2 jobs × 3 steps = 6 named checks) are green on the feature
  branch's HEAD commit prior to merge.
- **SC-008**: A representative assertion line drops from
  ~33 visible characters (e.g., `n = n + 1; CALL m 'eq', 4, 2 + 2, n`)
  to ~22 visible characters (`CALL m 'eq', 4, 2 + 2`) — a
  ~33% reduction in pilgrim-facing line length on every
  assertion. Multiplied across the ~30+ assertions in Stage I,
  the cleanup removes ~330+ characters of repeated framework
  bookkeeping from the pilgrim's reading load.
- **SC-009**: A pilgrim diffing any koan against its matching
  solution sees only the FILL_ME_IN-vs-value substitutions on
  the documented blank positions (typically 2–3 per koan); no
  shape differences, no wrapper differences, no idiomatic
  differences. Mechanically: `diff koans/NN_about_*.rexx
  solutions/NN_about_*.rexx` returns hunks that consist solely
  of `FILL_ME_IN` ↔ value lines.
- **SC-010**: A failure-path probe (introduce one wrong fill
  into one koan, run `bin/pilgrimage`, capture the failure
  message, revert) produces a `Damaged at: <file>, line N`
  diagnostic whose `line N` matches the line number that the
  pre-change corpus would have produced for the same wrong fill.
  Mechanically verifiable by running the same probe against
  `main` HEAD and the feature branch HEAD and diffing the
  failure-message line numbers.
- **SC-011**: A reviewer reading PLAN.md §8 unaided can name,
  in under 60 seconds, both the canonical assertion-line shape
  (`CALL m '<verb>', expected, actual`) and the forbidden legacy
  pattern (`n = n + 1; ... , n`). Subjective but verifiable by
  a quick review-pass during US5 acceptance.

## Assumptions

- **M2.2 is complete and committed.** The Stage I citations
  are in canonical form per
  `specs/004-m2-2-citation-rewrite/spec.md`. M2.5 does not edit
  citations, but the FR-009 byte-identity claim presumes the
  citations are at their final form already.
- **M2.3 is complete and committed.** The Stage I teaching
  prose has been vocabulary-reviewed per
  `specs/005-vocab-review/spec.md`. M2.5 does not edit prose;
  FR-009's byte-identity claim presumes the prose is at its
  final form already.
- **M2.4 is complete and committed.** `bin/lint_citations`
  performs the index existence join. M2.5 does not modify lint;
  FR-011 presumes the M2.4 lint behavior carries through
  unchanged.
- **PLAN.md v1.4 is committed at HEAD of the feature branch.**
  The §M2.5 milestone definition and the §8 style bullet are
  present (commit `9a5de4a`). The codification is a precondition,
  not a deliverable; FR-015 documents the gate.
- **`koans/0[0-5]_about_*.rexx` and `solutions/0[0-5]_about_*.rexx`
  follow a uniform shape.** Each file currently uses the
  legacy `n = n + 1; CALL m '...', ..., n` pattern on every
  assertion line and a 4-arg `m:` wrapper at the foot. The
  cleanup applies the same edit recipe to all 12 files. (The
  spike on `stash@{0}` validates the recipe on koan 00; the
  remaining 11 files are inferred to follow the same shape and
  will be confirmed during implementation.)
- **`SIGL` continues to resolve correctly to the koan's `CALL m`
  line.** Label-based CALLs in REXX set `SIGL` at the call site
  before transferring control to the label; the in-wrapper
  `n = n + 1` increment is a plain assignment and does not
  perturb `SIGL`. The wrapper reads `SIGL` as the 6th argument
  to the external CALL, which evaluates before the external CALL
  executes, so the value passed is the koan's CALL line. Per
  the M1 design decisions, Regina's behavior on this point is
  the project's reference; no other backend is in scope.
- **Forward enforcement is by review, not by automation.**
  PLAN.md §8 names the forbidden pattern and the canonical
  shape. CI does not currently scan koans or solutions for the
  legacy pattern; review of M3+ contributions is the guard. If
  contributor regression proves common, a successor feature can
  add a mechanical lint check (zero-match grep on `n = n + 1;
  ... CALL m` and on trailing-`n` arguments). Out of scope for
  M2.5.
- **The koan/solution file ordering and line counts above
  assertion lines do not change.** The cleanup edits assertion
  lines in place (replacing one line with one line) and the
  `m:` wrapper at the foot. Comment blocks, the `n = 0`
  initializer, the `EXIT 0` line, and the wrapper's position
  do not move. Therefore line numbers for assertion lines are
  preserved across the cleanup, and SC-010's line-number-
  identity claim holds.
- **The spike at `stash@{0}` is a reference, not the source of
  truth.** The implementation may reproduce the spike's edits
  on koan 00 by `git stash apply stash@{0}` or by hand from this
  spec. Either is acceptable; the spec governs. The stash entry
  is dropped after merge.

## Out of Scope

- **Modifying `lib/meditation.rexx`.** The dispatcher's external
  interface is the contract; M2.5 changes only how `n` is sourced
  on the caller's side.
- **Modifying any koan or solution beyond Stage I (06+).**
  Stages II–VI do not exist yet. M2.5's forward style guideline
  governs them when M3+ ships them; M2.5 itself only migrates
  the existing 12 files.
- **Modifying `bin/pilgrimage`, `bin/verify_solutions`, or
  `bin/lint_citations`.** None of the runner or CI scripts need
  changes; the cleanup is purely on the koan/solution side.
- **Adding a new assertion verb to the `m:` wrapper or the
  meditation library.** The four verbs (`eq`, `neq`, `true`,
  `datatype`) are unchanged.
- **Renaming `m`, `n`, the meditation library, or any
  participant.** The names are stable; only the shape of the
  caller's line changes.
- **Removing the `n = 0` top-of-file initializer.** The
  initializer remains; it is the single counter surface visible
  to the pilgrim and the necessary kickoff for the
  wrapper-internal increment.
- **Refactoring the koan-local wrapper into a shared library
  function.** Each file keeps its own wrapper because the
  wrapper's third argument is the file's own path (used by
  `lib/meditation.rexx` to phrase the file name in failure
  messages). A shared wrapper would need to learn its caller's
  filename, which would force a `PARSE SOURCE` or similar
  workaround that complicates rather than simplifies. The
  per-file wrapper is the local maximum.
- **Adding a mechanical lint check for the forbidden pattern.**
  Forward enforcement is by review (per the §8 style bullet) at
  least until contributor regression motivates automation. Out
  of scope here; can be added in a successor feature if needed.
- **Touching pilgrim voice, scripture mechanic, or any
  non-assertion content.** Constitution Principle V (pilgrim
  voice / pilgrimage flavor) is preserved by construction; no
  prose moves.
- **Re-deriving any solution from its koan or vice versa.**
  Solutions and koans are edited in lockstep; neither side is
  re-derived from the other. The PLAN.md §10 standard work order
  ("solution first, koan derived from it") applied at original
  authoring time; M2.5 edits both as already-paired files.

## Dependencies

- **Upstream (blocking)**: M2.2
  (`specs/004-m2-2-citation-rewrite/`) committed at HEAD of
  `main`. M2.2's citation rewrites must be in place before
  M2.5 edits the same files; otherwise, citation churn during
  the M2.5 cleanup would force re-review.
- **Upstream (blocking)**: M2.3
  (`specs/005-vocab-review/`) committed at HEAD of `main`.
  M2.3's vocabulary edits must be in place for the same reason;
  prose churn during M2.5 would force re-review.
- **Upstream (blocking)**: M2.4
  (`specs/006-citation-existence-lint/`) committed at HEAD of
  `main`. M2.4's lint extension is the existence-check guard
  for citations; M2.5 must not regress it. The dependency is on
  M2.4 already being merged so that FR-011's all-green claim
  is the post-M2.4 lint state, not the pre-M2.4 state.
- **Upstream (informational, on-branch)**: PLAN.md v1.4 with
  §M2.5 milestone and §8 style bullet (commit `9a5de4a` on this
  feature branch). FR-015 gates on this; the codification ships
  with the spec.
- **Downstream (informational)**: M3 — when Stages II + III
  koans (06–17) ship, every new assertion line MUST follow the
  cleaned shape from inception. M2.5's §8 style bullet is the
  authoritative reference for M3+ koan authors.

## Out-of-band Considerations

- **Working spike at `stash@{0}`.** A POC of the new shape
  applied to `koans/00_about_asserts.rexx` is preserved in the
  git stash on this branch (stash message: "spike: simplified
  assertion-line shape (M2.5 POC); per-line ordinal moved into
  m: wrapper"). The spike was UAT'd against `bin/pilgrimage`
  (both unsolved-state and solved-state) and `bin/verify_solutions`
  (6/6 green on solutions because solutions were not part of
  the spike) before being stashed. The spike demonstrates the
  mechanic is sound; it is a reference for the implementation,
  not the deliverable. The spec governs. The spike is dropped
  after merge.
- **Diff blast radius is small but uniform.** Twelve files,
  ~3–5 assertion-line edits per file plus one wrapper edit per
  file, totals roughly 50–70 line changes. The edit recipe is
  identical across files; review burden is the recipe × 12,
  not 12 × independent judgment.
- **No precedent for an "edit every koan" feature.**
  Prior milestones edited per-feature surfaces (M2.2: citations;
  M2.3: vocabulary; M2.4: lint script + contract). M2.5 is the
  first cleanup that touches the assertion mechanic itself
  across the corpus. The 12-file blast is intentional: shipping
  the cleanup atomically (rather than incrementally) preserves
  the SC-009 "diff returns only FILL_ME_IN substitutions" parity
  invariant on every file from the moment the feature lands.
