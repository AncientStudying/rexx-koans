# Contract: `docs/cowlishaw_index.md` File Format

**Date**: 2026-05-08
**Status**: Complete
**Audience**: M2.2 (citation rewrite), M2.3 (vocabulary review),
and every later milestone that adds koans referencing Cowlishaw.

This is M2.1's only external contract: the canonical layout of
`docs/cowlishaw_index.md`. Downstream features rely on this
format being stable. Changes to the format require a coordinated
update to M2.2 / M2.3 / `bin/lint_citations` extension; ad-hoc
edits to the index file are not permitted to reshape the format.

---

## Top-of-file boilerplate

The file opens with one `#` heading (the document title), a
short non-row preamble that names the source, the PDF↔book
offset, and the layout conventions, then the first `#` Part
wrapper.

```markdown
# Cowlishaw Ground-Truth Index

Structural index of M.F. Cowlishaw, *The REXX Language: A
Practical Approach to Programming*, 2nd edition (1990).
Authoritative reference for every Cowlishaw citation in this
project.

- **Source PDF**: `reference/REXX Language - 2nd Edition.pdf`
  (gitignored; obtained from the Internet Archive scan linked
  in `README.md`).
- **Page numbers**: book pages (the printed edition's pagination
  preserved in the scan), never PDF-viewer pages. PDF↔book
  offset: book p. N = PDF p. N+11.
- **Citation format**: canonical form `Cowlishaw §X.Y, p. NN`,
  where §X.Y identifies (Part X, SECTION Y); for child-heading
  rows the canonical form MAY be followed by an optional
  disambiguator suffix ` — <child heading>` when needed (e.g.,
  when two child rows share both a §X.Y and a book page).
- **Layout**: see "Heading hierarchy" below.

# Part 1 — Background

[... §1.1 through §1.5 follow ...]

# Part 2 — REXX Language Definition

[... §2.1 through §2.17 follow ...]

# Appendices

[... Appendix A through D follow ...]
```

Implementation notes:

- The preamble is contributor-facing prose, not a row. It carries
  no `Page:` / `Summary:` / `Vocabulary:` bullets.
- `# Part 1 — Background` and `# Part 2 — REXX Language
  Definition` mirror Cowlishaw's part titles verbatim. The
  `# Appendices` wrapper is editorial — Cowlishaw does not
  name the appendices collectively, but a single wrapper aids
  GitHub's auto-generated TOC.

---

## Heading hierarchy

| Level | Used for | Carries Page/Summary/Vocabulary? |
|---|---|---|
| `#` | File title (one occurrence) | no |
| `#` | `Part 1`, `Part 2`, `Appendices` (three navigation wrappers) | no |
| `##` | One per Cowlishaw §X.Y SECTION (Parts 1 + 2 = 22 total) | yes |
| `##` | One per Appendix top-level entry (Appendix A, B, C, D = 4 total) | yes |
| `###` | One per named typographically distinct child heading inside a §X.Y SECTION or appendix | yes |

No row uses `####` or deeper. (Reserved for a hypothetical
fourth tier if a future Cowlishaw revision introduces one. Not
used in the second edition.)

---

## Per-row content schema

Every `##` and `###` heading is followed immediately by exactly
three Markdown bullets in this order, with bolded labels:

```markdown
## §X.Y — TITLE

- **Page:** NN
- **Summary:** ONE-LINE FACTUAL PARAPHRASE.
- **Vocabulary:** term1, term2, term3
```

Constraints:

- **No additional bullets.** No `Notes:`, no `See also:`, no
  `Cross-reference:`. Cross-references are out of scope per spec.
- **No prose paragraphs between heading and bullets.** The first
  non-blank line under the heading is the `Page:` bullet.
- **No prose paragraphs between bullets.** The three bullets are
  contiguous.
- **Bullet order is fixed**: Page → Summary → Vocabulary.
- **Labels are bolded with `**Page:**`, `**Summary:**`,
  `**Vocabulary:**`** — exactly that case, exactly that
  punctuation. M2.2's mechanical lookup may use these labels as
  anchors.

---

## §X.Y SECTION rendering

```markdown
## §X.Y — Title in Mixed Case

- **Page:** NN
- **Summary:** One-line paraphrase covering what the SECTION as a whole introduces.
- **Vocabulary:** primary term, secondary term, ...
```

Notes on the heading text:

- The §X.Y identifier appears first, prefixed with `§`, with the
  Y not zero-padded (write `§2.2`, not `§2.02`).
- An em-dash separates `§X.Y` from the title.
- The title is **Cowlishaw's wording**, but not necessarily in
  Cowlishaw's casing: Cowlishaw renders SECTION titles in ALL
  CAPS (e.g., `STRUCTURE AND GENERAL SYNTAX`). The index renders
  them in headline case (`Structure and General Syntax`) for
  readability. This is the one permitted typographic adjustment.
  All-caps Cowlishaw rendering is recorded as the
  unmistakable signal of SECTION rank, but the index's heading
  text uses headline case so readers' eyes track normally.

(Child-heading rows below preserve Cowlishaw's exact
mixed-case wording verbatim — the section-title casing
adjustment is a one-time concession to the contrast against
ALL-CAPS source text.)

---

## Child-heading rendering

```markdown
### Cowlishaw's Verbatim Heading Text

- **Page:** NN
- **Summary:** One-line paraphrase covering what this child heading introduces.
- **Vocabulary:** ...
```

Notes:

- The heading text is **Cowlishaw's verbatim**, case and
  punctuation preserved (e.g., `### Logical (Boolean)`,
  `### Implied semicolons and continuations`).
- Child-heading rows do **not** repeat the parent §X.Y in their
  heading text. Parent is inferred from the preceding `##`
  heading. M2.2's citation includes the parent §X.Y (e.g.,
  `Cowlishaw §2.2, p. 19 — Literal strings`).

---

## Appendix rendering

```markdown
## Appendix A: REXX Syntax Diagrams

- **Page:** 165
- **Summary:** ...
- **Vocabulary:** ...

## Appendix B: A Sample REXX Program

- **Page:** 171
- **Summary:** ...
- **Vocabulary:** ...
```

Notes:

- Appendix top-level rows render at `##` like a §X.Y SECTION row.
- Identifier shape is `Appendix N` where N ∈ {A, B, C, D}; the
  full `Appendix N: Title` form appears in the heading text.
- Appendix sub-rows (if any — none in the second edition; see
  data-model.md §"appendix_sub") would render at `###`.

---

## Worked example: §2.2 with its child headings

```markdown
## §2.2 — Structure and General Syntax

- **Page:** 18
- **Summary:** Defines how a REXX program is built from clauses composed of tokens, blanks, and semicolons, including the semicolon-implication rules and continuation conventions.
- **Vocabulary:** clause, token, blank, implied semicolon, continuation, comment

### Comments

- **Page:** 18
- **Summary:** Comment delimiters `/*` and `*/` may nest to any depth; comments are removed during clause scanning and act as token separators.
- **Vocabulary:** comment, nested comments

### Implied semicolons and continuations

- **Page:** 23
- **Summary:** Line-end normally implies a semicolon; a trailing comma defers the semicolon to the next non-blank line, joining the lines into one clause.
- **Vocabulary:** implied semicolon, continuation, comma continuation

### Tokens

- **Page:** 19
- **Summary:** The five categories of REXX tokens — literal strings, hexadecimal strings, binary strings, symbols, operator characters, and special characters — and what each may contain.
- **Vocabulary:** token, literal string, hexadecimal string, binary string, symbol, operator character, special character

### Literal strings

- **Page:** 19
- **Summary:** Sequences of characters delimited by single or double quotes; constants REXX never modifies; the zero-length literal is the null string.
- **Vocabulary:** literal string, null string, single quote, double quote

### Hexadecimal Strings

- **Page:** 20
- **Summary:** Sequences of hex digits grouped in pairs (with optional leading group of 1–2 digits), suffixed with `x` or `X`, denoting an encoding-independent constant.
- **Vocabulary:** hexadecimal string, hexadecimal digit

### Binary Strings

- **Page:** 21
- **Summary:** Sequences of binary digits grouped in fours (with optional leading group of 1–4 digits), suffixed with `b` or `B`, denoting an encoding-independent constant.
- **Vocabulary:** binary string, binary digit

### Symbols

- **Page:** 21
- **Summary:** Groups of characters from a fixed alphabet (letters, digits, period, underscore, and four special characters), used as variable names, function names, or constant tokens; case is normalized to upper.
- **Vocabulary:** symbol, simple symbol, compound symbol, stem, constant symbol, uninitialized

### Operator characters

- **Page:** 22
- **Summary:** The character set used for operators; some have synonyms (e.g., `\` and `¬` for logical not) to accommodate keyboards lacking certain glyphs.
- **Vocabulary:** operator character, synonym

### Special characters

- **Page:** 22
- **Summary:** The non-operator metacharacters (comma, semicolon, parens, colon) plus the operator characters; together they delimit tokens.
- **Vocabulary:** special character

```

This block illustrates every contract rule. The actual file
extends this pattern across all 22 §X.Y SECTIONs and 4
appendices.

---

## Stability commitment

This contract is the M2.1 deliverable's external interface.
Future milestones MUST NOT break it without a coordinated
amendment that updates M2.2's citation rewrite logic and any
extended `bin/lint_citations` index check. Specifically:

- **Stable**: heading hierarchy, bullet schema, bullet order,
  bullet labels, ordering of rows by section number, citation
  format — canonical form `Cowlishaw §X.Y, p. NN` with optional
  disambiguator suffix ` — <child heading>` for child-heading
  rows.
- **Stable but expandable**: vocabulary list per row may grow
  if a Cowlishaw revision introduces new terms; the inclusion
  threshold from research.md §4 governs additions.
- **Not stable**: row summaries are paraphrases; their wording
  may be improved between commits without breaking the
  contract, as long as the summary remains a one-line factual
  description and contains no Cowlishaw prose verbatim.
