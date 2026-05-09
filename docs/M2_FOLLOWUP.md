# M2 Follow-Up — Citation and Vocabulary Audit

**Status**: Open — three discrete tasks queued post-M2 implementation.
**Created**: 2026-05-08.
**Origin**: M2 UAT review.

## Background

During UAT of the M2 Stage I curriculum, two issues with the koan
content surfaced:

1. **Citation pages are inaccurate.** The
   `Cowlishaw §N.N, p. NN` references in the M2 koans were authored
   from training-data memory of REXX rather than from the actual
   *The REXX Language* (2nd edition, 1990) text. A direct audit
   against the PDF (in `reference/REXX Language - 2nd Edition.pdf`,
   gitignored) found that 9 of the 11 unique cited (section, page)
   pairs are wrong, often by 10+ pages. Several point to the wrong
   *section* entirely. Only `§1.1, p. 1` and `§2.3, p. 27` are
   correct as written. Full audit findings are reproduced in the
   "Audit findings (2026-05-08)" section below; they must remain
   the source of truth for Task 2.
2. **Concept naming uses non-Cowlishaw vocabulary.** The koan
   teaching prose uses terms ("assertion", "literal" framing,
   etc.) that are koan-framework conventions or training-data
   approximations rather than the canonical terminology Cowlishaw
   uses (e.g., "literal string", "symbol", "compound symbol",
   "Comparative" not "Comparisons", "Logical (Boolean)", etc.).
   This is layered on top of the citation issue and is not
   resolved by fixing pages alone.

The agreed fix is to build a structural ground-truth index of the
book first, then use that index as the authority for both
citations and terminology in a second pass, and for the vocabulary
review in a third.

## Tasks

### Task 1: Build `docs/cowlishaw_index.md` — whole book

**Scope**: Cowlishaw, *The REXX Language* (2nd edition, 1990) —
all 188 numbered pages + Appendices A–D + Index. Not just Stage I
range; future stages benefit from a complete index already
present.

**Procedure** (three internal passes):

1. **Programmatic skeleton.** Run `pdftotext -layout` against the
   PDF (poppler installed). Parse the output to extract every
   `SECTION N: TITLE` heading and every recognised subsection
   heading (Cowlishaw uses a consistent indented-bold style; the
   layout dump preserves it). Pair each row with its book page
   number (the PDF↔book offset is +11; book p. N = PDF p. N+11).
   Emit a Markdown skeleton with one row per (section,
   subsection), summaries blank.
2. **Populate summaries and vocabulary.** Read the dumped text
   page-by-page and fill in, for each row:
   - A one-line factual summary in our own words (so contributors
     don't need to re-open the PDF).
   - The canonical Cowlishaw vocabulary tied to the topic
     (the *exact terms Cowlishaw uses*: "literal string",
     "symbol", "compound symbol", "stem", "Comparative",
     "Logical (Boolean)", etc.). This vocabulary list is what
     Task 3 reviews koan prose against.
3. **UAT review.** User reads the populated index and corrects
   anything off; then commit.

**Acceptance**:
- Every `SECTION N: TITLE` in the book is present with its book
  page.
- Every named subsection (e.g., "Concatenation", "Arithmetic",
  "Comparative", "Logical (Boolean)", "Numbers") that begins on
  its own page-anchored heading line is present.
- Each row has a one-line summary and a canonical-vocabulary
  list.
- Appendices A–D are covered (syntax diagrams, sample program,
  language changes since first edition, glossary).
- File is committed at `docs/cowlishaw_index.md`.

**Copyright posture**: the index records *structure* (titles,
page numbers, our paraphrase, key terminology) — factual
reference, not redistribution. Raw extracted prose from
Cowlishaw is NEVER committed to the repo; it stays under
`reference/` (gitignored) or in `/tmp`. The PDF itself remains
gitignored.

**Forward use**: Future milestones extend the index only when
Cowlishaw revisions or omissions are discovered. Adding a koan
in M3+ does NOT modify the index — the index is anchored to the
book, not the curriculum.

### Task 2: Rewrite M2 citations against the index

**Depends on**: Task 1 complete.

**Scope**: Replace every `Cowlishaw §N.N, p. NN` line in the six
M2 koans and six M2 solutions with a citation that points at a
row in `docs/cowlishaw_index.md`. The replacement section number
and page number must match what the index records for the topic
the citation is meant to anchor.

**Procedure**:
1. For each existing citation, identify the concept the teaching
   block above it covers (literal strings, comments, semicolons,
   arithmetic, comparison, logical, concatenation, assignment,
   SAY, etc.).
2. Look up the matching row in the index.
3. Apply the replacement (`Edit` with `replace_all: true` per
   distinct old citation, since most appear multiple times across
   koan + solution).
4. Re-run `bin/lint_citations` (must remain 6/6 green).
5. Re-capture `tests/fixtures/runner_stdout.txt` only if the
   visible runner output changed (it should not — citations live
   in koan comments, never echoed to stdout).
6. Optionally extend `bin/lint_citations` to verify each citation
   matches a row in the index (mechanical existence check, not
   just format). If extended, document in the lint contract.

**Acceptance**:
- Every koan and solution citation references an existing row in
  `docs/cowlishaw_index.md`.
- `verify_solutions` 6/6 green.
- `lint_citations` 6/6 green.
- Runner fixture unchanged (or updated and re-confirmed
  byte-identical across the CI matrix if changed).

### Task 3: Review M2 koan teaching-prose vocabulary

**Depends on**: Task 1 complete (Task 2 may run first or in
parallel; vocabulary review is independent of citation pages).

**Scope**: Read the teaching-comment blocks in each of the six
M2 koans (and matching solutions, since teaching prose is shared)
and rewrite any term that doesn't match Cowlishaw's canonical
vocabulary as recorded in the index.

**Specific concerns surfaced at UAT**:
- "Assertion" framing in koan 00 is *koan-framework* vocabulary,
  not REXX vocabulary. The teaching block must distinguish: the
  koan-framework provides assertion verbs (eq, neq, true,
  datatype) layered on top of REXX; the REXX concepts those
  verbs *exercise* (string equality, comparison, boolean values,
  DATATYPE built-in) are what Cowlishaw teaches. The current
  prose blurs that.
- "Literal strings" vs "string literals" — Cowlishaw uses the
  former; verify our prose matches.
- "Symbol" vs "variable name" / "identifier" — Cowlishaw uses
  "symbol" as the formal term; "variable" only when the symbol
  has been bound. Our koan 02 prose uses both interchangeably;
  verify Cowlishaw's distinction is preserved.
- "Comparative" vs "Comparisons" — Cowlishaw's subsection is
  "Comparative".
- "Logical (Boolean)" — Cowlishaw's subsection title.
- Any other term in the index's vocabulary column that doesn't
  match what the koans say.

**Procedure**:
1. For each koan, walk teaching blocks top to bottom.
2. Cross-check each technical term against the relevant index row.
3. Substitute Cowlishaw's term if ours differs.
4. If a koan-framework concept (like "assertion") needs to live
   alongside a REXX concept, frame it explicitly: "the koan's
   assertion verb is `eq`; REXX's underlying mechanism is the `=`
   comparison operator (Cowlishaw §..., p. ...)". The two layers
   stay distinguishable.
5. Re-run `verify_solutions` and `lint_citations`.
6. Manual re-walk of the runner output to confirm pilgrim-facing
   pedagogy still reads cleanly.

**Acceptance**:
- Every technical term in koan teaching prose appears either
  literally in the index's vocabulary column or is explicitly
  framed as koan-framework vocabulary distinct from REXX.
- `verify_solutions` 6/6 green.
- `lint_citations` 6/6 green.
- Runner fixture unchanged (teaching prose lives in comments,
  never echoed).

## Audit findings (2026-05-08)

For posterity, the page-audit findings against the PDF — the input
that motivates Task 2:

| # | Original | Reality | Verdict |
|---|---|---|---|
| 1 | `§1.1, p. 1 — Introduction` | Part 1 §1 starts p. 1; introductory in tone. | ✓ correct |
| 2 | `§2.1, p. 15 — Literal strings` | §2.1 = "Characters and Encodings" starts p. 17. Literal strings are defined in §2.2 on book pp. 18–19. | ✗ section + page wrong |
| 3 | `§2.2, p. 17 — Numbers` | §2.2 = "Structure and General Syntax" starts p. 18. "Numbers" subsection is in §2.3 on p. 27. | ✗ section + page wrong |
| 4 | `§2.3, p. 22 — Operators / Arithmetic` | §2.3 = "Expressions and Operators" starts p. 24. "Arithmetic" subsection on p. 25. | ✗ page wrong |
| 5 | `§2.3, p. 25 — Comparisons` | "Comparative" subsection starts on p. 26. | ✗ page wrong by 1 |
| 6 | `§2.3, p. 27 — Logical operators` | "Logical (Boolean)" subsection on p. 27. | ✓ correct |
| 7 | `§2.3, p. 30 — Concatenation` | "Concatenation" subsection starts on p. 25. | ✗ page wrong |
| 8 | `§2.4, p. 38 — Clauses / Continuation` | §2.4 = "Clauses and Instructions" is a 1-page taxonomy on p. 31. Comma-continuation mechanics are in §2.2: "Implied semicolons and continuations" on p. 23. | ✗ section + page wrong |
| 9 | `§2.4, p. 39 — Comments` | "Comments" subsection in §2.2 on p. 18. | ✗ section + page wrong |
| 10 | `§2.5, p. 42 — Assignments` | §2.5 = "Assignments and Variables" starts p. 32. p. 42 is mid-§2.7 (ARG keyword). | ✗ page wrong |
| 11 | `§2.7, p. 56 — The SAY instruction` | SAY subsection on p. 70. p. 56 is mid-INTERPRET. | ✗ page wrong |

PDF↔book offset for future audits: book p. N = PDF p. N + 11.
