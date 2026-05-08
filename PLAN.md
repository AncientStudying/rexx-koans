# REXX Koans — Project Plan

**Version:** 1.1  
**Status:** Locked  
**Locked on:** 2026-05-07

*Changes since v1.0: Inserted M1 (Smoke Test and Design Validation) ahead
of the former M1 to pressure-test design assumptions in actual REXX
before they are baked into the curriculum. Renumbered subsequent
milestones M1→M2, M2→M3, …, M6→M7. Updated stale milestone references
in §14 accordingly.*

---

## 1. Overview

**REXX Koans** is a self-paced, test-driven training course for the REXX
programming language, modeled on Edgecase's *Ruby Koans*. The learner edits
small REXX source files in place to make failing assertions pass; each
passing koan reveals the next. The curriculum is anchored to the section
ordering of M.F. Cowlishaw's *The REXX Language: A Practical Approach to
Programming* (2nd edition, 1990), and progresses from basic syntax through
language extendibility.

The project's framing device is the **Mainframe Pilgrimage**: the learner
is a pilgrim walking a path toward fluency, with each koan a station along
the way. When a lesson hinges on one of Cowlishaw's stated design principles,
the koan invokes **The Great Bathonian Cowlishaw** and presents the principle
as scripture — used sparingly, never as decoration.

## 2. Tooling and Environment

**Primary interpreter:** Regina REXX (chosen for closest behavioral
alignment with z/OS TSO/E REXX, both being implementations of the
ANSI X3.274 / Cowlishaw definition).

**Primary development platform:** macOS, installed via Homebrew:

```sh
brew install regina-rexx
```

**Best-effort installation notes** for Linux (package manager or build from
source via `regina-rexx.sourceforge.io`) and Windows (installer or WSL) will
be included in `docs/INSTALLING.md` and validated as a future task.

**No third-party REXX libraries.** The project uses only what ships with
Regina, so that lessons translate directly to a z/OS TSO/E or VM/CMS
environment with minimum surprise.

## 3. Repository Structure

```
rexx-koans/
├── README.md                       # What this is, how to start; links to Internet Archive PDF
├── PLAN.md                         # This document
├── COWLISHAW.md                    # Biographical sketch of Mike Cowlishaw
├── LICENSE                         # MIT (compatible with Ruby Koans heritage)
├── CONTRIBUTING.md                 # How to add or fix a koan
├── .gitignore                      # Includes reference/ (see below)
├── .github/
│   └── workflows/
│       └── verify.yml              # GitHub Actions CI: runs verify_solutions + citation lint
├── bin/
│   ├── pilgrimage                  # POSIX shell launcher (macOS/Linux)
│   ├── pilgrimage.bat              # Windows launcher (best-effort)
│   ├── verify_solutions            # Runs solutions/ files through assertion machinery
│   └── lint_citations              # Checks every koan has a well-formed Cowlishaw citation
├── lib/
│   ├── pilgrimage.rexx             # Runner: walks koans in order, stops at first failure
│   ├── meditation.rexx             # Assertion library (assert, assert_equal, etc.)
│   ├── stations.rexx               # Achievement output / progress display (see §11)
│   └── scripture.rexx              # Cowlishaw quotation lookup
├── koans/
│   ├── path_to_enlightenment.rexx  # Master ordering file
│   ├── 00_about_asserts.rexx
│   ├── 01_about_strings.rexx
│   ├── ...                         # See §4 for full list
│   └── 30_about_extendibility.rexx
├── solutions/                      # Parallel structure to koans/; passing implementations
│   ├── 00_about_asserts.rexx       # Each file is the koan with all FILL_ME_IN values resolved
│   └── ...                         # Used by verify_solutions to assure correctness (see §10)
├── reference/                      # GITIGNORED. Local-only working copy of source materials.
│   └── REXX_Language_2nd_Edition.pdf  # Contributor-supplied; not committed (see §8)
└── docs/
    ├── INSTALLING.md               # Per-platform setup
    └── PHILOSOPHY.md               # Project values; the Bathonian's principles
```

The `solutions/` tree is a working artifact of the project, not a hint
system for the pilgrim. Pilgrims find it by reading the source — that is
their right — but the README does not advertise it, and the runner does
not read from it.

The `reference/` tree is gitignored. It exists only on contributor
machines and holds local working copies of source materials —
principally the second edition of *The REXX Language* — so that page-
number citations can be verified at writing time. The repository never
contains the PDF; `CONTRIBUTING.md` directs contributors to the
Internet Archive link in the README to obtain their own copy.

## 4. The Pilgrimage: Full Curriculum

The path is divided into six stages. Section references (e.g., *§2.2*) point
to Part 2 of *The REXX Language*. Numeric prefixes are stable across reorders
of intra-stage content.

### Stage I — The Foundation (basic syntax and data)

| # | Koan | Maps to |
|---|---|---|
| 00 | `about_asserts.rexx` | meta — how the koans work |
| 01 | `about_strings.rexx` | §2.1, §2.2 — everything is a string |
| 02 | `about_variables.rexx` | §2.5 — assignment, uninitialized symbols, case |
| 03 | `about_expressions.rexx` | §2.3 — arithmetic, comparison, logical, concatenation |
| 04 | `about_clauses.rexx` | §2.4 — clauses, comments, continuation, semicolons |
| 05 | `about_say.rexx` | §2.7 (SAY) — output, expression evaluation in context |

### Stage II — The Path (flow and control)

| # | Koan | Maps to |
|---|---|---|
| 06 | `about_if.rexx` | §2.7 (IF/THEN/ELSE) |
| 07 | `about_select.rexx` | §2.7 (SELECT/WHEN/OTHERWISE) |
| 08 | `about_do_loops.rexx` | §2.7 (DO, DO i=1 TO n, DO WHILE, DO UNTIL, DO FOREVER) |
| 09 | `about_iterate_leave.rexx` | §2.7 (ITERATE, LEAVE) |
| 10 | `about_signal.rexx` | §2.7 (SIGNAL) — non-local transfer |
| 11 | `about_interpret.rexx` | §2.7 (INTERPRET) — runtime evaluation |

### Stage III — The Tools (built-in functions)

| # | Koan | Maps to |
|---|---|---|
| 12 | `about_string_functions.rexx` | §2.9 — LENGTH, SUBSTR, POS, LEFT, RIGHT, COPIES, TRANSLATE |
| 13 | `about_word_functions.rexx` | §2.9 — WORD, WORDS, WORDPOS, WORDLENGTH, SUBWORD, WORDINDEX |
| 14 | `about_arithmetic_functions.rexx` | §2.9, §2.11 — ABS, MAX, MIN, TRUNC, FORMAT, SIGN |
| 15 | `about_conversion_functions.rexx` | §2.9 — D2X, X2D, C2X, X2C, B2X, X2B, D2C, C2D |
| 16 | `about_bit_functions.rexx` | §2.9 — BITAND, BITOR, BITXOR |
| 17 | `about_misc_functions.rexx` | §2.9 — DATATYPE, DATE, TIME, RANDOM, ADDRESS |

### Stage IV — The Numbers (arithmetic and parsing)

| # | Koan | Maps to |
|---|---|---|
| 18 | `about_numbers_arithmetic.rexx` | §2.11 — NUMERIC DIGITS / FUZZ / FORM, precision, scientific notation |
| 19 | `about_parse.rexx` | §2.7 (PARSE), §2.10 — templates, patterns, positional parsing |
| 20 | `about_arg.rexx` | §2.7 (ARG, PULL), §2.10 — argument passing semantics |

### Stage V — The Discipline (user-defined functions and structure)

| # | Koan | Maps to |
|---|---|---|
| 21 | `about_internal_functions.rexx` | §2.7 (RETURN), §2.8 — defining and invoking functions |
| 22 | `about_call_vs_function.rexx` | §2.7 (CALL), §2.8 — CALL form vs. expression form, RESULT |
| 23 | `about_procedure_scope.rexx` | §2.7 (PROCEDURE), §2.5 — variable scoping with EXPOSE |
| 24 | `about_external_routines.rexx` | §2.6, §2.8 — external function and subroutine search order |

### Stage VI — The World Beyond (the program meets reality)

| # | Koan | Maps to |
|---|---|---|
| 25 | `about_io_streams.rexx` | §2.12 — LINEIN, LINEOUT, CHARIN, CHAROUT, STREAM |
| 26 | `about_address.rexx` | §2.6, §2.7 (ADDRESS) — issuing commands to external environments |
| 27 | `about_conditions.rexx` | §2.13 — SIGNAL ON / CALL ON ERROR, FAILURE, NOTREADY, HALT, NOVALUE, SYNTAX |
| 28 | `about_trace.rexx` | §2.7 (TRACE), §2.14 — interactive tracing modes |
| 29 | `about_special_variables.rexx` | §2.16 — RC, RESULT, SIGL |
| 30 | `about_extendibility.rexx` | §2.15 — reserved keywords, language extension philosophy |

### Beyond the Path

A single capstone exercise — `the_pilgrim_writes_a_program.rexx` — gives the
learner a small but realistic problem combining material from Stages I–VI,
inspired by Appendix B of the book ("A Sample REXX Program"). Solution is
graded by the same assertion machinery against expected output.

## 5. Runner Architecture (`lib/pilgrimage.rexx`)

The runner is a single REXX program that:

1. Reads the ordered koan list from `koans/path_to_enlightenment.rexx`.
2. Iterates koans in order. For each, it `INTERPRET`s or `CALL`s the koan's
   tests one at a time.
3. On the first failed assertion, it prints:
    - The koan filename and line number where karma was damaged.
    - The pilgrim's progress (e.g., "You have walked 47 steps along the path
      and have 113 steps remaining.").
    - The actual assertion failure message.
    - When applicable, the relevant Cowlishaw scripture for that koan.
4. Exits with a non-zero return code.
5. On a fully passing run, prints a closing benediction and exits 0.

Re-running the runner picks up where the pilgrim left off (the first
unsolved koan). No state file is required because correctness is
re-derived from the sources on each run.

## 6. The Assertion Library (`lib/meditation.rexx`)

A small assertion vocabulary, all of which fail loudly and informatively:

- `assert(condition [, message])`
- `assert_equal(expected, actual [, message])`
- `assert_not_equal(expected, actual [, message])`
- `assert_match(pattern, actual [, message])` — using REXX-flavored matching, not regex
- `assert_raises(condition_name, code_to_run)` — for SIGNAL ON traps
- `assert_datatype(value, type [, message])` — leverages the DATATYPE built-in

Failure output uses the pilgrim's voice: *"The eighth koan of about_strings has
damaged your karma. The pilgrim expected 'HELLO' but received 'hello'.
Meditate on the difference between TRANSLATE and the case of source text."*

## 7. The Blank Mechanism

Ruby Koans uses `__` (double underscore) as the placeholder the learner
fills in. REXX has its own elegant equivalent: an **uninitialized symbol
evaluates to its own uppercase name**, which we exploit.

The convention: any uninitialized symbol whose name begins with `FILL_ME_IN`
(e.g., `FILL_ME_IN`, `FILL_ME_IN_2`) is treated by the assertion library as a
deliberate blank. Encountering one in either argument of an assertion produces
the specific message *"This koan awaits your contribution. Replace the
FILL_ME_IN symbol with the value the pilgrim must learn."* rather than a
generic mismatch.

This keeps the koans as readable REXX — no special syntax, no macros, just
the language's own semantics doing the work. The Bathonian would approve.

## 8. Voice and Style Guidelines

These guidelines govern koan prose, comments, and runner output:

- **Address the learner as "the pilgrim" or in second person.** Avoid "the user."
- **Failure messages are diagnostic first, atmospheric second.** Every failure
  must tell the pilgrim what went wrong before any pilgrimage flourish.
- **The Mainframe Pilgrimage is light flavor, not a setting.** No invented
  characters, no plot, no NPCs. The path, the pilgrim, and the Bathonian's
  occasional voice are the only fixed elements.
- **Each test is preceded by a teaching comment block** that contains:
  1. A short heading naming the concept the test reveals (e.g.,
     *"Concatenation by abuttal vs. by blank"*).
  2. Sufficient prose — typically two to six sentences — to teach the
     concept on its own, without requiring the pilgrim to context-switch
     to the book. The pilgrim should be able to make the test pass from
     the comment alone in most cases; the book is a deeper reference,
     not a prerequisite.
  3. A citation back to *The REXX Language* (2nd edition) in the form
     `Cowlishaw §2.3, p. 27` so the pilgrim can read further. Page numbers
     refer to the print edition pagination as preserved in the Internet
     Archive scan. **Verification is a writing-time activity by the koan
     author**, performed against the contributor's local copy of the PDF
     in the gitignored `reference/` directory (see §3). The repository
     does not contain the PDF, and CI does not verify page numbers
     against it; CI only verifies that each koan contains a citation
     of the correct form (see `bin/lint_citations` in §10).
- **Restraint with humor.** A dry note lands; a sustained joke wears thin
  across thirty koans.

## 9. The Great Bathonian Cowlishaw — Scripture Mechanic

Selected design principles and observations from the book are stored in
`lib/scripture.rexx` as a lookup table keyed by short tag. A koan that turns
on one of these principles invokes the scripture in a comment block at the
top of the relevant test, and the runner re-prints it at failure time when
that test fails.

Initial scripture set (subject to expansion as koans are written):

- `humans_not_machines` — design for people, not for ease of implementation
- `least_astonishment` — behavior should match what a reader would expect
- `everything_is_string` — the unifying data model
- `read_aloud` — clauses should read naturally when spoken
- `consistency` — same construct, same meaning, everywhere
- `whitespace_matters_just_enough` — concatenation rules
- `numbers_are_strings_too` — arithmetic precision is configurable, not magic

The mechanic earns its keep only when the principle genuinely illuminates the
lesson. A koan with no relevant principle gets no scripture. This is enforced
by a contributor checklist in `CONTRIBUTING.md`.

## 10. Implementation Milestones

Each milestone produces a runnable, tagged release. **Solutions are
developed in lockstep with their koans**: a koan is not considered
complete until its corresponding `solutions/NN_about_x.rexx` file exists,
runs cleanly under the assertion machinery, and produces zero failures.
The `bin/verify_solutions` script enforces this on every commit by
running every solution file through the same runner the pilgrim will
use, with the assertion library substituted for one that requires every
assertion to pass.

### Continuous integration

The project uses **GitHub Actions** for CI, with the workflow defined in
`.github/workflows/verify.yml`. The workflow runs on every push and on
every pull request to `main`, and consists of two parallel jobs:

- **Linux** — `ubuntu-latest` runner. Installs Regina via
  `sudo apt-get install -y regina-rexx`, then runs `bin/verify_solutions`
  followed by `bin/lint_citations`.
- **macOS** — `macos-latest` runner. Installs Regina via
  `brew install regina-rexx`, then runs the same two scripts. Catches
  divergence between Linux and macOS Regina behavior, which matters
  because macOS is the primary development platform.

`bin/lint_citations` is a small REXX program that scans every `koans/*.rexx`
file and verifies that every test is preceded by a teaching comment block
containing a citation of the form `Cowlishaw §N.N, p. NN`. It is
syntactic only — it does not check page-number correctness, since the
PDF is not available to CI by design (see §8).

### Standard work order within each milestone

1. Draft the teaching comments for each koan in the milestone, including
   the citation back to *The REXX Language* (verified at writing time
   against the local PDF in `reference/`).
2. Write the **solution** file — actual passing REXX — and verify it
   passes under `verify_solutions`.
3. Derive the **koan** file from the solution by replacing the values
   the pilgrim is meant to discover with `FILL_ME_IN` symbols.
4. Run the runner against the koan and confirm it fails with a
   diagnostic message that teaches.
5. Replace the `FILL_ME_IN` with the solution value; confirm the runner
   now advances to the next assertion.

This order — solution first, koan derived from it — guarantees that no
koan ships with an assertion that has no valid answer, and that every
teaching comment matches code that actually passes.

**M1 — Smoke Test and Design Validation.** A deliberately throwaway
end-to-end prototype to pressure-test design assumptions in actual REXX
before they get baked into the rest of the curriculum. Finding out that
`SIGNAL ON SYNTAX` doesn't trap the way the runner architecture assumes
is worse after ten koans than after zero. This milestone produces:

- A minimal assertion library — a single `assert_equal` is enough.
- A minimal runner that loads and executes one koan file.
- One throwaway koan (`00_about_smoke.rexx`) and its matching solution,
  exercising at least one passing assertion, one failing assertion, and
  one `FILL_ME_IN` blank.
- A minimal `bin/lint_citations` written in REXX that scans the one koan
  and confirms it has a well-formed `Cowlishaw §N.N, p. NN` citation.
- A minimal `.github/workflows/verify.yml` that installs Regina and runs
  both `verify_solutions` and `lint_citations` on `ubuntu-latest` and
  `macos-latest`.

The questions this milestone exists to answer concretely, with working
code as evidence:

- **INTERPRET vs. CALL vs. subprocess.** Does the runner load koans by
  `INTERPRET`ing their text, by `CALL`ing them as subroutines, or by
  spawning each as a separate `regina` process? Each has different
  variable-scoping and error-recovery consequences.
- **`PROCEDURE EXPOSE` and shared state.** Can the assertion library
  maintain pass/fail counters that survive across koan invocations
  without leaking the runner's internals into the koan's namespace?
- **`SIGNAL ON SYNTAX` behavior.** When a koan contains a syntax error
  — which will happen, since pilgrims type wrong things — does the trap
  fire cleanly and let the runner report and continue (or exit
  gracefully), or does Regina abort before the trap activates?
- **`FILL_ME_IN` detection.** Does an uninitialized symbol reliably
  evaluate to its uppercase name in every context the assertion library
  cares about? Can the library distinguish "not filled in" from "filled
  in with the wrong value"?
- **Cross-runner Regina parity.** Does `apt-get install regina-rexx` on
  `ubuntu-latest` produce a Regina that behaves equivalently to
  Homebrew's macOS Regina for the operations the project depends on?
- **Citation linting in REXX itself.** Can REXX scan files and match the
  citation pattern comfortably, or does the awkwardness motivate a
  non-REXX implementation? (A non-REXX implementation would compromise
  the "pure REXX, dogfooded in CI" stance from §2 and is a meaningful
  decision, not a casual one.)

The deliverable that matters most from this milestone is **knowledge**,
captured as a short ADR-style note in `docs/DESIGN_DECISIONS.md`
recording the answers to the questions above with brief rationale. The
prototype's source files may be partially salvaged into M2 or fully
discarded; either is acceptable. M2 builds on the answers, not on the
code.

Exit criterion for M1: the prototype runs end-to-end on macOS locally
and is green on both CI runners, and `docs/DESIGN_DECISIONS.md` has a
written answer for every question above.

**M2 — Walking Skeleton.** Runner, assertion library, blank mechanism,
station-display module, `verify_solutions` and `lint_citations` scripts,
GitHub Actions workflow, and Stage I koans (00–05) complete with matching
solutions. End-to-end pilgrim experience verified on macOS and in CI.
Built on the design decisions recorded in M1.

**M3 — The Path.** Stages II and III koans (06–17) with matching
solutions. Scripture mechanic implemented and exercised by at least
three koans.

**M4 — Numbers and Discipline.** Stages IV and V koans (18–24) with
matching solutions. Procedure scoping is the most subtle terrain in the
curriculum and warrants extra review of both the koan and the solution.

**M5 — World Beyond.** Stage VI koans (25–30) with matching solutions.
ADDRESS koan uses Regina's default ADDRESS environment (`SYSTEM` or
`COMMAND`) but explicitly notes the TSO/E and CMS host-command
environments the learner will encounter on z/OS.

**M6 — Capstone and Polish.** `the_pilgrim_writes_a_program.rexx` and
its corresponding solution. Editorial pass over all failure messages,
teaching comments, and scripture for tone consistency. README gardening.
Every page-number citation re-verified against the source.

**M7 — Portability.** Validate Linux installation path beyond CI (i.e.,
on distributions other than Ubuntu). Validate Windows path (native
Regina or WSL). Resolve any portability issues uncovered.

## 11. Achievement Output (`lib/stations.rexx`)

The runner displays the pilgrim's progress in the form of a station list.
The aesthetic borrows from the print conventions of mainframe operator
consoles and JES output — fixed-pitch, status codes in brackets, a
deliberate plainness — rather than from path-map iconography.

A typical display:

```
                  THE PATH OF REXX

  [  ok  ] 00 about_asserts            The First Truths
  [  ok  ] 01 about_strings            Of the Word Made String
  [  ok  ] 02 about_variables          The Naming of Things
  [  ok  ] 03 about_expressions        Of Operators and Their Powers
  [  ok  ] 04 about_clauses            The Shape of an Instruction
  [  ok  ] 05 about_say                The Pilgrim Speaks
  [  ok  ] 06 about_if                 At the Branch of the Road
  [  ok  ] 07 about_select             Of Many Ways
  [ here ] 08 about_do_loops           The Returning of the Path
  [      ] 09 about_iterate_leave      ...
  [      ] 10 about_signal             ...
  ...

  Stations walked: 8 of 31.  Karma damaged at: about_do_loops, line 47.
```

Three states only: `[  ok  ]` for passed, `[ here ]` for the current
station, and a blank pair `[      ]` for stations not yet attempted.
A short subtitle on each line names the koan in pilgrim's voice. Output
is monochrome by default; an optional ANSI color mode is acceptable
future work but explicitly off the critical path.

A successful walk to the end of the path produces a closing benediction
in the same plain style — a single short paragraph, no ASCII art.

## 12. Documentation

- `README.md` — what the project is, how to start the pilgrimage, how to
  reset, where to ask for help. **Includes a link to the Internet Archive
  scan of *The REXX Language*, 2nd edition**
  (`https://archive.org/details/REXXLanguage2ndEdition`) so the pilgrim
  can read the cited passages alongside the koans. Keeps the
  marketing-to-mechanics ratio low.
- `COWLISHAW.md` — biographical sketch of Mike Cowlishaw drawing on the
  Wikipedia article (`https://en.wikipedia.org/wiki/Mike_Cowlishaw`):
  born in Bath; educated at Monkton Combe School and the University of
  Birmingham; joined IBM in 1974 as an electronic engineer; designer
  and original implementer of REXX (1979–1982, released 1984); also
  responsible for the LEXX live parsing editor used to typeset the
  Oxford English Dictionary, contributions to JPEG, the IBM Jargon File,
  and NetRexx; later worked extensively on decimal arithmetic, with his
  specification forming the proposal for the decimal parts of IEEE 754.
  Retired IBM Fellow (2010); Fellow of the Royal Academy of Engineering.
  Outside computing, a caver and life member of the National Speleological
  Society. Document attributes Wikipedia as the source and is kept short
  enough to stay accurate without becoming a maintenance burden.
- `docs/INSTALLING.md` — per-platform setup, including known good Regina
  versions.
- `docs/PHILOSOPHY.md` — the Bathonian's principles in full, with citations
  back to *The REXX Language*. Doubles as the source-of-truth for
  `scripture.rexx`.
- `CONTRIBUTING.md` — how to propose, write, review, and merge a new koan,
  including the scripture-relevance checklist and the solution-first work
  order from §10.

## 13. License

MIT, with attribution acknowledging *Ruby Koans* (Edgecase / Jim Weirich
and Joe O'Brien) as the structural inspiration and *The REXX Language* as
the curricular source. The Cowlishaw quotations are short, attributed, and
limited to passages directly illustrative of language design — used as
instruction, not redistribution.

## 14. Open Questions and Future Work

### Documented future addenda

These are explicitly out of scope for the present plan but constitute
intentional, named future work. They are recorded here so that the core
curriculum stays anchored to Cowlishaw's language definition and does
not drift into platform-specific territory.

- **z/OS-specific addendum.** A future stage covering TSO/E host commands,
  the standard ADDRESS environments (`TSO`, `MVS`, `ISPEXEC`, `ISREDIT`),
  dataset I/O via `EXECIO` and related host services, `LISTDSI` and other
  TSO-specific functions, stem variables in mainframe idiom, and the
  conventions for REXX execs as members of partitioned datasets. Natural
  sequel; out of scope here because Regina cannot exercise most of it.
- **OPS/MVS addendum.** A future stage covering the OPS/REXX dialect used
  by Broadcom (formerly CA) OPS/MVS for z/OS event automation: AOF rules,
  the OPS-specific built-in functions and address environments, and the
  rule lifecycle. A different operational context from interactive TSO
  REXX and worth its own treatment. Also out of scope here because it
  requires an OPS/MVS instance to validate against.

### Open questions

- **Backend portability.** Does the runner work unmodified on ooRexx and
  on z/OS TSO/E? An adapter shim may be required for non-Regina backends;
  decide after M6.
- **Optional hint system.** Should a pilgrim be able to request a hint
  on a stuck koan? Adds value but also complicates the editing model.
  Defer to post-M7.
- **Color in station display.** ANSI color in `lib/stations.rexx` is
  appealing but risks breaking on some terminals and on z/OS consoles.
  Off by default; opt-in via environment variable if implemented.
- **Solutions branch vs. directory.** Current plan keeps `solutions/` in
  the working tree because its presence is required by `verify_solutions`
  in CI. A cleaner alternative — solutions on a separate branch — is
  rejected for the friction it adds to the solution-first work order
  in §10. Revisit if this proves wrong in practice.
