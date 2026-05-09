# Contract: Pilgrimage Runner (`lib/pilgrimage.rexx`)

**Invocation**: `regina lib/pilgrimage.rexx` (via `bin/pilgrimage` launcher in normal use).

## Behavior

1. Sources `koans/path_to_enlightenment.rexx` via `LINEIN` + `INTERPRET`, populating the `koans.` stem in its own scope (Decision 5, research.md; `docs/DESIGN_DECISIONS_M2.md` ADR-007). External `CALL` is not used here because Regina (and ANSI REXX) gives external `CALL` targets their own variable scope.
2. If `koans.0` is unset or zero: prints "The path is empty. No stations are defined." and exits 1.
3. For `i = 1` to `koans.0`:
   - Verifies `koans.i` exists as a regular file. If not: prints "Station <seq> <topic> is missing from the path." and exits 1.
   - Invokes `regina <koans.i>` as a subprocess with stdout+stderr captured to a temp file (Decision 1, M1 ADR-001).
   - Reads `RC`. If non-zero: marks this station as `[ here ]`, marks all earlier stations as `[  ok  ]`, marks all later stations as blank, hands off to `lib/stations.rexx` for rendering, exits with the koan's RC.
   - Otherwise: marks this station as `[  ok  ]` and continues.
4. On loop completion (all stations passed): renders the full station list with all `[  ok  ]` markers, prints the closing benediction, exits 0.

## Output Format (stdout)

**On failure** (any koan returns non-zero):

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts        The First Truths
  [  ok  ] 01 about_strings        Of the Word Made String
  [ here ] 02 about_variables      The Naming of Things
  [      ] 03 about_expressions
  [      ] 04 about_clauses
  [      ] 05 about_say

  <verbatim stdout from the failing koan subprocess>

  Stations walked: 2 of 6.  Karma damaged at: about_variables.
```

**On full pass** (every station green):

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts        The First Truths
  [  ok  ] 01 about_strings        Of the Word Made String
  [  ok  ] 02 about_variables      The Naming of Things
  [  ok  ] 03 about_expressions    Of Operators and Their Powers
  [  ok  ] 04 about_clauses        The Shape of an Instruction
  [  ok  ] 05 about_say            The Pilgrim Speaks

  Stations walked: 6 of 6.

  The pilgrim has walked the foundation. The path opens further.
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Every koan in the manifest passed |
| 1 | Manifest empty / malformed, or a koan exited 1 |
| ≥2 | Subprocess exit code from the first failing koan (passed through unchanged) |

## Constraints

- MUST NOT execute koan code in-process (no `INTERPRET` of koan text).
- MUST pass the failing koan's stdout through verbatim, indented to align with the station list.
- MUST NOT print volatile values (timestamps, PIDs, temp file paths) in any code path (Decision 4).
- MUST use ASCII only, LF line endings, spaces (no tabs) (Decision 4).
- MUST stop at the first failure; subsequent koans MUST NOT be executed.
- The closing benediction is printed only on full pass (Decision 6).

## Subtitle handling

For each station, the runner asks `lib/stations.rexx` (or its
internal helper) to extract the `Station: <text>` directive from the
koan file. If a station's koan has no `Station:` directive, the
subtitle column is empty in the rendered list (the build will be red
because `bin/lint_citations` rejects the koan).
