# Phase 0: Research — M2.1 Cowlishaw Ground-Truth Index

**Date**: 2026-05-08
**Status**: Complete
**Method**: Empirical inspection of the source PDF
(`reference/REXX Language - 2nd Edition.pdf`) using
`pdftotext -layout` and direct grep/awk surveys; cross-reference
with `PLAN.md` §M2.1 and `docs/M2_FOLLOWUP.md` Task 1.

This document records the decisions reached for every open
question that the spec deferred to plan-time, plus an empirical
correction to the spec's heading hierarchy that the
plan integrates back into the spec as a plan-time clarification.

---

## 1. Empirical PDF heading structure

**Question**: How does Cowlishaw's typography organize the book?
The spec assumed a two-tier numbered hierarchy ("top-level
numbered section" + "numbered §X.Y subsection") in FR-003 and
FR-004; is that accurate?

**Decision**: The book has exactly one tier of Cowlishaw-numbered
structure: each Part contains a flat list of `SECTION N: TITLE`
entries. The audit's `§X.Y` notation encodes (Part, SECTION):

- `§1.1` = Part 1, SECTION 1 (`WHAT KIND OF A LANGUAGE IS REXX?`)
- `§1.2` = Part 1, SECTION 2 (`SUMMARY OF THE REXX LANGUAGE`)
- `§2.1` = Part 2, SECTION 1 (`CHARACTERS AND ENCODINGS`)
- `§2.2` = Part 2, SECTION 2 (`STRUCTURE AND GENERAL SYNTAX`)
- … and so on.

Empirical counts from `pdftotext -layout`:

- **Part 1**: 5 numbered SECTIONs (§1.1–§1.5).
  Titles: WHAT KIND OF A LANGUAGE IS REXX?, SUMMARY OF THE REXX
  LANGUAGE, FUNDAMENTAL LANGUAGE CONCEPTS, DESIGN PRINCIPLES,
  HISTORY.
- **Part 2**: 17 numbered SECTIONs (§2.1–§2.17).
  Titles: CHARACTERS AND ENCODINGS, STRUCTURE AND GENERAL SYNTAX,
  EXPRESSIONS AND OPERATORS, CLAUSES AND INSTRUCTIONS,
  ASSIGNMENTS AND VARIABLES, COMMANDS TO EXTERNAL ENVIRONMENTS,
  KEYWORD INSTRUCTIONS, FUNCTION CALLS, BUILT-IN FUNCTIONS,
  PARSING FOR ARG/PARSE/AND PULL, NUMBERS AND ARITHMETIC, INPUT
  AND OUTPUT STREAMS, CONDITIONS AND CONDITION TRAPS, INTERACTIVE
  TRACING, RESERVED KEYWORDS AND LANGUAGE EXTENDIBILITY, SPECIAL
  VARIABLES, ERROR NUMBERS AND MESSAGES.
- **Appendices**: A (REXX Syntax Diagrams), B (A Sample REXX
  Program), C (Language Changes since First Edition), D (Glossary).

**Spec amendment** (recorded in spec's `## Clarifications`
section as a plan-time clarification): FR-003 and FR-004 are
merged; both refer to the same §X.Y level. The spec's example
"SECTION 1: INTRODUCTION" is replaced with empirical examples.

**Rationale**: The spec was authored before PDF inspection. The
correction reflects the book's actual structure and removes a
phantom tier that would have produced empty rows in the index.
M2.2 cites `§X.Y, p. NN — <subject>`; a single tier matches
that citation format.

**Alternatives considered**:
- *Keep both FR-003 and FR-004 separate, treat FR-004 as
  vacuously satisfied.* Rejected — leaves a misleading
  requirement live in the spec; future contributors might believe
  there is a missing tier of rows to populate.
- *Re-tier as Part / SECTION / child heading with three numbered
  levels.* Rejected — the book's typography does not present
  Parts as numbered tiers; numbering is part-scoped.

---

## 2. In-section heading nesting

**Question**: Cowlishaw's named in-section child headings — like
"Tokens", "Literal strings", "Comments" inside §2.2 — sometimes
nest (e.g., §2 → "Tokens" → "Literal strings"). Should the index
preserve nesting in its heading hierarchy, or flatten?

**Decision**: **Flatten.** Every named typographically distinct
heading inside a §X.Y row gets its own row at the same heading
level (`###` per the chosen rendering — see §5 below), regardless
of typographic nesting depth in the source. The contributor reads
the parent §X.Y from context; the row's identifier is the parent
§X.Y plus the heading title.

**Rationale**:
- The audit's existing citation format already flattens:
  `Cowlishaw §2.2, p. 18 — Literal strings` cites the parent
  §2.2, not §2.2 → Tokens → Literal strings.
- Multi-tier rendering would require a synthetic numbering scheme
  that Cowlishaw does not use and that M2.2's mechanical lookup
  doesn't need.
- For the only non-trivial nesting case observed empirically
  (§2.2 → Tokens → Literal strings / Hexadecimal Strings / Binary
  Strings / Symbols), flattening produces five sibling rows
  ("Tokens", "Literal strings", "Hexadecimal Strings", "Binary
  Strings", "Symbols") under §2.2 — none of which loses
  information.

**Alternatives considered**:
- *Preserve typographic nesting via deeper Markdown headings
  (`####` for "Literal strings" under `###` for "Tokens" under
  `##` for §2.2).* Rejected — adds presentation tiers without
  citation-side payoff; complicates `replace_all` lookups in M2.2.
- *Drop the intermediate "Tokens"-style group headings entirely
  and only record leaf child headings.* Rejected — "Tokens" is
  itself a Cowlishaw heading and a contributor might want to
  cite it (e.g., for a koan about clause structure); it deserves
  its own row.

---

## 3. Extraction tooling — language choice

**Question**: The skeleton-extraction step uses `pdftotext -layout`
plus a small parser to identify SECTION headings and child
headings. Constitution Principle II says utility scripts in `bin/`
MUST be REXX; does that constrain this script?

**Decision**: **Contributor-discretion. Recommended:** Bash +
`grep -nE` + `awk`, since the work is primarily line-pattern
filtering. The extractor is a one-shot tool that lives in
gitignored `reference/` and never enters the repository.
Principle II does not apply.

**Rationale**:
- Principle II governs `bin/` scripts and curriculum-touching
  tooling. The extractor is contributor-side ephemeral work;
  Cowlishaw's heading typography is a one-time problem solved by
  one person, then thrown away.
- REXX would work, but `pdftotext` output is line-oriented text
  that grep/awk handle in a few lines. Forcing REXX would inflate
  the script for no reuse benefit.
- Spec FR-011 forbids committing the raw `pdftotext` output. By
  symmetry, committing the extractor — which embeds knowledge of
  the layout-dump format — adds no value and gently encourages
  someone to re-run it later (which the spec Out-of-Scope
  explicitly prohibits).

**Alternatives considered**:
- *REXX extractor in `bin/build_cowlishaw_index`*. Rejected per
  above; also conflicts with spec Out of Scope (no
  re-derivation tooling in the repo).
- *Python with `pypdf` instead of `pdftotext`*. Rejected —
  `pdftotext -layout` is already the agreed mechanism per
  PLAN.md §M2.1 and `docs/M2_FOLLOWUP.md`; switching adds an
  un-validated dependency.

---

## 4. Vocabulary inclusion threshold

**Question**: FR-007 requires that vocabulary terms "appear
verbatim in Cowlishaw's text within or near the cited section."
What counts as "near"? What kind of term qualifies?

**Decision**: A term qualifies for a row's vocabulary list if it
appears in the cited section or its immediately surrounding pages
AND meets at least one of:

1. **Typographically marked.** Cowlishaw italicizes or
   bold-stylizes terms-being-defined consistently (e.g., *symbol*,
   *literal string*, *compound symbol*). Marked terms are the
   primary vocabulary candidates.
2. **Subsection title.** The title of any in-section child heading
   (e.g., "Comparative", "Logical (Boolean)", "Implied semicolons
   and continuations") is canonical vocabulary for the parent
   §X.Y row.
3. **Glossary entry.** If a term appears in Appendix D (Glossary)
   AND is used in the cited section, it qualifies. The Glossary is
   Cowlishaw's authoritative term list.

Generic English words (e.g., "value", "result", "argument" in
their everyday sense) are excluded unless typographically marked
or glossary-listed.

**Rationale**:
- This threshold is what the M2.3 review needs: a list of terms
  whose canonical form is unambiguous, against which koan prose
  can be checked.
- Typographic marking and glossary inclusion are both objective
  criteria — a UAT reviewer can verify them without judgment
  calls.
- Excludes the failure mode of including everyday English nouns
  that Cowlishaw happens to use in the section but doesn't define.

**Alternatives considered**:
- *Include every distinct content word in the section.* Rejected
  — produces noise; M2.3's vocabulary check would drown in
  false-positive flags.
- *Include only glossary entries.* Rejected — misses
  typographically-defined terms that aren't separately
  glossary-listed (e.g., several keyword-instruction-specific
  terms).

---

## 5. Heading hierarchy in `docs/cowlishaw_index.md`

**Question**: The spec's FR-012a fixed `##` for top-level
numbered section, `###` for numbered §X.Y subsection, `####` for
named child heading. With Phase 0's finding that the book has
only one numbered tier, FR-012a's `###` level becomes vacant.
What should the file's heading hierarchy actually be?

**Decision**: Refined hierarchy:

- `# Cowlishaw Ground-Truth Index` — file title (one occurrence).
- `# Part 1 — Background` / `# Part 2 — REXX Language Definition`
  / `# Appendices` — three navigation wrappers, present for
  GitHub TOC and contributor scanning. **These are not rows.**
- `## §X.Y — Title in Headline Case` — one row per Cowlishaw
  `SECTION N: TITLE`, with the §X.Y identifier rendered prominently
  in the heading for citation traceability and the title rendered
  in headline case per FR-008 (e.g., `## §2.2 — Structure and
  General Syntax`). Spans Part 1 and Part 2.
- `## Appendix N: Title in Headline Case` — one row per appendix
  top-level entry (e.g., `## Appendix A: REXX Syntax Diagrams`).
- `### Cowlishaw's Verbatim Heading` — one row per named
  typographically distinct child heading inside a §X.Y or appendix
  (e.g., `### Literal strings`, `### Logical (Boolean)`); casing
  preserved verbatim per FR-008.

Each `##` and `###` heading is followed by exactly the three
sub-bullets specified in FR-012b: `Page`, `Summary`, `Vocabulary`.

**Spec amendment** (recorded in spec's `## Clarifications`):
FR-012a's heading hierarchy is updated to match the empirical
structure. The original `####` tier is reassigned (now `###`)
to keep child headings at one level below their parent SECTION
row.

**Rationale**:
- `#`-level Part wrappers give GitHub a clean three-bucket TOC
  ("Part 1", "Part 2", "Appendices") without inflating the row
  count.
- `##` for `§X.Y` rows preserves the spec's intent (top-level row
  at `##`) and rendering the §X.Y identifier in the heading text
  makes citation key visible at the row's anchor.
- `###` for child headings sits one level below their parent —
  the right typographic relationship for a reader scanning the
  document, and the right depth for GitHub anchor links.
- Two row tiers (`##` and `###`) instead of three (the spec's
  vacated `####` tier) simplifies M2.2's mechanical lookup
  surface and matches the book's actual structural depth.

**Alternatives considered**:
- *Keep three row tiers for forward-compatibility (`##` SECTION,
  `###` reserved-for-future, `####` child heading).* Rejected —
  introduces an unused tier the spec already cautioned against
  ("don't promote sub-subsection or list-item heading to
  subsection rank"); easier to amend the index format later if
  a future Cowlishaw revision actually adds a tier.
- *Two tiers without Part wrappers (everything at `##` and
  `###`).* Rejected — loses Part-level navigation, which matters
  because Part 1 §1 and Part 2 §1 share the SECTION number.

---

## 6. Extraction script reproducibility

**Question**: The spec Out-of-Scope says "Building any tool,
watcher, or CI check that re-derives the index from the PDF" is
forbidden. Does that include the one-shot extraction script
itself? Should the script be committed for reproducibility, kept
in gitignored `reference/`, or deleted after use?

**Decision**: Keep the extraction script in gitignored
`reference/` for the duration of the build; not committed.
After M2.1 ships, the script may be deleted or retained at the
contributor's discretion.

**Rationale**:
- Spec Out-of-Scope rules out re-derivation tooling that lives
  in the repo. A committed extraction script signals
  "re-runnable" and creates pressure to re-run it whenever the
  PDF or extraction logic changes — exactly the redistribution
  risk the spec gates against.
- Gitignored reference/ is the existing pattern for
  contributor-side working materials (PLAN.md §3, §8). The
  extraction script naturally belongs there.
- The script is short enough (a few dozen lines of Bash + grep +
  awk) that any future contributor can reconstruct it from this
  research doc plus PLAN.md §M2.1.

**Alternatives considered**:
- *Commit the script as `scripts/build_cowlishaw_index.sh`*.
  Rejected per spec Out of Scope.
- *Embed the script verbatim in this research doc.* Rejected —
  encourages copy-paste re-runs; the doc's value is the *findings*
  not the source.

---

## 7. UAT defect resolution workflow

**Question**: SC-009 requires that the UAT review pass identify
and resolve every defect found before the index is committed. How
does that work mechanically?

**Decision**: Standard inline correction:

1. The contributor produces a populated `docs/cowlishaw_index.md`
   draft on the working branch. Branch is **not** merged.
2. Project owner reads the draft against the PDF, optionally
   side-by-side. As defects are spotted (wrong page, wrong
   vocabulary term, paraphrase summary that misses the row's
   actual content), the owner notes them.
3. Defects are fixed in the same draft commit (or a follow-up
   commit on the same branch) before the branch is merged. The
   index is never committed to `main` in a known-incorrect state.
4. Once the owner signals UAT-passed, the branch may be merged.
   The merge commit is the first commit of the index on `main`.

**Rationale**:
- Branches make this trivial: the index can be revised
  iteratively without polluting `main`'s history.
- "Fix before commit" is the constitutional acceptance posture
  for all curriculum work and naturally extends here.
- A separate "errata" log post-merge would create the wrong
  authority hierarchy: the committed index would be normative
  AND wrong simultaneously.

**Alternatives considered**:
- *Merge the populated draft and follow up with a corrections
  PR.* Rejected — even a brief window of `main` containing a
  known-wrong index undermines its authority for the M2.2 work
  that immediately follows.

---

## Summary of decisions

| # | Topic | Decision |
|---|---|---|
| 1 | PDF heading structure | Single §X.Y tier; FR-003 + FR-004 merge into one. |
| 2 | In-section nesting | Flatten all named child headings to one row tier. |
| 3 | Extraction tooling | Bash + grep/awk; contributor-side; not committed. |
| 4 | Vocabulary threshold | Typographically marked terms + child-heading titles + glossary entries. |
| 5 | File heading hierarchy | `#` Part wrappers, `##` §X.Y + Appendix top, `###` child heading. |
| 6 | Script reproducibility | Gitignored `reference/`; not committed. |
| 7 | UAT defect resolution | Inline corrections on the working branch before merge. |

All NEEDS CLARIFICATION resolved. Ready for Phase 1.
