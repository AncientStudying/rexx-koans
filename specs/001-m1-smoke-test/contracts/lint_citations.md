# Contract: lint_citations (`bin/lint_citations`)

**Invocation**: `bin/lint_citations` (REXX script)

## Behavior

1. Scans every `koans/*.rexx` file line by line.
2. For each koan file, checks that at least one line contains a well-formed
   Cowlishaw citation: the literal string `Cowlishaw §` followed by a section
   reference (`N.N` or `N.N.N`) followed by `, p. ` followed by a page number
   (one or more digits).
3. Reports OK or MISSING per file.
4. Exits 0 if all koan files have a valid citation; non-zero if any are missing.

## Citation Pattern

```
Cowlishaw §<section>, p. <page>
```

Examples of valid citations:
```
/* Cowlishaw §2.1, p. 15 */
/* Cowlishaw §2.9, p. 47 */
```

The check is syntactic (presence of the correctly-formed string) only.
Page number correctness is a contributor responsibility, not enforced by this script.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All koan files contain a valid citation |
| 1 | At least one koan file is missing a valid citation |

## Output Format (stdout)

```
[lint] koans/00_about_smoke.rexx ... OK
[lint] All citations valid.
```

On failure:
```
[lint] koans/00_about_smoke.rexx ... MISSING
[lint] 1 of 1 koan(s) failed citation check.
```

## Constraints

- MUST be implemented in REXX (Constitution Principle II).
- MUST run without modification on both macOS (Homebrew Regina) and Ubuntu (apt Regina).
- MUST NOT depend on any third-party REXX library.
- MUST exit non-zero if `koans/` is empty (no koans to lint is a configuration error).
