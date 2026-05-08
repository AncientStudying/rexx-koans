# Contract: Assertion Library (`lib/meditation.rexx`)

**Invocation**: `CALL 'lib/meditation.rexx' kind, arg1, arg2, koan_file, n, line`

Called from a koan via the koan-local `m:` wrapper (Decision 1, research.md).

## Arguments

| # | Name | Type | Description |
|---|---|---|---|
| 1 | `kind` | String | One of `'eq'`, `'neq'`, `'true'`, `'datatype'` |
| 2 | `arg1` | Value | Expected value (`eq`, `neq`); boolean condition (`'true'`); value to type-check (`datatype`) |
| 3 | `arg2` | Value | Actual value (`eq`, `neq`); ignored (`'true'`, pass `''`); REXX type code such as `'W'`, `'N'`, `'A'`, `'X'` (`datatype`) |
| 4 | `koan_file` | String | Path to the koan, e.g. `'koans/01_about_strings.rexx'` (or `'solutions/...'` from a solution) |
| 5 | `n` | Integer | The 1-based ordinal of this assertion within the koan |
| 6 | `line` | Integer | Source line of the assertion in the koan (caller's `SIGL`) |

## Return values

| RC | Meaning | Side effect |
|---|---|---|
| 0 | Assertion passed | No output |
| 1 | `fail_blank` — `arg1` or `arg2` (where applicable) equals literal `'FILL_ME_IN'` | Print blank diagnostic to stdout |
| 2 | `fail_mismatch` — kind-specific check failed; not a blank | Print kind-specific mismatch diagnostic to stdout |

## Per-kind semantics

### `'eq'` — `assert_equal`

Pass iff `arg1 = arg2` (REXX string comparison, with implicit numeric
coercion for numeric strings — this matches REXX's native `=`).

Mismatch diagnostic:

```
The <ordinal(n)> assertion of <koan_file> has damaged your karma. The pilgrim expected '<arg1>' but received '<arg2>'.
Damaged at: <koan_file>, line <line>.
```

### `'neq'` — `assert_not_equal`

Pass iff `arg1 \= arg2`.

Mismatch diagnostic:

```
The <ordinal(n)> assertion of <koan_file> has damaged your karma. The pilgrim expected a value other than '<arg1>' but received the same value.
Damaged at: <koan_file>, line <line>.
```

### `'true'` — `assert`

Pass iff `arg1` is truthy in REXX boolean semantics: equal to `1`. Any
other value (`0`, `'FILL_ME_IN'`, anything else) fails.

Mismatch diagnostic:

```
The <ordinal(n)> assertion of <koan_file> has damaged your karma. The pilgrim expected a true condition but received '<arg1>'.
Damaged at: <koan_file>, line <line>.
```

### `'datatype'` — `assert_datatype`

Pass iff `DATATYPE(arg1, arg2) = 1`. `arg2` is the standard REXX
DATATYPE type code (`W` whole number, `N` number, `A` alphanumeric,
`X` hex string, etc.).

Mismatch diagnostic:

```
The <ordinal(n)> assertion of <koan_file> has damaged your karma. The pilgrim expected '<arg1>' to be of REXX type '<arg2>' but it is not.
Damaged at: <koan_file>, line <line>.
```

## FILL_ME_IN detection (rc=1, all kinds)

Before the kind-specific check, the library tests:

- For `'eq'`, `'neq'`, `'datatype'`: `arg1 = 'FILL_ME_IN'` OR `arg2 = 'FILL_ME_IN'` → rc 1.
- For `'true'`: `arg1 = 'FILL_ME_IN'` → rc 1.

Diagnostic:

```
This koan awaits your contribution. Replace the FILL_ME_IN symbol with the value the pilgrim must learn.
Damaged at: <koan_file>, line <line>.
```

## Constraints

- MUST use only Regina built-ins (Constitution Principle II).
- MUST NOT print citations, timestamps, or temp paths (Decision 4).
- MUST keep diagnostics ASCII-only.
- The koan-side `m:` wrapper is responsible for `EXIT`'ing on non-zero RC; the library itself only `RETURN`s.
