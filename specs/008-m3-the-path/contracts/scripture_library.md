# Contract: Scripture Library (`lib/scripture.rexx`) — M3

**Effective at**: M3 merge (`008-m3-the-path` → `main`).
**Invocation**: `CALL 'lib/scripture.rexx' 'fetch', key`

## Purpose

`lib/scripture.rexx` is a keyed lookup library carrying the
seven Bathonian design-principle texts named in PLAN §9. The
runner consults it on a scripture-bound koan failure and emits
the principle text + citation as the FR-012 two-line block.

The library is invoked via REXX external `CALL` from
`lib/pilgrimage.rexx` (and by no other code in the repository
as of M3). It is a pure data-table dispatcher; it has no side
effects on stdout, no interaction with stdin, and no global
state beyond its own local variables.

## Invocation

```rexx
CALL 'lib/scripture.rexx' 'fetch', key
RESULT  /* contains the lookup result */
```

| Argument | Position | Type | Notes |
|---|---|---|---|
| Verb | 1 | string literal | MUST be `'fetch'` (case-sensitive). M3 defines no other verbs; future milestones MAY add verbs. |
| `key` | 2 | string | A scripture key. MUST match `[a-z_]+` if known; otherwise treated as unknown (returns empty string). |

## Return value

`RESULT` is set to one of:

| Result shape | Meaning |
|---|---|
| `<principle> '09'x <citation>` | Known key. `<principle>` is the principle text (no quotes, no surrounding whitespace). `'09'x` is a single literal TAB byte separator. `<citation>` is the canonical-form Cowlishaw citation (e.g., `Cowlishaw §1.4, p. 7`). |
| empty string (`''`) | Unknown key. The runner emits no scripture block for this failure. |

The TAB-separated single-string return mirrors the
`lib/stations.rexx` extract idiom and minimizes external-CALL
boundary crossings (one CALL per failure rather than two).

## Required keys (M3)

The library MUST define an entry for each of the following keys
(per FR-010 and PLAN §9). Each entry's principle text is at
most 150 characters (per spec Assumptions). Each entry's
citation MUST resolve against `docs/cowlishaw_index.md` per
Constitution Principle III.

| Key | Working principle text | Working citation |
|---|---|---|
| `humans_not_machines` | REXX is designed for people, not for ease of implementation. | Cowlishaw §1.4, p. 7 |
| `least_astonishment` | A program should behave the way its reader expects. | Cowlishaw §1.4, p. 7 |
| `everything_is_string` | Every value in REXX is a string of characters; the language has no other data type. | Cowlishaw §1.3, p. 5 |
| `read_aloud` | A clause should read naturally when spoken; clarity for the reader outweighs concision. | Cowlishaw §1.4, p. 7 |
| `consistency` | The same construct should mean the same thing wherever it appears. | Cowlishaw §1.4, p. 7 |
| `whitespace_matters_just_enough` | Concatenation by abuttal binds tighter than concatenation by blank; whitespace is a real operator, used sparingly. | Cowlishaw §2.3, p. 25 |
| `numbers_are_strings_too` | Arithmetic produces strings of digits formatted under the prevailing NUMERIC settings; precision is configurable, not magic. | Cowlishaw §2.11, p. 137 |

Final principle text and final citations are pinned at
implementation time against the index. Refinements during
implementation are allowed *if* the citation continues to
resolve; the table above is the working baseline.

## File-format expectations

`lib/scripture.rexx` MUST be a single REXX program that:

1. Begins with a comment block naming the file path, the
   contract reference (`Contract: specs/008-m3-the-path/contracts/scripture_library.md.`),
   the seven required keys, and a Constitution Principle II
   note ("Regina built-ins only.").
2. Parses the verb and key from `ARG`:
   ```rexx
   PARSE ARG verb, key
   ```
3. Dispatches via `SELECT`/`WHEN`:
   ```rexx
   SELECT
     WHEN verb = 'fetch' THEN RETURN fetch(key)
     OTHERWISE RETURN ''
   END
   ```
4. Defines a `fetch:` procedure that does a `SELECT`/`WHEN`
   over the seven keys, returning the
   `<principle> '09'x <citation>` shape per known key and the
   empty string otherwise.
5. Uses **only** Regina built-ins. No external libraries,
   external CALLs, or file I/O.
6. Has no top-level side effects (no `SAY`, no
   `LINEOUT`/`CHAROUT`, no `ADDRESS`).

## Positive case table

For every required key, the dispatcher returns
`<principle> '09'x <citation>` per the table above.

Spot-check (pseudocode — actual probe lives in
`quickstart.md`):

```rexx
CALL 'lib/scripture.rexx' 'fetch', 'least_astonishment'
PARSE VAR RESULT principle '09'x citation
SAY principle    /* "A program should behave the way its reader expects." */
SAY citation     /* "Cowlishaw §1.4, p. 7" */
```

## Negative case table

| Input | Result | Runner behavior |
|---|---|---|
| Unknown key, e.g., `'fetch', 'unknown_key'` | `''` (empty string) | Runner emits no FR-012 block. The pilgrim sees the standard meditation diagnostic only. Forward-compatible: future milestones may add keys without changing the runner. |
| Empty key, e.g., `'fetch', ''` | `''` | Same as unknown key. |
| Unknown verb, e.g., `'principle', 'least_astonishment'` | `''` | Same. The runner only ever issues `'fetch'`; an unknown-verb path would only be reached by a contributor extension. |
| Missing key argument, e.g., `'fetch'` (one positional arg) | `''` | `PARSE ARG` binds `key` to the empty string. Same as empty-key case. |

## Cross-platform parity

`lib/scripture.rexx` emits ASCII text only. The §-prefix in
citation strings is byte-equivalent UTF-8 on both Regina
runners. No platform-divergent behavior expected.

## Compatibility

The library's external interface — `'fetch', key` returning
`<principle> '09'x <citation>` or empty — is the contract from
M3 onward. M4–M7 may:
- Add new keys to the dispatcher.
- Refine existing principle text (pull-request, not amendment;
  Constitution Principle III's citation resolution must continue
  to hold).

Not without an amendment to this contract:
- Change the return shape (e.g., a different separator, a
  multi-line return, a stem variable).
- Add or remove verbs.
- Make the library stateful (introduce file I/O, persistent
  variables).

## Constitution Principle II compliance

The library uses only the following Regina constructs:
`PARSE ARG`, `SELECT`/`WHEN`/`OTHERWISE`/`END`, `RETURN`,
string-literal data, the procedure-definition idiom
(`fetch: PROCEDURE`), and the implicit `RESULT` return. No
external CALLs, no file I/O, no third-party libraries.
