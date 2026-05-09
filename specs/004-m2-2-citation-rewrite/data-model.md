# Data Model — M2.2

This document formalizes the entities operated on by M2.2 and the
join relationships between them. The model is content-only — there
is no database, no on-disk format, and no runtime data flow. The
"entities" are sections of files governed by lint rules.

## Entities

### `Citation line`

A single line in a `koans/*.rexx` or `solutions/*.rexx` file that
carries a Cowlishaw citation. Always inside a leading or
mid-comment block (` * ` or `/* ... */` style).

**Fields**:

| Field | Type | Description |
|---|---|---|
| `file` | path | One of `koans/00–05_about_*.rexx` or `solutions/00–05_about_*.rexx`. |
| `line_number` | int | 1-indexed line within `file`. |
| `text` | string | The full line, including leading comment prefix. |
| `citation_string` | string | The substring matching `Cowlishaw §<sec>, p. <page>[<suffix>]`. |
| `section` | string | The §X.Y identifier (digits and dots). |
| `page` | int | The book page (positive integer). |
| `suffix_present` | bool | True iff the citation_string carries the disambiguator suffix. |
| `suffix_heading` | string \| null | The verbatim child-heading text when `suffix_present` is true; null otherwise. |
| `comment_close` | bool | True iff the line ends with ` */` (one-line comment). |

**Constraints**:

- `citation_string` MUST conform to the canonical form per
  `contracts/lint_citations.md` Rule C1.
- `suffix_present` is true iff the (`section`, `page`) pair does not
  uniquely identify a row in `docs/cowlishaw_index.md`
  (FR-005, bare-preferred policy).
- When `suffix_present` is true, `suffix_heading` MUST match the
  index row's verbatim `###` heading text (FR-006).

**Invariants enforced by this feature**:

- For every `(koans/NN_about_x.rexx, solutions/NN_about_x.rexx)`
  pair, the sequence of `Citation line` records (ordered by line
  number) is byte-identical between koan and solution (FR-003).

### `Distinct citation string`

The unique value of `Citation line.citation_string` aggregated over
all `Citation line` records. The unit on which `Edit replace_all`
operations are performed.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `old_value` | string | The pre-rewrite citation_string. |
| `new_value` | string | The post-rewrite citation_string. |
| `affected_files` | list of paths | Files in which `old_value` appears. |
| `audit_rows_closed` | list of int | The `docs/M2_FOLLOWUP.md` audit-table row numbers this rewrite closes. |

**Cardinality**: 14 records pre-rewrite (see `research.md` §1
rewrite table). Some `new_value`s coincide (e.g., bare
`Cowlishaw §2.5, p. 32` is the post-rewrite value of two distinct
`old_value`s); the `Distinct citation string` aggregation is on
`old_value`.

### `Audit row`

One row of the "Audit findings (2026-05-08)" table in
`docs/M2_FOLLOWUP.md`. The canonical defect record that motivates
this feature.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `row_number` | int | 1–11. |
| `original_citation` | string | As authored in M2 (audit "Original" column). |
| `audit_reality` | string | The audit's "Reality" prose. |
| `audit_verdict` | enum {`correct`, `page wrong`, `section + page wrong`, `page wrong by 1`} | Audit "Verdict" column. |
| `closed_by` | list of `Distinct citation string` | The rewrite operation(s) that close this row. |

**Cardinality**: 11. Two rows (1, 6) have `audit_verdict = correct`;
the other 9 are wrong. All 11 are closed by this feature (SC-004).

### `Index row`

One row in `docs/cowlishaw_index.md`. The lookup target for every
citation.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `heading_level` | enum {`##`, `###`} | `##` = SECTION row or Appendix top; `###` = named child heading. |
| `heading_text` | string | Verbatim from the index. For `##` SECTION rows, format is `§X.Y — <Title>`; for `###` rows, format is the child heading verbatim. |
| `parent_section` | string | The §X.Y identifier this row belongs to (equal to `heading_text` minus prefix when level is `##`). |
| `book_page` | int | From the `**Page:**` bullet. |
| `summary` | string | From the `**Summary:**` bullet. |
| `vocabulary` | list of string | From the `**Vocabulary:**` bullet. |

**Constraints**:

- `Index row` is **read-only** for this feature (FR-009). No row is
  added, modified, or removed by M2.2.
- For citation lookup, the join key is (`parent_section`,
  `book_page`); when this pair is unique across the index, the bare
  citation form suffices, otherwise the suffix `— <heading_text>`
  (or `— <child heading>` extracted from `heading_text` when level
  is `###`) is required.

### `Lint script`

`bin/lint_citations`. Modified by FR-008 to enforce the canonical
citation form.

**Modified procedure**: `check_citation`. The pre-rewrite version
is permissive (validates only the prefix `Cowlishaw §<sec>, p. <page>`); the post-rewrite version inspects the tail and accepts only
the bare or suffixed canonical forms. See
`contracts/lint_citations.md` Rule C1 for the post-rewrite
specification, and `research.md` §2 for the design.

### `Lint contract`

The documented behavior of `bin/lint_citations`.

**Files**:

- `specs/002-m2-walking-skeleton/contracts/lint_citations.md` —
  M2-era contract. Retained as historical record. Not modified by
  M2.2.
- `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md` —
  this feature's contract. Supersedes the M2-era contract for the
  citation-format check. The `Station:` directive check and the
  exit-code/output-format rules are unchanged.

## Joins and lookups

### Citation → Index

Given a `Citation line` with (`section`, `page`, optional
`suffix_heading`), the matching `Index row` is found by:

1. If `suffix_present` is false: find the unique `Index row` where
   `parent_section = section` AND `book_page = page`. (Uniqueness is
   guaranteed by the bare-preferred policy.)
2. If `suffix_present` is true: find the unique `Index row` where
   `parent_section = section` AND `book_page = page` AND
   the `###` child-heading text equals `suffix_heading` verbatim.

A citation that does not produce a unique match is malformed under
FR-001/FR-005. M2.2 ensures every citation in the rewritten corpus
produces a unique match by construction (`research.md` §1 rewrite
table).

### Audit row → Distinct citation string(s)

Each audit row is closed by one or two distinct citation rewrites.
Two-rewrite cases (rows 4 and 8) occur where the original audit
combines a SECTION-level and a child-level concept that are cited
separately in the koan corpus.

| Audit row | Closed by Distinct citation string(s) | Notes |
|---|---|---|
| 1 (✓) | #1 | Bare normalization. |
| 2 | #4 | `Literal strings` was misfiled to §2.1 in the corpus. |
| 3 | #5 | `Numbers` was misfiled to §2.2 in the corpus. |
| 4 | #7, #8 | One general "Operators" citation + one specific "Arithmetic" citation. |
| 5 | #3 | `Comparative` is at p. 26, not p. 25. |
| 6 (✓) | #9 | Vocab fix: `Logical operators` → `Logical (Boolean)`. |
| 7 | #10 | `Concatenation` is at p. 25, not p. 30. |
| 8 | #11, #12 | One "Clauses" → §2.4 SECTION; one "Continuation" → §2.2 child. |
| 9 | #13 | `Comments` is in §2.2, not §2.4. |
| 10 | #2, #6 | `Assignments and equality` (koan 00) + `Assignments` (koan 02) collapse to the same bare §2.5 citation. |
| 11 | #14 | `SAY` is at p. 70, not p. 56. |

The "Distinct citation string" numbers (#1–#14) match the rewrite
table in `research.md` §1.

## State transitions

There is one state transition for the feature as a whole:

- **Before M2.2**: 14 distinct citation strings; 9/11 audit rows
  open; lint regex permissive after page digits.
- **After M2.2**: ≤ 14 distinct citation strings (some old strings
  collapse to a shared new string, per the rewrite table); 11/11
  audit rows closed; lint regex enforces canonical form.

There are no per-citation incremental states — the rewrite is
applied as a single atomic content change per (koan, solution) pair.
The 6/6 CI matrix is the acceptance gate (Constitution Principle IV;
spec FR-011).
