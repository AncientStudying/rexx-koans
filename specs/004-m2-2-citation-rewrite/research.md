# Phase 0 Research — M2.2

This document records the lookups and design choices made during
Phase 0 of `/speckit-plan` for M2.2.

## §1. Citation rewrite mapping

For each distinct citation string currently in `koans/` and
`solutions/`, the index-supported replacement is derived by:

1. Identify the concept the surrounding teaching block teaches.
2. Locate the matching row in `docs/cowlishaw_index.md` — by topic
   first, then verify §X.Y and book page.
3. Apply the bare-preferred policy from spec FR-005 (clarified
   2026-05-09): bare `Cowlishaw §X.Y, p. NN` if (§X.Y, page) uniquely
   identifies a single row in the index; suffixed
   `Cowlishaw §X.Y, p. NN — <verbatim child heading>` if it does not.

Collision detection (does (§X.Y, page) uniquely identify?) is
performed by reading the index page-by-page and noting which child
rows share a parent + page. The relevant collisions for this
feature's mapping:

| Parent §X.Y | Page | Rows on this page |
|---|---|---|
| §2.2 | 18 | §2.2 SECTION row + child "Comments" → **collision** |
| §2.2 | 19 | child "Tokens" + child "Literal strings" → **collision** |
| §2.3 | 25 | child "Concatenation" + child "Arithmetic" → **collision** |
| §2.3 | 27 | child "Logical (Boolean)" + child "Numbers" → **collision** |
| §2.3 | 24 / 26 / 28 | one row each → bare suffices |
| §2.4 | 31 | §2.4 SECTION row only (1-page taxonomy) → bare suffices |
| §2.5 | 32 | §2.5 SECTION row only on this page → bare suffices |
| §2.7 | 70 | child "SAY" only on this page → bare suffices |

### Rewrite table

The 14 distinct citation strings currently in the Stage I corpus,
with their replacement under FR-005/FR-006/FR-007 and the audit
row(s) closed by each:

| # | Old citation | New citation | Audit row(s) closed | Files affected |
|---|---|---|---|---|
| 1 | `Cowlishaw §1.1, p. 1 -- Introduction` | `Cowlishaw §1.1, p. 1` | 1 (✓ → bare) | `koans/00`, `solutions/00` |
| 2 | `Cowlishaw §2.5, p. 42 -- Assignments and equality` | `Cowlishaw §2.5, p. 32` | 10 | `koans/00`, `solutions/00` |
| 3 | `Cowlishaw §2.3, p. 25 -- Comparisons` | `Cowlishaw §2.3, p. 26` | 5 | `koans/00`, `solutions/00`, `koans/03`, `solutions/03` |
| 4 | `Cowlishaw §2.1, p. 15 -- Literal strings` | `Cowlishaw §2.2, p. 19 — Literal strings` | 2 | `koans/01`, `solutions/01` |
| 5 | `Cowlishaw §2.2, p. 17 -- Numbers` | `Cowlishaw §2.3, p. 27 — Numbers` | 3 | `koans/01`, `solutions/01` |
| 6 | `Cowlishaw §2.5, p. 42 -- Assignments` | `Cowlishaw §2.5, p. 32` | 10 | `koans/02`, `solutions/02` |
| 7 | `Cowlishaw §2.3, p. 22 -- Operators` | `Cowlishaw §2.3, p. 24` | 4 (general "Operators") | `koans/03`, `solutions/03` |
| 8 | `Cowlishaw §2.3, p. 22 -- Arithmetic operators` | `Cowlishaw §2.3, p. 25 — Arithmetic` | 4 ("Arithmetic") | `koans/03`, `solutions/03` |
| 9 | `Cowlishaw §2.3, p. 27 -- Logical operators` | `Cowlishaw §2.3, p. 27 — Logical (Boolean)` | 6 (✓ on page; vocab fix) | `koans/03`, `solutions/03` |
| 10 | `Cowlishaw §2.3, p. 30 -- Concatenation` | `Cowlishaw §2.3, p. 25 — Concatenation` | 7 | `koans/03`, `solutions/03` |
| 11 | `Cowlishaw §2.4, p. 38 -- Clauses` | `Cowlishaw §2.4, p. 31` | 8 ("Clauses") | `koans/04`, `solutions/04` |
| 12 | `Cowlishaw §2.4, p. 38 -- Continuation` | `Cowlishaw §2.2, p. 23` | 8 ("Continuation") | `koans/04`, `solutions/04` |
| 13 | `Cowlishaw §2.4, p. 39 -- Comments` | `Cowlishaw §2.2, p. 18 — Comments` | 9 | `koans/04`, `solutions/04` |
| 14 | `Cowlishaw §2.7, p. 56 -- The SAY instruction` | `Cowlishaw §2.7, p. 70` | 11 | `koans/05`, `solutions/05` |

All 11 audit rows are closed by these 14 distinct edits. Two audit
rows (rows 4 and 8) each correspond to two koan citations (a general
section reference + a specific child reference); both are addressed.

### Rationale per row

- **Row 1 — `§1.1, p. 1` (audit ✓ correct)**: Bare suffices because
  §1.1 SECTION row is the only row at (§1.1, p. 1). The trailing
  `-- Introduction` is dropped per FR-006. The verbatim §1.1 SECTION
  title is "What Kind of a Language is REXX?" — long and awkward as
  a label; bare is also editorially better.
- **Row 2 — `§2.5, p. 32` (audit row 10, page wrong)**: §2.5
  SECTION ("Assignments and Variables") starts on book p. 32, not
  p. 42 (p. 42 is mid-§2.7, the ARG keyword). (§2.5, p. 32) uniquely
  identifies the SECTION row → bare. Both `koans/00` (citing
  "Assignments and equality") and `koans/02` (citing "Assignments")
  collapse to the same bare form because both teaching blocks
  anchor to §2.5 as a whole, not to a child row.
- **Row 3 — `§2.3, p. 26` (audit row 5, page off by 1)**:
  "Comparative" child row in the index is at §2.3 p. 26, not p. 25.
  Only "Comparative" begins at §2.3 p. 26 → bare suffices. The
  trailing `-- Comparisons` is dropped (also a vocabulary correction
  — the canonical Cowlishaw heading is "Comparative" — but per FR-012
  prose-body vocabulary is M2.3, not M2.2).
- **Row 4 — `§2.2, p. 19 — Literal strings` (audit row 2)**:
  "Literal strings" is in §2.2, not §2.1 (which is "Characters and
  Encodings"). At (§2.2, p. 19) the index has both "Tokens" and
  "Literal strings" → suffix required.
- **Row 5 — `§2.3, p. 27 — Numbers` (audit row 3)**: "Numbers" is in
  §2.3, not §2.2. At (§2.3, p. 27) the index has both
  "Logical (Boolean)" and "Numbers" → suffix required.
- **Row 7 — `§2.3, p. 24` (audit row 4 general "Operators")**: §2.3
  SECTION ("Expressions and Operators") starts on book p. 24. Only
  the SECTION row is at p. 24 → bare. The teaching block is about
  operators in general; cite the SECTION, not a child.
- **Row 8 — `§2.3, p. 25 — Arithmetic` (audit row 4 specific
  "Arithmetic")**: At (§2.3, p. 25) the index has both
  "Concatenation" and "Arithmetic" → suffix required.
- **Row 9 — `§2.3, p. 27 — Logical (Boolean)` (audit row 6, vocab)**:
  Audit confirms (§2.3, p. 27) is correct. Suffix required because
  of the §2.3-p. 27 collision with "Numbers". Verbatim heading from
  the index is `Logical (Boolean)`, not `Logical operators`.
- **Row 10 — `§2.3, p. 25 — Concatenation` (audit row 7)**:
  "Concatenation" is at §2.3 p. 25, not p. 30. Suffix required
  because of the §2.3-p. 25 collision with "Arithmetic".
- **Row 11 — `§2.4, p. 31` (audit row 8 "Clauses")**: §2.4 SECTION
  ("Clauses and Instructions") starts on p. 31. The index records
  it as a 1-page taxonomy with no child rows on p. 31. Bare
  suffices.
- **Row 12 — `§2.2, p. 23` (audit row 8 "Continuation")**:
  Comma-continuation is in §2.2 "Implied semicolons and
  continuations" on p. 23. Only that child is at (§2.2, p. 23) →
  bare suffices.
- **Row 13 — `§2.2, p. 18 — Comments` (audit row 9)**: "Comments"
  is in §2.2 p. 18, not §2.4 p. 39. The §2.2 SECTION row also
  begins on p. 18 → collision → suffix required.
- **Row 14 — `§2.7, p. 70` (audit row 11)**: SAY is at §2.7 p. 70,
  not p. 56 (p. 56 is mid-INTERPRET). Only "SAY" is at (§2.7, p. 70)
  → bare suffices.

### Index defects discovered

None. All 14 replacement citations resolve to existing index rows
without correction. FR-009's defect-patch escape hatch is not
exercised by this feature.

## §2. Lint regex tightening (FR-008)

The current `check_citation` (lines 123–142 of `bin/lint_citations`)
is **permissive**: it scans for the prefix `Cowlishaw §<sec>, p. <page>`
anywhere in the file but does not validate or reject any text after
the page-digit run. This is the root cause of the constitution sync
report's note about lint enforcing only "the bare canonical form" —
in practice, lint accepts the legacy `--` separator, the canonical
em-dash separator, and any other tail content.

FR-008 requires `bin/lint_citations` to enforce the canonical form
defined in FR-005:

- **Bare**: `Cowlishaw §<sec>, p. <page>` followed only by
  whitespace and/or a comment-close `*/` and end-of-line.
- **Suffixed**: `Cowlishaw §<sec>, p. <page> — <heading>` where
  ` — ` is space + UTF-8 em-dash (`E2 80 94`) + space, and
  `<heading>` is non-empty after stripping.

### Design

`check_citation` is restructured so that, after parsing the page
digits, it inspects the tail and returns 1 only if the tail
matches one of the two canonical shapes.

Pseudocode (REXX-shaped):

```rexx
check_citation: PROCEDURE
  PARSE ARG line
  marker = 'Cowlishaw §'
  p1 = POS(marker, line)
  IF p1 = 0 THEN RETURN 0

  section_start = p1 + LENGTH(marker)
  p2 = POS(', p. ', line, section_start)
  IF p2 = 0 THEN RETURN 0
  section = SUBSTR(line, section_start, p2 - section_start)
  IF \is_section(section) THEN RETURN 0

  page_start = p2 + 5
  digits = 0
  DO j = page_start TO LENGTH(line)
    IF \DATATYPE(SUBSTR(line, j, 1), 'W') THEN LEAVE
    digits = digits + 1
  END
  IF digits = 0 THEN RETURN 0

  /* FR-008 tail check */
  trail = SUBSTR(line, page_start + digits)
  trail = STRIP(trail, 'T')                     /* trim trailing whitespace */
  IF RIGHT(trail, 2) = '*/' THEN
    trail = STRIP(LEFT(trail, LENGTH(trail) - 2), 'T')

  IF trail = '' THEN RETURN 1                   /* bare canonical form */

  /* Suffix form: ` — <heading>` */
  emdash_prefix = ' 'X2C('E28094')' '
  IF LEFT(trail, LENGTH(emdash_prefix)) \= emdash_prefix THEN RETURN 0
  heading = STRIP(SUBSTR(trail, LENGTH(emdash_prefix) + 1))
  IF heading = '' THEN RETURN 0
  RETURN 1
```

Notes:

- `X2C('E28094')` produces the 3-byte UTF-8 sequence for `—`. The
  literal `'E2 80 94'X` would be byte-equivalent; the `X2C` form is
  used for clarity. Either is acceptable.
- The tail check trims a trailing `*/` (allowing inline citations
  inside a `/* ... */` line) and any trailing whitespace, then
  examines what's left.
- The leading whitespace and `*` characters of the comment block
  are not part of the tail; they precede the marker and are
  irrelevant to the tail check.
- The check is line-local; multi-line citations are not supported
  (and not used by any koan today).

### Negative-test coverage

The tightened regex MUST reject:

1. Legacy ASCII separator: `Cowlishaw §2.5, p. 32 -- Anything`
2. Wrong dash type: `Cowlishaw §2.5, p. 32 - heading` (en-dash or
   single hyphen)
3. Missing space around em-dash: `Cowlishaw §2.5, p. 32—heading`,
   `Cowlishaw §2.5, p. 32 —heading`,
   `Cowlishaw §2.5, p. 32— heading`
4. Empty heading after suffix: `Cowlishaw §2.5, p. 32 — `
5. Garbage after page: `Cowlishaw §2.5, p. 32 garbage`

It MUST accept:

A. Bare with no trailing content: `Cowlishaw §2.5, p. 32`
B. Bare followed only by whitespace: `Cowlishaw §2.5, p. 32   `
C. Bare followed by `*/`: `Cowlishaw §2.5, p. 32 */`
D. Suffixed: `Cowlishaw §2.2, p. 19 — Literal strings`
E. Suffixed inside a closed comment: `Cowlishaw §2.2, p. 19 — Literal strings */`
F. Suffixed with multi-word heading: `Cowlishaw §2.3, p. 27 — Logical (Boolean)`

### Failure-mode reporting

The existing failure list (`MISSING citation`, `MISSING Station: directive`, `MULTIPLE Station: directives`) gains no new entries
under FR-008 — the citation either passes the tightened check or is
treated as "MISSING citation" (since `check_citation` only returns 1
when the canonical form is matched). A non-canonical citation is
indistinguishable from no citation at the lint-failure level. This is
acceptable because:

1. The diagnostic message points the contributor at the file, and the
   non-canonical line is trivially visible there.
2. Adding a "MALFORMED citation" failure mode would tempt
   over-engineering of the regex into a parse-and-explain pass; the
   "either canonical or absent" model keeps the lint script simple.

A future feature MAY introduce a richer failure taxonomy if the
audit-style reviews show contributors stumbling on the binary
classification; not in scope here.

## §3. Runner stdout fixture invariance (FR-010)

`tests/fixtures/runner_stdout.txt` is 12 lines and contains no
Cowlishaw citation text. Citations live in `koans/*.rexx` comment
blocks and are not echoed by the runner (`lib/pilgrimage.rexx`),
the assertion library (`lib/meditation.rexx`), or the station-display
module (`lib/stations.rexx`). The rewrite is therefore guaranteed
to be a comment-only edit; the fixture invariance under FR-010 holds
by construction. SC-006 is satisfied without any fixture re-baseline.

## §4. Constitution and Sync Impact

This feature operationalizes Constitution Principle III (canonical
citation form) but does not require a constitution version bump:

- Principle III's wording (introduced at v1.1.0) already permits the
  canonical form; M2.2 simply enforces what was already authoritative.
- Principle IV's CI-job enumeration (also v1.1.0) is unchanged; the
  6/6 check count is unaffected.
- The deferred lint-update item recorded in the M2.1 spec's Sync
  Impact Report is closed by FR-008. The Sync Impact Report itself
  is historical and is not modified by this feature.

No constitution amendment commit is part of M2.2.

## §5. Out-of-scope items confirmed

Final review against spec.md "Out of Scope" section confirms:

- **Teaching prose body changes (vocabulary review)**: Not touched by
  any rewrite operation in §1. The only prose-adjacent change is the
  citation line itself, which is governed by FR-006 (trailing label
  policy).
- **Index modifications**: None needed (research §1: "No index
  defects discovered").
- **Mechanical existence-check lint extension (FR-014)**: Deferred
  per Clarifications session 2026-05-09. The lint regex tightening
  in §2 above is FR-008 work, not FR-014 work — it does not parse
  the index.
- **Stages II–VI koans**: Do not exist; not edited.
- **Runner stdout fixture refresh**: Invariance verified in §3.
- **Re-deriving the index from the PDF**: Not performed by this
  feature.
- **PDF-posture migration**: Not touched.

Phase 0 is complete. No NEEDS-CLARIFICATION markers remain.
