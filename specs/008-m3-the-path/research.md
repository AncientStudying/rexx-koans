# Research — M3 — The Path

**Feature**: `008-m3-the-path` | **Date**: 2026-05-10 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

Phase 0 research for M3. The spec's Clarifications session
2026-05-10 (Q1: text shape; Q2: directive scope; Q3: benediction
wording) resolved the substantive design questions before
planning began. Research below pins the mechanical specification
work that planning's Phase 1 contracts depend on.

## §1 — Runner-side scripture-scan algorithm

**Decision**: linear backward scan from `line N − 1` toward line
1, halting at the first event encountered. Two events are
recognized:

| Event | Detection | Action |
|---|---|---|
| `Scripture: <key>` directive line | The line, after stripping leading whitespace and a leading `*` plus optional whitespace, begins with `Scripture: ` (literal, case-sensitive) and the rest matches `[a-z_]+`. | Halt scan. Bind to the captured key. Look up in `lib/scripture.rexx`. Emit FR-012 two-line block. |
| Teaching-block boundary | The line, after stripping leading whitespace, begins with `/*`. | Halt scan. No binding. Emit no scripture text. |
| Line 1 reached without either | n/a | No binding. Emit no scripture text. |

**Rationale**: The scope rule from FR-024 (block-scoped) maps
to a backward walk because the runner knows only the failed
line N (from the `Damaged at: <file>, line N` diagnostic
emitted by `lib/meditation.rexx`). Walking backward, the *first*
event that closes the scope determines the result: a
`Scripture:` directive in the failed test's teaching block (or
in any earlier teaching block whose scope extends through to
line N because no intervening `/*` re-opens) means the failed
test is bound; an intervening `/*` (a new teaching block
starting before the failed line) means a fresh teaching block
opened without a `Scripture:` directive, so the failed test is
in an unbound block.

**Alternatives considered**:
- Forward scan from line 1 to N, tracking the most recent
  `Scripture:` directive and resetting at each `/*`. Equivalent
  result; more lines walked on average; no advantage.
- Whole-file pre-scan at runner startup, building a per-koan
  `(line range) → key` table. Premature optimization; the failure
  path runs once per pilgrim invocation and the per-koan source
  is small (≤200 lines for the largest M3 koan).
- Recursive teaching-block boundary detection (matching `/* */`
  pairs). Unnecessary — REXX comments don't nest in practice
  and the koan idiom never has nested `/* */` blocks.

**Performance**: O(D) where D is the source-line distance from
the failed assertion to either a `Scripture:` directive or a
`/*` line, whichever comes first. For the koan shapes M3
produces, D ≤ 30 lines and the scan is sub-millisecond.

**Implementation sketch** (in `lib/pilgrimage.rexx`):

```rexx
scripture_for_failure: PROCEDURE
  PARSE ARG koan_path, fail_line
  /* Read the koan's lines into a stem. */
  CALL load_lines koan_path
  /* Walk backward from fail_line - 1. */
  DO i = fail_line - 1 TO 1 BY -1
    line = STRIP(lines.i)
    /* Strip leading '*' if present (continuation comment line). */
    IF LEFT(line, 1) = '*' THEN line = STRIP(SUBSTR(line, 2))
    IF LEFT(line, 11) = 'Scripture: ' THEN DO
      key = STRIP(SUBSTR(line, 12))
      RETURN key
    END
    IF LEFT(line, 2) = '/*' THEN RETURN ''
  END
  RETURN ''
```

The detail "strip leading `*`" matches the existing comment-
continuation idiom (`* Concept: ...`, `* Cowlishaw §X.Y, p. NN`)
that `lib/stations.rexx`'s `extract_subtitle` already handles.

## §2 — `lib/scripture.rexx` dispatch shape

**Decision**: one-verb dispatcher mirroring `lib/stations.rexx`.

**Invocation**:
```
CALL 'lib/scripture.rexx' 'fetch', key
```
Returns (in `RESULT`) a single string of the form
`<principle text>` `'09'x` `<citation>` (TAB-separated). The
runner splits on `'09'x` and emits the FR-012 block.

**Unknown key**: returns the empty string. The runner treats
empty as "no scripture" and emits no block (covers FR-024's
contributor-error edge case where a `Scripture: <key>` directive
names a key not present in the library).

**Library content**: seven keys per PLAN §9. Working principle
text and citation per key (refinable during implementation, but
this draft satisfies FR-010 and the FR-012 emission shape):

| Key | Principle text (≤150 chars) | Citation |
|---|---|---|
| `humans_not_machines` | REXX is designed for people, not for ease of implementation. | Cowlishaw §1.4, p. 7 |
| `least_astonishment` | A program should behave the way its reader expects. | Cowlishaw §1.4, p. 7 |
| `everything_is_string` | Every value in REXX is a string of characters; the language has no other data type. | Cowlishaw §1.3, p. 5 |
| `read_aloud` | A clause should read naturally when spoken; clarity for the reader outweighs concision. | Cowlishaw §1.4, p. 7 |
| `consistency` | The same construct should mean the same thing wherever it appears. | Cowlishaw §1.4, p. 7 |
| `whitespace_matters_just_enough` | Concatenation by abuttal binds tighter than concatenation by blank; whitespace is a real operator, used sparingly. | Cowlishaw §2.3, p. 25 |
| `numbers_are_strings_too` | Arithmetic produces strings of digits formatted under the prevailing NUMERIC settings; precision is configurable, not magic. | Cowlishaw §2.11, p. 137 |

**Citation rows confirmed against the index**:
- §1.3 (Fundamental Language Concepts) is on p. 5; rows exist at
  `docs/cowlishaw_index.md:39`.
- §1.4 (Design Principles) is on p. 7; rows exist at
  `docs/cowlishaw_index.md:45`.
- §2.3 (Expressions and Operators) Concatenation is at
  `docs/cowlishaw_index.md:137` with `**Page:** 25`.
- §2.11 (Numbers and Arithmetic — exact title verified during
  implementation) — verify row at writing time.

**Citation hygiene**: every scripture's citation MUST resolve
under M2.4's lint join (see §5 of plan.md). The
`lib/scripture.rexx` library carries citations in its data
table; if `bin/lint_citations` is later extended to scan
`lib/*.rexx` for citations, those citations must already pass.
For M3, lint scans only `koans/` and `solutions/` per the M2.4
contract — `lib/scripture.rexx`'s citations are reviewed
manually during implementation against the index.

**Alternatives considered**:
- Two-verb dispatcher (`'principle', key` returns just the text;
  `'citation', key` returns just the citation). Marginally
  cleaner, twice the call overhead. The TAB-separated single-
  call shape mirrors `lib/stations.rexx`'s extract pattern and
  avoids two crossings of the script boundary.
- Stem-variable export from `lib/scripture.rexx` to the runner.
  Forbidden by the M1 ADR-001 finding that external `CALL` does
  not share variable scope.
- Embedded scripture data in `lib/pilgrimage.rexx`. Couples the
  runner to scripture content; violates the separation PLAN §9
  asks for.

## §3 — Runner-smoke fixture regeneration recipe

**Decision**: regenerate from the fully-solved walk after all 18
koans are in place.

**Recipe** (also surfaced in `quickstart.md`):

```sh
# In a clean checkout of the feature branch (or a temp tree):
for n in 06 07 08 09 10 11 12 13 14 15 16 17; do
  cp solutions/${n}_about_*.rexx koans/${n}_about_*.rexx.solved
done
# Swap koan files for solution files atomically:
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17; do
  cp solutions/${n}_about_*.rexx koans/${n}_about_*.rexx
done
# Generate fixture:
regina lib/pilgrimage.rexx > tests/fixtures/runner_stdout.txt
# Reset koan tree:
git checkout -- koans/
```

**Expected fixture shape** (post-M3, eighteen-row walk):

```
THE PATH OF REXX

  [  ok  ] 00 about_asserts            The First Truths
  [  ok  ] 01 about_strings            Of the Word Made String
  [  ok  ] 02 about_variables          The Naming of Things
  [  ok  ] 03 about_expressions        Of Operators and Their Powers
  [  ok  ] 04 about_clauses            The Shape of an Instruction
  [  ok  ] 05 about_say                The Pilgrim Speaks
  [  ok  ] 06 about_if                 At the Branch of the Road
  [  ok  ] 07 about_select             Of Many Ways
  [  ok  ] 08 about_do_loops           The Returning of the Path
  [  ok  ] 09 about_iterate_leave      Of Skipping and Leaving
  [  ok  ] 10 about_signal             When the Path Bends
  [  ok  ] 11 about_interpret          What is Spoken Becomes Done
  [  ok  ] 12 about_string_functions   Of Letters and Their Manipulation
  [  ok  ] 13 about_word_functions     Of Words and Their Counting
  [  ok  ] 14 about_arithmetic_functions  Of Numbers and Their Shape
  [  ok  ] 15 about_conversion_functions  Between One Form and Another
  [  ok  ] 16 about_bit_functions      Down to the Bits
  [  ok  ] 17 about_misc_functions     Of Time and Chance

  Stations walked: 18 of 18.

  The pilgrim has walked the foundation, the path, and the tools. The path opens further.
```

**Note on column widths**: `lib/stations.rexx`'s `render_list`
computes `topic_col = max_topic_width + 2` from the longest
topic name in the manifest. The longest M3 topic is
`about_arithmetic_functions` (26 chars) and `about_conversion_functions`
(also 26). `max_topic_width = 26` → `topic_col = 28`. M2's
fixture used `max_topic_width = 14` (longest Stage I topic) →
`topic_col = 16`. The post-M3 fixture's column alignment
naturally widens to 28; this is automatic from
`lib/stations.rexx`'s existing logic — no edit needed there.

**Determinism**: the fully-solved walk emits no scripture
(FR-013); fixture content is stable across runs.

## §4 — Station subtitles for koans 09–17

**Decision**: working list below; refinable during implementation
with reviewer pushback. PLAN §11 fixes 06–08 by example.

| Koan | Subtitle | Rationale |
|---|---|---|
| 06 about_if | At the Branch of the Road | PLAN §11 example. The path forks. |
| 07 about_select | Of Many Ways | PLAN §11 example. SELECT is a multi-way branch. |
| 08 about_do_loops | The Returning of the Path | PLAN §11 example. The pilgrim circles back. |
| 09 about_iterate_leave | Of Skipping and Leaving | ITERATE skips ahead; LEAVE departs the loop. |
| 10 about_signal | When the Path Bends | SIGNAL transfers control non-locally — the path bends. |
| 11 about_interpret | What is Spoken Becomes Done | INTERPRET evaluates a string; speech becomes execution. |
| 12 about_string_functions | Of Letters and Their Manipulation | The string built-ins handle individual characters. |
| 13 about_word_functions | Of Words and Their Counting | The word built-ins operate on space-delimited words. |
| 14 about_arithmetic_functions | Of Numbers and Their Shape | Arithmetic built-ins format numeric output. |
| 15 about_conversion_functions | Between One Form and Another | Conversions: dec↔hex, char↔hex, etc. |
| 16 about_bit_functions | Down to the Bits | BITAND/BITOR/BITXOR — the lowest level. |
| 17 about_misc_functions | Of Time and Chance | DATE/TIME/RANDOM — the world outside the koan's strict logic. |

Subtitles are unique across the manifest (FR-007). The
pilgrim-voice register matches PLAN §11's restraint: short,
plain, lightly metaphorical, never plot-bearing.

## §5 — Scripture-bound koan selection

**Decision**: three bindings, the floor per PLAN §10.

| Koan | Scripture key | Why this principle illuminates this koan |
|---|---|---|
| 07 about_select | `least_astonishment` | SELECT/WHEN/OTHERWISE behaves the way a reader of spoken English expects: "do this when X, that when Y, otherwise this third thing." The OTHERWISE-required-when-no-WHEN-matches rule is least-astonishment in action. A pilgrim who omits OTHERWISE and is then surprised by a SYNTAX error is the exact moment the principle illuminates. |
| 12 about_string_functions | `everything_is_string` | LENGTH, SUBSTR, POS, LEFT, RIGHT, COPIES, TRANSLATE all assume their argument is a string of characters — because in REXX every value is. The principle illuminates *why* the built-in family looks the way it does and why no separate "byte" or "char" types exist. |
| 14 about_arithmetic_functions | `numbers_are_strings_too` | ABS, MAX, MIN, TRUNC, FORMAT, SIGN return *strings* of digits formatted under the prevailing NUMERIC settings. The principle illuminates why FORMAT and TRUNC exist as separate functions rather than operators — number formatting is part of the value's *display*, and the value is always a string. |

The implementation MAY add a fourth or fifth binding if a
principle organically illuminates a koan during authoring (the
spec's Assumption permits up to seven). Candidates considered
and deferred:
- 11 about_interpret ↔ `humans_not_machines`. INTERPRET
  serves human flexibility (build code at runtime); strong
  match. Deferred because the failure mode (the pilgrim's
  fill is invalid REXX) is a SYNTAX condition that aborts the
  subprocess before any `Damaged at:` diagnostic — so the
  scripture-emission path is not reachable from the typical
  failure of this koan. A scripture binding here would not
  fire on the most common failure mode.
- 17 about_misc_functions ↔ `consistency`. DATATYPE returns
  0/1 like every comparative operator — same construct, same
  meaning. Plausible but the koan also covers DATE/TIME/
  RANDOM, where consistency is less central.

## §6 — Implementation ordering (Constitution Principle I)

**Decision**: infrastructure before scripture-bound curriculum.
Per-koan ordering preserves Solution-First.

**Macro ordering (commit-by-commit)**:

1. **Infrastructure phase**:
   - Commit A: add `lib/scripture.rexx` with the seven keys.
     UAT against a sandbox `CALL` invocation.
   - Commit B: extend `lib/pilgrimage.rexx` with
     `scripture_for_failure` + emission point. UAT: a Stage I
     koan with a deliberate wrong fill produces byte-identical
     output to pre-change (no scripture emitted because Stage I
     is unbound). The runner-smoke fixture for Stage I-only
     remains unchanged at this point because no Stage I koan
     binds.
2. **Stage II phase** (six commits, one per koan):
   - 06 about_if (no scripture binding) — solution + koan +
     manifest entry.
   - 07 about_select (binds `least_astonishment`).
   - 08 about_do_loops.
   - 09 about_iterate_leave.
   - 10 about_signal.
   - 11 about_interpret.
3. **Stage III phase** (six commits, one per koan):
   - 12 about_string_functions (binds `everything_is_string`).
   - 13 about_word_functions.
   - 14 about_arithmetic_functions (binds `numbers_are_strings_too`).
   - 15 about_conversion_functions.
   - 16 about_bit_functions.
   - 17 about_misc_functions.
4. **Fixture regeneration**:
   - Final commit: regenerate `tests/fixtures/runner_stdout.txt`
     from the fully-solved 18-station walk. This is the only
     step that requires every preceding commit to have landed.

**Per-koan ordering (within each koan commit)**: per Constitution
Principle I:
1. Draft the teaching comments + Cowlishaw citation(s) +
   (if scripture-bound) the `Scripture: <key>` directive.
2. Write the solution file. Run `regina solutions/NN_about_*.rexx`
   directly; confirm zero output (success path).
3. Derive the koan from the solution by replacing answers with
   `FILL_ME_IN`. Update the koan's `m:` wrapper's filename
   string from `solutions/...` to `koans/...`.
4. Run `bin/pilgrimage` with the manifest extended to include the
   new koan. Confirm the runner stops at the first blank with
   the expected diagnostic.
5. Re-apply the solution value (i.e., copy `solutions/NN…` over
   `koans/NN…`); confirm the runner advances. Reset.
6. For scripture-bound koans: introduce a deliberate wrong fill
   on the bound assertion; confirm the two-line Bathonian block
   appears between the meditation diagnostic and the station
   list. Revert.

The runner-smoke fixture is *not* regenerated during the per-
koan loop; the fixture would change with every koan added.
Regenerating once at the end (step 4 in the macro ordering)
captures the final state.

## §7 — Performance envelope

| Operation | Estimate |
|---|---|
| Per-koan subprocess spawn (`ADDRESS SYSTEM 'regina ...'`) | 30–80 ms on Regina + macOS / Linux. |
| Per-koan solution execution (~5 assertions) | 1–10 ms. |
| Eighteen stations green walk | <2 s total. |
| Runner-side scripture-scan on failure | <1 ms (≤30 lines). |
| `lib/scripture.rexx` dispatch (one `SELECT`/`WHEN` over 7 keys) | <1 ms. |
| `bin/verify_solutions` 18-of-18 | <2 s total. |
| `bin/lint_citations` 36 files | <1 s (M2.4 baseline scaled × 3). |

No performance work required. No caching, no incremental
parsing, no stdout buffering changes.

## §8 — Stage I non-modification verification recipe

**Mechanical guard for the Stage I read-only constraint**:

```sh
# All commands run from repo root, on the feature branch.

# 1. Stage I koans + solutions byte-identical to main:
git diff main -- koans/0[0-5]_*.rexx solutions/0[0-5]_*.rexx
# Expected: empty.

# 2. lib/meditation.rexx and lib/stations.rexx byte-identical:
git diff main -- lib/meditation.rexx lib/stations.rexx
# Expected: empty.

# 3. bin/* byte-identical:
git diff main -- bin/
# Expected: empty.

# 4. docs/cowlishaw_index.md byte-identical:
git diff main -- docs/cowlishaw_index.md
# Expected: empty.

# 5. tests/fixtures/runner_stdout.txt diff is exactly the
#    eighteen-row + new-benediction regeneration:
git diff main -- tests/fixtures/runner_stdout.txt
# Expected: removes 6-row fixture, adds 18-row fixture per §3.

# 6. lib/pilgrimage.rexx diff is the scripture-scan addition only:
git diff main -- lib/pilgrimage.rexx
# Expected: additive — scripture_for_failure procedure + emission
# point inside the existing failure branch. No edits to the
# subprocess-spawn loop or the manifest-validation logic.

# 7. lib/scripture.rexx is a new file:
git diff --stat main -- lib/scripture.rexx
# Expected: A (added).

# 8. M2.5 forward-style greps:
grep -rE 'n = n \+ 1; *CALL m' koans/ solutions/
grep -rE "CALL m '[a-z]+', [^,]+, [^,]+, n\b" koans/ solutions/
# Both expected: empty.
```

A CI guard for these checks is out of scope for M3 — they are
spec-level acceptance gates, run by reviewer at PR time, not
mechanical gates baked into `lint_citations`. (Adding a
mechanical M2.5-pattern lint is named in spec § Out of Scope.)

## Outputs

- `data-model.md` — entities and relationships (Phase 1).
- `contracts/runner.md` — supersedes M2 runner contract.
- `contracts/scripture_library.md` — new contract.
- `contracts/koan_directives.md` — new contract.
- `quickstart.md` — local verification recipe.
- `CLAUDE.md` agent context — repointed at this plan.

No NEEDS-CLARIFICATION remains.
