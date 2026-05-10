# Contract: Assertion-Line Shape and Koan-Local `m:` Wrapper

This document is the post-M2.5 contract for the assertion-line
shape and the koan-local `m:` wrapper body in every Stage I
koan and solution file. It documents both the canonical
post-change shape (the only shape permitted on `main` after M2.5
merges) and the forbidden legacy shape (the pattern M2.5 removes
and that M3+ koans must not reintroduce).

The contract's authority is PLAN.md §8 (the style bullet
"Assertion lines stay single-statement", codified at commit
`9a5de4a`) and PLAN.md §M2.5 (the milestone definition,
codified at the same commit). This contract elaborates the
syntactic detail; PLAN.md resolves judgment calls.

## Scope

This contract governs:

- Every assertion line in `koans/*.rexx` and `solutions/*.rexx`.
- Every koan-local `m:` wrapper in `koans/*.rexx` and
  `solutions/*.rexx`.
- The single `n = 0` initializer at the top of every koan and
  solution.

This contract does NOT govern:

- The dispatcher `lib/meditation.rexx`. Its external interface
  is documented in its own header docstring; M2.5 does not
  change it.
- The pilgrimage runner `lib/pilgrimage.rexx`, the station
  display `lib/stations.rexx`, or any `bin/*` script. Out of
  scope per spec FR-005 / FR-006.
- Teaching prose, citations, Station: directives, file
  headers. Out of scope per spec FR-009 (byte-identity).

## The Canonical Assertion-Line Shape

An assertion line is a single REXX clause that invokes the
koan-local `m:` wrapper with three positional arguments.

**Canonical syntactic shape**:

```
CALL m '<verb>', <arg1>, <arg2>
```

where:

- `<verb>` is exactly one of the four verb literals: `eq`,
  `neq`, `true`, `datatype`. Single-quoted REXX string
  literal; uppercase variants are not used.
- `<arg1>` is a REXX expression. May be a numeric literal
  (`4`), a string literal (`'pilgrim'`), a parenthesized
  comparison (`(1 = 1)`, `(5 > 3)`), or the deliberate
  blank symbol `FILL_ME_IN` / `FILL_ME_IN_<n>`.
- `<arg2>` is a REXX expression. For `eq`/`neq` it is the
  actual value (typically the REXX expression the koan is
  teaching). For `true` it is conventionally the empty
  string `''` (unused by the dispatcher). For `datatype`
  it is the single-character REXX type code as a string
  literal (e.g., `'N'`, `'A'`, `'W'`).

**Examples** (canonical, accepted):

```rexx
CALL m 'eq', 4, 2 + 2
CALL m 'eq', 'pilgrim', 'pilgrim'
CALL m 'neq', 'pilgrim', 'wanderer'
CALL m 'true', (1 = 1), ''
CALL m 'true', (5 > 3), ''
CALL m 'datatype', 5, 'N'
CALL m 'datatype', 'pilgrim', 'A'
CALL m 'eq', FILL_ME_IN, 2 + 2
CALL m 'datatype', 5, FILL_ME_IN
```

**Forbidden patterns** (rejected):

```rexx
n = n + 1; CALL m 'eq', 4, 2 + 2, n           # legacy: counter prefix + trailing n arg
CALL m 'eq', 4, 2 + 2, n                       # legacy: trailing n arg only
n = n + 1; CALL m 'eq', 4, 2 + 2               # legacy: counter prefix only
CALL m 'eq', 4, 2 + 2, n; SAY 'aside'          # multi-clause line splitting m: invocation
```

The mechanical guards on the forbidden patterns are FR-013
(zero matches for `n = n + 1;\s*CALL m`) and FR-014 (zero
`CALL m` lines passing trailing `n`).

## The Canonical `m:` Wrapper Body

Every koan and solution file ends with a `m:` label-based
subroutine that takes three positional arguments, increments
`n` internally, and delegates to the dispatcher.

**Canonical body** (post-M2.5):

```rexx
m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, '<koan_path>', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
```

where `<koan_path>` is the file's own relative path as a
single-quoted REXX string literal (e.g., `'koans/00_about_asserts.rexx'`
in `koans/00_about_asserts.rexx`, `'solutions/03_about_expressions.rexx'`
in `solutions/03_about_expressions.rexx`).

**Required properties**:

- The wrapper is declared without `PROCEDURE`. It shares the
  caller's variable pool, which is how `n` is read-and-written
  directly.
- The signature has exactly three positional arguments
  (`kind, arg1, arg2`). Adding a fourth argument is the
  legacy shape and is forbidden.
- The `n = n + 1` increment immediately follows `PARSE ARG`
  and precedes the external CALL.
- The third argument to the external CALL is a literal
  string matching the file's own relative path.
- The wrapper does not call any other label or function
  between the `n = n + 1` line and the external CALL —
  doing so would perturb `SIGL` and break the
  "Damaged at: …, line N" diagnostic's line-number
  fidelity.
- The wrapper's behavior on a non-zero return code from
  the dispatcher is `EXIT RESULT` (propagates the exit
  code to the runner). The wrapper's behavior on a zero
  return code is `RETURN` (drops back to the caller).

**Forbidden wrapper shapes**:

```rexx
# Legacy (4-arg, n on caller's side):
m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, '<path>', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN

# Forbidden — n is now a wrapper-internal concern, not a parameter.
```

```rexx
# Forbidden — wrapper introduces PROCEDURE EXPOSE (loses scope share):
m: PROCEDURE EXPOSE n
   PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' ...

# Acceptable in raw REXX, but rejected here: PROCEDURE adds noise
# without benefit, since the no-PROCEDURE form already works.
```

```rexx
# Forbidden — uses PARSE SOURCE for the path:
m: PARSE ARG kind, arg1, arg2
   n = n + 1
   PARSE SOURCE . . my_path
   CALL 'lib/meditation.rexx' kind, arg1, arg2, my_path, n, SIGL
   ...

# Rejected per research.md §4: PARSE SOURCE returns
# platform-variable strings and would break runner stdout
# fixture byte-identity.
```

## The Top-of-File `n = 0` Initializer

Every koan and solution file MUST contain a single `n = 0`
clause at the top of the file, immediately above the first
concept block. The clause:

- Is the only counter assignment visible to the pilgrim
  (FR-004).
- Initializes `n` to integer 0 before any assertion can
  execute.
- Is necessary to prevent `NOVALUE` errors when the wrapper
  evaluates `n + 1` on the first call.

**Canonical position**:

```rexx
/* file header comment (purpose, station, top-level citation) */

n = 0

/* Concept: equality.
 * (teaching prose...)
 * Cowlishaw §..., p. ...
 */
CALL m 'eq', ...
```

The blank line above and below `n = 0` is conventional but
not required. The `n = 0` MUST be a top-level clause (not
inside a comment, not inside any control structure).

## Positive Case Table

The following lines conform to this contract:

| Line (verbatim) | Why it conforms |
|---|---|
| `CALL m 'eq', 4, 2 + 2` | 3 args, no n suffix, valid verb |
| `CALL m 'eq', 'pilgrim', 'pilgrim'` | 3 args, string-literal args |
| `CALL m 'neq', 'pilgrim', 'wanderer'` | 3 args, neq verb |
| `CALL m 'true', (1 = 1), ''` | 3 args, true verb, conventional empty arg2 |
| `CALL m 'datatype', 5, 'N'` | 3 args, datatype verb, type-code arg2 |
| `CALL m 'eq', FILL_ME_IN, 2 + 2` | 3 args, deliberate blank arg1 |
| `n = 0` (top of file) | Required initializer, top-level position |
| `m: PARSE ARG kind, arg1, arg2` (wrapper line 1) | 3-arg signature |
| `   n = n + 1` (wrapper line 2) | Internal counter increment |

## Negative Case Table

The following lines violate this contract:

| Line (verbatim) | Reason rejected |
|---|---|
| `n = n + 1; CALL m 'eq', 4, 2 + 2, n` | Legacy shape: counter prefix + trailing n arg (FR-013, FR-014) |
| `CALL m 'eq', 4, 2 + 2, n` | Trailing n arg (FR-014) |
| `n = n + 1; CALL m 'eq', 4, 2 + 2` | Counter prefix (FR-013) |
| `CALL m 'eq', 4, 2 + 2, n; SAY 'aside'` | Multi-clause line splits m: invocation |
| `CALL m 'EQ', 4, 2 + 2` | Uppercase verb literal — verbs are lowercase |
| `CALL m 'unknown', 4, 2 + 2` | Verb not in the four-verb set; dispatcher would emit "unknown assertion kind" |
| `m: PARSE ARG kind, arg1, arg2, num` (wrapper line 1) | 4-arg legacy signature (FR-003) |
| `m: PROCEDURE EXPOSE n` (wrapper line 1) | Adds PROCEDURE; loses scope share — rejected per contract |
| `n = 5` (mid-file, non-initializer position) | Counter mutation outside the initializer or wrapper |
| (no `n = 0` at top of file) | Missing required initializer (FR-004) |

## Cross-Platform Parity

The contract uses only Regina REXX language features that have
identical semantics on the project's two CI platforms (macOS
Homebrew Regina, Ubuntu apt Regina):

- `CALL <label>` and label-based subroutines without
  `PROCEDURE`.
- `PARSE ARG` for positional argument extraction.
- Variable assignment and arithmetic (`n = n + 1`).
- `SIGL` automatic variable, set at label-call sites.
- `CALL 'lib/meditation.rexx'` external-program invocation
  (string-quoted name).
- `IF ... THEN EXIT RESULT` and `RETURN`.

No platform-divergent feature is exercised. The runner stdout
fixture (`tests/fixtures/runner_stdout.txt`) is the binding
cross-platform parity check; FR-007 enforces byte-identity
pre/post.

## What Carries Forward Unchanged

This contract specifies what M2.5 changes; everything else in
the in-scope files is unchanged. Specifically:

- The file header comment (purpose, station, top-level
  citation) is byte-identical pre/post.
- Every concept comment block (heading, prose, citation) is
  byte-identical pre/post.
- The `Station: <text>` directive is byte-identical pre/post.
- Every Cowlishaw citation is byte-identical pre/post.
- The `EXIT 0` line is byte-identical pre/post.
- The wrapper's third argument (the per-file path literal)
  is unchanged.
- The wrapper's invocation of `lib/meditation.rexx` and its
  exit handling (`IF RESULT \= 0 THEN EXIT RESULT; RETURN`)
  are unchanged.

The cleanup is surgical: assertion lines and the wrapper's
parse-args + counter-source. Nothing else.

## Forward Requirement

From M3 onward, every newly authored koan and matching solution
MUST conform to this contract from inception. Authoring a new
koan with the legacy `n = n + 1; ... , n` pattern is a
review-blocker. PLAN.md §8 records the rule; reviewers enforce
it.

A successor feature MAY add a mechanical lint check (e.g., a
zero-match grep on `n = n + 1;\s*CALL m`) if contributor
regression occurs. M2.5's spec defers automation explicitly;
the §8 style bullet plus PR review is the enforcement plane
today.
