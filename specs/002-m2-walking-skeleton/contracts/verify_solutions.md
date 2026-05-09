# Contract: `bin/verify_solutions`

**Invocation**: `regina bin/verify_solutions` (or just `bin/verify_solutions` if shebang executable).

REXX script (Constitution Principle II). Inherited from M1; M2 changes
only the surface area it must cover (six solutions instead of one).

## Behavior

1. Lists every file matching `solutions/*.rexx`.
2. If the list is empty: prints `solutions/ is empty — nothing to verify` and exits 1.
3. For each solution file, in lexicographic order by filename:
   - Invokes `regina <solution_file>` as a subprocess with stdout+stderr captured.
   - Reads `RC`. If non-zero: marks this solution as failed, prints `[FAIL] <solution_file>`, prints captured output indented under it.
   - Otherwise: prints `[ ok ] <solution_file>` and continues.
4. After all solutions are tried, prints a one-line summary: `<passed>/<total> solutions passed.`
5. Exits 0 if every solution passed; otherwise exits 1.

## Output format (stdout)

```
[ ok ] solutions/00_about_asserts.rexx
[ ok ] solutions/01_about_strings.rexx
[FAIL] solutions/02_about_variables.rexx
  <captured stdout from the failing subprocess>
[ ok ] solutions/03_about_expressions.rexx
[ ok ] solutions/04_about_clauses.rexx
[ ok ] solutions/05_about_say.rexx

5/6 solutions passed.
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | All solutions passed |
| 1 | At least one solution failed, or `solutions/` is empty |

## Constraints

- MUST be written in REXX (Constitution Principle II, ADR-006).
- MUST process all solutions even after a failure (unlike the runner,
  which stops at first failure). This gives contributors the full
  damage report in one CI run.
- MUST NOT depend on the runner (`lib/pilgrimage.rexx`) or station
  display — `verify_solutions` is the assertion-machinery acceptance
  gate, while the runner smoke step (FR-017) is the pilgrim-experience
  acceptance gate.
- MUST NOT print volatile values (timestamps, paths beyond
  `solutions/...`).
