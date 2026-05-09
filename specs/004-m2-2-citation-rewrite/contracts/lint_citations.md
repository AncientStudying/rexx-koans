# Contract: `bin/lint_citations` (M2.2 amendment)

**Invocation**: `regina bin/lint_citations` (or `bin/lint_citations` if shebang executable).

REXX script (Constitution Principle II). This contract supersedes
`specs/002-m2-walking-skeleton/contracts/lint_citations.md` for the
citation-format check (Rule C1 below). All other behavior — file
discovery, path-manifest exclusion, the `Station:` directive check,
output format, and exit codes — is **unchanged** from the M2 contract.

## Behavior (unchanged from M2 contract)

1. Lists every file matching `koans/*.rexx`. Excludes
   `koans/path_to_enlightenment.rexx` (it is the manifest, not a koan).
2. If the list is empty: prints `koans/ is empty -- nothing to lint`
   and exits 1.
3. For each koan file, in lexicographic order:
   - Reads the file line-by-line up to the first non-comment, non-blank
     line, or up to a 50-line safety bound, for the `Station:` check.
   - **Citation check**: scans the entire file for at least one line
     matching the canonical citation form defined in Rule C1 below.
   - **Station check**: within the leading comment block, finds
     exactly one stripped line matching `Station: <text>`
     (case-sensitive, `<text>` non-empty after stripping).
   - If both checks pass: prints `[ ok ] <koan_file>` and continues.
   - Otherwise: prints `[FAIL] <koan_file>` followed by the specific
     failure reasons (e.g., `MISSING citation`,
     `MISSING Station: directive`, `MULTIPLE Station: directives`).
4. Prints a one-line summary: `<passed>/<total> koans passed lint.`
5. Exits 0 if every koan passed; otherwise exits 1.

## Rule C1: Canonical citation form (M2.2 tightening, FR-008)

A citation line MUST contain a substring matching one of two shapes:

### C1.bare — bare canonical form

```
Cowlishaw §<sec>, p. <page>
```

Where:

- `<sec>` is one or more digits, optionally followed by one or more
  groups of `.<digits>`. The legal pattern is the same as the
  pre-existing `is_section` predicate: digits, dots, no leading or
  trailing dot, no `..`, no other characters.
- `<page>` is one or more decimal digits.
- Immediately after `<page>`, the line MUST contain only:
  - end-of-line (no trailing content), OR
  - any sequence of whitespace characters and at most one
    occurrence of the comment-close `*/`, in any order, with no
    other non-whitespace content.

### C1.suffixed — suffixed canonical form

```
Cowlishaw §<sec>, p. <page> — <heading>
```

Where:

- `<sec>` and `<page>` are as in C1.bare.
- The separator between `<page>` and `<heading>` is exactly:
  one space (` `, U+0020) + em-dash (`—`, U+2014, encoded as the
  3-byte UTF-8 sequence `E2 80 94`) + one space (` `, U+0020).
  Other dash characters (hyphen `-`, en-dash `–`, double-hyphen
  `--`) MUST be rejected.
- `<heading>` is one or more characters of any kind, non-empty after
  whitespace stripping.
- Immediately after `<heading>` (and any trailing whitespace), the
  line MUST contain only end-of-line, optionally preceded or
  interleaved with `*/` and whitespace as in C1.bare.

### Rejection cases (negative tests)

The tightened check MUST treat each of the following as
"MISSING citation" (i.e., return false from `check_citation`) when
no other citation in the file is canonical:

| Case | Example | Reason |
|---|---|---|
| Legacy ASCII separator | `Cowlishaw §2.5, p. 32 -- Anything` | not space-em-dash-space |
| Single hyphen | `Cowlishaw §2.5, p. 32 - heading` | not em-dash |
| En-dash | `Cowlishaw §2.5, p. 32 – heading` | not em-dash |
| No spaces around em-dash | `Cowlishaw §2.5, p. 32—heading` | missing required spaces |
| Missing trailing space | `Cowlishaw §2.5, p. 32 —heading` | missing space after em-dash |
| Missing leading space | `Cowlishaw §2.5, p. 32— heading` | missing space before em-dash |
| Empty heading after suffix | `Cowlishaw §2.5, p. 32 — ` | heading whitespace-only |
| Garbage after page | `Cowlishaw §2.5, p. 32 garbage` | not C1.bare or C1.suffixed |

### Acceptance cases (positive tests)

The tightened check MUST return true for each of the following:

| Case | Example |
|---|---|
| Bare, line-terminated | `* Cowlishaw §2.5, p. 32` |
| Bare, trailing whitespace | `* Cowlishaw §2.5, p. 32   ` |
| Bare, comment-closed | `/* Cowlishaw §2.5, p. 32 */` |
| Suffixed, line-terminated | `* Cowlishaw §2.2, p. 19 — Literal strings` |
| Suffixed, comment-closed | `/* Cowlishaw §2.2, p. 19 — Literal strings */` |
| Suffixed, parenthesized heading | `* Cowlishaw §2.3, p. 27 — Logical (Boolean)` |
| Suffixed, multi-word heading | `* Cowlishaw §2.2, p. 23 — Implied semicolons and continuations` |

The leading-line content (`*`, `/*`, leading whitespace, etc.) is
not part of the tail check; it precedes the marker
`Cowlishaw §` and is irrelevant.

## Constraints (unchanged from M2 contract)

- MUST be written in REXX (Constitution Principle II).
- MUST verify citation **format** only; page-number accuracy
  remains a contributor responsibility (Constitution Principle III).
- MUST NOT depend on or inspect `solutions/`.
- MUST NOT depend on or parse `docs/cowlishaw_index.md` —
  mechanical existence-check against the index is FR-014, deferred
  per Clarifications session 2026-05-09. A successor feature MAY
  introduce that capability with its own contract amendment.
- MUST NOT print volatile values.
- MUST gracefully handle a koan with no leading comment block
  (treat `Station:` check as failed, surface the failure reason).

## Failure-mode taxonomy (unchanged from M2 contract)

The failure-reason strings emitted by `[FAIL]` lines remain:

- `MISSING citation` — no line in the file matches Rule C1.
- `MISSING Station: directive` — no `Station:` line in the leading
  comment block.
- `MULTIPLE Station: directives` — more than one `Station:` line in
  the leading comment block.

A non-canonical citation (e.g., legacy `--` separator) yields
`MISSING citation`. A finer-grained `MALFORMED citation` failure
mode is intentionally not introduced; rationale is in
`research.md` §2.

## Output format (unchanged from M2 contract)

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

## Exit Codes (unchanged from M2 contract)

| Code | Meaning |
|---|---|
| 0 | All koans passed both citation and `Station:` checks |
| 1 | At least one koan failed, or `koans/` is empty |

## Cross-platform parity

The em-dash character `—` is encoded as 3 bytes in UTF-8
(`E2 80 94`). Both Regina builds in the CI matrix
(macOS Homebrew, ubuntu-latest apt) read koan files as raw byte
streams; the byte-level comparison `'E2 80 94'X` (or equivalently
`X2C('E28094')`) MUST match the canonical em-dash on both platforms.

The `koans/*.rexx` and `solutions/*.rexx` files are committed as
UTF-8 by Git (`.gitattributes` defaults; no per-file overrides).
Locale-dependent collation is not used by the lint check.

## Compatibility with the M2-era corpus

The M2-era citations (e.g., `Cowlishaw §2.5, p. 42 -- Assignments`)
all carried the legacy `--` separator. Under the tightened Rule C1,
**none** of those citations would pass. M2.2's purpose is to rewrite
them so they do; lint is updated and the corpus is rewritten as a
single atomic feature so the CI gate remains green at every commit
on the feature branch where both the script and at least one
matching koan have been updated.

If a partial commit occurs (script updated but corpus not, or vice
versa), CI MAY fail. Recovery is to complete the rewrite or revert
the lint script.
