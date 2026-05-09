# Feature Specification: M2 — Walking Skeleton

**Feature Branch**: `002-m2-walking-skeleton`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "M2 — Walking Skeleton"

## Clarifications

### Session 2026-05-08

- Q: Teaching comment block granularity — one block per individual assertion, or one per logical concept group of related assertions? → A: One block per concept group (placed before the first assertion of the cluster); subsequent assertions in the same group do not need their own block.
- Q: Where does the pilgrim-voice subtitle in the station list live? → A: Each koan file declares its own subtitle in a structured header comment; `lib/stations.rexx` extracts subtitles by reading the koan files.
- Q: Should CI exercise the production runner end-to-end, beyond `verify_solutions` and `lint_citations`? → A: Yes — CI runs `lib/pilgrimage.rexx` against the fully-solved Stage I curriculum on both platforms, asserts exit 0 with a benediction, AND verifies the captured runner stdout is byte-identical to a recorded fixture committed in the repo (cross-platform fingerprint).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Walk the Foundation Stage end-to-end (Priority: P1)

A pilgrim clones the repository on macOS, follows the `README.md` start
instructions, and walks through all six Stage I koans (`00_about_asserts`
through `05_about_say`). Each koan starts with `FILL_ME_IN` blanks and at
least one failing assertion; with each correct fill the runner advances
to the next assertion or station. When the last assertion of the last
Stage I koan passes, the runner prints a closing benediction and exits
zero.

**Why this priority**: This is the central deliverable of M2. Without an
end-to-end pilgrim experience over Stage I, the curriculum has no
audience and the design decisions from M1 are unproven against real
teaching content. Every other piece of M2 exists to support this walk.

**Independent Test**: Can be fully tested by checking out the M2 branch
on a fresh macOS machine with Regina installed, running `bin/pilgrimage`,
and walking each koan through to its passing state using only what is
documented in `README.md` and the koan teaching comments. No outside
materials should be required.

**Acceptance Scenarios**:

1. **Given** a fresh clone on macOS with Regina REXX installed, **When**
   the pilgrim runs `bin/pilgrimage` for the first time, **Then** the
   runner stops at the first unfilled assertion in `koans/00_about_asserts.rexx`,
   prints the koan filename and line number, and prints the
   "awaits your contribution" message for the FILL_ME_IN.

2. **Given** a koan with an unfilled FILL_ME_IN, **When** the pilgrim
   replaces it with the correct value and re-runs the runner, **Then**
   the runner advances past that assertion and either stops at the next
   blank or progresses to the next koan.

3. **Given** all assertions across koans 00–05 are correctly filled in,
   **When** the pilgrim runs `bin/pilgrimage`, **Then** the runner walks
   every koan in order, prints a final benediction, and exits zero.

4. **Given** any Stage I koan, **When** a contributor reads it from top
   to bottom, **Then** every assertion is preceded by a teaching comment
   block containing a concept heading, two to six sentences of teaching
   prose, and a `Cowlishaw §N.N, p. NN` citation.

5. **Given** the matching solution for any Stage I koan, **When**
   `bin/verify_solutions` is run, **Then** the script exits zero,
   confirming every solution passes every assertion.

---

### User Story 2 - Resume at the first unsolved koan (Priority: P2)

A pilgrim has walked the first three Stage I koans on a previous day.
They open the runner again. The runner does not re-prompt them for
already-passed assertions; instead it picks up at the first koan whose
assertions do not all pass and stops there with the same diagnostic
behavior as a first-time encounter.

**Why this priority**: Resumption is the user-experience promise that
makes the koan format viable across multiple sittings. Without it, every
session forces the pilgrim to re-walk known ground or to manually skip
ahead. The mechanic is required by `PLAN.md` §5 ("Re-running the runner
picks up where the pilgrim left off").

**Independent Test**: Can be tested by filling in koans 00–02 to passing
state, leaving 03 with an unfilled blank, running `bin/pilgrimage`, and
verifying the runner stops at koan 03 — not earlier — with the standard
FILL_ME_IN diagnostic.

**Acceptance Scenarios**:

1. **Given** koans 00–02 pass all assertions and koan 03 contains an
   unfilled FILL_ME_IN, **When** the pilgrim runs `bin/pilgrimage`,
   **Then** the runner reports its first failure inside koan 03 and
   does not error inside koans 00–02.

2. **Given** all six Stage I koans pass, **When** the pilgrim runs
   `bin/pilgrimage`, **Then** the runner walks all stations and prints
   the closing benediction.

3. **Given** the runner is invoked twice in a row with no source
   changes between runs, **When** the second invocation completes,
   **Then** its behavior matches the first invocation exactly (state is
   re-derived from sources on each run; no hidden state file is required
   or written).

---

### User Story 3 - Station display shows progress (Priority: P3)

After each run, the pilgrim sees a fixed-pitch station list summarizing
the path: each koan with a status marker (`[  ok  ]` for passed,
`[ here ]` for the current station where karma was damaged, blank for
not yet attempted), a station number, the koan filename, and a short
pilgrim-voice subtitle. Below the list, a one-line summary states how
many stations the pilgrim has walked and where karma was damaged (if
applicable).

**Why this priority**: The station display is the pilgrim-facing surface
that turns "tests passed" into "progress made." It is mandated by
`PLAN.md` §11 and is the visual identity of the project. M2 is the first
milestone with enough koans for the display to matter. The runner could
ship without it, so it is P3, but the M2 release without it would feel
unfinished.

**Independent Test**: Can be tested by running `bin/pilgrimage` against
any combination of passed/here/unattempted koans and visually confirming
the output matches the format specified in `PLAN.md` §11. Format
correctness can be verified mechanically by string-matching the bracket
markers and station ordering; subtitle aesthetics are a contributor
review concern.

**Acceptance Scenarios**:

1. **Given** all six Stage I koans pass, **When** the pilgrim runs
   `bin/pilgrimage`, **Then** the station display shows six `[  ok  ]`
   markers, no `[ here ]` marker, and a summary line indicating six
   stations walked.

2. **Given** koans 00–02 pass and koan 03 has an unfilled FILL_ME_IN,
   **When** the pilgrim runs `bin/pilgrimage`, **Then** the station
   display shows `[  ok  ]` for koans 00–02, `[ here ]` for koan 03,
   and blank markers for koans 04–05; the summary names koan 03 as
   the station where karma was damaged.

3. **Given** the station display is rendered in a default terminal,
   **When** the pilgrim views it, **Then** the output uses no ANSI color
   escapes and renders identically on a monochrome terminal (color
   output is explicitly out of scope for M2).

---

### Edge Cases

- What happens when a pilgrim runs the runner with the koans directory
  empty? The runner must report the empty path explicitly (not crash
  silently) and exit non-zero.
- What happens when a pilgrim introduces a syntax error into a koan?
  Per ADR-003 from M1, the koan's subprocess exits non-zero with the
  Regina diagnostic on stderr; the runner surfaces the diagnostic and
  treats the koan as the failure point. The runner itself remains alive.
- What happens when a pilgrim deletes or renames a Stage I koan? The
  runner ordering is driven by `koans/path_to_enlightenment.rexx`; a
  missing koan must produce a clear error naming which entry could not
  be loaded, not an opaque `ADDRESS SYSTEM` failure.
- What happens when a Stage I koan's matching solution is missing or
  diverges from the koan? `bin/verify_solutions` must fail loudly,
  blocking CI per Constitution Principle IV.
- What happens when a koan's teaching comment lacks a `Cowlishaw §N.N,
  p. NN` citation? `bin/lint_citations` must fail loudly, blocking CI
  per Constitution Principle III.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The runner (`lib/pilgrimage.rexx`) MUST execute every koan
  listed in `koans/path_to_enlightenment.rexx` in order, stop at the
  first failing assertion, and report the koan filename and line number
  of the failure.
- **FR-002**: The runner MUST resume at the first koan whose assertions
  do not all pass on every invocation, deriving that position from the
  current state of the source files (no persisted state file).
- **FR-003**: The runner MUST exit zero only when all listed koans pass
  every assertion, and exit non-zero otherwise.
- **FR-004**: The runner MUST print a closing benediction in the project
  voice when, and only when, the pilgrim has walked the entire path.
- **FR-005**: The assertion library (`lib/meditation.rexx`) MUST provide
  the assertion vocabulary required by Stage I koans, at minimum
  `assert`, `assert_equal`, `assert_not_equal`, and `assert_datatype`.
- **FR-006**: The assertion library MUST distinguish a FILL_ME_IN blank
  from an incorrect filled-in value, producing a different diagnostic
  message for each case (per ADR-004 from M1).
- **FR-007**: The station display module (`lib/stations.rexx`) MUST
  render a fixed-pitch list of all stations with status markers
  `[  ok  ]`, `[ here ]`, and blank, plus a one-line summary of stations
  walked and the location of any failure, per `PLAN.md` §11. Each
  station's pilgrim-voice subtitle MUST be sourced from a structured
  header comment in the corresponding koan file (extracted by
  `lib/stations.rexx` at render time); no separate subtitle registry
  is maintained.
- **FR-008**: The station display MUST use no ANSI color escapes by
  default; M2 ships monochrome.
- **FR-009**: A POSIX shell launcher (`bin/pilgrimage`) MUST exist and
  invoke the runner correctly on macOS and Linux.
- **FR-010**: Six Stage I koans MUST exist (`koans/00_about_asserts.rexx`
  through `koans/05_about_say.rexx`) covering the topics in `PLAN.md` §4
  Stage I, with at least one matching solution file in `solutions/` for
  each.
- **FR-011**: Every Stage I koan MUST contain a teaching comment block
  before the first assertion of each concept group, with: a concept
  heading, two-to-six sentences of prose, and a `Cowlishaw §N.N, p. NN`
  citation per Constitution Principle III. Subsequent assertions within
  the same concept group do not require their own teaching block. A
  concept group is a contiguous set of assertions that exercise one
  named concept (e.g., "concatenation by abuttal vs. by blank").
- **FR-012**: `bin/verify_solutions` MUST run every file in `solutions/`
  through the assertion machinery and fail if any solution fails any
  assertion.
- **FR-013**: `bin/lint_citations` MUST scan every file in `koans/` and
  fail if any koan is missing a well-formed `Cowlishaw §N.N, p. NN`
  citation.
- **FR-014**: The CI workflow (`.github/workflows/verify.yml`) MUST run
  `verify_solutions`, `lint_citations`, AND a runner end-to-end smoke
  step on both `ubuntu-latest` and `macos-latest` on every push and
  pull request to `main`, and MUST be green before any merge to
  `main`.
- **FR-017**: The CI runner smoke step MUST execute `lib/pilgrimage.rexx`
  against the fully-solved Stage I curriculum (sourced from
  `solutions/`), assert exit code 0, assert the closing benediction is
  present in the captured stdout, and verify that the captured stdout
  is byte-identical to a recorded fixture committed in the repository.
  The same fixture MUST satisfy both the macOS and Ubuntu jobs (single
  cross-platform fingerprint).
- **FR-015**: `koans/path_to_enlightenment.rexx` MUST list the six Stage I
  koans in the curricular order specified in `PLAN.md` §4 and serve as
  the single source of truth for runner ordering.
- **FR-016**: The `README.md` start instructions MUST be sufficient for a
  pilgrim with Regina REXX installed to begin the pilgrimage with no
  additional documentation lookups, including the link to the Internet
  Archive scan of *The REXX Language* (2nd edition).

### Key Entities

- **Runner** (`lib/pilgrimage.rexx`): Production runner. Loads the
  ordered koan list, executes each koan as a subprocess (per ADR-001),
  reports the first failure, and prints the closing benediction on a
  fully passing walk.
- **Assertion Library** (`lib/meditation.rexx`): Provides the assertion
  vocabulary used by Stage I koans, with FILL_ME_IN-aware diagnostics.
- **Station Display Module** (`lib/stations.rexx`): Renders the
  fixed-pitch progress list and summary line per `PLAN.md` §11.
- **Path Manifest** (`koans/path_to_enlightenment.rexx`): Master ordering
  file enumerating the six Stage I koans for the runner to walk.
- **Stage I Koans** (`koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx`): The six teaching koans of Stage I, each
  with teaching comments, citations, a structured header comment
  declaring the koan's pilgrim-voice subtitle, and at least one
  FILL_ME_IN blank.
- **Stage I Solutions** (`solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx`): Matching passing implementations for
  each Stage I koan, verified by `bin/verify_solutions`.
- **Pilgrimage Launcher** (`bin/pilgrimage`): POSIX shell launcher that
  invokes the runner with appropriate environment for macOS and Linux.
- **Runner Smoke Fixture**: A recorded reference of the runner's stdout
  for a fully-solved Stage I walk, committed in the repository and
  consumed by the CI runner smoke step (FR-017) on both platforms.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A pilgrim on a fresh macOS clone, with only Regina REXX
  installed and `README.md` open, can walk all six Stage I koans to a
  passing state in under sixty minutes of focused study time, with no
  guidance beyond the koan teaching comments and the Cowlishaw reference.
- **SC-002**: The runner, on a fully solved Stage I, walks all six
  stations and prints the closing benediction in under one second on
  a development laptop.
- **SC-003**: CI passes green on both `ubuntu-latest` and `macos-latest`
  for both `verify_solutions` (six solutions, zero failures) and
  `lint_citations` (six koans, zero missing citations) on every push to
  the M2 branch.
- **SC-004**: A pilgrim who has solved koans 00–02 and re-runs the
  pilgrimage sees the runner advance past those three koans without
  re-emitting their FILL_ME_IN diagnostics, and stops at the first
  unsolved assertion in koan 03 (or wherever the next blank lives).
- **SC-005**: Every assertion in every Stage I koan can be made to pass
  by replacing FILL_ME_IN values alone, without modifying any other line
  of the koan — confirmed by `bin/verify_solutions` against the matching
  solution files.
- **SC-006**: The runner's stdout for a fully-solved Stage I walk is
  byte-identical on macOS and Ubuntu, confirmed by the CI runner smoke
  step (FR-017) matching a single committed reference fixture on both
  platforms.

## Assumptions

- M2 builds on the design decisions recorded in M1's
  `docs/DESIGN_DECISIONS.md`, specifically the subprocess loading model
  (ADR-001) and the FILL_ME_IN detection mechanism (ADR-004). M2 does
  not re-investigate those decisions; it adopts them.
- The M1 smoke koan (`koans/00_about_smoke.rexx`) and its solution are
  replaced by the production curriculum and removed in M2. `PLAN.md`
  §10 explicitly permits this ("M1 source files may be partially
  salvaged into M2 or fully discarded; either is acceptable").
- The scripture mechanic (`lib/scripture.rexx`) is M3 work and is out of
  scope for M2. Stage I koans MUST NOT depend on it.
- Stages II through VI, the capstone, and the addenda (z/OS, OPS/MVS)
  are explicitly out of scope.
- The Windows launcher (`bin/pilgrimage.bat`) is deferred to M7
  (Portability) and is not required by M2. M2 targets macOS and Ubuntu
  only.
- ANSI color in the station display is explicitly deferred to future
  work (`PLAN.md` §11). M2 ships monochrome.
- The single capstone exercise (`the_pilgrim_writes_a_program.rexx`) is
  M6 work and is out of scope for M2.
- The hint system, color in station display, and solutions-on-a-branch
  alternatives listed in `PLAN.md` §14 remain deferred and are out of
  scope.
- Regina REXX (3.9.x) installed via Homebrew on macOS and via apt on
  Ubuntu is the only supported development and CI environment for M2,
  matching the M1 baseline.
- Page numbers in citations are verified at writing time by the koan
  author against a local copy of *The REXX Language* (2nd edition) per
  Constitution Principle III; CI verifies citation **format** only.
