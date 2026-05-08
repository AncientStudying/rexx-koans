# Contract: Path Manifest (`koans/path_to_enlightenment.rexx`)

**Invocation**: Sourced by the runner via `LINEIN` + `INTERPRET`
(Decision 5, research.md; `docs/DESIGN_DECISIONS_M2.md` ADR-007).
Not invoked as a subprocess and not loaded via external `CALL` —
external `CALL` does not share variable scope with the caller in
Regina or ANSI X3.274 conformant REXX, so the manifest's stem
assignments would not reach the runner that way.

## Behavior

When sourced, the file's clauses execute in the runner's own
variable scope, populating the `koans.` stem and reaching the
trailing `RETURN`.

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

- MUST be sourced via `LINEIN` + `INTERPRET` by the runner so the
  populated stem appears in the runner's variable scope. MUST NOT be
  invoked as a subprocess. External `CALL` is forbidden because it
  does not share scope with the caller.
- MUST NOT contain executable logic beyond stem assignments, comments,
  and the trailing `RETURN`. (The body is `INTERPRET`ed in the runner's
  scope; anything more than data assignment risks polluting that
  scope or aborting the runner on a syntax error.)
- The order of `koans.1` ... `koans.koans.0` IS the curriculum order;
  it is the single source of truth for runner walk order.
- Adding a koan: increment `koans.0` and append a new line. Removing
  or reordering: edit accordingly. No other file touches.
- Future stages (M3+) extend the manifest by appending; M2 owns the
  initial six entries and the file format.
