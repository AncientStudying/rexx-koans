# Contract: Path Manifest (`koans/path_to_enlightenment.rexx`)

**Invocation**: `CALL 'koans/path_to_enlightenment.rexx'` from the runner.

## Behavior

When `CALL`'d, this REXX file populates the `koans.` stem in the
caller's variable scope (Decision 5, research.md), then `RETURN`s.

## Variables populated

| Variable | Type | Description |
|---|---|---|
| `koans.0` | Integer | Count of stations on the path |
| `koans.1` ... `koans.<koans.0>` | String | Repo-relative path to each koan file, in walk order |

## M2 contents

```rexx
/* koans/path_to_enlightenment.rexx — master ordering for the pilgrim's path. */
koans.0 = 6
koans.1 = 'koans/00_about_asserts.rexx'
koans.2 = 'koans/01_about_strings.rexx'
koans.3 = 'koans/02_about_variables.rexx'
koans.4 = 'koans/03_about_expressions.rexx'
koans.5 = 'koans/04_about_clauses.rexx'
koans.6 = 'koans/05_about_say.rexx'
RETURN
```

## Constraints

- MUST be `CALL`'d (shared-scope), not invoked as a subprocess. The
  runner depends on the populated stem appearing in its own variables.
- MUST NOT contain executable logic beyond stem assignments, comments,
  and the trailing `RETURN`.
- The order of `koans.1` ... `koans.koans.0` IS the curriculum order;
  it is the single source of truth for runner walk order.
- Adding a koan: increment `koans.0` and append a new line. Removing
  or reordering: edit accordingly. No other file touches.
- Future stages (M3+) extend the manifest by appending; M2 owns the
  initial six entries and the file format.
