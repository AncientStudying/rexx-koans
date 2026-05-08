# Contract: verify_solutions (`bin/verify_solutions`)

**Invocation**: `bin/verify_solutions` (REXX script, executed via `regina bin/verify_solutions`)
or as a shell-executable if given a shebang line.

## Behavior

1. Scans `solutions/*.rexx` for all solution files.
2. For each solution file, runs it through the assertion machinery (either by invoking
   `lib/meditation.rexx` inline or via subprocess).
3. Requires every assertion in every solution file to pass.
4. Reports pass/fail per file to stdout.
5. Exits 0 if all pass; non-zero if any fail.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All solution files pass all assertions |
| 1 | At least one solution file has a failing assertion |

## Output Format (stdout)

```
[verify] solutions/00_about_smoke.rexx ... PASS
[verify] All solutions pass.
```

On failure:
```
[verify] solutions/00_about_smoke.rexx ... FAIL
[verify]   Assertion failed at line <L>: expected '<E>', got '<A>'
[verify] 1 of 1 solution(s) failed.
```

## Constraints

- MUST run without modification on both macOS (Homebrew Regina) and Ubuntu (apt Regina).
- MUST NOT depend on any third-party REXX library.
- A FILL_ME_IN symbol in a solution file MUST be treated as a failure (solutions have no blanks).
- MUST exit non-zero if `solutions/` is empty (no solutions to verify is a configuration error).
