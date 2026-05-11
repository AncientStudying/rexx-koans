# Contract: Koan Directives — M3

**Effective at**: M3 merge (`008-m3-the-path` → `main`).
**Scope**: directive lines that may appear in `koans/*.rexx`
and `solutions/*.rexx` source files. The `Station:` directive
is carried forward from M2 unchanged; the `Scripture:` directive
is new in M3.

This document is the single shared reference for koan-side
directives, replacing scattered references in `lib/stations.rexx`'s
docstring and the M2-era contracts. It does not introduce new
behavior for `Station:` — that contract stays as-is — and adds
the `Scripture:` directive contract.

## Directive shape (general)

A directive is a single line inside a comment block. It takes
the form:

```
<Verb>: <argument>
```

Where:

| Element | Constraint |
|---|---|
| `<Verb>` | Capitalized identifier matching `[A-Z][a-zA-Z]+`. Case-sensitive. M3 defines two verbs: `Station:` and `Scripture:`. |
| Separator | Literal `:` immediately after the verb (no whitespace before the colon), then a single space, then the argument. |
| `<argument>` | Free-form text per directive rules below. Trailing whitespace is stripped. |

A directive line MUST appear inside a comment block. The
comment-block context can be:

1. The interior of a `/* ... */` block (the canonical form
   used by every koan today): the directive is a continuation
   line whose first non-whitespace token is `*` followed by a
   space, then the directive verb. Example:
   ```
   /* Concept: ...
    * <prose>
    * Scripture: least_astonishment
    * Cowlishaw §2.7, p. 71
    */
   ```
2. The first line of a `/* ... */` block (rare, but legal
   per existing M2 stations.rexx parser): the directive is
   immediately after `/*` plus optional whitespace.
3. The last line of a `/* ... */` block (rare): the directive
   is immediately before ` */` or `*/`.

A directive MUST NOT appear:
- Outside a comment block (e.g., as REXX code, or in a string
  literal).
- Inside a `/* ... */` block that has been line-split such that
  one continuation line lacks the leading `*` (a malformed
  comment block; legal REXX, contributor convention forbids it).

## Directive: `Station:`

**Carried forward from M2.** Unchanged.

**Purpose**: declares the station's pilgrim-voice subtitle for
the runner's station-list display.

**Location**: in the koan's leading comment block, before the
first `n = 0` initializer.

**Cardinality**: exactly one per koan. `bin/lint_citations`
reports `MISSING Station:` if absent and `MULTIPLE Station:`
if more than one (per the M2.2 lint contract).

**Argument**: free-form pilgrim-voice text (e.g.,
`The First Truths`, `Of Many Ways`).

**Harvested by**: `lib/stations.rexx`'s `extract_subtitle`
procedure (line-by-line scan up to 50 lines into the koan;
matches `POS('Station:', s) = 1` after stripping leading
comment characters).

**Solutions**: solution files MAY include their matching koan's
`Station:` directive (the solutions/00_about_asserts.rexx
pattern); the runner does not consume solution files at runtime,
so the directive is informational in solutions. Lint does not
check `Station:` on solution files.

## Directive: `Scripture:` (NEW IN M3)

**Purpose**: binds a teaching block (and every assertion line
that follows it within block scope) to a scripture entry in
`lib/scripture.rexx`. On a failed assertion within the bound
scope, the runner emits the FR-012 two-line Bathonian block.

**Location**: inside a teaching comment block — i.e., the
`/* Concept: ... */` block that precedes one or more `CALL m`
assertion lines. NOT in the koan's leading comment block (use
`Station:` there).

**Cardinality**: at most one `Scripture:` directive per teaching
comment block. A second directive in the same block is a
contributor error (forward enforcement by review per
spec § Out of Scope).

**Argument**: a scripture key matching `[a-z_]+`. The key MUST
be one of the seven keys defined in `lib/scripture.rexx` (per
`scripture_library.md`):
`humans_not_machines`, `least_astonishment`, `everything_is_string`,
`read_aloud`, `consistency`, `whitespace_matters_just_enough`,
`numbers_are_strings_too`.

**Harvested by**: `lib/pilgrimage.rexx`'s
`scripture_for_failure` procedure (added in M3) at koan-failure
time. See `runner.md` § "Scripture-emission pass" and
research.md §1 for the algorithm.

**Solutions**: solution files MUST replicate the koan's
`Scripture:` directive byte-for-byte (per FR-002, SC-010 — only
FILL_ME_IN-vs-value substitutions differ between a koan and
its solution). The runner doesn't consume solution files at
runtime, so the directive is informational in solutions; the
parity invariant is what makes it required.

**Lint**: M3 does not extend `bin/lint_citations` to validate
`Scripture:` directives mechanically. A future milestone may
add a check that every `Scripture: <key>` directive in
`koans/*.rexx` and `solutions/*.rexx` resolves to a defined
key in `lib/scripture.rexx`. Out of scope for M3 (per spec §
Out of Scope).

## Binding-scope algorithm

The `Scripture:` directive's binding scope is **block-scoped**
(per Clarifications Q2 → FR-024). The directive binds every
`CALL m` assertion line that follows it in source order, up to
the start of the next teaching comment block (next `/*`) or
end-of-file.

**Mechanical resolution** (used by the runner; see `runner.md`):

Given the failed line N (from the meditation `Damaged at:`
diagnostic), the runner walks backward from `N − 1` toward
line 1, halting at the first event:

| Event | Detection | Result |
|---|---|---|
| `Scripture: <key>` directive line | After stripping leading whitespace and a leading `* `, the line begins with literal `Scripture: ` and the rest matches `[a-z_]+`. | Bound to `<key>`. |
| `/*` line | After stripping leading whitespace, the line begins with literal `/*`. | Unbound (a fresh teaching block opened before the directive could be reached). |
| Line 1 reached | n/a | Unbound. |

If bound, the runner calls
`CALL 'lib/scripture.rexx' 'fetch', key` and emits the FR-012
block (per `runner.md`).

## Examples

### Example 1: Stage I (no scripture binding)

```rexx
/* Concept: equality.
 * The first assertion verb is `eq`. ...
 *
 * Cowlishaw §2.5, p. 32
 */
CALL m 'eq', FILL_ME_IN, 2 + 2
CALL m 'eq', 'pilgrim', 'pilgrim'
```

Failure on line 1 (the FILL_ME_IN line): scan backward; encounter
`*/` (or `* Cowlishaw §2.5, p. 32`, then `*/`); encounter `/*`
before any `Scripture:` directive; **unbound**. Stage I shape.

### Example 2: M3 koan 07 (scripture-bound)

```rexx
/* Concept: SELECT and the OTHERWISE clause.
 * SELECT chooses one of several alternative WHEN branches. ...
 *
 * Scripture: least_astonishment
 * Cowlishaw §2.7, p. 71
 */
CALL m 'eq', 'apple', choose_fruit('A')
CALL m 'eq', 'banana', choose_fruit('B')
CALL m 'eq', 'unknown', choose_fruit('Z')
```

Failure on the third `CALL m` line: scan backward; pass two
sibling `CALL m` lines (no event); encounter `*/`; encounter
`* Cowlishaw §2.7, p. 71`; encounter `* Scripture: least_astonishment`;
**bound to `least_astonishment`**.

Note: all three assertions in this teaching block are bound,
because the directive's scope extends from its position to the
next teaching block boundary.

### Example 3: M3 koan with two teaching blocks, one bound, one unbound

```rexx
/* Concept: A.
 * <prose>
 * Scripture: everything_is_string
 * Cowlishaw §X.Y, p. NN
 */
CALL m 'eq', expected_a, actual_a   /* bound */

/* Concept: B.
 * <prose>
 * Cowlishaw §X.Y, p. NN
 */
CALL m 'eq', expected_b, actual_b   /* unbound */
```

Failure on the `Concept: B` assertion: scan backward; encounter
`*/`; encounter `*` lines; encounter `/*` (start of `Concept: B`
block); **unbound** (the scan halted at the new block boundary
before reaching the `Scripture:` directive in the previous
block). The directive's scope ended at the `Concept: B` block
opening, exactly as block-scoped binding requires.

### Example 4: Multi-line citation suffix in a teaching block (cross-line continuation)

The Stage I corpus contains a citation whose suffix wraps:

```rexx
/* ...
 * Cowlishaw §2.3, p. 27 — Logical
 * (Boolean)
 */
```

This is *not* a `Scripture:` directive — it's a citation. The
backward-scan algorithm identifies `Scripture:` directives by
the prefix `Scripture: `, not by content of cited headings.
Citation suffix continuation lines are passed through during
the backward scan as ordinary lines (no event raised). The
`/*` and `Scripture:` events are the only ones the algorithm
reacts to.

## Cross-platform parity

The directive verbs are ASCII; the directive arguments are
ASCII (Station subtitles, scripture keys); the directive shape
is byte-identical on both runners. No platform divergence.

## Compatibility

`Station:` carries forward from M2 unchanged. Existing Stage I
koans satisfy the contract without edit.

`Scripture:` is new in M3. M3 koans introduce ≥3 directives
(per the working scripture-binding selection: koans 07, 12, 14).
M4–M7 may add directives to additional koans without changing
this contract. Adding a `Scripture:` directive to a Stage I
koan would be a Stage I edit and is out of scope for M3 (per
plan Constraints).

The two-line FR-012 block is the runner's emission, not the
directive's content. Changing the emission shape requires a
new runner contract (this contract document covers only the
source-side directive).
