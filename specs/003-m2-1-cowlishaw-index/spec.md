# Feature Specification: M2.1 — Cowlishaw Ground-Truth Index

**Feature Branch**: `003-m2-1-cowlishaw-index`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "M2.1 — Cowlishaw Ground-Truth Index — reference PLAN.md and docs/M2_FOLLOWUP.md Task 1"

## Background

During UAT of the M2 Stage I curriculum, a citation audit found that 9
of the 11 unique `Cowlishaw §N.N, p. NN` references in the koans pointed
to the wrong section, the wrong page, or both — often by ten or more
pages. The root cause was that citations had been authored from
training-data memory of REXX rather than from the actual text of M.F.
Cowlishaw's *The REXX Language: A Practical Approach to Programming*
(2nd edition, 1990). A separate audit found that some koan teaching
prose used non-Cowlishaw vocabulary (e.g., "string literal" instead of
the book's "literal string"; "Comparisons" instead of the book's
"Comparative" subsection title).

The agreed remediation, recorded in `PLAN.md` (M2.1–M2.3) and
`docs/M2_FOLLOWUP.md`, is sequenced in three sub-milestones:

1. **M2.1 (this feature)** — build a structural ground-truth index of
   the entire book at `docs/cowlishaw_index.md`, extracted from the
   gitignored PDF in `reference/`. From this point forward, the index
   is the authority for every citation and every piece of canonical
   REXX terminology in the curriculum.
2. **M2.2** — rewrite every Stage I citation against the index.
3. **M2.3** — review koan teaching prose against the index's
   vocabulary column and align any non-Cowlishaw terms.

M2.1 is a prerequisite for M2.2 and M2.3 and for every later
curriculum stage that adds new citations.

## Clarifications

### Session 2026-05-08

- Q: Should each named typographically distinct child heading inside a
  §X.Y subsection (e.g., "Literal strings", "Comments", "Numbers",
  "Comparative", "Logical (Boolean)", "Concatenation", "Implied
  semicolons and continuations") get its own index row, or only the
  numbered §X.Y subsections? → A: Each named child heading gets its
  own row. Citation format remains `Cowlishaw §X.Y, p. NN — <child
  heading>`, where the §X.Y is the parent subsection's number and the
  page is the page on which the child heading begins.
- Q: Which in-file layout should `docs/cowlishaw_index.md` use —
  Markdown headings + bullet rows, a single Markdown table, one table
  per top-level section, or a definition-list style? → A: Markdown
  headings + bullet rows. Top-level section = `##`; numbered §X.Y
  subsection = `###`; named child heading = `####`. Each heading is
  followed by `Page:`, `Summary:`, and `Vocabulary:` as sub-bullets.
  This gives GitHub anchor links per row, accommodates multi-term
  vocabulary lists comfortably, and keeps M2.2's mechanical lookups
  unambiguous.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Koan author looks up a citation while writing teaching prose (Priority: P1)

A contributor authoring or revising a koan teaching block needs to cite
the section of *The REXX Language* that introduces the concept being
taught (e.g., "the SAY instruction", "the comma-continuation rule",
"compound symbols"). Today they must page through a 240-page PDF — the
behavior that produced the 9/11-wrong audit result. With the index,
they can locate the concept in a single Markdown file by topic name,
read a one-line factual summary, copy the verbatim section title, and
copy the book page number into the citation.

**Why this priority**: This is the failure mode the index exists to
eliminate. Without it, every future Cowlishaw citation in the
curriculum is at the same risk that produced the M2 audit findings.
M2.2 and every subsequent stage that adds koans depend on this lookup
being trivially correct.

**Independent Test**: Open `docs/cowlishaw_index.md`, search for any of
the eleven topics covered by the M2 koans (literal strings, comments,
implied semicolons / continuation, assignment, arithmetic, comparative,
logical / boolean, concatenation, numbers, SAY instruction, INTERPRET).
Each topic must resolve to a single index row whose section number,
verbatim subsection title, and book page can be transcribed directly
into a `Cowlishaw §N.N, p. NN` citation that survives audit.

**Acceptance Scenarios**:

1. **Given** the contributor is writing a teaching block about literal
   strings, **When** they open `docs/cowlishaw_index.md` and search for
   "Literal strings", **Then** they find a row whose subsection title
   reads exactly "Literal strings" (Cowlishaw's wording, not "string
   literals"), with the parent section number and the book page where
   the subsection begins, and a one-line summary that confirms this is
   the right row without re-opening the PDF.
2. **Given** the contributor is writing a teaching block about
   comma-continuation, **When** they search the index for
   "continuation", **Then** they find Cowlishaw's "Implied semicolons
   and continuations" subsection in §2.2 on book p. 23 — not §2.4
   p. 38 (one of the audit-wrong citations).
3. **Given** every one of the eleven topics flagged in the M2 audit,
   **When** the contributor looks each up in the index, **Then** the
   resulting citation is the one the audit identifies as correct (or,
   for the two already-correct citations, matches what is already in
   the koan).

---

### User Story 2 — Project owner reviews the populated index for factual correctness (Priority: P1)

The project owner must read the populated `docs/cowlishaw_index.md` end
to end and confirm that every entry — section title, subsection title,
book page, summary, vocabulary list — matches the source PDF. The
index is the authority for every downstream citation; an undetected
error in the index propagates into every koan that cites that row.
This UAT review is the explicit third pass of the build procedure
(`PLAN.md` §M2.1, `docs/M2_FOLLOWUP.md` Task 1).

**Why this priority**: The index has no value if its accuracy is not
established before downstream work depends on it. Skipping or skimping
this review re-introduces the original failure mode at a higher
authority level.

**Independent Test**: With the populated index file and the gitignored
PDF both available, the owner reads through the index sequentially.
Every section/subsection title can be located in the PDF at the
recorded book page; every one-line summary is factually accurate to
the page it cites; every term in the vocabulary column appears
verbatim somewhere in or near that section in the book.

**Acceptance Scenarios**:

1. **Given** the populated index, **When** the owner verifies every
   `SECTION N: TITLE` row against the PDF, **Then** every section
   title is verbatim and every section page is correct.
2. **Given** the populated index, **When** the owner spot-checks
   subsection rows against the PDF, **Then** every subsection title
   matches the book's wording (e.g., "Comparative", not "Comparisons";
   "Logical (Boolean)", not "Logical operators"), and every book page
   is correct to the start of that subsection.
3. **Given** the populated index, **When** the owner reads a sample of
   summaries against the cited page, **Then** each summary is a true
   one-line description of what the page covers and contains no
   verbatim Cowlishaw prose beyond the section/subsection titles
   themselves.
4. **Given** the populated index, **When** the owner finds a defect,
   **Then** the defect is corrected in the index file before the
   feature is considered done — the index is not committed in a
   known-incorrect state.

---

### User Story 3 — Vocabulary review against canonical Cowlishaw terms (Priority: P1)

The vocabulary column in the index is the input to M2.3 (vocabulary
review of koan prose) and to every future stage's vocabulary check.
For each row, it records the *exact terms* Cowlishaw uses for the
concepts that row covers — "literal string", "symbol", "compound
symbol", "stem", "uninitialized", "Comparative", "Logical (Boolean)",
and so on. This list is what later milestones cross-reference koan
teaching prose against.

**Why this priority**: Without the vocabulary column, M2.3 has no
authority to point to and devolves back into "what term does
Cowlishaw use here?" — exactly the question whose unreliable answer
caused the original audit findings. The vocabulary column is also what
distinguishes this index from a generic table of contents.

**Independent Test**: For any row in the index, the listed canonical
terms can be located literally in the cited section of the PDF, and
the relevant koan-prose-flagged candidates from the audit
("string literal" → "literal string"; "variable name"/"identifier" →
"symbol"; "Comparisons" → "Comparative"; "Logical operators" →
"Logical (Boolean)"; etc.) each have their canonical replacement
present in the appropriate row's vocabulary column.

**Acceptance Scenarios**:

1. **Given** the populated index, **When** any vocabulary entry is
   checked against the PDF page(s) it claims to draw from, **Then**
   the term appears verbatim there.
2. **Given** the audit-flagged vocabulary swaps (string literal →
   literal string; variable name → symbol; Comparisons → Comparative;
   Logical operators → Logical (Boolean)), **When** the relevant index
   rows are inspected, **Then** the canonical Cowlishaw form is
   present in the vocabulary column of the appropriate row.

---

### Edge Cases

- **Multiple child headings on the same page.** A §X.Y subsection
  may contain several named child headings (e.g., §2.3 has
  "Arithmetic", "Comparative", "Concatenation", "Logical (Boolean)"
  in close succession). Each gets its own row; rows may legitimately
  share a book page when two child headings begin on the same page.
- **Section that is a one-page taxonomy with no named subsections.**
  E.g., §2.4 "Clauses and Instructions" is a single page that lists
  clause categories. The row for §2.4 captures the section as a whole;
  no subsection rows are forced.
- **Heading-rank confusion.** Cowlishaw's typographic conventions
  distinguish top-level sections, numbered §X.Y subsections, and
  named child headings inside subsections. The index must record
  each at its true rank — the parent section number on a row is
  always the closest enclosing §X.Y, never an arbitrarily chosen
  ancestor; and inline labels, list-item bold runs, and caption
  text are not headings and do not get rows.
- **Concept that appears across multiple sections.** E.g.,
  arithmetic precision is touched in §2.3 and elaborated in §2.11.
  Each section's row records the canonical vocabulary that section
  introduces; the contributor consults whichever row matches the
  concept their koan is anchoring to.
- **Page-number defects in the source PDF.** The PDF↔book offset is
  fixed at +11 (book p. N = PDF p. N+11). If a page of the PDF is
  scanned out of order, the row records the *book* page, since that
  is what citations refer to.
- **Appendix material with non-numeric section identifiers.**
  Appendices A–D each get a top-level row; sub-headings inside an
  appendix follow the same rules as subsections in Parts 1–2.
- **Defect found after the index is committed.** A correction is a
  one-row edit; the index is the source of truth, so corrections to
  it precede any koan change that depends on the corrected row.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST contain a single committed file at
  `docs/cowlishaw_index.md` that serves as the authoritative
  structural index of *The REXX Language* (2nd edition, 1990).
- **FR-002**: The index MUST cover the entire book — Part 1
  (Introduction), Part 2 (Definition: Sections 2.1 through the end of
  the language definition), and Appendices A through D — not just the
  range needed for Stage I koans.
- **FR-003**: For every top-level numbered section (`SECTION N: TITLE`
  in Cowlishaw's typography — e.g., `SECTION 1: INTRODUCTION`,
  `SECTION 2: REXX GENERAL CONCEPTS`) in Parts 1 and 2, the index
  MUST contain a row recording the section number, the section title
  verbatim as written in the book, and the book page on which the
  section begins.
- **FR-004**: For every numbered subsection (§X.Y — e.g., §2.2
  "Structure and General Syntax", §2.5 "Assignments and Variables")
  in Parts 1 and 2, the index MUST contain a row recording the §X.Y
  identifier, the subsection title verbatim, and the book page on
  which the subsection begins.
- **FR-004a**: For every named, typographically distinct child
  heading inside a numbered subsection (e.g., "Literal strings"
  inside §2.2; "Comments" inside §2.2; "Numbers" inside §2.3;
  "Comparative" inside §2.3; "Logical (Boolean)" inside §2.3;
  "Concatenation" inside §2.3; "Implied semicolons and continuations"
  inside §2.2; "Compound symbols" inside §2.5) in Parts 1 and 2, the
  index MUST contain a row recording the parent §X.Y identifier, the
  child heading verbatim, and the book page on which the child
  heading begins. Citations against such a row use the format
  `Cowlishaw §X.Y, p. NN — <child heading>`. Inline labels, list-item
  headings, and figure or table captions MUST NOT be promoted to
  child-heading rank.
- **FR-005**: For each Appendix A through D, the index MUST contain
  a top-level row, plus rows for any named sub-headings inside the
  appendix that follow the same heading conventions as Parts 1–2
  subsections.
- **FR-006**: Every row in the index MUST include a one-line factual
  summary of what that section or subsection covers, written in the
  index author's own words, sufficient that a contributor can identify
  whether the row matches the concept they are looking up without
  re-opening the PDF.
- **FR-007**: Every row in the index MUST include a vocabulary list
  recording the canonical Cowlishaw terms tied to that row's topic
  (e.g., for §2.5: "variable", "symbol", "compound symbol", "stem",
  "uninitialized"). Each listed term MUST appear verbatim in
  Cowlishaw's text within or near the cited section.
- **FR-008**: Section and subsection titles in the index MUST match
  Cowlishaw's wording exactly (case-sensitive, including parenthetical
  forms — e.g., "Literal strings", "Comparative", "Logical (Boolean)",
  not paraphrases).
- **FR-009**: All page numbers in the index MUST be **book pages**
  (the printed edition's page numbers as preserved in the Internet
  Archive scan), not PDF-viewer page numbers. The index MUST be
  consistent on this convention without exception.
- **FR-010**: The index MUST NOT contain verbatim prose extracts from
  Cowlishaw beyond the section/subsection titles themselves and the
  short canonical vocabulary terms. Summaries are paraphrases written
  by the index author.
- **FR-011**: The repository MUST NOT commit the source PDF, raw
  `pdftotext` output, or any other byproduct that contains
  redistributed Cowlishaw prose. Such artifacts remain under the
  gitignored `reference/` directory or in `/tmp`.
- **FR-012**: The index file MUST be a single Markdown file
  (`docs/cowlishaw_index.md`) and MUST be readable directly on
  GitHub's Markdown renderer and in a plain-text editor.
- **FR-012a**: The index MUST use Markdown headings to encode row
  hierarchy: top-level numbered section (e.g., `SECTION 1:
  INTRODUCTION`) at heading level `##`; numbered §X.Y subsection
  at heading level `###`; named child heading inside a subsection
  at heading level `####`; appendix top-level entries (Appendix A,
  B, C, D) at heading level `##`; named appendix sub-headings at
  heading level `###`. Each heading represents exactly one index
  row.
- **FR-012b**: Under each heading, the row's content MUST appear as
  three Markdown bullets, in this order: `- **Page:** <book page>`,
  `- **Summary:** <one-line factual summary>`,
  `- **Vocabulary:** <comma-separated canonical terms>`. No
  additional fields. No prose paragraphs between heading and
  bullets.
- **FR-013**: The index file MUST be ordered by Cowlishaw's section
  numbering (Parts 1–2 in numeric section order, then Appendices A–D
  in alphabetical order). Rows within a section MUST be in the order
  they appear in the book.
- **FR-014**: The build of the index MUST proceed in the three
  internal passes recorded in `PLAN.md` §M2.1 — (1) programmatic
  skeleton extracted from the PDF; (2) summaries and canonical
  vocabulary populated from page-by-page reading; (3) UAT review by
  the project owner — and MUST NOT be committed until the UAT pass
  is complete.
- **FR-015**: The index, once committed, MUST be the authority that
  M2.2 (citation rewrite) and M2.3 (vocabulary review) cite against.
  Both downstream features look up rows in this file; neither
  re-derives section, page, or vocabulary information from the PDF
  independently.
- **FR-016**: After commit, the index MUST be modified only when a
  Cowlishaw revision or omission is discovered — i.e., when the index
  itself is found to misrepresent the book. The index MUST NOT be
  modified in response to curriculum changes (adding a koan, renaming
  a koan, restructuring a stage), since the index is anchored to the
  book, not the curriculum.
- **FR-017**: All Stage I citation defects identified in the
  `docs/M2_FOLLOWUP.md` audit table MUST be resolvable by lookup
  against the committed index — i.e., for each of the eleven audit
  rows, the index MUST contain a row that produces the correct
  citation for the concept that audit row covers. (Resolution itself
  is M2.2's deliverable; this requirement is on the index's
  completeness, not on koan contents.)

### Key Entities

- **Index file** (`docs/cowlishaw_index.md`): single Markdown
  document. Authoritative reference for the project's citations and
  canonical REXX vocabulary. Anchored to the book, not the curriculum.
- **Index row**: one entry of the index representing either a
  top-level section, a numbered §X.Y subsection, a named child
  heading inside a subsection, or an appendix heading. Carries
  section/appendix identifier, verbatim title, book page, one-line
  summary, and canonical vocabulary list. Child-heading rows record
  their parent §X.Y identifier (not a synthetic §X.Y.Z number, since
  Cowlishaw does not number child headings).
- **Source PDF**: M.F. Cowlishaw, *The REXX Language: A Practical
  Approach to Programming*, 2nd edition (1990). Lives at
  `reference/REXX Language - 2nd Edition.pdf` on contributor machines
  only. Gitignored. The Internet Archive scan referenced from the
  README is the canonical public source the print edition is paginated
  against.
- **Audit table**: `docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)"
  — the eleven-row record of which Stage I citations were wrong and
  why. Used as the test set for FR-017.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The index covers 100% of `SECTION N: TITLE` headings in
  Parts 1 and 2 of the book, with verbatim title and correct book
  page for each.
- **SC-002**: The index covers 100% of numbered §X.Y subsections in
  Parts 1 and 2 and 100% of named typographically distinct child
  headings inside those subsections, with verbatim title and correct
  book page for each.
- **SC-003**: All four appendices (A, B, C, D) are present, each with
  at least its top-level row.
- **SC-004**: Every row has a non-empty one-line summary and a
  non-empty canonical vocabulary list; no row ships with placeholder
  content.
- **SC-005**: For each of the eleven audit-table rows in
  `docs/M2_FOLLOWUP.md`, the contributor can produce the
  audit-correct citation in under one minute by consulting the index
  alone, without re-opening the PDF.
- **SC-006**: An external reviewer with the PDF open can verify any
  randomly chosen index row's title and page in under thirty seconds,
  because the title is verbatim and the page is the book page (not a
  PDF-viewer page).
- **SC-007**: The four audit-flagged vocabulary swaps (string literal
  → literal string; variable name/identifier → symbol; Comparisons →
  Comparative; Logical operators → Logical (Boolean)) are each
  resolvable by reading the relevant index row's vocabulary column.
- **SC-008**: The repository contains no committed file with verbatim
  Cowlishaw prose beyond section/subsection titles and short
  canonical vocabulary terms; specifically, neither the source PDF
  nor any raw `pdftotext` dump is committed.
- **SC-009**: The UAT review pass identifies and resolves every
  defect found before the index is committed; the committed file
  reflects the post-review corrected state.

## Assumptions

- The contributor's local copy of the PDF at `reference/REXX Language
  - 2nd Edition.pdf` is paginated identically to the Internet Archive
  scan linked from `README.md`. The PDF↔book offset of +11 (book
  p. N = PDF p. N+11) recorded in `docs/M2_FOLLOWUP.md` is treated as
  a fixed property of that scan.
- The `reference/` directory is and remains gitignored
  (`PLAN.md` §3, §8). The PDF is acquired by each contributor from
  the Internet Archive link in `README.md`, not redistributed by the
  project.
- "Whole book" means Parts 1–2 plus Appendices A–D and is finite and
  fixed; the second edition is not under revision. Future Cowlishaw
  publications would not motivate updates to this index.
- Curriculum-side use of the index (M2.2, M2.3, and beyond) is out of
  scope for this feature. M2.1 delivers the index; the koans are not
  modified by this feature.
- The fair-use posture of recording structure (titles, page numbers,
  paraphrased summaries, key terminology) but not redistributing
  Cowlishaw's prose is sufficient for the project's MIT-licensed,
  attribution-bearing publication of the index. This matches the
  posture already taken by `PLAN.md` §13.
- The skeleton-extraction step relies on `pdftotext -layout`
  (poppler) being installable on the contributor's machine, as
  recorded in `PLAN.md` §M2.1 and `docs/M2_FOLLOWUP.md` Task 1. This
  is a one-time contributor-side dependency, not a runtime project
  dependency.

## Dependencies

- **Upstream**: M2 (Walking Skeleton) is complete; the M2 UAT audit
  recorded in `docs/M2_FOLLOWUP.md` motivates this feature.
- **Downstream**: M2.2 (citation rewrite against index) and M2.3
  (vocabulary review against index) both block on M2.1 completion.
  Every later milestone (M3–M6) that introduces new koans relies on
  the index for its citations.

## Out of Scope

- Modifying koan files (`koans/`) or solution files (`solutions/`)
  to use the index. That is M2.2 and M2.3 work.
- Extending `bin/lint_citations` to verify citations against the
  index. Optional and explicitly assigned to M2.2 in `PLAN.md`.
- Building any tool, watcher, or CI check that re-derives the index
  from the PDF. The index is a one-time human-curated artifact;
  re-derivation tooling would re-introduce the redistribution risk
  that the gitignore policy exists to prevent.
- Indexing the book's back-of-book Index pages as separate rows.
  Those pages are referential and add no canonical-vocabulary value
  the front-matter sections do not already supply.
- Recording cross-references between sections (e.g., "see also") in
  the index. Contributors look up by topic; cross-references are a
  reading aid the PDF already provides.
