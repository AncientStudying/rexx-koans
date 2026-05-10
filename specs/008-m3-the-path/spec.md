# Feature Specification: M3 — The Path

**Feature Branch**: `008-m3-the-path`
**Created**: 2026-05-10
**Status**: Draft
**Input**: User description: "M3 — The Path"

## Background

PLAN.md §10 defines M3 — The Path as: "Stages II and III koans (06–17)
with matching solutions. Scripture mechanic implemented and exercised by
at least three koans." This feature delivers that scope on the
foundations laid by M1 (design validation), M2 (walking skeleton), and
M2.1–M2.5 (citation index, citation rewrite, vocabulary review,
mechanical citation existence check, and the assertion-line shape
cleanup).

**Curriculum scope** (PLAN.md §4):

- **Stage II — The Path** (control flow), six koans:
  - 06 `about_if` — IF/THEN/ELSE (Cowlishaw §2.7, p. 54).
  - 07 `about_select` — SELECT/WHEN/OTHERWISE/END (§2.7, p. 71).
  - 08 `about_do_loops` — DO group, controlled DO, WHILE, UNTIL,
    FOREVER (§2.7, p. 47).
  - 09 `about_iterate_leave` — ITERATE (§2.7, p. 57), LEAVE
    (§2.7, p. 58).
  - 10 `about_signal` — non-local transfer via SIGNAL labelname
    (§2.7, p. 72). The SIGNAL ON / CALL ON condition-trapping forms
    are deferred to Stage VI's `about_conditions` (out of scope here).
  - 11 `about_interpret` — runtime evaluation via INTERPRET
    (§2.7, p. 55).
- **Stage III — The Tools** (built-in functions), six koans:
  - 12 `about_string_functions` — LENGTH, SUBSTR, POS, LEFT, RIGHT,
    COPIES, TRANSLATE (all §2.9).
  - 13 `about_word_functions` — WORD, WORDS, WORDPOS, WORDLENGTH,
    SUBWORD, WORDINDEX (all §2.9).
  - 14 `about_arithmetic_functions` — ABS, MAX, MIN, TRUNC, FORMAT,
    SIGN (all §2.9).
  - 15 `about_conversion_functions` — D2X, X2D, C2X, X2C, B2X, X2B,
    D2C, C2D (all §2.9).
  - 16 `about_bit_functions` — BITAND, BITOR, BITXOR (all §2.9).
  - 17 `about_misc_functions` — DATATYPE, DATE, TIME, RANDOM,
    ADDRESS-the-built-in (returns the current environment name; *not*
    the ADDRESS instruction, which is deferred to Stage VI's
    `about_address`).

(Every citation in the delivered koans MUST resolve against an
existing row in `docs/cowlishaw_index.md` — see FR-006. Page numbers
are sourced row by row at authoring time, not from this spec.)

**Scripture mechanic.** PLAN.md §9 introduces the Bathonian scripture
mechanic: `lib/scripture.rexx` holds a small lookup keyed by short tag
(initial set: `humans_not_machines`, `least_astonishment`,
`everything_is_string`, `read_aloud`, `consistency`,
`whitespace_matters_just_enough`, `numbers_are_strings_too`). PLAN.md
§5 also says the runner "re-prints the relevant Cowlishaw scripture for
that koan" at failure time. M3 is the milestone in which this mechanic
goes from doc-only to running code; at least three koans MUST invoke
scripture.

The binding from a koan-test to a scripture key is a **per-test
directive comment with runner-side detection**, mirroring the
project's existing patterns:

- A scripture-bound test is preceded by a `Scripture: <key>` line
  inside its teaching comment block — adjacent to the existing
  `Cowlishaw §N.N, p. NN` citation. PLAN.md §9 names this location
  verbatim ("in a comment block at the top of the relevant test").
- The runner, on a koan-subprocess failure, scans the failed koan's
  source to find the relevant `Scripture: <key>` directive, looks up
  the key in `lib/scripture.rexx`, and emits the principle text after
  the meditation diagnostic.
- `lib/meditation.rexx` is unchanged. The 6-argument dispatcher
  contract from M2 carries through M3 verbatim.
- The koan-local `m:` wrapper stays three-arg (`kind, arg1, arg2`).
  Scripture-bound assertion lines look identical to non-bound lines:
  `CALL m '<verb>', <expected>, <actual>`. The M2.5 minimal-shape
  ideal is preserved.

This choice falls naturally out of three patterns already in the
codebase: (1) every test already has a per-test teaching comment
block carrying its own Cowlishaw citation, so a sibling
`Scripture:` directive sits where the prose already lives;
(2) `lib/stations.rexx`'s `extract_subtitle` already harvests a
directive (`Station:`) by source-scanning a koan's leading comment
block, so runner-side directive harvesting has precedent and an
implementation pattern to reuse; (3) M2.5 just collapsed every
assertion line to its minimum, and routing scripture through the
`m:` wrapper would re-clutter assertion lines — a direct regression
of the milestone we just shipped.

**Forward-style baseline.** Every M3 koan and solution MUST be authored
in the M2.5 cleaned shape from inception (PLAN.md §8): single-statement
assertion lines `CALL m '<verb>', <arg1>, <arg2>` with no per-line
counter, a single `n = 0` initializer at the top, and a three-arg
`m:` wrapper at the foot that increments `n` internally before
delegating to `lib/meditation.rexx`. Reintroducing the legacy
`n = n + 1; ... , n` pattern is a review-blocker.

**The pilgrim-facing change.** A pilgrim on `main` today sees a
six-station path ending at `[ ok ] 05 about_say  The Pilgrim Speaks`
followed by "The pilgrim has walked the foundation. The path opens
further." After M3 ships, that same pilgrim sees an eighteen-station
path; solving 06 advances to 07, 07 to 08, and so on through 17, and
the closing benediction reflects the larger journey. On a failure of a
scripture-bound test, the pilgrim sees the relevant principle alongside
the standard "Damaged at: …" diagnostic.

**Out-of-scope reminders.** M3 does not begin Stage IV (numbers,
parsing, ARG; reserved for M4) or Stage V (functions, scoping; M4) or
Stage VI (I/O, ADDRESS instruction, conditions, TRACE, special
variables, extendibility; M5). The capstone is M6. Portability
validation is M7.

PLAN authority for this feature: §10 ("M3 — The Path"), §4 (curriculum
table), §5 (runner architecture, scripture re-print), §8 (style
guidelines including the M2.5 line shape), §9 (scripture mechanic),
§11 (achievement output / station subtitles).

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Pilgrim walks Stage II, control flow (Priority: P1) 🎯 MVP

A pilgrim who has completed Stage I re-runs `bin/pilgrimage`. The
station list now shows eighteen rows, and the runner stops at the first
unsolved blank in `koans/06_about_if.rexx`. The pilgrim reads the
teaching block, fills the blank, re-runs, and advances. The same pattern
carries them through 07 SELECT, 08 DO, 09 ITERATE/LEAVE, 10 SIGNAL,
and 11 INTERPRET. Every teaching block teaches the construct from the
comment alone — the pilgrim does not need to consult Cowlishaw to make
the test pass — and every assertion line shows only the REXX being
taught, with no per-line counter bookkeeping.

**Why this priority**: Stage II is the half-way mark of the curriculum
and the most visible deliverable in M3. Without it, the pilgrim hits a
dead end at koan 05 and the milestone has shipped nothing beyond
infrastructure. P1 because it is the user-facing core of the feature.

**Independent Test**: Check out the feature branch on a fresh clone,
fill the blanks in `solutions/06_about_if.rexx` through
`solutions/11_about_interpret.rexx` into the matching `koans/`
files (or copy them wholesale, then verify), and run
`bin/pilgrimage`. The runner must advance through stations 00–11
without error, leaving 12–17 blank. Repeated for each Stage II koan
solved sequentially: solve 06 → runner stops at 07; solve 07 → stops
at 08; etc. through 11.

**Acceptance Scenarios**:

1. **Given** a pilgrim has filled the blanks in koans 00–05, **When**
   they run `bin/pilgrimage` on the post-M3 corpus, **Then** the runner
   stops at the first blank in `koans/06_about_if.rexx` with a
   `Damaged at: koans/06_about_if.rexx, line N` diagnostic naming the
   blank's line.
2. **Given** the same pilgrim has now also filled koan 06's blanks
   correctly, **When** they re-run `bin/pilgrimage`, **Then** the runner
   advances past 06 and stops at the first blank in
   `koans/07_about_select.rexx`.
3. **Given** the pilgrim continues solving 07 through 11 in turn,
   **When** they re-run `bin/pilgrimage` after each koan,
   **Then** the runner advances one station per pass and the
   station-list `[ here ]` marker moves accordingly through the Stage II
   row band.
4. **Given** the pilgrim deliberately enters a wrong fill in any
   Stage II koan, **When** they run `bin/pilgrimage`, **Then** the
   meditation library's failure message names the koan, the assertion
   ordinal, the expected vs received values, and the source line —
   exactly as it does for Stage I koans.

---

### User Story 2 — Pilgrim walks Stage III, the built-in toolbox (Priority: P1)

A pilgrim who has completed Stages I–II works through six built-in-
function koans: 12 string, 13 word, 14 arithmetic, 15 conversion,
16 bit, 17 misc. Each koan teaches a small, related family of
built-ins from `Cowlishaw §2.9 — Built-in Functions`, with each test
preceded by a teaching block citing the specific built-in's index row.
The pilgrim leaves Stage III able to manipulate strings, words,
numbers, encodings, and bits using only Regina's standard built-ins.

**Why this priority**: Stage III is the second half of M3's curricular
deliverable and the foundation on which Stages IV–VI build (parsing
templates, arithmetic precision, ADDRESS, I/O, conditions all rely on
the built-in repertoire). P1 because the milestone explicitly names
"Stages II and III"; shipping only Stage II would not satisfy the
milestone definition.

**Independent Test**: Same as US1 but for stations 12–17. After Stage II
is solved, the pilgrim's runner stops at the first blank in
`koans/12_about_string_functions.rexx`. They solve each in turn through
17. After 17 is solved, the runner reaches the end of the path and
emits the closing benediction.

**Acceptance Scenarios**:

1. **Given** a pilgrim has solved koans 00–11, **When** they run
   `bin/pilgrimage`, **Then** the runner stops at the first blank in
   `koans/12_about_string_functions.rexx`.
2. **Given** the same pilgrim solves 12 through 17 in turn,
   **When** they re-run `bin/pilgrimage` after each, **Then** the
   runner advances one station per pass through the Stage III row band.
3. **Given** the pilgrim solves all 18 koans correctly, **When** they
   run `bin/pilgrimage`, **Then** the runner prints the full station
   list with `[ ok ]` on every row, the summary line showing
   "Stations walked: 18 of 18.", and the closing benediction; exit
   code is 0.
4. **Given** any Stage III koan, **When** the pilgrim reads its
   teaching blocks unaided, **Then** every block names a single
   Cowlishaw built-in by its canonical name (matching the function's
   row title in `docs/cowlishaw_index.md`) and cites that row.

---

### User Story 3 — Scripture amplifies failure on principle-bearing koans (Priority: P1)

A pilgrim damages their karma on a koan whose teaching turns on one of
the Bathonian's design principles — for example, `everything_is_string`
in a Stage III string-functions koan, or `least_astonishment` in a
Stage II SELECT koan. The runner's failure output includes, in addition
to the standard meditation diagnostic and the `Damaged at:` line, the
relevant scripture: a short attributed quotation or principle statement
that connects the failed test to Cowlishaw's intent. The amplification
appears only on tests that genuinely turn on a principle; koans whose
tests are mechanical have no scripture and the failure output is
unchanged. At least three of the twelve M3 koans are scripture-bound
in this way.

**Why this priority**: PLAN.md §10 explicitly requires "Scripture
mechanic implemented and exercised by at least three koans" as part
of M3. PLAN.md §5 specifies that the runner "re-prints the relevant
Cowlishaw scripture for that koan" at failure time. Without the
runtime mechanism, scripture is documentation rather than a feature
of the pilgrimage. P1 because it is the milestone's third named
deliverable.

**Independent Test**: Identify the M3 koans that are scripture-bound
(at least three; the working list is in this spec's Assumptions
section). For each, deliberately introduce a wrong fill that would
cause the scripture-bound assertion to fail; run `bin/pilgrimage`;
capture stdout; confirm the relevant principle text appears in the
failure output for that test. Then run the same wrong fill against a
non-scripture-bound koan in M3; confirm no scripture text appears.

**Acceptance Scenarios**:

1. **Given** a M3 koan whose failing assertion is scripture-bound to
   key K, **When** that assertion fails, **Then** the runner's stdout
   for that station contains, in addition to the standard meditation
   diagnostic, the principle text associated with key K as defined
   in `lib/scripture.rexx`.
2. **Given** an M3 koan whose failing assertion is NOT scripture-bound,
   **When** that assertion fails, **Then** the runner's stdout for
   that station is identical in shape to a Stage I failure — meditation
   diagnostic + "Damaged at:" line + nothing else.
3. **Given** all M3 koans pass, **When** the runner runs to completion,
   **Then** no scripture text appears in stdout. Scripture is a
   failure-time amplification, not a passing-state decoration.
4. **Given** the M3 spec acceptance review, **When** a maintainer
   counts the scripture-bound koans, **Then** the count is at least 3
   (PLAN.md §10).

---

### User Story 4 — Solutions ship in lockstep with koans (Priority: P1)

A pilgrim or maintainer who consults `solutions/` after solving a
Stage II or III koan finds a parallel file with the same teaching
prose, the same `Station:` directive, the same M2.5 cleaned assertion
shape, and only the FILL_ME_IN values resolved to the canonical
answers. `bin/verify_solutions` runs every solution through the same
assertion machinery and reports `18 of 18 solutions passed.` (the M2
fixture said `6 of 6`; M3 grows the count to 18).

**Why this priority**: Constitution Principle I (Solution-First
Development) is non-negotiable: every koan ships with its passing
solution. P1 because shipping a koan without its matching verified
solution violates the project constitution and breaks CI.

**Independent Test**: Run `bin/verify_solutions` on the feature
branch HEAD; observe `18 of 18 solutions passed.` (or equivalent
all-green report). For each Stage II/III file pair, run
`diff koans/NN_about_*.rexx solutions/NN_about_*.rexx` and confirm
the diff consists solely of FILL_ME_IN-vs-value substitutions on
the documented blank positions — no shape differences, no wrapper
differences, no idiomatic differences (the M2.5 SC-009 invariant
extended to Stages II–III).

**Acceptance Scenarios**:

1. **Given** the feature branch HEAD, **When** a maintainer runs
   `bin/verify_solutions`, **Then** the script reports all 18
   solution files green and exits 0.
2. **Given** any Stage II/III file pair (06–17 koan ↔ 06–17
   solution), **When** the maintainer diffs them, **Then** the
   only differences are FILL_ME_IN-vs-value substitutions on the
   blank positions named in each koan's teaching prose.
3. **Given** any Stage II/III koan, **When** the maintainer
   inspects its `m:` wrapper, **Then** the wrapper takes exactly
   three positional arguments (`kind, arg1, arg2`), increments
   `n` internally, and passes `n` to `lib/meditation.rexx` as
   the 5th argument and `SIGL` as the 6th — matching the M2.5
   shape verbatim.

---

### User Story 5 — Citations resolve against the Cowlishaw index (Priority: P1)

Every teaching block in every Stage II and Stage III koan and matching
solution carries a citation in canonical form `Cowlishaw §N.N, p. NN`
(optionally followed by ` — <heading>` for child-heading
disambiguation). `bin/lint_citations` — extended in M2.4 to perform
the index-existence join — accepts every citation: each (§N.N, page)
pair (and the optional suffix where present) resolves against an
existing row in `docs/cowlishaw_index.md`. No M3 citation introduces
a "fictional" reference (the M2 failure mode that motivated M2.1).

**Why this priority**: Constitution Principle III (Every Koan Is
Self-Teaching) requires the canonical citation form, and M2.4's
mechanical existence check is the guard that keeps citations honest.
P1 because a fabricated citation is a regression of the M2.4 promise
and a Constitution Principle III violation.

**Independent Test**: Run `bin/lint_citations` on the feature branch
HEAD; observe all-green output for every koan and solution file in
Stages I–III. Spot-check at least three Stage II citations and three
Stage III citations against `docs/cowlishaw_index.md` to confirm the
(§N.N, page) row exists and the page matches the row's `**Page:**`
field. The M2.4 negative spot-check (a fabricated citation rejected
at lint time) continues to hold; the post-M3 lint exhibits the same
rejection on the same fabricated input.

**Acceptance Scenarios**:

1. **Given** the feature branch HEAD, **When** a maintainer runs
   `bin/lint_citations`, **Then** the script reports all-green for
   every file in `koans/` and `solutions/` (Stages I–III, 18 files
   each side).
2. **Given** any Stage II/III citation, **When** a reviewer looks
   up the cited (§N.N, page) pair in `docs/cowlishaw_index.md`,
   **Then** an existing row is found whose `**Page:**` field equals
   the citation's page number.
3. **Given** a fabricated citation deliberately introduced into a
   sandbox copy of a Stage II/III koan, **When** the lint runs,
   **Then** the script rejects the citation with a
   citation-resolves-to-no-row error. Revert.

---

### User Story 6 — Path manifest, station display, and runner-smoke fixture grow to 18 stations (Priority: P2)

The path manifest `koans/path_to_enlightenment.rexx` declares 18 koans
in numeric order. The station-list display (`lib/stations.rexx`)
renders 18 rows, each with the canonical `NN about_<topic>` and the
koan's `Station:` subtitle. The runner-smoke fixture
`tests/fixtures/runner_stdout.txt` is regenerated from a fully-solved
walk and committed; CI compares the runner's stdout byte-for-byte
against this fixture on both `ubuntu-latest` and `macos-latest`.

**Why this priority**: P2 because it is the project-level acceptance
gate that fires automatically once the user-facing US1–US5 deliverables
land. The fixture update is mechanical (regenerate, commit, watch CI
turn green); the manifest and station display already support arbitrary
counts (the M2 walking skeleton designed for it). Mirrors the
M2.5 US4 framing.

**Independent Test**: Push the feature branch; observe GitHub Actions
reports `success` on both runner-smoke jobs (ubuntu-latest and
macos-latest). Locally, run `bin/pilgrimage > /tmp/out` against the
fully-solved corpus and confirm `diff -u tests/fixtures/runner_stdout.txt
/tmp/out` returns empty (modulo CRLF normalization).

**Acceptance Scenarios**:

1. **Given** the M3 changes pushed to `origin/008-m3-the-path`,
   **When** GitHub Actions runs the `verify` workflow, **Then** all
   six matrix steps (`verify_solutions`, `lint_citations`,
   `runner-smoke`, each on `ubuntu-latest` and `macos-latest`)
   complete with conclusion `success`.
2. **Given** the path manifest at HEAD, **When** a maintainer reads
   `koans/path_to_enlightenment.rexx`, **Then** `koans.0 = 18` and
   `koans.1` through `koans.18` enumerate the eighteen koan files in
   numeric order from `00_about_asserts` through `17_about_misc_functions`.
3. **Given** the runner-smoke fixture at HEAD, **When** a maintainer
   runs `bin/pilgrimage` against the fully-solved corpus and diffs
   stdout against the fixture, **Then** the diff is empty.

---

### Edge Cases

- **A pilgrim solves Stage I and Stage III but not Stage II.** The
  runner walks 00–05 green, stops at the first blank in 06. There is
  no path to 12+ that bypasses 06–11; the manifest is linear.
- **A pilgrim deliberately introduces a syntax error in a Stage II
  koan.** Per M1 ADR-001 (subprocess isolation), the koan runs as a
  Regina subprocess and any SYNTAX condition aborts the subprocess
  with non-zero RC. The runner reports the failure and exits.
  Behavior matches Stage I; M3 does not change this.
- **A Stage II koan teaches INTERPRET, which compiles a string at
  runtime.** The teaching value of INTERPRET is precisely that the
  pilgrim sees their fill substituted into a string and executed.
  The koan's assertion confirms the resulting computed value.
  Edge: if the pilgrim's fill is itself syntactically invalid REXX,
  the koan subprocess aborts with a SYNTAX condition. Same handling
  as any other malformed fill.
- **A Stage III koan tests a built-in whose result varies by NUMERIC
  setting (FORMAT, TRUNC).** The koan asserts only against values
  produced under the default NUMERIC settings (DIGITS 9, FORM
  SCIENTIFIC, FUZZ 0). The teaching block names the dependence
  explicitly when the choice matters; deeper NUMERIC manipulation
  is reserved for Stage IV's `about_numbers_arithmetic`.
- **A scripture-bound koan's failing assertion is itself the
  blank-not-filled case (FILL_ME_IN).** The meditation library
  reports `fail_blank` (RC 1), not `fail_mismatch` (RC 2). The
  runner's scripture emission (FR-025) fires on any non-zero RC
  from a koan subprocess, including `fail_blank`, because the
  principle illuminates the test regardless of which failure
  mode triggered it.
- **A Stage III koan's built-in produces a result whose REXX type
  is not obvious (e.g., RANDOM returns a number string but its
  shape may surprise).** The teaching block frames the result type
  explicitly — using Cowlishaw's vocabulary from the index row —
  and the assertion uses `eq` against a literal-string expectation,
  not type-magic. This is the project pattern from Stage I.
- **Two different built-ins share a §2.9 page.** This is common
  (the index has many §2.9 entries clustered on a page or two).
  The citation form `Cowlishaw §2.9, p. NN — <built-in name>`
  disambiguates per Constitution Principle III's child-heading
  suffix. M2.4's existence check joins on the suffix.
- **A koan's `Station:` directive is missing.** `lib/stations.rexx`'s
  `extract_subtitle` returns the empty string, and the station-list
  row renders without a subtitle — visually broken. M3's exit gate
  is the runner-smoke fixture: a missing subtitle would change the
  fixture and fail CI. Hard guard.
- **A scripture key is invoked by a koan but is not defined in
  `lib/scripture.rexx`.** The runner's lookup returns the empty
  string (or similar sentinel); the runner falls back to the
  Stage I failure shape (no scripture lines). Acceptance: this
  case is forbidden in M3 by review (a koan citing an undefined
  key is rejected). A mechanical lint for scripture-key existence
  is out of scope (see the Out of Scope section).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: New koan files MUST exist:
  `koans/06_about_if.rexx`, `koans/07_about_select.rexx`,
  `koans/08_about_do_loops.rexx`, `koans/09_about_iterate_leave.rexx`,
  `koans/10_about_signal.rexx`, `koans/11_about_interpret.rexx`,
  `koans/12_about_string_functions.rexx`,
  `koans/13_about_word_functions.rexx`,
  `koans/14_about_arithmetic_functions.rexx`,
  `koans/15_about_conversion_functions.rexx`,
  `koans/16_about_bit_functions.rexx`,
  `koans/17_about_misc_functions.rexx`. Twelve files.
- **FR-002**: New solution files MUST exist with the same numeric
  prefixes and names under `solutions/`. Twelve files.
- **FR-003**: Every M3 koan and solution MUST be authored in the
  M2.5 cleaned shape from inception:
  - exactly one `n = 0` initializer at the top of the file (above
    the first concept block);
  - every assertion line is a single-statement
    `CALL m '<verb>', <arg1>, <arg2>` with no `n = n + 1;` prefix
    and no trailing `, n` argument; scripture binding does not
    extend the assertion line — the binding lives in the preceding
    teaching comment block (FR-024);
  - exactly one koan-local `m:` wrapper at the foot of the file
    that increments `n` internally before delegating, and forwards
    `n` and `SIGL` to `lib/meditation.rexx` as the 5th and 6th
    arguments respectively;
  - the wrapper's third argument to `lib/meditation.rexx` is the
    file's own relative path (e.g., `'koans/06_about_if.rexx'`
    inside the koan; `'solutions/06_about_if.rexx'` inside the
    solution).
- **FR-004**: A grep for the substring `n = n + 1;` followed (with
  optional whitespace) by `CALL m` across `koans/*.rexx` and
  `solutions/*.rexx` MUST return zero matches on the feature branch
  HEAD. (Forward enforcement of the M2.5 forbidden-pattern rule.)
- **FR-005**: A grep for `CALL m` lines passing a trailing bare
  token `n` as the final positional argument across `koans/*.rexx`
  and `solutions/*.rexx` MUST return zero matches on the feature
  branch HEAD.
- **FR-006**: Every teaching block in every M3 koan and matching
  solution MUST contain a citation in canonical form
  `Cowlishaw §N.N, p. NN`, optionally followed by ` — <heading>`
  for child-heading disambiguation. Every (§N.N, page) pair (and
  every suffix where present) MUST resolve against an existing row
  in `docs/cowlishaw_index.md`, as enforced by `bin/lint_citations`.
- **FR-007**: Every M3 koan MUST contain a `Station: <subtitle>`
  directive in the file's leading comment block, in the same form
  used by Stage I koans. Subtitles MUST be unique across the
  manifest and conform to the pilgrim-voice register of PLAN.md §11.
- **FR-008**: Every test in every M3 koan MUST be preceded by a
  teaching comment block containing (a) a short concept heading,
  (b) two to six sentences of prose sufficient to make the test
  pass without consulting the book, and (c) the Cowlishaw citation
  named in FR-006. (Constitution Principle III.)
- **FR-009**: `koans/path_to_enlightenment.rexx` MUST be updated
  to declare `koans.0 = 18` and to enumerate `koans.1` through
  `koans.18` in numeric order from `koans/00_about_asserts.rexx`
  through `koans/17_about_misc_functions.rexx`.
- **FR-010**: `lib/scripture.rexx` MUST exist as a Regina-only
  REXX library. It MUST expose at least the seven scripture keys
  named in PLAN.md §9: `humans_not_machines`, `least_astonishment`,
  `everything_is_string`, `read_aloud`, `consistency`,
  `whitespace_matters_just_enough`, `numbers_are_strings_too`. For
  each key, the library MUST provide both a short principle text
  (suitable for inline display in a runner failure message) and a
  Cowlishaw citation pointing to the passage from which the
  principle is drawn (resolving against `docs/cowlishaw_index.md`
  per FR-006).
- **FR-011**: At least three of the twelve M3 koans MUST be
  scripture-bound: i.e., at least one assertion in each is
  associated with a scripture key via a `Scripture: <key>`
  directive in the assertion's teaching comment block (FR-024).
  The runner surfaces the principle on failure of that assertion
  (FR-012, FR-025).
- **FR-012**: When the runner detects a failed assertion in a
  scripture-bound koan, it MUST emit, in addition to the standard
  meditation diagnostic and the `Damaged at:` line, the principle
  text and citation associated with the bound scripture key. When
  the failed assertion is not scripture-bound, the runner output
  MUST be identical in shape to the Stage I failure output (no
  scripture lines). Scripture text MUST appear after the meditation
  diagnostic and before the runner's station-list and summary
  output (Constitution Principle V — diagnostic first).
- **FR-013**: A passing assertion MUST NOT produce scripture
  output. Scripture is a failure-time amplification only.
- **FR-014**: `bin/verify_solutions` MUST report 18 of 18
  solutions green on the feature branch HEAD prior to merge.
- **FR-015**: `bin/lint_citations` MUST report all-green on the
  feature branch HEAD prior to merge across all 18 koan files and
  all 18 solution files. Both the canonical-form check (M2.2) and
  the index-existence join (M2.4) MUST pass.
- **FR-016**: `tests/fixtures/runner_stdout.txt` MUST be updated
  on the feature branch to match the post-M3 fully-solved walk
  byte-for-byte. The fixture grows from 12 lines (M2's six-station
  walk + benediction) to a length consistent with eighteen station
  rows + summary + benediction. The closing benediction line MAY
  be updated to reflect the larger journey or MAY be retained
  verbatim — see Assumptions.
- **FR-017**: `bin/pilgrimage` against the post-M3 fully-solved
  corpus MUST exit 0 and produce stdout byte-identical to the
  updated `tests/fixtures/runner_stdout.txt` (modulo CRLF
  normalization).
- **FR-018**: All six CI workflow checks (`verify_solutions`,
  `lint_citations`, `runner-smoke`, each on `ubuntu-latest` and
  `macos-latest`) MUST be green on the feature branch HEAD prior
  to merge. (Constitution Principle IV.)
- **FR-019**: `lib/meditation.rexx` MUST NOT be modified by this
  feature. Its external interface (six positional arguments,
  return codes 0/1/2, the diagnostic strings emitted on
  fail_blank and fail_mismatch) carries forward from M2 unchanged.
  The scripture mechanism is implemented runner-side (see
  FR-025); meditation has no view of, and no responsibility for,
  scripture. The four assertion verbs (`eq`, `neq`, `true`,
  `datatype`) suffice for every Stage II and Stage III koan and
  are not extended.
- **FR-020**: M3 MUST NOT introduce content from Stages IV–VI:
  - no NUMERIC instruction; no PARSE instruction; no PROCEDURE
    instruction; no ARG/PULL keyword instructions; no CALL form
    teaching beyond the existing `CALL m` invocation pattern; no
    user-defined internal or external routines beyond the koan-
    local `m:` wrapper; no I/O built-ins (LINEIN, LINEOUT,
    CHARIN, CHAROUT, STREAM); no ADDRESS instruction; no
    SIGNAL ON / CALL ON condition trapping; no TRACE; no special
    variables RC/RESULT/SIGL teaching beyond the framework's
    existing internal use of SIGL inside the wrapper.
  - The Stage III `about_misc_functions` koan MAY teach the
    ADDRESS *built-in function* (returns the current environment
    name) per Cowlishaw §2.9; this is distinct from the
    ADDRESS *instruction* (Stage VI).
- **FR-021**: Constitution Principle II (No Third-Party REXX
  Libraries) MUST be honored: every koan, solution, and
  `lib/scripture.rexx` MUST use only Regina built-ins and language
  features. No external REXX libraries.
- **FR-022**: Constitution Principle V (Voice — Diagnostic First,
  Pilgrimage Flavor Second) MUST be honored: every teaching block
  addresses the pilgrim in second person; humor is restrained;
  failure messages remain diagnostic-first; scripture text appears
  *after* the meditation diagnostic, not before.
- **FR-023**: PLAN.md authority MUST be cited in M3 artifacts
  (this spec, the planning artifact, and the implementation
  artifact) as PLAN.md v1.4 §10 (M3), §9 (scripture), §5 (runner
  re-print), §4 (curriculum table), §11 (station subtitles), §8
  (M2.5 cleaned shape).
- **FR-024**: A `Scripture:` directive MUST take the shape
  `Scripture: <key>` on a single line inside a teaching comment
  block (between `/*` and `*/`, on a continuation line whose
  first non-whitespace character is `*`, or at the start of a
  block-comment line). The verb is case-sensitive (`Scripture:`,
  matching the existing `Station:` directive's case). The `<key>`
  MUST be one of the keys defined in `lib/scripture.rexx`
  (initial set per FR-010). One directive binds the next
  assertion that follows it within the same teaching comment
  block. A directive MUST NOT appear outside a comment block; a
  directive whose key does not resolve in `lib/scripture.rexx`
  is a contributor error (forward enforcement is by review;
  mechanical lint is out of scope per the Out of Scope section).
- **FR-025**: When `lib/pilgrimage.rexx` detects that a koan
  subprocess exited non-zero with a `Damaged at: <file>, line N`
  diagnostic on stdout, it MUST identify the failing assertion
  (the `CALL m` on line N), search the koan's source for the
  `Scripture: <key>` directive that binds to that assertion (per
  FR-024's "next assertion in the same teaching comment block"
  rule), and — if found — look up the key in `lib/scripture.rexx`
  and emit the principle text and citation to stdout after the
  failure diagnostic and before the runner's station-list output.
  If no binding directive is found for the failing assertion, no
  scripture text is emitted; the failure output retains its
  Stage I shape. The exact text shape and the precise scope-rule
  edge cases (e.g., what counts as "the same teaching comment
  block" when assertions follow each other without intervening
  comments) are locked in the runner contract artifact under
  `specs/008-m3-the-path/contracts/` at planning time.

### Key Entities

- **Stage II koan**: a file under `koans/` numbered 06 through 11
  that teaches one control-flow construct (IF, SELECT, DO,
  ITERATE/LEAVE, SIGNAL, INTERPRET) from `Cowlishaw §2.7`. Each
  ships with a matching solution.
- **Stage III koan**: a file under `koans/` numbered 12 through 17
  that teaches one family of built-in functions (string, word,
  arithmetic, conversion, bit, misc) from `Cowlishaw §2.9`. Each
  ships with a matching solution.
- **Path manifest**: `koans/path_to_enlightenment.rexx`. After M3,
  declares `koans.0 = 18` and lists 18 ordered koan paths.
- **Scripture entry**: a `(key, principle text, citation)` record
  in `lib/scripture.rexx`, looked up by key. The PLAN-named keys
  are `humans_not_machines`, `least_astonishment`,
  `everything_is_string`, `read_aloud`, `consistency`,
  `whitespace_matters_just_enough`, `numbers_are_strings_too`.
- **Scripture binding**: an association between a specific
  assertion and a scripture key, declared by a
  `Scripture: <key>` directive in the assertion's teaching
  comment block (FR-024). The runner surfaces the keyed
  principle when the bound assertion fails (FR-025).
- **Station subtitle**: the `Station: <text>` directive in a
  koan's leading comment block, harvested by
  `lib/stations.rexx`'s `extract_subtitle` for the station-list
  display. Twelve new subtitles are introduced in M3 (one per
  new koan).
- **Runner-smoke fixture**: `tests/fixtures/runner_stdout.txt`,
  the byte-for-byte expected stdout of a fully-solved walk.
  Updated in M3 to reflect the eighteen-station path.
- **Cowlishaw index**: `docs/cowlishaw_index.md`, M2.1's
  whole-book structural index. Authority for every M3 citation
  per Constitution Principle III and `bin/lint_citations` per
  M2.4.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A pilgrim on a fresh checkout of the feature branch
  HEAD, running `bin/pilgrimage` for the first time, sees an
  eighteen-row station list (00–17) with `[ here ]` on the first
  unsolved blank's row and `[      ]` on every row after it.
- **SC-002**: After all 18 koans are filled correctly,
  `bin/pilgrimage` exits 0 and prints a station list with
  `[ ok ]` on every row, the summary line "Stations walked: 18 of
  18.", and the closing benediction.
- **SC-003**: `bin/verify_solutions` reports `18 of 18 solutions
  passed.` (or the equivalent all-green report shape used by the
  M2 walking skeleton's contract) on the feature branch HEAD prior
  to merge.
- **SC-004**: `bin/lint_citations` reports all-green across all 18
  koan files and all 18 solution files on the feature branch HEAD
  prior to merge — both the canonical-form check (M2.2) and the
  index-existence join (M2.4).
- **SC-005**: 100% of Cowlishaw citations in M3 koans and solutions
  resolve against an existing row in `docs/cowlishaw_index.md`.
  Spot-checkable mechanically: the M2.4 join finds a row for every
  citation; manually: a maintainer can locate each cited (§N.N,
  page) pair in the index in under 30 seconds.
- **SC-006**: At least three M3 koans are scripture-bound. On a
  failure of any scripture-bound assertion, the runner output
  contains the bound principle text. On a failure of any
  non-scripture-bound assertion, the runner output is identical in
  shape to a Stage I failure (no scripture lines). Mechanically
  verifiable by running probes on each scripture-bound koan and on
  one non-scripture-bound koan and diffing failure output shape.
- **SC-007**: All six CI workflow checks (`verify_solutions`,
  `lint_citations`, `runner-smoke`, each on `ubuntu-latest` and
  `macos-latest`) pass on the feature branch HEAD prior to merge.
- **SC-008**: `bin/pilgrimage > /tmp/out` against the
  fully-solved post-M3 corpus produces stdout byte-identical to
  `tests/fixtures/runner_stdout.txt` (modulo CRLF). Mechanically:
  `diff -u tests/fixtures/runner_stdout.txt /tmp/out` returns
  empty.
- **SC-009**: Pilgrim-facing path length triples: from 6 stations
  before M3 to 18 stations after M3 (a 3× expansion of the
  user-visible curriculum in a single milestone).
- **SC-010**: Solution-koan parity invariant (M2.5 SC-009 extended
  to Stages II–III): for any of the twelve new file pairs,
  `diff koans/NN_about_*.rexx solutions/NN_about_*.rexx` returns
  hunks consisting solely of `FILL_ME_IN` ↔ value substitutions.
- **SC-011**: Stage II/III pilgrim teaching density: each new
  koan contains at least three teaching comment blocks and at
  least four assertions, so the pilgrim has multiple chances to
  internalize the construct or built-in family. (Lower bound;
  some koans may teach more, e.g., DO has many forms.)
- **SC-012**: PLAN.md §10 milestone definition for M3 is fully
  satisfied at HEAD: "Stages II and III koans (06–17) with
  matching solutions" — yes (FR-001, FR-002); "Scripture mechanic
  implemented" — yes (FR-010, FR-012); "exercised by at least
  three koans" — yes (FR-011, SC-006).
- **SC-013**: M2.5 forward-style requirement is honored end to
  end: zero matches for `n = n + 1;` followed by `CALL m`, and
  zero matches for trailing-`n` arguments, across all of
  `koans/*.rexx` and `solutions/*.rexx` (Stages I–III).
- **SC-014**: A reviewer reading any single M3 koan unaided can
  fill its blanks correctly using only the koan's teaching prose
  in 60 seconds (Constitution Principle III: every koan is
  self-teaching). Subjective but verifiable by review-pass on a
  representative sample of M3 koans during US1/US2 acceptance.

## Assumptions

- **PLAN.md v1.4 is committed at `main` HEAD.** The M3 milestone
  definition (§10), the scripture mechanic spec (§9), the runner
  scripture re-print (§5), the curriculum table (§4), the station
  subtitle conventions (§11), and the M2.5 cleaned shape style rule
  (§8) are all in place. Locked on 2026-05-10. M3 builds on this
  baseline.
- **All upstream milestones are merged.** M1 (specs/001),
  M2 (specs/002), M2.1 (specs/003), M2.2 (specs/004), M2.3
  (specs/005), M2.4 (specs/006), and M2.5 (specs/007) are all
  committed at HEAD of `main`. M3 inherits the M2.5 cleaned
  assertion-line shape (Stage I in HEAD already conforms) and
  the M2.4 index-existence lint behavior; FR-003, FR-004, FR-005,
  FR-015 presume these.
- **The Cowlishaw index covers every concept M3 teaches.** The
  rows for §2.7 keyword instructions (IF, SELECT, DO, ITERATE,
  LEAVE, SIGNAL, INTERPRET) and the §2.9 built-ins (LENGTH,
  SUBSTR, POS, LEFT, RIGHT, COPIES, TRANSLATE, WORD, WORDS,
  WORDPOS, WORDLENGTH, SUBWORD, WORDINDEX, ABS, MAX, MIN, TRUNC,
  FORMAT, SIGN, D2X, X2D, C2X, X2C, B2X, X2B, D2C, C2D, BITAND,
  BITOR, BITXOR, DATATYPE, DATE, TIME, RANDOM, ADDRESS-built-in)
  are all present in `docs/cowlishaw_index.md`. (Spot-confirmed
  during spec drafting: the index contains §2.7 ## headers and
  §2.9 ### headers for every keyword instruction and every
  built-in named in Stages II/III.) Citations during koan
  authoring resolve against these rows.
- **The four meditation verbs suffice for Stages II–III.** Every
  test in every Stage II/III koan can be expressed as `eq`, `neq`,
  `true`, or `datatype`. Control-flow tests typically use `eq` to
  assert the post-construct value of a variable; built-in tests
  use `eq` against expected literal results, occasionally
  `datatype` for type-introspection tests, and `true` for boolean
  predicates. No new verb is needed; FR-019 is comfortable.
- **Scripture-bound koan candidates** (working list; final
  selection and per-test directive placement during planning):
  - **`07_about_select`** ↔ `least_astonishment`. SELECT/WHEN/
    OTHERWISE behaves the way a reader expects from spoken
    English; the OTHERWISE-required-when-no-WHEN-matches rule is
    a least-astonishment win and a footgun if forgotten.
  - **`12_about_string_functions`** ↔ `everything_is_string`.
    Every Stage III string built-in operates on character data
    that, in REXX, is the universal data type. The principle
    illuminates why these built-ins exist at all.
  - **`14_about_arithmetic_functions`** ↔ `numbers_are_strings_too`.
    Arithmetic built-ins return strings of digits formatted under
    the prevailing NUMERIC settings; the principle illuminates
    why FORMAT and TRUNC exist as separate functions rather than
    operators.
  - Three is the floor (PLAN.md §10); the spec author may bind
    additional koans during planning if a fourth or fifth
    principle organically illuminates a koan. The total is
    capped at no more than seven (the count of PLAN.md §9
    keys), and no fewer than three. The final list is fixed
    during planning and recorded in the implementation artifact.
- **Closing benediction wording.** The current Stage I-only
  benediction reads: "The pilgrim has walked the foundation. The
  path opens further." After M3, three valid options exist:
  (a) keep verbatim — still accurate ("foundation" can be read
  as "first foundations laid"); (b) update to reflect Stages
  I–III complete (e.g., "The pilgrim has walked the foundation,
  the path, and the tools."); (c) generalize to a milestone-
  agnostic line that survives M4–M7 unchanged. The spec author's
  default during planning is (b) for M3 and a generalized line
  later; the runner-smoke fixture reflects whichever choice
  lands. The choice is editorial; all three options are
  acceptable.
- **Station subtitles for new koans.** PLAN.md §11 names three
  by example: 06 about_if → "At the Branch of the Road"; 07
  about_select → "Of Many Ways"; 08 about_do_loops → "The
  Returning of the Path". The remaining nine subtitles (09–17)
  will be authored by the spec author during planning in the
  same pilgrim-voice register. Subtitle authorship is editorial
  and tracked as planning-time work.
- **Scripture text length.** Each scripture entry's principle
  text is one or two short sentences — long enough to convey
  the principle in failure-time output, short enough to not
  drown the meditation diagnostic. Order of magnitude: 50–150
  characters per principle. The library may refine wording during
  planning. (Constitution Principle V: scripture amplifies; it
  does not replace the diagnostic.)
- **Runner subprocess isolation continues.** Per M1 ADR-001,
  every koan runs as a Regina subprocess under
  `lib/pilgrimage.rexx`'s control. M3 does not change this. The
  runner-side scripture scan (FR-025) operates on the koan's
  source file (already on disk) and the captured subprocess
  stdout (the `Damaged at: <file>, line N` diagnostic provides
  the failing line number); no new IPC channel is required.
- **Stage I files are not edited in M3.** The Stage I koan
  files (00–05) are at HEAD as delivered by M2.2 + M2.3 + M2.5;
  none has a `Scripture:` directive and none gains one in this
  milestone. FR-004 and FR-005 grep checks cover all of
  `koans/*.rexx` and `solutions/*.rexx`, but no Stage I file
  should change. `lib/meditation.rexx` is not edited (FR-019);
  `lib/pilgrimage.rexx` is edited only to add the scripture
  scan (FR-025), and the existing failure-output flow for
  non-scripture-bound failures is preserved byte-for-byte.
- **CI fixture regeneration is deterministic.** The runner-smoke
  fixture is regenerated from a fully-solved walk. The
  fully-solved walk produces no failures, hence no scripture
  output (FR-013), hence the fixture content is independent of
  scripture state. Determinism is preserved by construction.

## Out of Scope

- **Stages IV–VI.** No NUMERIC, PARSE, PROCEDURE, ARG/PULL, user-
  defined functions, I/O built-ins, ADDRESS instruction, SIGNAL
  ON / CALL ON, TRACE, special-variables teaching beyond what
  exists. (FR-020.)
- **The capstone exercise.** `the_pilgrim_writes_a_program.rexx`
  is M6.
- **Portability validation.** Linux/Windows beyond the existing
  CI matrix is M7.
- **Editorial pass over Stage I.** M3 does not re-edit Stage I
  koans, solutions, or teaching prose. Stage I is at HEAD as
  delivered by M2 + M2.2 + M2.3 + M2.5; M3 extends the path
  forward only. (Stage I files appear in FR-004/FR-005 grep
  scopes but no Stage I file should change.)
- **A mechanical lint for scripture-key existence.** Whether
  `bin/lint_citations` (or a sibling lint) gains a check that
  every `Scripture: <key>` directive in a koan resolves to a
  defined key in `lib/scripture.rexx` is deferred to a later
  milestone (candidate: M6's editorial pass). Forward enforcement
  in M3 is by review. Not blocking M3 acceptance.
- **A mechanical lint for the M2.5 forbidden pattern.** As in
  M2.5, forward enforcement is by review (PLAN.md §8); FR-004
  and FR-005 grep checks are spec-level acceptance gates, not
  lint checks. Adding mechanical lint is a successor feature.
- **Renaming or restructuring `lib/scripture.rexx`'s interface
  after first ship.** The library's external interface — keyed
  lookup returning `(principle text, citation)` — is the
  contract from M3 onward; M4–M7 may add more keys but not
  change the dispatch mechanism without an amendment.
- **Editorial polish on scripture text.** A draft for each of
  the seven keys ships in M3 sufficient to satisfy FR-010 and
  FR-012; refinement of wording is a candidate for M6's editorial
  pass (PLAN.md §10).
- **Internationalization, color output, ANSI escapes, alternate
  station-display modes.** Per PLAN.md §11 and §14 (open
  questions), color is opt-in, deferred. M3 emits monochrome
  ASCII as Stage I does.

## Dependencies

- **Upstream (blocking)**: M1 → M2 → M2.1 → M2.2 → M2.3 → M2.4 →
  M2.5, all merged at `main` HEAD. M3 inherits:
  - the M1 design decisions (subprocess isolation, SIGNAL ON
    SYNTAX behavior, FILL_ME_IN detection mechanic);
  - the M2 walking skeleton (runner, meditation, stations, blank
    mechanism, Stage I corpus, GitHub Actions workflow);
  - the M2.1 Cowlishaw index (citation authority);
  - the M2.2 citation rewrite (Stage I citations canonical);
  - the M2.3 vocabulary review (Stage I prose Cowlishaw-vocab
    aligned);
  - the M2.4 mechanical citation existence check
    (`bin/lint_citations` joins on the index);
  - the M2.5 cleaned assertion-line shape (Stage I migrated;
    M3 inherits as authoring baseline).
- **Upstream (informational)**: PLAN.md v1.4 (locked 2026-05-10)
  with the M3 definition in §10, scripture mechanic in §9,
  runner re-print in §5, curriculum table in §4, station
  conventions in §11, and §8 style bullet for the M2.5 shape.
- **Downstream (informational)**: M4 — Numbers and Discipline
  (Stages IV–V, koans 18–24). M3 establishes the scripture
  mechanic that M4 may exercise on additional koans (e.g., a
  procedure-scope koan binding `humans_not_machines` or
  `consistency`). M4 does not need to extend scripture
  infrastructure; M3's library is intended to grow by data, not
  by interface change.

## Decisions

- **Scripture invocation mechanism** (formerly Q1, resolved
  2026-05-10 during `/speckit-specify` review): per-test
  `Scripture: <key>` directive in the assertion's teaching
  comment block, with runner-side source-scan and lookup against
  `lib/scripture.rexx`. `lib/meditation.rexx` is not modified;
  the koan-local `m:` wrapper stays three-arg. Rationale:
  (1) PLAN.md §9 names the location verbatim ("in a comment
  block at the top of the relevant test"); (2) the project
  already harvests directives by source-scan
  (`lib/stations.rexx`'s `extract_subtitle` for `Station:`);
  (3) the M2.5 minimal-shape ideal for assertion lines is
  preserved. Codified in FR-024 (directive shape) and FR-025
  (runner contract). Recorded in
  `specs/008-m3-the-path/checklists/requirements.md`.
