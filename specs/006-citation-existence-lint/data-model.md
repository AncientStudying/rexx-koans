# Data Model — M2.4

This document formalizes the entities operated on by M2.4 and
the join relationships between them. The model is content-only
— there is no persistent storage and no runtime data flow
beyond a single `bin/lint_citations` invocation. The "entities"
are parser intermediates and lookup keys held in stem variables
during one script run.

## Entities

### `Index row`

A `## §X.Y — <title>` parent heading or a `### <child heading>`
child heading in `docs/cowlishaw_index.md`. Each row is followed
by exactly three Markdown bullets — `**Page:** N`, `**Summary:**
<prose>`, `**Vocabulary:** <terms>` — in that order.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `kind` | enum {`parent`, `child`} | `parent` for `## §X.Y` rows; `child` for `### <heading>` rows. |
| `section` | string | The §X.Y identifier of the row (or, for `child` rows, the most-recently-seen parent's §X.Y). Examples: `1.1`, `2.2`, `2.3`, `2.5`. |
| `heading` | string | For `parent` rows: empty (the row's title is descriptive but not used as a citation suffix). For `child` rows: the verbatim child-heading text (e.g., `Literal strings`, `Logical (Boolean)`, `Implied semicolons and continuations`). |
| `page` | int | The book-page number from the row's `**Page:**` bullet. |
| `source_line_no` | int | 1-indexed line number in `docs/cowlishaw_index.md` where the row's heading appears. Used only for bootstrap-error messages, not for the lookup table itself. |

**Cardinality**: ~80 across the current
`docs/cowlishaw_index.md` (per `research.md` §1).

**Constraints**:

- `kind = child` implies a non-empty `heading` and a non-empty
  `section` inherited from the most-recent `parent`.
- `kind = parent` implies an empty `heading`.
- `page` MUST be present and a positive integer; otherwise the
  parser triggers a bootstrap error (FR-010).
- Read-only for this feature (FR-013, SC-007). M2.4 consults
  the index, never modifies it.

### `Lookup table`

The in-memory data structure `bin/lint_citations` builds at
startup by walking `docs/cowlishaw_index.md`. Maps `(section,
page)` keys to lists of `### <heading>` texts.

**Schema** (REXX stem-variable representation):

```
table.<section>.<page>.0     = N (count of headings at this key)
table.<section>.<page>.1     = "first heading" (or empty for parent-only)
table.<section>.<page>.2     = "second heading" (if N >= 2)
...
table.<section>.<page>.has_parent = 1 if a `## §<section>` row has page <page>
                                    else 0
```

**Build rule** (per `research.md` §1):

- A `## §X.Y` row with `**Page:** N`: set
  `table.X.Y.N.has_parent = 1`. If `table.X.Y.N.0` is undefined,
  set it to 0 (no children yet).
- A `### <heading>` row with `**Page:** N` (under the
  most-recent `## §X.Y`): increment `table.X.Y.N.0`; set
  `table.X.Y.N.<count>` to `<heading>`. If
  `table.X.Y.N.has_parent` is undefined, set it to 0.

**Lookup**:

- A bare-form citation `Cowlishaw §X.Y, p. N` resolves iff
  `table.X.Y.N.has_parent = 1` OR `table.X.Y.N.0 > 0`.
- A suffixed-form citation
  `Cowlishaw §X.Y, p. N — <suffix>` resolves iff
  `table.X.Y.N.0 >= 1` AND `<suffix>` matches `table.X.Y.N.k`
  verbatim for some `1 <= k <= table.X.Y.N.0`.

**Cardinality**: ~80 entries (one per index row).

**Constraints**:

- Read-only after the parse phase. The table is built once per
  invocation; no mutation occurs during the per-file existence
  check.

### `Citation`

A substring matching M2.4's broad citation-detection pattern
(per `research.md` §2) found in any reassembled paragraph of
any `koans/*.rexx` or `solutions/*.rexx` file.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `verbatim_text` | string | The exact substring as it appeared in the source paragraph (e.g., `Cowlishaw §2.3, p. 27 — Logical (Boolean)`). |
| `section` | string | Parsed §X.Y identifier (e.g., `2.3`). |
| `page` | int | Parsed page number (e.g., `27`). |
| `suffix` | string \| null | Parsed `<heading>` text after ` — `, or null if no suffix. Whitespace-stripped. |
| `file` | path | The koan or solution file the citation lives in. |
| `line_no` | int | 1-indexed line number in `file` where the `Cowlishaw §` marker began. (For citations whose suffix wraps across a `\n * ` continuation, this is the line of the marker, not the line where the suffix terminates.) |
| `paragraph_offset` | int | Position within the reassembled paragraph (used internally for source-order reporting per FR-016). |

**Cardinality**: ~50 across the post-M2.3 corpus (12 files;
both trailing canonical and in-prose parenthetical citations).

**Constraints**:

- `section` MUST satisfy `is_section` (M2.2 Rule C1's predicate:
  digits + optional `.digits`; no `..`; no leading/trailing
  dot).
- `page` MUST be a positive integer.
- `suffix` (if non-null) MUST be non-empty after whitespace
  stripping. The em-dash separator preceding it MUST be the
  canonical 3-byte UTF-8 em-dash (per the M2.2 contract carried
  forward).

**Invariants enforced by this feature**:

- Every `Citation` in the corpus MUST resolve against the
  `Lookup table` per the lookup rules above. The post-M2.3
  corpus satisfies this on first run (US2). A citation that
  doesn't resolve produces a `Failure mode` (below) and the
  containing file is reported `[FAIL]`.

### `Reassembled paragraph`

A contiguous run of `*` comment-prose lines within a single
`/* ... */` block in a koan or solution file, joined by single
spaces with the leading ` * ` decoration stripped. Per
`research.md` §3.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `file` | path | The containing file. |
| `start_line` | int | 1-indexed line number of the first prose line of the paragraph. |
| `end_line` | int | 1-indexed line number of the last prose line of the paragraph (just before a blank ` *` separator, ` */` close, or non-comment line). |
| `text` | string | The reassembled prose text (decoration stripped, lines joined by single spaces). |

**Cardinality**: ~24 across Stage I (matches M2.3's "~24
teaching comment blocks" estimate; same blocks but split into
sub-paragraphs by blank `* ` separators).

**Constraints**:

- A paragraph never crosses a blank-decoration line ` *\n` or
  the closing ` */`. These are paragraph boundaries.
- A `Citation`'s `verbatim_text` MUST lie wholly within one
  paragraph's `text`; citations do not span paragraph
  boundaries.

### `Failure mode`

A one-line indented reason string emitted under a `[FAIL]
<file>` line. M2.2 introduced three modes; M2.4 introduces a
fourth.

**Existing M2.2 modes (carry forward unchanged)**:

| Mode | Reason string |
|---|---|
| `MISSING citation` | (literal: `MISSING citation`) — the file has no line passing M2.2 Rule C1's strict canonical-form check. |
| `MISSING Station: directive` | (literal) — the koan has no `Station:` line in its leading comment block. Koans only. |
| `MULTIPLE Station: directives` | (literal) — the koan has more than one `Station:` line in its leading comment block. Koans only. |

**New M2.4 mode**:

| Mode | Reason string |
|---|---|
| `UNRESOLVED citation: <text> (no §<sec> + p. <page> row in docs/cowlishaw_index.md)` | The (§sec, page) key is absent from the lookup table. |
| `UNRESOLVED citation: <text> (heading "<suffix>" does not match index row "<verbatim_csv>")` | The (§sec, page) key resolves to one or more `### <heading>` children, but `<suffix>` doesn't match any of them verbatim. `<verbatim_csv>` is the comma-joined list of valid heading alternatives. |
| `UNRESOLVED citation: <text> (heading "<suffix>" does not match any §<sec>+p.<page> row; use bare form)` | The (§sec, page) key resolves but its heading list is empty (the citation refers to a `## §X.Y` row directly with no `###` children at that page). |

**Constraints**:

- Multi-failure reporting (FR-016): a file with N unresolved
  citations emits N `UNRESOLVED citation:` reason lines under a
  single `[FAIL] <file>` line, in source order
  (line-number-ascending; if multiple unresolved citations
  share a line, in column order within that line).

## Joins and lookups

### Citation → Lookup table → Index row

Given a `Citation` with parsed `(section, page, suffix)`:

1. Look up `(section, page)` in the `Lookup table`.
2. If absent: emit `Failure mode` variant 1 (no row).
3. If present:
   - If `suffix` is null (bare form): the citation resolves
     (regardless of how many headings are at the key, including
     zero — the parent §X.Y row at that page is sufficient).
   - If `suffix` is non-null:
     - If the heading list is non-empty AND `suffix` matches
       any heading verbatim: the citation resolves.
     - If the heading list is non-empty AND `suffix` does NOT
       match: emit `Failure mode` variant 2 (suffix mismatch
       with `<verbatim_csv>` listing valid alternatives).
     - If the heading list is empty: emit `Failure mode`
       variant 3 (suffix present but no children).

### Citation → Reassembled paragraph → File

Each citation belongs to exactly one paragraph in exactly one
file. The paragraph's `start_line` plus the citation's
within-paragraph offset determines the citation's reported
`line_no` for failure messages.

## State transitions

There is one state transition for the feature as a whole:

- **Before M2.4**: `bin/lint_citations` checks canonical-form
  (M2.2 Rule C1) and the `Station:` directive on koans only.
  Citation existence against `docs/cowlishaw_index.md` is a
  contributor responsibility (Constitution Principle III), not
  a CI responsibility. ~22 in-prose parenthetical citations
  (M2.3) and ~28 trailing canonical citations are
  silently unchecked for §+page resolution at lint time.
- **After M2.4**: `bin/lint_citations` builds a (§sec, page) →
  headings lookup from `docs/cowlishaw_index.md` once at
  startup, then validates every citation in
  `koans/*.rexx` and `solutions/*.rexx` against the table. The
  `Station:` directive check stays koans-only. The 6/6 CI matrix
  (Constitution Principle IV; spec FR-009) is the acceptance
  gate.

There are no per-citation incremental states — every citation
is validated as a discrete lookup against the pre-built table.
The 6 CI checks (matrix verify_solutions × 2 OS, lint_citations
× 2 OS, runner-smoke × 2 OS) are the acceptance gate.
