# Data Model — M2.3

This document formalizes the entities operated on by M2.3 and the
join relationships between them. The model is content-only — there
is no database, no on-disk format, and no runtime data flow. The
"entities" are sections of files (teaching comment blocks, terms
within them) and the index rows they reference.

## Entities

### `Teaching comment block`

A contiguous `/* ... */` REXX comment block in a koan or solution
file that introduces the next test (or, for the file-header
variant, introduces the file as a whole). Each block contains a
heading line, a short prose body (typically 2–6 sentences), and
a trailing `Cowlishaw §N.N, p. NN[ — <heading>]` citation line.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `file` | path | One of `koans/00–05_about_*.rexx` or `solutions/00–05_about_*.rexx`. |
| `block_kind` | enum {`file_header`, `concept`} | `file_header` for the leading comment block of the file; `concept` for the per-test concept blocks. |
| `block_id` | string | For `concept` blocks, the `Concept: <heading>` text; for `file_header`, the literal token `file_header`. |
| `start_line` | int | 1-indexed line of the opening `/*`. |
| `end_line` | int | 1-indexed line of the closing `*/`. |
| `body_text` | string | The prose body between the heading and the trailing citation. The substitution target. |
| `trailing_citation` | string | The `Cowlishaw §N.N, p. NN[ — <heading>]` line. **Read-only** for this feature (FR-006). |
| `in_prose_citations` | list of string | Any additional `(Cowlishaw §X.Y, p. NN)` parenthetical references inside `body_text`. Pre-feature: zero on every block. Post-feature: non-zero on the four koan-00 layered blocks and on the koan-01 / solution-01 numbers block (per `research.md` §3 and §4). |

**Cardinality**: ~24 across Stage I (6 file headers + 18 concept
blocks).

**Constraints**:

- `trailing_citation` is **frozen** by FR-006. M2.3 does not
  modify it.
- `body_text` is the substitution target; modifications are
  governed by `Technical term` substitution (below) plus the
  layering rewrites in `research.md` §3 / §4.
- The runner-stdout-fixture invariance (FR-008) is enforced by
  the structural fact that `body_text` lives inside `/* ... */`
  and is never echoed to stdout.

**Invariants enforced by this feature**:

- Every `Technical term` instance in `body_text` is either a
  Cowlishaw vocabulary term (per `Index vocabulary entry`) or is
  framed as `Framework verb` / framework vocabulary (per FR-002 /
  FR-002a). Pre-feature: ~22 terms violate this; post-feature: 0.

### `Technical term`

A noun (or noun phrase) inside a `Teaching comment block.body_text`
that *names* a REXX construct (operator family, syntactic
category, value domain, built-in function, etc.) in a
subject/object identifier role. The lookup unit for the §1
discipline in `research.md`.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `verbatim` | string | The exact text of the term as it appears in the block (e.g., `Quoted strings`, `the truth values of REXX`, `whole number`). |
| `block` | reference to `Teaching comment block` | Where the term lives. |
| `is_construct_naming` | bool | True iff the term plays a construct-naming role (per `research.md` §1 discipline). General English description has `is_construct_naming = false`. |
| `is_framework` | bool | True iff the term names a koan-framework construct (`eq`, `neq`, `true`, `datatype`, "assertion", `FILL_ME_IN`). Mutually exclusive with REXX construct naming. |
| `canonical_replacement` | string \| null | The Cowlishaw canonical term (per `Index vocabulary entry`) when `is_construct_naming` is true and `verbatim` is non-canonical; null when `verbatim` is already canonical or `is_framework` is true. |

**Constraints**:

- A term with `is_construct_naming = true` AND `is_framework = false`
  AND `canonical_replacement \= null` is in scope for substitution
  (FR-001).
- A term with `is_framework = true` is preserved (FR-002 carve-out)
  but, where it appears alongside a REXX claim (FR-002a conflation
  point), the surrounding sentence is re-labeled per `research.md`
  §4.

### `Index vocabulary entry`

An item in a `Vocabulary:` bullet on a row of
`docs/cowlishaw_index.md`. The lookup target for every
construct-naming `Technical term`.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `term` | string | The canonical Cowlishaw vocabulary term (e.g., `literal string`, `comparative operator`, `Logical (Boolean)`, `blank operator`, `null string`). |
| `index_row` | reference | The `docs/cowlishaw_index.md` row whose `Vocabulary:` bullet carries this term. |
| `parent_section` | string | The §X.Y identifier of the row. |
| `book_page` | int | The book page where the row's content begins. |

**Constraints**:

- `Index vocabulary entry` is **read-only** for this feature
  (FR-007). No row, term, or page is added, modified, or removed.

**Cardinality**: hundreds across the full index. Only ~25 entries
are actively used as substitution targets by this feature (per
`research.md` §2 + §3 + §4).

### `UAT-flagged candidate`

One of the five terminology gaps recorded in PLAN.md §M2.3:

| # | Source | Canonical replacement | Index row |
|---|---|---|---|
| 1 | "string literal" | "literal string" | §2.2 — Literal strings |
| 2 | "identifier" / "variable name" | "symbol" / "variable" (Cowlishaw distinction) | §2.5 |
| 3 | "Comparisons" | "Comparative" | §2.3 — Comparative |
| 4 | "boolean" / "boolean values" | "Logical (Boolean)" | §2.3 — Logical (Boolean) |
| 5 | The blanket "assertion" framing in koan 00 | Framework-vs-REXX layering per FR-002 | §2.3 + §2.5 + §2.9 (per concept block) |

**Constraint**: All five MUST be resolved by this feature
(FR-003, SC-003). Items 1–4 are addressed by entries in the
`research.md` §2 substitution table; item 5 is addressed by the
koan-00 layering in `research.md` §3.

### `Framework verb`

One of the four assertion entry points (`eq`, `neq`, `true`,
`datatype`) defined by `lib/meditation.rexx`, plus the umbrella
term "assertion" and the `FILL_ME_IN` mechanism. Framework
vocabulary; not subject to substitution per FR-001.

**Constraints**:

- A `Framework verb` mention in `body_text` is preserved verbatim.
- Where a `Framework verb` appears in the same sentence as a REXX
  construct claim (per `research.md` §4 conflation walk), the
  sentence is re-labeled to name the two layers separately
  (FR-002a). The framework verb itself is not changed.

## Joins and lookups

### Technical term → Index vocabulary entry

Given a `Technical term` with `verbatim` text and the surrounding
`Teaching comment block`, the matching `Index vocabulary entry`
is found by:

1. Identify the relevant index row — the row whose §N.N + book
   page matches the block's `trailing_citation`, OR the row whose
   subject matches the block's concept heading when the trailing
   citation anchors a broader context (e.g., koan 00 type block's
   `Cowlishaw §2.5, p. 32` is a §2.5 anchor; the relevant row for
   DATATYPE vocabulary is §2.9 DATATYPE, surfaced via the concept
   heading "type").
2. Walk that row's `Vocabulary:` column. If `verbatim` matches an
   entry literally, the term is canonical (no substitution).
3. If `verbatim` does not match but a different entry in the
   `Vocabulary:` column names the same construct, that entry is
   the `canonical_replacement` for the substitution.
4. If no entry in any plausibly-relevant row's `Vocabulary:`
   column names the construct, the term is potentially an index
   defect (FR-007 escape hatch). `research.md` §6 confirms: no
   such case surfaced for this feature.

### UAT-flagged candidate → Substitution table row(s)

| UAT # | Closed by `research.md` §2 row(s) / §3 layering |
|---|---|
| 1 ("string literal") | Row 4 ("Quoted strings" → "Literal strings"). The literal phrase "string literal" does not appear in the current corpus; the equivalent non-Cowlishaw phrasing that does appear is "Quoted strings", which is corrected. |
| 2 ("identifier" / "variable name") | Rows 2, 3 ("uninitialized symbols" → "uninitialized variables"; "the unbound symbol NEVER_SET" → "the uninitialized variable NEVER_SET"). The literal terms "identifier" and "variable name" do not appear in the current corpus; the equivalent non-canonical phrasings ("uninitialized symbol", "unbound symbol") are corrected. |
| 3 ("Comparisons") | Rows 5, 6 ("comparison" → "comparative" in koan 03 file header and concept heading). |
| 4 ("boolean" / "boolean values") | Row 10 ("truth values of REXX" → "Logical (Boolean) values"); §3.2 truth block layered prose ("REXX boolean 1" → "Logical (Boolean) value '1'"); §3.0 / §3.1 reword "comparisons" as "comparative" in koan-00 prose. |
| 5 ("assertion" framing in koan 00) | §3 — the four koan-00 concept blocks are restructured per FR-002 to layer framework verbs above REXX mechanisms, with each REXX mechanism named using Cowlishaw vocabulary and cited to its index row. |

All five UAT candidates resolve. SC-003 is satisfied by the
combination of §2 substitutions, §3 layered prose, and §4 targeted
re-labels.

## State transitions

There is one state transition for the feature as a whole:

- **Before M2.3**: ~22 non-canonical `Technical term` instances
  in Stage I `Teaching comment block.body_text`; koan 00's four
  concept blocks present framework verbs without explicit REXX
  layering; one koan-01 conflation point.
- **After M2.3**: 0 non-canonical `Technical term` instances; koan
  00's four concept blocks present the framework-vs-REXX layering
  per FR-002; the koan-01 conflation point is re-labeled per
  FR-002a; per-substitution parity holds across every (koan,
  solution) pair.

There are no per-term incremental states — substitutions are
applied as discrete `Edit replace_all` operations per file. The
6/6 CI matrix (Constitution Principle IV; spec FR-009) is the
acceptance gate.
