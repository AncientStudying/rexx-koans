# Quickstart: Using the Cowlishaw Ground-Truth Index

**Audience**: koan authors, reviewers, anyone writing or
auditing a `Cowlishaw §N.N, p. NN` citation in this project.

The index lives at `docs/cowlishaw_index.md`. This quickstart
shows how to use it; for the file's internal format see
`contracts/index_format.md`.

---

## The 60-second lookup workflow

Goal: produce a correct `Cowlishaw §X.Y, p. NN — <heading>`
citation for a concept your koan teaches.

**Step 1.** Identify the concept's name as Cowlishaw would
phrase it.

If you're not sure, scan the **Vocabulary:** lines in the index.
Cowlishaw uses some terms differently from common
training-data lore — "literal string" not "string literal",
"symbol" not "variable name" / "identifier", "Comparative" not
"Comparisons", "Logical (Boolean)" not "Logical operators".
Vocabulary lines surface those canonical forms.

**Step 2.** Open `docs/cowlishaw_index.md` and use your
editor's full-text search.

The file is a few hundred lines. A direct find on the heading
text or the vocabulary terms returns the matching row immediately.

**Step 3.** Read the row.

Each row is a heading followed by three bullets:

```markdown
### Literal strings

- **Page:** 19
- **Summary:** Sequences of characters delimited by single or double quotes; constants REXX never modifies; the zero-length literal is the null string.
- **Vocabulary:** literal string, null string, single quote, double quote
```

The **Summary** confirms you've found the right row. The
**Page** is the citation's page number. The parent §X.Y
identifier is the closest preceding `##` heading.

**Step 4.** Construct the citation.

Format: `Cowlishaw §X.Y, p. NN — <heading>`. For the row above,
the closest preceding `##` is `## §2.2 — Structure and General
Syntax`. Citation:

```text
Cowlishaw §2.2, p. 19 — Literal strings
```

That's it. No PDF lookup required.

---

## Worked examples for the M2 audit topics

The eleven Stage I topics flagged in `docs/M2_FOLLOWUP.md` and
their post-index citations:

| Topic | Citation |
|---|---|
| Introduction (Part 1 SECTION 1) | `Cowlishaw §1.1, p. 1 — What Kind of a Language is REXX?` |
| Literal strings | `Cowlishaw §2.2, p. 19 — Literal strings` |
| Numbers | `Cowlishaw §2.3, p. 27 — Numbers` |
| Arithmetic operators | `Cowlishaw §2.3, p. 25 — Arithmetic` |
| Comparison operators | `Cowlishaw §2.3, p. 26 — Comparative` |
| Logical operators | `Cowlishaw §2.3, p. 27 — Logical (Boolean)` |
| Concatenation | `Cowlishaw §2.3, p. 25 — Concatenation` |
| Implied semicolons and continuation | `Cowlishaw §2.2, p. 23 — Implied semicolons and continuations` |
| Comments | `Cowlishaw §2.2, p. 18 — Comments` |
| Assignments | `Cowlishaw §2.5, p. 32 — Assignments and Variables` |
| The SAY instruction | `Cowlishaw §2.7, p. 70 — SAY` |

(Pages above are the audit table's "Reality" column. The
populated index will record exactly these — and where it
doesn't, the index is wrong, not the table.)

---

## What the index is NOT for

- **Not for hint-style guidance.** Use the index to anchor your
  citation; do not paste vocabulary lists or summaries into
  pilgrim-facing teaching prose. The pilgrim sees the koan,
  not the index.
- **Not for cross-referencing topics.** The index is a flat
  reference, not a topic graph. If two koans teach related
  concepts, that's the koan author's editorial work, not the
  index's.
- **Not editable in response to curriculum changes.** The
  index is anchored to the book, not to the koans (FR-016). If
  you're tempted to add a row "for completeness" because a koan
  needs a citation that doesn't fit any existing row, you've
  found a real Cowlishaw heading the index missed — fix that.
  Don't invent rows.

---

## What to do if you can't find a row

1. **Search by vocabulary first.** The term you want is more
   likely in a `Vocabulary:` line than in a heading.
2. **Check the parent §X.Y.** If you know the section but not
   the child heading, jump to the §X.Y row and scan the child
   headings under it.
3. **Check Appendix D (Glossary).** If you're working on a
   conceptual term, the Glossary may name the row.
4. **Suspect a missing row.** If none of the above produces a
   match, you've potentially found a row the index missed.
   Open an issue against `docs/cowlishaw_index.md` with the
   heading text from the PDF and its book page; this is the
   procedure for the rare post-commit defect (FR-016, spec
   edge case "Defect found after the index is committed").

Do not invent a citation. Do not cite by training-data memory.
The audit findings in `docs/M2_FOLLOWUP.md` exist because that
shortcut produced 9-of-11 wrong citations. The index is the
fix.

---

## For M2.2 (citation rewrite)

When M2.2 begins, the procedure is mechanical:

1. For each existing `Cowlishaw §N.N, p. NN` line in `koans/` and
   `solutions/`, identify the topic the teaching block above it
   covers.
2. Look up the matching row in the index.
3. Replace the citation with the index's `§X.Y, p. NN —
   <heading>`. Most distinct citations appear in both koan and
   solution; `Edit replace_all: true` handles the symmetry.
4. Run `bin/lint_citations` (must remain 6/6 green; the
   citation format is unchanged).
5. The runner stdout fixture (`tests/fixtures/runner_stdout.txt`)
   should not change — citations live in koan comments, never
   echoed.

For optional `lint_citations` extension that verifies citation
references match an existing index row, see PLAN.md §M2.2's
acceptance bullet 3.

## For M2.3 (vocabulary review)

When M2.3 begins, the procedure is editorial:

1. For each teaching block in `koans/` and `solutions/`, walk
   each technical term.
2. Cross-check against the relevant index row's `Vocabulary:`
   line.
3. If the koan uses a non-canonical form, substitute Cowlishaw's
   form. Distinguish koan-framework vocabulary (e.g.,
   "assertion") from REXX vocabulary (e.g., "comparison
   operator") explicitly in the prose.
4. Re-run `verify_solutions` and `lint_citations`.
5. Re-walk the runner output to confirm pilgrim-facing pedagogy
   reads cleanly.
