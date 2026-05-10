# Data Model — M2.5

This document formalizes the entities operated on by M2.5 and the
relationships among them. The model is content-only — there is no
persistent storage and no runtime data flow beyond what is already
captured by `lib/meditation.rexx`'s six-argument interface. The
"entities" here are source-textual constructs in the Stage I corpus
files; the relationships are compile-time (the wrapper produces
the ordinal that the assertion lines consume by reference).

## Entities

### `Assertion line`

A single line of REXX in a koan or solution file that invokes the
koan-local meditation wrapper. The unit of edit for FR-001 /
FR-002.

**Pre-change syntactic shape**:

```rexx
n = n + 1; CALL m '<verb>', <arg1>, <arg2>, n
```

**Post-change syntactic shape**:

```rexx
CALL m '<verb>', <arg1>, <arg2>
```

**Fields**:

| Field | Type | Description |
|---|---|---|
| `verb` | enum {`eq`, `neq`, `true`, `datatype`} | The assertion-verb name. The four values are the dispatch keys handled by `lib/meditation.rexx`'s `SELECT WHEN` block. Quoted single-quote string literal in the source. |
| `arg1` | REXX expression | The first verb argument: expected-value for `eq`/`neq`, boolean condition for `true`, value-to-type-check for `datatype`. May be a literal (`'pilgrim'`, `4`), a parenthesized expression (`(1 = 1)`), or a deliberate blank (`FILL_ME_IN`). |
| `arg2` | REXX expression | The second verb argument: actual-value for `eq`/`neq`, conventionally `''` for `true` (unused by dispatcher), REXX type code (single-character string, e.g., `'N'`, `'A'`, `'W'`) for `datatype`. May also be `FILL_ME_IN`. |
| `koan_path` | string (implicit) | Not present on the assertion line itself; supplied by the wrapper's third argument to the dispatcher. The path is a property of the file the line appears in, not of the line. |

**Relationships**:

- One assertion line → one invocation of `m:` (the koan-local
  wrapper) → one invocation of `lib/meditation.rexx` → at most
  one diagnostic line in the runner's stdout (zero on success,
  one or two on failure depending on which verb failed and
  whether a FILL_ME_IN is detected).
- Every assertion line in the same file shares one ordinal
  counter `n`, advanced by the wrapper.

**Cardinality**: ~30+ assertion lines across the Stage I
corpus. Per-file counts vary (a small file like
`00_about_asserts.rexx` has ~7 assertion lines; larger files
like `03_about_expressions.rexx` have more — exact counts
verified by tasks.md pre-grep).

**Invariants**:

- Post-change, every assertion line in `koans/0[0-5]_about_*.rexx`
  and `solutions/0[0-5]_about_*.rexx` matches the post-change
  syntactic shape exactly. No `n = n + 1;` prefix; no trailing
  `, n` argument. (FR-001, FR-002, FR-013, FR-014.)
- Pre-change, every assertion line matches the pre-change
  syntactic shape exactly. (Assumed; verified by tasks.md
  pre-grep before edits begin.)

**Validation rules**:

- An assertion line must be a single statement. The line MUST
  begin with `CALL m '` and the line MUST NOT contain a `;`
  separator that splits it into multiple clauses.
- The first argument after `m` MUST be one of the four
  literal verb strings.
- The trailing argument MUST NOT be the bare token `n`. If
  three arguments are passed (kind, arg1, arg2), the wrapper
  drops any extras silently — but FR-014 forbids passing
  extras.

---

### `Koan-local m: wrapper`

A label-based subroutine at the foot of every koan and solution
file. It is the indirection layer between the koan body and
`lib/meditation.rexx`. Defined without `PROCEDURE`, so it shares
the caller's variable pool.

**Pre-change body**:

```rexx
m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, '<koan_path>', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
```

**Post-change body**:

```rexx
m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, '<koan_path>', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
```

**Fields**:

| Field | Type | Description |
|---|---|---|
| `signature` | tuple (kind, arg1, arg2) | The wrapper's PARSE ARG positional list. Pre-change: 4 args (`kind, arg1, arg2, num`). Post-change: 3 args. |
| `koan_path` | string literal | The relative path of the file the wrapper is in. Hard-coded as a single-quoted REXX string literal. Examples: `'koans/00_about_asserts.rexx'`, `'solutions/00_about_asserts.rexx'`, `'koans/03_about_expressions.rexx'`. |
| `body_line_count` | int | Pre-change: 4 lines (PARSE ARG, CALL, IF, RETURN). Post-change: 5 lines (PARSE ARG, n increment, CALL, IF, RETURN). Net per-file delta: +1 line in the wrapper, offset elsewhere by collapsed assertion-line bookkeeping. |

**Relationships**:

- One wrapper per file, exactly. (12 files × 1 wrapper = 12
  wrappers in scope.)
- The wrapper reads and writes the file's `n` directly.
- The wrapper invokes `lib/meditation.rexx` once per call.
  The dispatcher is shared across all wrappers; the wrapper
  is the per-file dispatch point.

**Cardinality**: 12 wrappers — one per Stage I corpus file.

**Invariants**:

- Post-change, every wrapper conforms to the post-change body
  shape exactly (FR-003).
- Pre-change, every wrapper conforms to the pre-change body
  shape exactly (assumed; verified by tasks.md pre-grep).
- `koan_path` matches the file's own relative path. A koan
  cannot be moved to a different path without also updating
  the literal — out of scope here, since no files move.

**Validation rules**:

- The wrapper appears below `EXIT 0` and is the last
  subroutine in the file.
- The `koan_path` literal in the wrapper's third CALL
  argument MUST match `<directory>/<basename>` of the file
  it is in (e.g., koan 02 has `'koans/02_about_variables.rexx'`,
  not `'02_about_variables.rexx'` and not the absolute path).

---

### `Assertion ordinal n`

A REXX symbol holding the 1-based count of completed assertion
deliveries within a single koan-or-solution execution. Sourced
by the `n = 0` initializer at the top of the file; advanced by
the wrapper before each delegation.

**Fields**:

| Field | Type | Description |
|---|---|---|
| `name` | string | Always `n`. The name is reserved by project convention for the assertion-counter; PLAN.md §8 records the convention. |
| `value` | non-negative integer | Starts at 0; monotonically incremented by 1 per `m:` invocation (post-change); never reset within a single execution. |
| `lifecycle_states` | enum {`uninitialized`, `zero`, `positive`} | Sequence: uninitialized (file load) → zero (after `n = 0` line) → positive (after first `m:` call). State never returns to zero or uninitialized within one execution. |

**Relationships**:

- `n` is the variable the wrapper's `n = n + 1` line
  reads-and-writes.
- `n` is the value the wrapper passes as the fifth argument
  to `lib/meditation.rexx`; the dispatcher uses it to phrase
  ordinal failure messages ("the 5th assertion of …").
- `n` does not appear on assertion lines post-change; the
  pilgrim sees `n` only on the `n = 0` initializer at the
  top of the file.

**Cardinality**: One `n` per file × 12 files = 12 distinct
counter scopes. Each is independent — the koan and the
solution have distinct `n` values, since they are distinct
program executions.

**Invariants**:

- After the `n = 0` initializer, `n` is integer 0.
- After the K-th call to `m:`, `n` is integer K (post-change;
  pre-change has identical semantics, just sourced
  differently).
- The pilgrim does not assign `n` outside the initializer.
  (Edge case: a pilgrim who writes `n = 5` mid-koan breaks
  the invariant; treated as user error per the spec's Edge
  Cases.)

**Validation rules**:

- The single `n = 0` line at the top of each file is the
  only counter assignment visible to the pilgrim (FR-004).
- Inside the wrapper, `n = n + 1` is the only mutation; the
  external CALL passes `n` by value (REXX has no
  pass-by-reference).

---

### `Stage I corpus`

The set of 12 source files that comprise the entire scope of
M2.5.

**Members** (12 total):

```
koans/00_about_asserts.rexx
koans/01_about_strings.rexx
koans/02_about_variables.rexx
koans/03_about_expressions.rexx
koans/04_about_clauses.rexx
koans/05_about_say.rexx
solutions/00_about_asserts.rexx
solutions/01_about_strings.rexx
solutions/02_about_variables.rexx
solutions/03_about_expressions.rexx
solutions/04_about_clauses.rexx
solutions/05_about_say.rexx
```

**File-level structure** (uniform across members):

| Position | Element | Edited by M2.5? |
|---|---|---|
| Top-of-file | File header comment block (purpose, station, citations) | NO (FR-009) |
| (then) | `n = 0` initializer | NO — kept as-is (FR-004) |
| (then) | Concept block N (comment + assertion line(s)) × M | Assertion lines edited (FR-001, FR-002); concept comment blocks unchanged (FR-009) |
| (then) | `EXIT 0` | NO |
| Bottom-of-file | `m:` wrapper | YES — body rewritten per FR-003 |

**Relationships**:

- Each koan has a matching solution; the pair shares the same
  numeric prefix and `_about_<topic>.rexx` basename.
- Every concept block within a file is independent of others;
  there is no cross-block state beyond the shared `n`.
- The Stage I corpus is the entire scope of M2.5; Stage II–VI
  files (06+) do not exist yet and are governed forward by
  the §8 PLAN.md style bullet.

**Cardinality**: 12 files. 6 koans + 6 solutions = 6 koan-
solution pairs.

**Invariants**:

- Pre-change: every member uses the legacy
  `n = n + 1; ... , n` shape uniformly across all assertion
  lines and a 4-arg `m:` wrapper at the foot. Verified by
  tasks.md pre-grep before edits begin.
- Post-change: every member uses the cleaned shape uniformly
  (FR-001, FR-002, FR-003).
- Solution-koan parity: post-change, the diff between any
  koan and its matching solution shows only FILL_ME_IN ↔
  value substitutions on documented blank positions. (SC-009.)

**Validation rules**:

- The set is closed: no new file is added (FR-016); no file
  is removed; no file is renamed; no file moves between
  `koans/` and `solutions/`.
- File ordering and line counts above the assertion lines
  are preserved (so that pre-change line numbers for
  assertion lines match post-change line numbers for the
  same assertion lines — see SC-010).

---

## Relationships Summary (compile-time entity graph)

```
Stage I corpus (12 files)
    ├─ 6 koans
    └─ 6 solutions
         each file contains:
              1× `n = 0` initializer
              N× Assertion line  ────► invokes ────► Koan-local m: wrapper
                                                          │
                                                          ├─ reads/writes Assertion ordinal n
                                                          └─ invokes ────► lib/meditation.rexx (READ-ONLY)
              1× m: wrapper (defined here)
```

The data model has no runtime data flow beyond a single
invocation of one assertion line (which becomes one
invocation of `m:`, which becomes one invocation of
`lib/meditation.rexx`, which returns 0/1/2). The "model" is
source-textual: the entities exist as REXX clauses in files,
and M2.5 transforms their textual shape while preserving
their runtime semantics.
