# Phase 1: Data Model — M2.1 Cowlishaw Ground-Truth Index

**Date**: 2026-05-08
**Status**: Complete

The deliverable contains a single entity — the **Index row** — with
three discriminated kinds. There are no relationships between rows
beyond document order; the index is a flat sequence with rendering
hierarchy carried in heading levels.

---

## Entity: Index row

A unit of structural reference. Each row represents one Cowlishaw
heading: either a numbered SECTION (the §X.Y level), a named child
heading inside such a SECTION, or an appendix entry / sub-entry.

### Discriminator: `kind`

| Value | Meaning | Heading level | Identifier shape |
|---|---|---|---|
| `cowlishaw_section` | A numbered SECTION inside Part 1 or Part 2. | `##` | `§X.Y` (X = Part 1 or 2; Y = SECTION-within-Part 1–17) |
| `child_heading` | A named typographically distinct heading inside a §X.Y SECTION. | `###` | `(parent §X.Y, verbatim heading title)` |
| `appendix_entry` | An `Appendix N: TITLE` top-level entry. | `##` | `Appendix N` (N ∈ {A, B, C, D}) |
| `appendix_sub` | A named heading inside an appendix that follows the same conventions as a §X.Y child heading. | `###` | `(parent Appendix N, verbatim heading title)` |

Two heading levels (`##` and `###`) carry rows; `#` is reserved
for the file title and the three Part / Appendix navigation
wrappers — those wrappers are **not rows** and carry no Page /
Summary / Vocabulary content.

### Fields (all kinds)

| Field | Type | Required | Notes |
|---|---|---|---|
| `kind` | enum (above) | yes | Implicit in heading position; not written verbatim. |
| `identifier` | string | yes | `§X.Y` for SECTION; `Appendix N` for appendix top; `(parent_id, title)` pair for child headings (rendered as the heading text only — parent inferred from preceding `##`). |
| `title` | string | yes | The heading verbatim from Cowlishaw. Case-sensitive. Includes parenthetical forms (e.g., "Logical (Boolean)"). |
| `book_page` | integer | yes | The book's printed page number where the heading begins. NEVER the PDF-viewer page. PDF↔book offset is +11 (book p. N = PDF p. N+11). |
| `summary` | string | yes | One-line factual paraphrase, in the index author's own words. Sufficient that a contributor can identify the row from this line alone. No verbatim Cowlishaw prose. |
| `vocabulary` | list[string] | yes | Comma-separated list of canonical Cowlishaw terms tied to this row. Each term must (a) appear verbatim within or near the cited page, AND (b) meet the vocabulary inclusion threshold from research.md §4 (typographically marked, subsection title, or glossary entry). May be empty for rows whose page introduces no canonical terms — but FR-007 / SC-004 require non-empty for every row, so the author MUST find at least one canonical term per row. |

### Validation rules (enforced at UAT review per spec User Story 2 / SC-009)

- `title` is verbatim and case-correct (FR-008).
- `book_page` matches the page where the heading visually begins
  in the source PDF (FR-009). Verified by spot-check (SC-006).
- `summary` is the author's paraphrase, contains no continuous
  prose extract from Cowlishaw beyond the title itself (FR-010).
- `vocabulary` entries each appear verbatim in or near the cited
  page (FR-007), and pass the inclusion threshold from
  research.md §4.
- Rows are ordered by Cowlishaw's section numbering (FR-013):
  Part 1 §1.1 → §1.5, Part 2 §2.1 → §2.17, Appendix A → D. Within
  a parent §X.Y or appendix, child rows appear in book order.

### Lifecycle

```text
                Pass 1                    Pass 2                  Pass 3
   ┌────────┐  skeleton    ┌──────────┐  populate    ┌────────────┐  UAT
   │  PDF   │ ───────────▶ │ skeleton │ ───────────▶ │ populated  │ ───────▶  COMMIT
   │ (ref/) │  pdftotext   │  (ref/)  │  by hand     │ (working)  │  fixes
   └────────┘  + grep/awk  └──────────┘              └────────────┘
                                                            │
                                                       (iterate
                                                        until UAT
                                                        accepts)
```

**State transitions**:

1. **Empty** → **Skeleton-populated**: Pass 1 extracts headings
   programmatically from `pdftotext -layout` output, producing
   one row per heading with `title` and `book_page` set,
   `summary` and `vocabulary` blank. Skeleton lives in
   gitignored `reference/`; not committed.
2. **Skeleton-populated** → **Fully populated**: Pass 2 reads
   the PDF page-by-page and fills in `summary` and `vocabulary`
   for every row.
3. **Fully populated** → **UAT-accepted**: Pass 3 reviews every
   row against the PDF; defects are fixed in-place. State
   advances when the project owner signals acceptance.
4. **UAT-accepted** → **Committed**: branch is merged to `main`.
   The committed file is normative; subsequent edits are only
   permitted to correct misrepresentation of the book (FR-016).

A row never reaches the `Committed` state with empty
`summary` / `vocabulary` (SC-004), incorrect `book_page`
(SC-001 / SC-002), or non-verbatim `title` (FR-008). The UAT
review is the gate.

### Worked examples

#### Kind = `cowlishaw_section`

```markdown
## §2.2 — Structure and General Syntax

- **Page:** 18
- **Summary:** Defines the structural building blocks of a REXX program — clauses, tokens, comments, semicolon and continuation rules — and how they compose.
- **Vocabulary:** clause, token, comment, blank, implied semicolon, continuation
```

Identifier: `§2.2`. Parent: Part 2 (the surrounding `# Part 2 —
REXX Language Definition` wrapper).

#### Kind = `child_heading`

```markdown
### Literal strings

- **Page:** 19
- **Summary:** Sequences of characters delimited by single or double quotes; constants whose contents REXX never modifies. The null string is the zero-length literal.
- **Vocabulary:** literal string, null string, hexadecimal string, binary string
```

Identifier: `(§2.2, "Literal strings")`. Parent: the immediately
preceding `## §2.2 — Structure and General Syntax`. Citation
form for M2.2: `Cowlishaw §2.2, p. 19 — Literal strings`.

#### Kind = `appendix_entry`

```markdown
## Appendix A: REXX Syntax Diagrams

- **Page:** 165
- **Summary:** Collected syntax diagrams for every REXX keyword instruction and operator construct presented in Part 2; references the page where each is defined.
- **Vocabulary:** syntax diagram, expression, instruction, name, pattern, string, symbol, template
```

Identifier: `Appendix A`. Parent: the `# Appendices` wrapper.

#### Kind = `appendix_sub`

Most appendices in this book are flat (Appendices B, C, D each
contain prose without typographically distinct sub-headings).
Appendix A's per-instruction syntax-diagram blocks (`Assignment`,
`Command`, `Keyword Instructions`, etc.) are *list-item labels*
for diagrams, not heading-rank elements, and per the spec's
edge-case rule are **not** promoted to row rank. Empirically,
this kind has zero rows in the second-edition book; it remains
in the model for forward-compatibility.

---

## Volume

Per research.md §1, the empirical row count:

| Kind | Count (estimated) |
|---|---|
| `cowlishaw_section` (Part 1) | 5 |
| `cowlishaw_section` (Part 2) | 17 |
| `child_heading` (across all sections) | ~80–120 |
| `appendix_entry` | 4 |
| `appendix_sub` | 0 |
| **Total** | **~106–146** |

The `child_heading` count is concentrated in §2.7 (KEYWORD
INSTRUCTIONS — one row per instruction: ADDRESS, ARG, CALL, DO,
DROP, EXIT, IF, INTERPRET, ITERATE, LEAVE, NOP, NUMERIC,
OPTIONS, PARSE, PROCEDURE, PULL, PUSH, QUEUE, RETURN, SAY,
SELECT, SIGNAL, TRACE, UPPER) and §2.9 (BUILT-IN FUNCTIONS —
one row per function: ABS, ADDRESS, ARG, B2X, BITAND, BITOR,
BITXOR, C2D, C2X, CENTER, CHARIN, CHAROUT, CHARS, COMPARE,
CONDITION, COPIES, D2C, D2X, DATATYPE, DATE, DELSTR, DELWORD,
DIGITS, ERRORTEXT, FORM, FORMAT, FUZZ, INSERT, LASTPOS, LEFT,
LENGTH, LINEIN, LINEOUT, LINES, MAX, MIN, OVERLAY, POS,
QUEUED, RANDOM, REVERSE, RIGHT, SIGN, SOURCELINE, SPACE,
STREAM, STRIP, SUBSTR, SUBWORD, SYMBOL, TIME, TRACE, TRANSLATE,
TRUNC, VALUE, VERIFY, WORD, WORDINDEX, WORDLENGTH, WORDPOS,
WORDS, X2B, X2C, X2D, XRANGE — approximately 60 functions,
each its own child heading row).

The estimate firms up after Pass 1 produces the actual skeleton.

## No relationships between rows

The data model has no foreign keys, no cross-references, no
"see also" links. Spec Out of Scope explicitly excludes
cross-references — the contributor consults the index by
direct topic lookup, not by following inter-row links. Document
order alone carries the structure.
