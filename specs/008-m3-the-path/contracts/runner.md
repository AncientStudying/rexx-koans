# Contract: Pilgrimage Runner (`lib/pilgrimage.rexx`) — post-M3

**Supersedes**: `specs/002-m2-walking-skeleton/contracts/runner.md`. The M2 contract is left in place as historical record.
**Effective at**: M3 merge (`008-m3-the-path` → `main`).
**Invocation**: `regina lib/pilgrimage.rexx` (via `bin/pilgrimage` launcher in normal use).

## Behavior

1. Sources `koans/path_to_enlightenment.rexx` via `LINEIN` +
   `INTERPRET`, populating the `koans.` stem in its own scope
   (M1 ADR-007; carried forward unchanged from M2).
2. If `koans.0` is unset or zero: prints
   `"The path is empty. No stations are defined."` and exits 1.
   (Unchanged from M2.)
3. For `i = 1` to `koans.0`:
   - Verifies `koans.i` exists as a regular file. If not:
     prints `"Station <seq> <topic> is missing from the path."`
     and exits 1. (Unchanged.)
   - Invokes `regina <koans.i>` as a subprocess with stdout +
     stderr captured to a temp file (M1 ADR-001; unchanged).
   - Reads `RC`. If non-zero: marks this station as `[ here ]`,
     marks all earlier stations as `[  ok  ]`, marks all later
     stations as blank. Captures the koan's stdout into
     `failed_output`.
4. **(NEW IN M3)** If a failure occurred (`failed_idx > 0`),
   the runner determines whether the failed assertion is
   scripture-bound by performing the runner-side scripture-scan
   (see §"Scripture-emission pass" below).
5. Renders the station list via `lib/stations.rexx 'list', ...`
   (unchanged).
6. **On failure** (any koan returned non-zero):
   - Emits the captured failed-koan stdout, indented two
     spaces per line (unchanged).
   - **(NEW IN M3)** If the failed assertion is scripture-bound,
     emits the two-line Bathonian block (see §"FR-012 emission
     shape" below) immediately after the indented stdout, before
     the blank line and summary.
   - Emits a blank line (unchanged).
   - Emits the summary line via `lib/stations.rexx 'summary',
     walked, total, failed_topic` (unchanged).
   - Exits with the failed koan's RC (unchanged).
7. **On full pass** (every station green):
   - Emits the summary line via `lib/stations.rexx 'summary',
     total, total, ''` (unchanged).
   - Emits a blank line.
   - Emits the closing benediction
     `"The pilgrim has walked the foundation, the path, and the tools. The path opens further."`
     (M3 update; was Stage I-only `"The pilgrim has walked the
     foundation. The path opens further."` in M2).
   - Exits 0 (unchanged).

## Scripture-emission pass (NEW IN M3)

Triggered only on a failed koan subprocess. Inputs:

- `koan_path` — the path of the failing koan (e.g.,
  `koans/07_about_select.rexx`).
- `fail_line` — the source line number named in the failed
  koan's `Damaged at: <file>, line N` diagnostic. The runner
  parses this from `failed_output`.

Algorithm: see [research.md §1](../research.md#1--runner-side-scripture-scan-algorithm)
and [koan_directives.md](koan_directives.md).

Emit decision:

| Scan result | Action |
|---|---|
| `Scripture: <key>` directive found before any `/*` line | Lookup via `CALL 'lib/scripture.rexx' 'fetch', key`. If `RESULT` is non-empty, split on `'09'x` to get principle and citation; emit FR-012 two-line block. If `RESULT` is empty (unknown key), emit nothing (forward-compatible silent fallback). |
| `/*` line found before any `Scripture:` directive | No binding. Emit nothing. |
| Scan reaches line 1 with neither found | No binding. Emit nothing. |
| `Damaged at:` line cannot be parsed (e.g., koan aborted with SYNTAX before any meditation diagnostic) | No binding. Emit nothing. (The runner has no `fail_line` to scan from.) |

## FR-012 emission shape

Two lines, ASCII-only, no surrounding blank lines:

```
From the Bathonian (Cowlishaw §N.N, p. NN):
  <principle text>
```

- **Line 1**: literal `From the Bathonian (` prefix; then the
  citation in canonical form `Cowlishaw §N.N, p. NN` (optionally
  with ` — <heading>` per Constitution Principle III); then
  literal `):`. Single trailing newline.
- **Line 2**: two leading spaces (column 1–2 are blank); then
  the principle text verbatim from `lib/scripture.rexx` (no
  surrounding quotes); single trailing newline.

The block sits immediately after the (indented) failed-koan
captured stdout and before the blank line that precedes the
summary. No blank line between the indented stdout's last line
and Line 1; no blank line between Line 2 and the summary's
preceding blank.

## Output Format (stdout)

**On failure of a non-scripture-bound assertion** (Stage I or
M3 unbound):

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts            The First Truths
  [  ok  ] 01 about_strings            Of the Word Made String
  [ here ] 02 about_variables          The Naming of Things
  [      ] 03 about_expressions
  [      ] 04 about_clauses
  [      ] 05 about_say

  <verbatim indented stdout from the failing koan>

  Stations walked: 2 of 18.  Karma damaged at: about_variables.
```

**On failure of a scripture-bound assertion** (e.g., koan 07
binding `least_astonishment`):

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts            The First Truths
  ...
  [ here ] 07 about_select             Of Many Ways
  [      ] 08 about_do_loops
  ...

  <verbatim indented stdout from the failing koan, ending with `Damaged at: ..., line N.`>
  From the Bathonian (Cowlishaw §1.4, p. 7):
    A program should behave the way its reader expects.

  Stations walked: 7 of 18.  Karma damaged at: about_select.
```

**On full pass** (eighteen-station green walk):

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
  [  ok  ] 08 about_do_loops           The Returning of the Path
  [  ok  ] 09 about_iterate_leave      Of Skipping and Leaving
  [  ok  ] 10 about_signal             When the Path Bends
  [  ok  ] 11 about_interpret          What is Spoken Becomes Done
  [  ok  ] 12 about_string_functions   Of Letters and Their Manipulation
  [  ok  ] 13 about_word_functions     Of Words and Their Counting
  [  ok  ] 14 about_arithmetic_functions  Of Numbers and Their Shape
  [  ok  ] 15 about_conversion_functions  Between One Form and Another
  [  ok  ] 16 about_bit_functions      Down to the Bits
  [  ok  ] 17 about_misc_functions     Of Time and Chance

  Stations walked: 18 of 18.

  The pilgrim has walked the foundation, the path, and the tools. The path opens further.
```

The `topic_col` width is computed by `lib/stations.rexx`'s
`render_list` from the longest topic name in the manifest
(`max_topic_width = 26` post-M3 → `topic_col = 28`); the runner
passes the computed `max_w` through unchanged. No edit to
`lib/stations.rexx` is needed for M3.

## Exit Codes

| Code | Meaning | Notes |
|---|---|---|
| 0 | Every koan in the manifest passed | Unchanged from M2. |
| 1 | Manifest empty / malformed, or a koan exited 1 | Unchanged from M2. |
| ≥2 | Subprocess exit code from the first failing koan (passed through unchanged) | Unchanged from M2. |

The scripture-emission pass is purely additive on stdout; it
does not affect exit codes. The runner exits with whatever RC
the failing koan returned, regardless of whether scripture was
emitted.

## Constraints

- **Subprocess isolation** (M1 ADR-001, unchanged): every koan
  runs as a separate `regina` subprocess; variable scope and
  condition state are not shared across koans.
- **Manifest sourcing** (M1 ADR-007, unchanged): the runner
  reads `koans/path_to_enlightenment.rexx` via `LINEIN` and
  `INTERPRET`s its contents in its own scope, because external
  `CALL` does not share variable scope.
- **Determinism on success**: the post-M3 success-path stdout
  must be byte-identical to `tests/fixtures/runner_stdout.txt`
  (modulo CRLF). Scripture is failure-time only (FR-013).
- **Stage I non-modification**: a Stage I koan's failure output
  is byte-identical to its M2 output, because no Stage I koan
  has a `Scripture:` directive and the scripture-scan returns
  empty for unbound failures. The Stage I failure path emits
  no scripture text.
- **Cross-platform parity**: the scripture-scan reads source
  bytes; the FR-012 block emits ASCII; both runners produce
  identical output.

## Implementation surface

The post-M3 runner adds one PROCEDURE (`scripture_for_failure`)
and one block of code at the existing failure-emission point
(currently at `lib/pilgrimage.rexx:96–101`). No edits to the
manifest-load loop, the subprocess-spawn loop, the
station-list build loop, the failure detection logic, or the
exit-code propagation. See research.md §6 for the
commit-by-commit ordering.
