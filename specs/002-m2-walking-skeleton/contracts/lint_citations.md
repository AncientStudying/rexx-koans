# Contract: `bin/lint_citations`

**Invocation**: `regina bin/lint_citations` (or just `bin/lint_citations` if shebang executable).

REXX script (Constitution Principle II, ADR-006). Inherited from M1;
M2 extends the script to also check the `Station:` directive (Decision
2, research.md).

## Behavior

1. Lists every file matching `koans/*.rexx`. Excludes
   `koans/path_to_enlightenment.rexx` (it is the manifest, not a koan).
2. If the list is empty: prints `koans/ is empty — nothing to lint` and exits 1.
3. For each koan file, in lexicographic order:
   - Reads the file line-by-line up to the first non-comment, non-blank line, or up to a 50-line safety bound.
   - **Citation check**: scans the entire file for at least one well-formed citation matching `Cowlishaw §<sec>, p. <page>`, where:
     - `<sec>` is one or more digits, optionally followed by `.<digits>` (one or more nesting levels).
     - `<page>` is one or more digits.
   - **Station check**: within the leading comment block, finds exactly one stripped line matching `Station: <text>` (case-sensitive, `<text>` non-empty after stripping).
   - If both checks pass: prints `[ ok ] <koan_file>` and continues.
   - Otherwise: prints `[FAIL] <koan_file>` followed by the specific failure reasons (e.g., `MISSING citation`, `MISSING Station: directive`, `MULTIPLE Station: directives`).
4. Prints a one-line summary: `<passed>/<total> koans passed lint.`
5. Exits 0 if every koan passed; otherwise exits 1.

## Output format (stdout)

```
[ ok ] koans/00_about_asserts.rexx
[FAIL] koans/01_about_strings.rexx
  MISSING Station: directive
[ ok ] koans/02_about_variables.rexx
[ ok ] koans/03_about_expressions.rexx
[ ok ] koans/04_about_clauses.rexx
[ ok ] koans/05_about_say.rexx

5/6 koans passed lint.
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | All koans passed both citation and Station: checks |
| 1 | At least one koan failed, or `koans/` is empty |

## Constraints

- MUST be written in REXX (Constitution Principle II, ADR-006).
- MUST verify citation **format** only; page-number accuracy is a
  contributor responsibility (Constitution Principle III).
- MUST NOT depend on or inspect `solutions/`.
- MUST NOT print volatile values.
- MUST gracefully handle a koan with no leading comment block (treat
  Station: check as failed, surface the failure reason).
