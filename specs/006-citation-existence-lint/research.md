# Phase 0 Research — M2.4

This document records the lookups and design choices made during
Phase 0 of `/speckit-plan` for M2.4. It resolves the eight
research questions named in `plan.md` Phase 0.

## §1. Index-row parser format

### Decision

The parser walks `docs/cowlishaw_index.md` once, line by line.
It tracks two pieces of state:

- **Current parent context** `cur_section` — the most recently
  seen `## §X.Y — <title>` heading's `<sec>` (e.g., `2.5`). Reset
  to empty by any `# Part …` or `# Appendix …` top-level heading
  or end-of-file.
- **Pending row state** `cur_row` — the most recently seen `##`
  or `###` heading text, awaiting its `**Page:** N` bullet.

### Format expectations

Confirmed against the current `docs/cowlishaw_index.md`:

- Top-level wrappers: `# Part 1 — Background`, `# Part 2 — REXX
  Language Definition`, etc., and `# Appendix N — …`. These are
  navigation, not rows; the parser ignores them but uses them to
  reset `cur_section` (so a stray `### <heading>` inside an
  Appendix preamble cannot inherit the last §X.Y).
- Section headings: `## §X.Y — <title>` where `X.Y` is digits
  optionally with `.digits` (matching M2.2 Rule C1's
  `is_section` predicate). The em-dash separator and ` — `
  spacing are required exactly as in citations (per the index's
  preamble convention).
- Child rows: `### <heading>` where `<heading>` is the verbatim
  human-readable child name (e.g., `Literal strings`,
  `Logical (Boolean)`, `Implied semicolons and continuations`).
  The heading text MAY contain spaces, parentheses, and
  punctuation; it MUST NOT contain a leading or trailing space
  after stripping the `### ` prefix.
- Bullets: each row is followed by exactly three Markdown
  bullets in this order:
  - `- **Page:** N` — N is one or more digits.
  - `- **Summary:** <prose>` — non-empty.
  - `- **Vocabulary:** <comma-separated terms>` — may be empty
    (some rows have no vocabulary).

The parser only consumes the `**Page:**` bullet for lookup-table
purposes; `**Summary:**` and `**Vocabulary:**` are ignored.

### Lookup-table build

For each row encountered:

- A `## §X.Y` row with `**Page:** N` adds the key `(X.Y, N)` to
  the table with value `[]` (empty heading list — bare-form
  matchable, but not a `###` child).
- A `### <heading>` row with `**Page:** N` (under the most-recent
  `## §X.Y`) appends `<heading>` to the headings list at key
  `(X.Y, N)`. If the key didn't exist, it's created with
  `[<heading>]`.

After the walk, two illustrative keys look like:

```
(2.2, 19): has_parent=1, headings=["Literal strings", ...]
            # the §2.2 parent row sits at p.19; ### children
            # such as "Literal strings" also sit at p.19.
(2.5, 32): has_parent=1, headings=[]
            # the §2.5 parent row sits at p.32; no ### children
            # of §2.5 share this page (its children sit elsewhere).
```

Note: a key may have an empty list (the parent §X.Y itself, no
children at that page) or a list of one or more headings. The
distinction matters for the `UNRESOLVED citation` reason: a
suffixed citation hitting a key with an empty heading list gets
the "no `###` children at this key" reason, while one hitting a
key with a non-empty list but mismatching gets the
"alternatives: ..." reason.

### Rationale

- **Single-pass parser**: simplest correct design; matches
  REXX's natural `LINEIN`/`LINES` per-line iteration model. The
  index file is small (~80 rows × ~5 lines each = ~400 lines
  total); a second pass would be wasted.
- **Track parent §X.Y context**: necessary because `### <heading>`
  rows don't repeat their parent section. The parent is implicit
  in the document's structure.
- **Parser is strict about row format**: any row violating the
  three-bullets-in-order convention triggers the bootstrap-error
  exit (FR-010). Strictness here surfaces index defects early
  rather than silently producing a malformed lookup table.

### Alternatives considered

- **Two-pass parser**: walk once to collect all headings, walk
  again to attach pages. Rejected: more complexity, no benefit
  at this scale.
- **Deferred parsing (parse on-demand per citation)**: rejected.
  ~80 rows × ~50 citations = 4000 row-visits if parsed lazily.
  Single pre-pass is simpler and faster.
- **Build a regex of all valid (§sec, page) pairs**: rejected.
  REXX's `POS`/`SUBSTR` plus stem-variable lookups are simpler
  than building and matching a 80-alternative regex.

## §2. M2.4 citation-detection pattern (broad)

### Decision

Per the Clarifications session 2026-05-10 (Q1 resolution), the
M2.4 existence check uses a more permissive citation-detection
pattern than M2.2's strict Rule C1. The pattern:

```
Cowlishaw §<sec>, p. <page>[ — <heading>]
```

Where:

- `<sec>` matches the same `is_section` predicate as M2.2 Rule
  C1 (digits with optional `.digits` groups; no `..`; no leading
  or trailing dot).
- `<page>` is one or more decimal digits.
- The optional ` — <heading>` group requires the canonical
  em-dash separator (space + U+2014 + space, byte-equivalent to
  `' E28094'x ' '`). `<heading>` is one or more characters,
  non-empty after whitespace stripping.
- **NO TAIL CONSTRAINT**: the substring may be embedded in
  prose, parentheticals (e.g., `(Cowlishaw §2.3, p. 26):`),
  comment-close (e.g., `*/`), or any other context. The
  substring scan terminates at:
  1. A clear in-line terminator: `)`, `*/`, end-of-line.
  2. A second `Cowlishaw §` marker on the same line (a second
     citation begins).
  3. End of paragraph (after the comment-block reassembly in
     §3 below, this collapses to "end of reassembled
     paragraph").

### Suffix termination

The optional ` — <heading>` group's `<heading>` extends from
the trailing space-em-dash-space to the first terminator (above
list). If no terminator is found before end-of-paragraph, the
heading text is what's between ` — ` and the paragraph end (with
trailing whitespace stripped).

### Rationale

- **Why broader than Rule C1**: M2.3 introduced in-prose
  parenthetical citations like `(Cowlishaw §2.3, p. 26):` which
  Rule C1 strictly rejects (the `):` violates Rule C1's
  whitespace-and-`*/`-only tail). For the existence check, we
  want to validate every citation a contributor can write,
  including these. M2.2's Rule C1 stays unchanged for the
  canonical-form anchor check (one canonical citation must exist
  per file); M2.4 adds the existence check on a broader detection
  scope.
- **Why preserve the canonical em-dash separator**: contributors
  writing `Cowlishaw §2.5, p. 32 -- Heading` (legacy ASCII) or
  using en-dash `–` should still fail M2.2's Rule C1 anchor
  check (which requires the canonical em-dash). M2.4's broader
  pattern also requires canonical em-dash for suffix detection;
  a citation with `--` would still fail Rule C1 (file gets
  `MISSING citation`) and would not be picked up as suffixed by
  M2.4 (because the broad pattern's suffix matcher requires
  canonical em-dash). The lint result is "unresolved" only when
  the citation IS in canonical em-dash form but doesn't resolve.

### Pseudocode (REXX-flavored)

```rexx
/* Returns parsed components or empty if no Cowlishaw §<sec>, p. <page> match. */
extract_citations: PROCEDURE
  PARSE ARG paragraph_text
  marker = 'Cowlishaw §'
  start = 1
  citations = ''
  DO FOREVER
    p1 = POS(marker, paragraph_text, start)
    IF p1 = 0 THEN LEAVE
    section_start = p1 + LENGTH(marker)
    p2 = POS(', p. ', paragraph_text, section_start)
    IF p2 = 0 THEN DO; start = p1 + LENGTH(marker); ITERATE; END
    section = SUBSTR(paragraph_text, section_start, p2 - section_start)
    IF \is_section(section) THEN DO; start = p1 + LENGTH(marker); ITERATE; END
    page_start = p2 + 5
    digits = 0
    DO j = page_start TO LENGTH(paragraph_text)
      IF \DATATYPE(SUBSTR(paragraph_text, j, 1), 'W') THEN LEAVE
      digits = digits + 1
    END
    IF digits = 0 THEN DO; start = p1 + LENGTH(marker); ITERATE; END
    page = SUBSTR(paragraph_text, page_start, digits)
    /* Optional suffix detection: */
    suffix_start = page_start + digits
    suffix = ''
    emdash_sep = ' ' || 'E28094'x || ' '
    IF SUBSTR(paragraph_text, suffix_start, LENGTH(emdash_sep)) = emdash_sep THEN DO
      heading_start = suffix_start + LENGTH(emdash_sep)
      /* Suffix terminates at ')', '*/', next 'Cowlishaw §', or end-of-paragraph */
      term_chars = ')'
      term_seq2 = '*/'
      term_seq3 = marker
      end_pos = LENGTH(paragraph_text) + 1  /* default: end-of-paragraph */
      /* find earliest terminator >= heading_start */
      ...
      heading_len = end_pos - heading_start
      suffix = STRIP(SUBSTR(paragraph_text, heading_start, heading_len))
    END
    /* Emit citation tuple (section, page, suffix, citation_text, line_no) */
    ...
    start = (suffix \= '' & end_pos > 0 ? end_pos : page_start + digits)
  END
  RETURN citations
```

### Alternatives considered

- **Two-pattern detection (line-anchored vs. substring)**:
  rejected; the broad substring pattern subsumes the
  line-anchored case.
- **Match suffix only when followed by `)`, `*/`, or
  end-of-line**: too strict — would miss `Cowlishaw §X.Y, p. NN
  — Heading.` followed by sentence-ending punctuation. Rejected
  in favor of "until next terminator or paragraph end".
- **Validate suffix only when bounded by punctuation
  (`)`/`*/`)** — matches the M2.2 strict feel but loses
  validation on common `Cowlishaw §X.Y, p. NN — Heading` trailing
  citation lines (no `)` or `*/` on a bare-trailing-line case).
  Rejected.

## §3. Cross-line suffix handling: comment-block reassembly

### Decision

Before running the broad citation-detection pattern, the lint
script reassembles consecutive comment-prose lines within a
`/* ... */` block by stripping the leading ` * ` (or `/* ` /
` */`) decoration and joining adjacent lines with a single
space.

### Concrete case

`solutions/00_about_asserts.rexx` lines 39–40 (post-M2.3):

```
 * Logical (Boolean) value '1' (Cowlishaw §2.3, p. 27 — Logical
 * (Boolean)). Comparative operators (Cowlishaw §2.3, p. 26) such as
```

After reassembly (stripping ` * ` decoration; joining with a
single space):

```
Logical (Boolean) value '1' (Cowlishaw §2.3, p. 27 — Logical (Boolean)). Comparative operators (Cowlishaw §2.3, p. 26) such as
```

The broad pattern now finds:
- `Cowlishaw §2.3, p. 27 — Logical (Boolean)` (suffix terminates
  at the `)` before `.`)
- `Cowlishaw §2.3, p. 26` (bare; suffix would terminate at the
  `)` immediately after page digits, but no ` — ` precedes that
  `)`, so suffix is empty)

Both citations are correctly extracted and validated.

### Reassembly rule

A "paragraph" is a contiguous run of lines within a single
`/* ... */` comment block where:

- The first line opens with `/*` (or starts mid-block with the
  decoration ` * `).
- Subsequent lines start with ` * ` (the standard REXX comment
  prose decoration).
- A blank-decoration line ` *\n` (or ` *` followed by end-of-line)
  starts a new paragraph.
- The closing ` */` ends the block.

Within a paragraph, lines are joined by replacing the boundary
between line-N's content (after stripping its trailing `\n`) and
line-(N+1)'s decoration ` * ` with a single space.

### Line-number tracking

Each citation match remembers the line where its `Cowlishaw §`
marker began (in the original file). This is the line reported
in `UNRESOLVED citation:` failure messages.

If a citation marker is on line N but its suffix terminates on
line N+1 (cross-line), the citation is reported as being on line
N. (Contributors fix at the marker; the suffix is part of the
same citation.)

### Rationale

- **Cross-line suffixes are real and intentional**: the M2.3
  in-prose parentheticals were authored by a contributor (and
  subsequently shipped on `main` by a green CI run); they are
  part of the corpus's natural prose flow. Rejecting them at
  M2.4 lint time would be a false positive.
- **Per-paragraph reassembly is the simplest correct
  abstraction**: it's how a human reads a comment block, and it
  cleanly bounds the substring scan (citations don't span across
  paragraph boundaries — the blank-decoration line is a hard
  barrier).
- **Line-number tracking via the marker's line**: matches the
  contributor's mental model — they fix the line where they
  wrote `Cowlishaw §`, not the line where the suffix happens to
  wrap.

### Alternatives considered

- **Per-line scan, suffix bounded by end-of-line**: rejected —
  would falsely fail the M2.3 cross-line cases.
- **Per-line scan, suffix optional with end-of-line tolerance**
  (suffix-mismatch falls back to bare-form check): considered;
  rejected. Hides real suffix typos behind a silent fallback.
  Worse contract: contributor doesn't see the rejection they
  should see.
- **Reassemble the entire file into one big string**: rejected —
  loses paragraph boundaries (citations could spuriously match
  across blank-line gaps where they wouldn't in human reading).
  Per-paragraph is the right level.
- **Multi-line regex (e.g., a regex that allows `\n *` inside
  the suffix)**: rejected — REXX doesn't have native multi-line
  regex; building one ad hoc with `POS`/`SUBSTR` is harder than
  reassembling first.

## §4. `UNRESOLVED citation` reason strings

### Decision

Three sub-reason variants, distinguished by the lookup outcome:

#### 4.1 Sub-reason: §+page does not resolve

When the (§sec, page) key is absent from the lookup table:

```
UNRESOLVED citation: <citation_text> (no §<sec> + p. <page> row in docs/cowlishaw_index.md)
```

`<citation_text>` is the verbatim citation as it appeared in the
source (including the optional ` — <heading>` suffix if present).

Example (a contributor types §99.99 by accident):
```
[FAIL] koans/06_about_io.rexx
  UNRESOLVED citation: Cowlishaw §99.99, p. 999 (no §99.99 + p. 999 row in docs/cowlishaw_index.md)
```

#### 4.2 Sub-reason: suffix mismatch with `###` children present

When the (§sec, page) key resolves to a list of one or more
`### <heading>` children, but the citation's `<suffix>` does not
match any of them verbatim (case-sensitive):

```
UNRESOLVED citation: <citation_text> (heading "<suffix>" does not match index row "<verbatim_csv>")
```

`<verbatim_csv>` is the comma-joined list of valid heading
alternatives at this key. If the list has one entry, the message
reads as singular ("does not match index row \"X\"" without
commas); for multiple entries, it's "does not match index row
\"X\", \"Y\"".

Example:
```
[FAIL] koans/06_about_io.rexx
  UNRESOLVED citation: Cowlishaw §2.3, p. 27 — Boolean (heading "Boolean" does not match index row "Logical (Boolean)", "Numbers")
```

#### 4.3 Sub-reason: suffix present but no `###` children at key

When the (§sec, page) key resolves but its heading list is empty
(the citation refers to a `## §X.Y` row directly with no `###`
children at that page):

```
UNRESOLVED citation: <citation_text> (heading "<suffix>" does not match any §<sec>+p.<page> row; use bare form)
```

Example:
```
[FAIL] koans/06_about_io.rexx
  UNRESOLVED citation: Cowlishaw §1.1, p. 1 — Some Heading (heading "Some Heading" does not match any §1.1+p.1 row; use bare form)
```

### Rationale

- **Verbatim citation text** (`<citation_text>`): contributor
  sees exactly what they wrote, anchoring the diagnostic to the
  source.
- **Verbatim valid alternatives** (`<verbatim_csv>` in §4.2):
  guides the contributor to the correct suffix without a
  separate index lookup. When the key has multiple valid
  headings (rare, but possible per the index's
  child-disambiguation rule), all are surfaced.
- **"Use bare form" guidance** (§4.3): the only fix when the
  suffix is rejected and no children exist is to drop the
  suffix; the message states this directly.
- **Diagnostic-first voice** (Constitution Principle V): every
  reason is structured as `UNRESOLVED citation: <what they
  wrote> (<why it failed>)`. No pilgrimage flavor.

### Alternatives considered

- **Single-form reason** ("UNRESOLVED citation: X"): too terse,
  doesn't differentiate the typo cases. Rejected.
- **Different prefixes per sub-reason** (e.g.,
  `MISSING_INDEX_ROW`, `SUFFIX_MISMATCH`, `SUPERFLUOUS_SUFFIX`):
  rejected — adds a third dimension to the failure-mode taxonomy
  (M2.2 has three modes: `MISSING citation`, `MISSING Station:
  directive`, `MULTIPLE Station: directives`; M2.4 adds one
  fourth: `UNRESOLVED citation`). Sub-reasons inside parentheses
  are simpler.
- **Suggestion text** (e.g., "did you mean §2.3, p. 26?"): out of
  scope. Adds substantial complexity (similarity scoring) for
  modest contributor benefit. Rejected.

## §5. Contract location: new file vs. amend M2.2's

### Decision

A new contract file at
`specs/006-citation-existence-lint/contracts/lint_citations.md`
that supersedes
`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.

`bin/lint_citations`'s docstring header is updated to point at
the new contract. The M2.2 contract is left in place as
historical record.

### Rationale

- **Matches the project's supersession pattern**: M2-era
  (`specs/002-m2-walking-skeleton/contracts/lint_citations.md`)
  → M2.2
  (`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`)
  → M2.4
  (`specs/006-citation-existence-lint/contracts/lint_citations.md`).
  Each successor contract names its predecessor explicitly and
  documents what carries forward unchanged.
- **Easier to review**: a new file is a clean diff against
  `main`; an in-place amendment of M2.2's contract would be a
  large mid-document patch that's harder to review in isolation
  from the script change.
- **Historical clarity**: future contributors curious about
  "what was M2.2's exact behavior" can read M2.2's contract
  directly without git-archaeology.

### Alternatives considered

- **Amend M2.2's contract in place**: rejected per above.
- **Add a single delta file** (e.g.,
  `specs/006-citation-existence-lint/contracts/lint_citations_delta.md`)
  that lists only the changes: rejected. Forces readers to
  consult two files (delta + M2.2) to understand the current
  contract; the supersession pattern presents one self-contained
  current-state document instead.

## §6. Integration with M2.2's existing per-file logic

### Decision

`bin/lint_citations` currently does the per-file check in three
phases:

1. **Per-line scan** (`check_citation`, `check_station`):
   line-by-line, tracking `has_citation` and `station_count`.
2. **Per-file evaluation**: after the file is fully read, decide
   `[ ok ]` (`has_citation = 1` AND `station_count = 1`) or
   `[FAIL]` with reason lines.
3. **Summary**: count passes, print `<passed>/<total> koans
   passed lint.`, exit accordingly.

M2.4 adds a fourth phase between (1) and (2):

1. **Per-line scan** (unchanged from M2.2): `has_citation`,
   `station_count`.
2. **NEW: Comment-block reassembly + per-paragraph existence
   scan**. After per-line scanning, the file's content (already
   read line by line) is grouped into paragraphs (per the
   reassembly rule in §3). For each paragraph, the broad pattern
   (per §2) extracts every citation occurrence; each is looked
   up in the pre-built table and accumulates an `UNRESOLVED
   citation:` reason string if it doesn't resolve.
3. **Per-file evaluation**: `[ ok ]` requires `has_citation = 1`
   AND `station_count = 1` AND zero unresolved citations. Each
   failure mode contributes its own reason line under `[FAIL]`.
4. **Summary**: count passes, print summary line, exit.

The lookup table is built once at the very start (before the
per-file loop) by parsing `docs/cowlishaw_index.md`. If parsing
fails, the script exits with the bootstrap-error message before
any file is processed (FR-010).

### Rationale

- **Phase ordering**: keeps M2.2's per-line scan untouched
  (preserves the well-tested Rule C1 behavior). The new phase is
  additive and runs *after* per-line scanning but *before* the
  per-file decision.
- **Reassembly happens in M2.4 phase only**: M2.2's `check_citation`
  doesn't need reassembled text (its scope is the per-line
  Rule C1 anchor check). Doing reassembly in M2.4 alone keeps
  the new logic self-contained.
- **Lookup table built once**: amortizes parser cost across all
  files (12 files × one parse = 1 parse, not 12 parses).
- **Bootstrap error before per-file loop**: aligns with FR-010 —
  no file gets `[ ok ]` if the index can't be loaded.

### Alternatives considered

- **Build lookup table per file**: rejected — wasteful at
  12-file scale, would also force re-reading the index file 12
  times.
- **Lazy lookup-table build (parse on first citation match)**:
  rejected — complexity without benefit; the index file is
  always read.
- **Reuse `check_citation`'s per-line logic for the existence
  scan too**: rejected — Rule C1's strict tail constraint would
  hide in-prose parentheticals from the existence check (the
  Q1 clarification's "narrow" option, explicitly rejected).

## §7. Performance envelope

### Decision

No performance work required.

### Numbers

- Index file: ~80 rows × ~5 lines each = ~400 lines.
- Corpus: 12 files × ~50 lines each = ~600 lines.
- Distinct citations across the corpus: ~50 (post-M2.3).
- Lookup table size: ~80 entries (one per index row).

Total work per lint invocation:

- Parse index: ~400 line reads + ~80 stem-variable assignments.
- Walk corpus: ~600 line reads.
- Reassembly: linear in file size.
- Existence checks: ~50 lookups (each O(1) on a stem-variable
  hash).

On a modest laptop, this is < 100 ms total. Even with a 10×
corpus growth (M3+ shipping ~50 koans), it's still < 1 s. No
caching, no incremental parsing, no parallelism is warranted.

### Rationale

- **Constitution Principle II**: REXX has stem variables (REXX's
  associative array idiom); they suffice for a sub-100-row
  lookup table. No external data structure is needed.
- **CI envelope**: the existing `lint_citations` job runs in
  seconds; M2.4's additions are small enough that the job's
  runtime envelope doesn't change perceptibly.

### Alternatives considered

- **Memo-cache parsed index across invocations**: out of scope.
  Lint is a one-shot CLI; caching would require an out-of-process
  state file. Rejected.

## §8. Index defects

### Decision

None expected.

### Process

If M2.4 implementation surfaces an index-row defect — i.e., a
row in `docs/cowlishaw_index.md` whose §+page doesn't match a
citation that the post-M2.3 corpus uses — the implementation
halts and the defect is escalated as a one-row M2.1 amendment in
a separate commit. The amendment lands first; M2.4 then resumes
against the corrected index.

The escalation procedure mirrors M2.2 / M2.3's escape-hatch
(both features had the same potential and neither exercised it).

### Rationale

- **M2.1 is the index's authoring feature**: M2.4 consumes the
  index, never modifies it (FR-013). Defect corrections are
  M2.1 amendments by definition.
- **Separate commit**: the defect-correction commit is reviewable
  in isolation; the M2.4 work is not entangled with it.

### Alternatives considered

- **Bundle index corrections into M2.4 commits**: rejected.
  Violates the project's contract-driven feature separation
  (M2.1 owns the index; M2.4 owns the lint script). Mixed-purpose
  commits are harder to review and harder to revert if one part
  is wrong.

## Summary

All eight Phase 0 questions resolved with explicit decisions and
rationales. No NEEDS-CLARIFICATION markers remain. The index
parser format, the broad detection pattern, the cross-line
reassembly rule, the failure-mode reason strings, the contract
supersession choice, the script-integration phase ordering, the
performance envelope, and the index-defect escape hatch are all
codified.

Phase 0 is complete. Proceed to Phase 1 (data model + contract
+ quickstart).
