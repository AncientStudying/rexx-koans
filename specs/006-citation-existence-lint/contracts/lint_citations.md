# Contract: `bin/lint_citations` (M2.4 — Mechanical Citation Existence Check)

**Invocation**: `regina bin/lint_citations` (or `bin/lint_citations` if shebang executable).

REXX script (Constitution Principle II). This contract supersedes
`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.
It documents the post-M2.4 behavior in full — including the
unchanged M2 / M2.2 behavior carried forward and the new M2.4
mechanical existence check. The M2.2 contract is left in place
as historical record; new contributors consult this M2.4
contract.

## Behavior summary

For each invocation:

1. **Bootstrap**: parse `docs/cowlishaw_index.md` and build an
   in-memory `(§sec, page)` → list-of-headings lookup table.
   If parsing fails, exit non-zero with a bootstrap-error
   message before any file is processed (FR-010).
2. **File discovery**: list every file matching
   `koans/*.rexx` AND `solutions/*.rexx`. Exclude
   `koans/path_to_enlightenment.rexx` (it is the manifest, not
   a koan). If both lists are empty, print
   `koans/ and solutions/ are both empty -- nothing to lint`
   and exit 1.
3. **Per-file processing** (for each file in lexicographic
   order, koans before solutions):
   - **Per-line scan** (M2.2 — unchanged): scan every line
     against M2.2's strict Rule C1 (`check_citation`); set
     `has_citation = 1` if any line passes. For koan files,
     also scan the leading comment block (≤50 lines until first
     non-comment-non-blank) for the `Station:` directive
     (`check_station`); track `station_count`.
   - **Comment-block reassembly** (M2.4 — new): group the
     file's comment-prose lines into paragraphs (per the rules
     in "Comment-block reassembly" below).
   - **Per-paragraph existence scan** (M2.4 — new): for each
     paragraph, run the broad citation-detection pattern (see
     "Broad citation-detection pattern" below); for each
     citation match, look up `(§sec, page)` in the table and
     accumulate an `UNRESOLVED citation:` reason if it doesn't
     resolve.
4. **Per-file evaluation**: a file passes (`[ ok ] <file>`)
   iff:
   - For koan files: `has_citation = 1` AND `station_count = 1`
     AND zero unresolved citations.
   - For solution files: `has_citation = 1` AND zero unresolved
     citations. (Solutions don't carry `Station:` directives;
     `station_count` is not checked.)
   Otherwise the file is `[FAIL] <file>` with one indented
   reason line per failure mode in the order: (a) `MISSING
   citation` if applicable, (b) `MISSING Station: directive` /
   `MULTIPLE Station: directives` if applicable, (c) every
   `UNRESOLVED citation: ...` reason in source order
   (line-ascending; column-ascending within a line).
5. **Summary**: print `<passed>/<total> files passed lint.` and
   exit 0 if every file passed, else exit 1.

## Bootstrap (Phase 1)

### Index parser

`bin/lint_citations` reads `docs/cowlishaw_index.md` line by
line and builds the lookup table. The parser tracks one piece
of context as it walks: `cur_section`, the most recently seen
`## §X.Y — <title>`'s `<sec>`. A `# Part …` or `# Appendix …`
top-level heading resets `cur_section` to empty.

For each row (`##` or `###` heading) the parser:

1. Captures the heading text.
2. Reads the following non-blank line; expects it to start with
   `- **Page:**` followed by whitespace and one or more decimal
   digits.
3. Records the row in the lookup table (per the rules in
   "Lookup table" below).

Any deviation from the expected row format triggers the
bootstrap-error mode (see "Bootstrap-error mode" below).

### Lookup table

Schema (REXX stem-variable representation):

```
table.<sec>.<page>.0          = N (count of `### <heading>` children at this key)
table.<sec>.<page>.1..N       = "<verbatim child heading>"
table.<sec>.<page>.has_parent = 1 if a `## §<sec>` row has page <page>, else 0
```

Build rule:

- A `## §X.Y` row with `**Page:** N`: set
  `table.X.Y.N.has_parent = 1`. If `table.X.Y.N.0` is undefined,
  set it to 0.
- A `### <heading>` row with `**Page:** N` (under the
  most-recent `## §X.Y`): increment `table.X.Y.N.0`; set
  `table.X.Y.N.<count>` to `<heading>` (verbatim, no whitespace
  stripping). If `table.X.Y.N.has_parent` is undefined, set it
  to 0.

A key may have:

- `has_parent=1, .0=0`: the parent `## §X.Y` row sits at this
  page with no `###` children at the same page.
- `has_parent=0, .0>=1`: only `###` children populate this key
  (the parent's page is different).
- `has_parent=1, .0>=1`: both the parent and one or more
  children share this (§X.Y, page) pair (rare; the canonical
  suffix disambiguates per the index conventions).
- `has_parent=0, .0=0`: never (such a key would never be
  inserted).

### Bootstrap-error mode

If `docs/cowlishaw_index.md` is missing, empty, or fails to
parse, `bin/lint_citations` prints to stderr a single line of
the form:

```
[BOOTSTRAP] cannot build lookup table: docs/cowlishaw_index.md <reason>
```

Where `<reason>` is one of:
- `is missing`
- `is empty`
- `line N: malformed Page bullet (expected '- **Page:** <digits>'; got '<actual>')`
- `line N: malformed heading (expected '## §<sec> — <title>' or '### <heading>'; got '<actual>')`
- `line N: '###' child appeared without a preceding '## §X.Y' parent`

The script then exits non-zero. No file is reported as
`[ ok ]`.

## Per-file checks (Phase 3)

### Rule C1: Canonical citation form (M2.2 — unchanged)

A line passes `check_citation` if it contains a substring
matching one of two shapes:

```
Cowlishaw §<sec>, p. <page>                          (bare canonical form)
Cowlishaw §<sec>, p. <page> — <heading>              (suffixed canonical form)
```

Where (carried forward verbatim from
`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`):

- `<sec>` is one or more digits, optionally followed by one or
  more groups of `.<digits>`. The legal pattern is the same as
  the existing `is_section` predicate: digits, dots, no leading
  or trailing dot, no `..`, no other characters.
- `<page>` is one or more decimal digits.
- For the bare form: immediately after `<page>`, the line MUST
  contain only end-of-line, OR any sequence of whitespace
  characters and at most one occurrence of the comment-close
  `*/`, in any order, with no other non-whitespace content.
- For the suffixed form: the separator between `<page>` and
  `<heading>` is exactly one space + em-dash (U+2014, encoded
  as the 3-byte UTF-8 sequence `E2 80 94`) + one space. Other
  dash characters are rejected. `<heading>` is one or more
  characters of any kind, non-empty after whitespace stripping.
  Immediately after `<heading>` (and any trailing whitespace),
  the line MUST contain only end-of-line, optionally preceded
  or interleaved with `*/` and whitespace.

`check_citation` returns true iff at least one such canonical
match exists on the line.

### Station: directive check (M2.2 — unchanged, koans only)

For koan files (and ONLY koan files), the leading comment block
is scanned (up to first non-comment-non-blank line, or 50-line
safety bound, whichever comes first). Within the block, count
the lines whose stripped content matches `Station: <text>`
(case-sensitive, `<text>` non-empty). Exactly one MUST be
present.

Solution files do not carry `Station:` directives by
convention; the check is not applied to them.

### Comment-block reassembly (M2.4 — new)

A "paragraph" is a contiguous run of comment-prose lines
within a single `/* ... */` block. The rules:

1. A `/*` opens a block. Lines until the matching ` */` are
   inside the block.
2. Within a block, a "prose line" is any line that, after
   stripping leading whitespace, begins with `* ` (asterisk +
   space) followed by content. The decoration ` * ` is
   stripped to obtain the line's content text.
3. A "blank-decoration line" is any line that, after stripping
   leading whitespace, equals `*` (a single asterisk with no
   content) or `*` followed only by whitespace. Such a line is
   a paragraph boundary.
4. A paragraph is a maximal run of consecutive prose lines (no
   blank-decoration line in the middle, no `/*` opening or
   ` */` closing line in the middle).
5. The paragraph's reassembled `text` is the prose lines'
   content texts joined by a single space (` `).
6. The paragraph's `start_line` is the 1-indexed line number of
   the first prose line; `end_line` is the line number of the
   last.

Citations matched by the broad pattern (see below) are
identified within the reassembled paragraph text. Each match's
reported `line_no` is `start_line + <offset_in_paragraph>`,
where `<offset_in_paragraph>` counts leading lines in the
paragraph until the line containing the `Cowlishaw §` marker.

### Broad citation-detection pattern (M2.4 — new)

Per the Clarifications session 2026-05-10 (Q1: broad scope), the
existence check uses a more permissive pattern than Rule C1:

```
Cowlishaw §<sec>, p. <page>[ — <heading>]
```

Where:

- `<sec>` and `<page>` use the same predicates as Rule C1
  (`is_section` for `<sec>`; one or more decimal digits for
  `<page>`).
- The optional ` — <heading>` group requires the canonical
  em-dash separator (space + U+2014 + space, byte-equivalent to
  `' E28094'x ' '`).
- `<heading>` extends from after the separator to the first
  *terminator*. Terminators are:
  1. `)` (closing parenthesis — for in-prose parentheticals).
  2. `*/` (comment-close).
  3. End of the reassembled paragraph.
  4. The next `Cowlishaw §` marker (a second citation begins).
- `<heading>` is whitespace-stripped after extraction; if empty
  after stripping, the suffix is treated as absent (the citation
  is bare-form).
- **NO TAIL CONSTRAINT** after `<page>` (or after `<heading>`).
  The substring may be embedded in prose, parentheticals, or
  any other context.

The scanner extracts ALL non-overlapping citations in the
paragraph, in source order.

### Per-citation existence check (M2.4 — new)

For each extracted citation `(sec, page, suffix)`:

- If `table.<sec>.<page>.has_parent = 0` AND
  `table.<sec>.<page>.0 = 0` (key absent): emit reason variant
  1.
- Else if `suffix` is empty (bare form): the citation resolves.
- Else (suffix present):
  - If `table.<sec>.<page>.0 = 0` (no `###` children at key):
    emit reason variant 3.
  - Else if `suffix` matches `table.<sec>.<page>.<k>` verbatim
    for some `1 ≤ k ≤ table.<sec>.<page>.0`: the citation
    resolves.
  - Else (suffix doesn't match any child): emit reason
    variant 2.

The verbatim match for the suffix is byte-level case-sensitive;
trailing whitespace on `suffix` is stripped before comparison
(per the broad-pattern extraction). Headings in the table are
NOT whitespace-stripped — they are verbatim from the index
file.

## Failure-mode taxonomy

The full taxonomy after M2.4:

| Mode | Reason string emitted under `[FAIL] <file>` |
|---|---|
| `MISSING citation` (M2.2, unchanged) | `MISSING citation` |
| `MISSING Station: directive` (M2.2, unchanged, koans only) | `MISSING Station: directive` |
| `MULTIPLE Station: directives` (M2.2, unchanged, koans only) | `MULTIPLE Station: directives` |
| `UNRESOLVED citation` (M2.4, new) variant 1 | `UNRESOLVED citation: <text> (no §<sec> + p. <page> row in docs/cowlishaw_index.md)` |
| `UNRESOLVED citation` (M2.4, new) variant 2 | `UNRESOLVED citation: <text> (heading "<suffix>" does not match index row "<verbatim_csv>")` |
| `UNRESOLVED citation` (M2.4, new) variant 3 | `UNRESOLVED citation: <text> (heading "<suffix>" does not match any §<sec>+p.<page> row; use bare form)` |

`<text>` is the citation's verbatim text from the source
(including the suffix if present). `<verbatim_csv>` is the
comma-joined list of valid heading alternatives (one or more,
verbatim).

### Multi-failure reporting (FR-016)

A file with N unresolved citations emits one `[FAIL] <file>`
line followed by N `UNRESOLVED citation:` reason lines in
source order (line-ascending; column-ascending within a line).
Pre-existing M2.2 modes (`MISSING citation`, `MISSING / MULTIPLE
Station:`) are emitted before the M2.4 modes if both apply to
the same file.

## Output format

### Success path

```
[ ok ] koans/00_about_asserts.rexx
[ ok ] koans/01_about_strings.rexx
[ ok ] koans/02_about_variables.rexx
[ ok ] koans/03_about_expressions.rexx
[ ok ] koans/04_about_clauses.rexx
[ ok ] koans/05_about_say.rexx
[ ok ] solutions/00_about_asserts.rexx
[ ok ] solutions/01_about_strings.rexx
[ ok ] solutions/02_about_variables.rexx
[ ok ] solutions/03_about_expressions.rexx
[ ok ] solutions/04_about_clauses.rexx
[ ok ] solutions/05_about_say.rexx

12/12 files passed lint.
```

### Failure path (example)

```
[ ok ] koans/00_about_asserts.rexx
[FAIL] koans/01_about_strings.rexx
  UNRESOLVED citation: Cowlishaw §99.99, p. 999 (no §99.99 + p. 999 row in docs/cowlishaw_index.md)
[ ok ] koans/02_about_variables.rexx
[FAIL] koans/03_about_expressions.rexx
  UNRESOLVED citation: Cowlishaw §2.3, p. 27 — Boolean (heading "Boolean" does not match index row "Logical (Boolean)", "Numbers")
  UNRESOLVED citation: Cowlishaw §2.5, p. 32 — Bogus Heading (heading "Bogus Heading" does not match any §2.5+p.32 row; use bare form)
[ ok ] koans/04_about_clauses.rexx
[ ok ] koans/05_about_say.rexx
[ ok ] solutions/00_about_asserts.rexx
[ ok ] solutions/01_about_strings.rexx
[ ok ] solutions/02_about_variables.rexx
[ ok ] solutions/03_about_expressions.rexx
[ ok ] solutions/04_about_clauses.rexx
[ ok ] solutions/05_about_say.rexx

10/12 files passed lint.
```

### Bootstrap-error path

```
[BOOTSTRAP] cannot build lookup table: docs/cowlishaw_index.md is missing
```

(or one of the other bootstrap-error reason strings; see
"Bootstrap-error mode" above.)

## Exit codes

| Code | Meaning |
|---|---|
| 0 | All discovered files passed all applicable checks. |
| 1 | At least one file failed, OR `koans/` and `solutions/` are both empty, OR the bootstrap parse of `docs/cowlishaw_index.md` failed. |

## Acceptance cases (positive)

The post-M2.4 lint MUST report `[ ok ]` for each of these
shapes:

| Case | Example | Notes |
|---|---|---|
| Bare trailing canonical, line-terminated | `* Cowlishaw §2.5, p. 32` | Resolves to `## §2.5` parent at p.32. |
| Bare trailing canonical, comment-closed | `/* Cowlishaw §2.5, p. 32 */` | Same row resolution. |
| Suffixed trailing canonical | `* Cowlishaw §2.2, p. 19 — Literal strings` | Resolves to `### Literal strings` child at (§2.2, p.19). |
| Suffixed trailing canonical, parenthesized heading | `* Cowlishaw §2.3, p. 27 — Logical (Boolean)` | Resolves to `### Logical (Boolean)` child at (§2.3, p.27). |
| Suffixed multi-word heading | `* Cowlishaw §2.2, p. 23 — Implied semicolons and continuations` | Resolves verbatim. |
| In-prose parenthetical, bare | `* (Cowlishaw §2.3, p. 26): a normal comparison` | Suffix terminates at `):`; no suffix; bare-form lookup resolves. |
| In-prose parenthetical, suffixed | `* (Cowlishaw §2.3, p. 27 — Logical (Boolean))` | Suffix `Logical (Boolean)` terminates at `)` after the inner `)`; matches the child verbatim. |
| Cross-line in-prose suffixed | `* (Cowlishaw §2.3, p. 27 — Logical\n * (Boolean))` | After paragraph reassembly, the suffix is `Logical (Boolean)`; matches the child verbatim. |

## Rejection cases (negative)

The post-M2.4 lint MUST treat each as `UNRESOLVED citation` with
the named variant when no other failure mode dominates:

| Case | Example | Reason variant | Reason string |
|---|---|---|---|
| Fabricated §+page | `* Cowlishaw §99.99, p. 999` | Variant 1 | `(no §99.99 + p. 999 row in docs/cowlishaw_index.md)` |
| Fabricated suffix at valid §+page (with children) | `* Cowlishaw §2.3, p. 27 — Boolean` | Variant 2 | `(heading "Boolean" does not match index row "Logical (Boolean)", "Numbers")` |
| Fabricated suffix at valid §+page (no children at this page) | `* Cowlishaw §2.5, p. 32 — Bogus Heading` | Variant 3 | `(heading "Bogus Heading" does not match any §2.5+p.32 row; use bare form)` |
| Wrong page for valid section | `* Cowlishaw §2.5, p. 999` | Variant 1 | `(no §2.5 + p. 999 row in docs/cowlishaw_index.md)` |
| Suffix typo (case wrong) | `* Cowlishaw §2.2, p. 19 — literal strings` | Variant 2 | `(heading "literal strings" does not match index row "Literal strings")` |

The pre-M2.2 rejection cases (legacy ASCII separator `--`,
en-dash `–`, missing spaces around em-dash, etc.) carry forward
unchanged: they fail M2.2's strict Rule C1 anchor check, so the
file gets `MISSING citation` (the M2.4 broad pattern wouldn't
even pick up such citations because it requires the canonical
em-dash separator for suffix detection).

## Constraints

- MUST be written in REXX (Constitution Principle II).
- MUST verify citation **resolution** against
  `docs/cowlishaw_index.md`. Page-number-against-the-physical-book
  accuracy remains a contributor responsibility (Constitution
  Principle III); §+page resolution is now CI-checked.
- MUST scan both `koans/*.rexx` and `solutions/*.rexx`.
- MUST NOT modify `docs/cowlishaw_index.md` (the lookup target;
  M2.1 owns it).
- MUST NOT modify any koan or solution file (the input corpus).
- MUST NOT modify `tests/fixtures/runner_stdout.txt` (the runner
  fixture; M2 owns it).
- MUST NOT print volatile values.
- MUST gracefully handle a koan with no leading comment block
  (treat `Station:` check as failed, surface the failure
  reason).
- MUST gracefully handle a solution file that fails the
  existence check (the file is reported `[FAIL]` with reasons;
  the script does not abort; it continues with the next file).
- MUST emit ALL unresolved-citation reasons for a single file in
  source order (FR-016 — multi-failure reporting).

## Cross-platform parity

The em-dash character `—` is encoded as 3 bytes in UTF-8
(`E2 80 94`). Both Regina builds in the CI matrix (macOS
Homebrew, ubuntu-latest apt) read koan, solution, and index
files as raw byte streams; the byte-level comparison
`'E2 80 94'x` (or equivalently `X2C('E28094')`) MUST match the
canonical em-dash on both platforms.

The §-prefix character `§` is encoded as 2 bytes in UTF-8
(`C2 A7`). The same byte-level comparison applies in the
citation-detection pattern's prefix `Cowlishaw §`.

The `koans/*.rexx`, `solutions/*.rexx`, and
`docs/cowlishaw_index.md` files are committed as UTF-8 by Git
(`.gitattributes` defaults; no per-file overrides).
Locale-dependent collation is not used by the lint check.

## Compatibility with the post-M2.3 corpus

The post-M2.3 corpus on `main` has been verified by human
review (M2.2 SC-001 + M2.3 mechanical
citation-line-read-only-check) to have every citation resolve
against `docs/cowlishaw_index.md`. The post-M2.4 lint MUST
report 12/12 `[ ok ]` on the post-M2.3 corpus on first run
(spec.md US2 / SC-001 + SC-002).

If a partial commit on the M2.4 feature branch leaves
`bin/lint_citations` in an intermediate state (e.g., the index
parser is added but the existence check phase is not yet
wired), CI MAY fail on intermediate commits but MUST be green
at the feature branch's HEAD prior to merge.

## Supersession

This contract supersedes:

- `specs/002-m2-walking-skeleton/contracts/lint_citations.md`
  (M2-era format check; superseded by M2.2).
- `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`
  (M2.2 canonical-form tightening; superseded by this M2.4
  contract).

Both predecessor contracts remain in place as historical
record. New contributors should consult **this** M2.4 contract
as the authoritative reference for `bin/lint_citations`'s
current behavior.
