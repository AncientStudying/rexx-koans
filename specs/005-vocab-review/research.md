# Phase 0 Research — M2.3

This document records the lookups and design choices made during
Phase 0 of `/speckit-plan` for M2.3.

## §1. Lookup discipline

The spec's FR-001 says every technical term in Stage I teaching
prose MUST appear in the relevant index row's `Vocabulary:` column
(or be explicitly framed as koan-framework vocabulary, per FR-002 /
FR-002a). Strict literal application of this rule would catch
common English connectives ("the", "is", "and") that obviously
shouldn't be subject to substitution. The pragmatic rule used to
build the substitution table in §2 below:

**A term is subject to substitution if and only if it *names* a
REXX construct in a subject/object identifier role (e.g., names an
operator family, a syntactic category, a value domain, a built-in
function, or a documented Cowlishaw concept). General English used
to *describe* a construct's behavior is unconstrained.**

Worked examples of the discipline:

- *"The = operator compares with numeric coercion."* — "operator"
  names a REXX construct → subject to lookup ("operator" is in
  §2.3 vocab; OK). "numeric coercion" is informal description →
  substitute to Cowlishaw's "normal comparison" (§2.3 Comparative
  vocab).
- *"Operands are converted to numbers as needed."* — "operands" is
  general English describing what the operator acts on; Cowlishaw's
  prose itself uses "operand" extensively (§2.3 Logical (Boolean)
  summary: *"take operands restricted to '0' or '1'"*). Not subject
  to substitution.
- *"Two values written next to each other"* — "values" is
  description, not a Cowlishaw construct name. But Cowlishaw §2.3
  uses "term" as the formal noun for an operand-position element.
  Substituting "values" → "terms" sharpens the prose to canonical
  vocabulary; the construct-naming rule applies.

The discipline produces a finite, traceable substitution set
rather than an open-ended editorial pass. It also keeps M2.3 from
silently sliding into M3+ content authoring (which would re-grow
the blast radius).

A term is NOT subject to substitution when:

1. It names a koan-framework construct (FR-002 carve-out): `eq`,
   `neq`, `true`, `datatype`, "assertion", `FILL_ME_IN`, "the
   runner", "the framework".
2. It is pilgrim voice (FR-012 carve-out): "the pilgrim", "the
   path", "the Bathonian", station taglines.
3. It is general English describing behavior, not naming a
   construct (per the worked examples above).

## §2. Substitution table (bulk vocabulary work)

The table lists every distinct substitution surfaced by walking
each Stage I koan + solution against the relevant index row. For
each substitution: the source string, the canonical Cowlishaw
replacement, the supporting index row, and the file(s) where the
source appears.

Substitutions that involve sentence restructuring (not a clean
find/replace) are not in this table — they live in §3 (koan 00
framework-vs-REXX layering) or §4 (koan 01 targeted re-label).

| # | Source string (verbatim) | Replacement | Index row | Files affected |
|---|---|---|---|---|
| 1 | `REXX has no separate character literal.` | `REXX has no separate character type.` | §2.1 — Characters and Encodings (vocab: character) | `koans/01` |
| 2 | `Concept: uninitialized symbols.` | `Concept: uninitialized variables.` | §2.5 (vocab: uninitialized variable) | `koans/02`, `solutions/02` |
| 3 | `the unbound symbol NEVER_SET` | `the uninitialized variable NEVER_SET` | §2.5 (vocab: uninitialized variable) | `koans/02` |
| 4 | `Quoted strings are case-sensitive` | `Literal strings are case-sensitive` | §2.2 — Literal strings (vocab: literal string) | `koans/02`, `solutions/02` |
| 5 | `arithmetic, comparison,` | `arithmetic, comparative,` | §2.3 — Comparative subsection title | `koans/03` |
| 6 | `Concept: comparison.` | `Concept: comparative operators.` | §2.3 — Comparative subsection title | `koans/03`, `solutions/03` |
| 7 | `compares with numeric coercion` | `performs a normal comparison` | §2.3 — Comparative (vocab: normal comparison) | `koans/03`, `solutions/03` |
| 8 | `is strict and compares the literal characters` | `is a strict comparison and compares strings character-by-character without padding` | §2.3 — Comparative (vocab: strict comparison) | `koans/03`, `solutions/03` |
| 9 | `& is AND, \| is OR, \ is NOT` | `& is And, \| is Inclusive or, \ is Logical not` | §2.3 — Logical (Boolean) (vocab: And, Inclusive or, Logical not) | `koans/03`, `solutions/03` |
| 10 | `The truth values of REXX are the strings '0' (false) and '1' (true).` | `The Logical (Boolean) values are the strings '0' (false) and '1' (true).` | §2.3 — Logical (Boolean) | `koans/03`, `solutions/03` |
| 11 | `Two values written next to each other with no operator between them are concatenated.` | `Two terms written next to each other with no operator between them are concatenated by abuttal.` | §2.3 — Concatenation (vocab: term, abuttal operator) | `koans/03`, `solutions/03` |
| 12 | `the result has exactly one blank inserted (blank concatenation).` | `the blank operator inserts exactly one blank in the result.` | §2.3 — Concatenation (vocab: blank operator) | `koans/03`, `solutions/03` |
| 13 | `The \|\| operator forces concatenation regardless of whitespace.` | `The \|\| operator joins without a blank, regardless of whitespace.` | §2.3 — Concatenation summary | `koans/03`, `solutions/03` |
| 14 | `what marks the boundary of one clause and how a clause may be stretched across more than one line.` | `what implies the semicolon at the end of a clause and how a continuation character carries a clause across more than one line.` | §2.2 — Implied semicolons and continuations (vocab: implied semicolon, continuation character) | `koans/04` |
| 15 | `A comma at the end of a line continues the clause onto the next line.` | `A continuation character (a comma) at the end of a line continues the clause onto the next line.` | §2.2 — Implied semicolons and continuations (vocab: continuation character) | `koans/04`, `solutions/04` |
| 16 | `A REXX comment opens with slash-star and closes with star-slash.` | `A REXX comment opens with \`/*\` and closes with \`*/\`.` | §2.2 — Comments (vocab: `/*`, `*/`) | `koans/04`, `solutions/04` |
| 17 | `emits the result to standard output.` | `emits the result to the default character output stream.` | §2.7 — SAY (vocab: default character output stream) | `koans/05` |
| 18 | `emits the resulting string to standard output followed by` | `emits the resulting string to the default character output stream followed by` | §2.7 — SAY (vocab: default character output stream) | `koans/05`, `solutions/05` |
| 19 | `blank-concatenates` | `joins by the blank operator` | §2.3 — Concatenation (vocab: blank operator) | `koans/05` |
| 20 | `Concept: blank concatenation in SAY context.` | `Concept: the blank operator in SAY context.` | §2.3 — Concatenation (vocab: blank operator) | `koans/05`, `solutions/05` |
| 21 | `Two operands separated by whitespace concatenate with exactly one blank between them.` | `Two terms separated by whitespace are joined by the blank operator with exactly one blank between them.` | §2.3 — Concatenation (vocab: term, blank operator) | `koans/05`, `solutions/05` |
| 22 | `The empty string has length zero` | `The null string has length zero` | §2.2 — Literal strings (vocab: null string) | `koans/05`, `solutions/05` |

### Per-substitution-parity check

Per the FR-004 revision (Clarifications session 2026-05-09), each
substitution must be applied to every file where the source-term
appears, but not to files where it does not. Substitutions #1, #3,
#5, #14, #17, #19 above appear in koans only (the corresponding
solution prose is intentionally divergent and does not contain the
source-term — so no solution edit is needed for those rows).
Substitutions #2, #4, #6 through #13, #15, #16, #18, #20 through
#22 appear in both koan and solution, so the substitution must be
applied to both files.

### Substitutions deliberately NOT made

- **"empty string"** in koan 01's LENGTH block ("The empty string
  has length 0") and elsewhere where the phrase appears in
  pedagogical prose describing the concept of "a string with length
  0" → left as "empty string" rather than substituted to "null
  string". Rationale: Cowlishaw's §2.2 Literal strings does say "a
  zero-length string is the null string", so "null string" is the
  canonical term — but it is also a less recognizable noun for a
  pilgrim coming from other languages. Substitution #22 makes the
  swap in the one place ("The empty string has length zero") where
  the prose is naming the *category* (the null string is a thing
  the language defines); occurrences that describe the concrete
  case (`LENGTH('')` = 0) keep "empty string" as a reader-friendly
  description. This is an exception to FR-001's strict reading; it
  preserves Principle V (Voice — clarity for the pilgrim) where
  the construct-naming rule (per §1) does not actually apply.
- **Concept heading "case folding of symbols"** (koan 02) — left
  unchanged. "Case folding" is a CS term not in any §2.5
  vocabulary column; Cowlishaw's prose uses "lower case translated
  to upper case before use". The concept-heading line is an
  editorial heading describing the behavior the test reveals, not
  a construct-naming role. Substituting would force a rewrite of
  the heading without anchoring to a specific Cowlishaw vocab term
  — outside the §1 discipline.
- **`%` (integer divide) and `//` (remainder) absent from koan 03
  arithmetic block** — the koan lists `+ - * / **` but omits `%`
  and `//`. This is content-completeness, not vocabulary, and
  belongs in a future content-pass feature (or M3+ koans on
  arithmetic). FR-012 keeps M2.3 to vocabulary substitutions.

## §3. Koan 00 framework-vs-REXX layered prose (FR-002)

Per FR-002 and US3, koan 00's four concept blocks (equality,
difference, truth, type) MUST distinguish the framework layer
from the REXX layer at every point both layers appear. The
proposed layered prose below replaces the existing per-block
teaching prose. Trailing citations are preserved verbatim
(FR-006); new in-prose parenthetical Cowlishaw references are
added per the §5 interpretation below.

The same prose applies to `solutions/00_about_asserts.rexx` for
the per-substitution-parity invariant (FR-004), excepting the
existing pre-feature solution divergences (file header and the
already-present "The pilgrim's first instrument is assertion of
equality" framing in solution 00); see §3.1 for the
solution-side disposition.

### 3.0 Equality block (koan 00 lines 19–28)

**Source (current):**

```
/* Concept: equality.
 * The first kind of assertion is 'eq'. It passes when its two values
 * match. The first argument is the value the koan expects; the
 * second is the value the koan computes. They are compared as REXX
 * strings, with numeric coercion when both look like numbers.
 *
 * The expression  2 + 2  produces the string for the obvious sum.
 *
 * Cowlishaw §2.5, p. 32
 */
```

**Layered (proposed):**

```
/* Concept: equality.
 * The first assertion verb is `eq`. The koan framework defines `eq`
 * to pass when its two arguments compare equal — the first argument
 * is the value the koan expects, the second the value the koan
 * computes.
 *
 * The REXX mechanism `eq` exercises is the `=` comparative operator
 * (Cowlishaw §2.3, p. 26): a normal comparison that performs a
 * numeric comparison when both terms are numeric and otherwise
 * pads and compares them as strings. The expression  2 + 2  is
 * arithmetic and produces the numeric string for the obvious sum.
 *
 * Cowlishaw §2.5, p. 32
 */
```

### 3.1 Difference block (koan 00 lines 32–37)

**Source:**

```
/* Concept: difference.
 * The 'neq' kind passes when its two values do NOT match. Here the
 * koan asserts that two distinct names are unequal.
 *
 * Cowlishaw §2.5, p. 32
 */
```

**Layered:**

```
/* Concept: difference.
 * The `neq` assertion verb is the framework's mirror of `eq`: it
 * passes when its two values do NOT match. Here the koan asserts
 * that two distinct names are unequal.
 *
 * The REXX mechanism `neq` exercises is the `\=` comparative
 * operator (Cowlishaw §2.3, p. 26) — the negation of `=`.
 *
 * Cowlishaw §2.5, p. 32
 */
```

### 3.2 Truth block (koan 00 lines 40–46)

**Source:**

```
/* Concept: truth.
 * The 'true' kind passes when its first argument evaluates to the
 * REXX boolean 1. Comparisons such as 1 = 1 and 5 > 3 produce the
 * string '1' on success. The second argument is unused for 'true'.
 *
 * Cowlishaw §2.3, p. 26
 */
```

**Layered:**

```
/* Concept: truth.
 * The `true` assertion verb passes when its first argument
 * evaluates to the Logical (Boolean) value '1'. The framework
 * uses '0' and '1' as its pass/fail signal because that is what
 * REXX's comparative and logical operators return.
 *
 * The REXX mechanism: comparative operators such as `=` and `>`
 * (Cowlishaw §2.3, p. 26) return the Logical (Boolean) values
 * '0' and '1' (Cowlishaw §2.3, p. 27 — Logical (Boolean)) on
 * success and failure respectively. The second argument is
 * unused for `true`.
 *
 * Cowlishaw §2.3, p. 26
 */
```

### 3.3 Type block (koan 00 lines 50–56)

**Source:**

```
/* Concept: type.
 * The 'datatype' kind passes when the value's REXX type matches the
 * type code given. Common codes: W for whole number, N for any
 * number, A for alphanumeric. The pilgrim fills in the code that
 * declares 5 a whole number.
 *
 * Cowlishaw §2.5, p. 32
 */
```

**Layered:**

```
/* Concept: type.
 * The `datatype` assertion verb passes when the value's REXX type
 * matches the type code given. The framework's verb name borrows
 * from the REXX built-in.
 *
 * The REXX mechanism is the DATATYPE built-in function
 * (Cowlishaw §2.9, p. 91): with a type code as its second
 * argument it returns '1' or '0' according to whether the first
 * argument matches the named type. Common codes: W for Whole, N
 * for Number, A for Alphanumeric. The pilgrim fills in the code
 * that declares 5 a Whole.
 *
 * Cowlishaw §2.5, p. 32
 */
```

### 3.4 Solution-side disposition (`solutions/00_about_asserts.rexx`)

The solution's pre-feature divergences (terse file header, the
"pilgrim's first instrument" framing in the equality block, the
"mirror of `eq`" framing in the difference block, the conventional-
empty-string note in the truth block, the missing FILL_ME_IN
sentence in the type block) are pedagogical and out of scope for
M2.3 substitution. The vocabulary terms inside the solution's
diverging prose are, however, in scope per FR-004:

- Solution equality block (lines 12–17): contains `compared as
  REXX strings, with numeric coercion when both look like numbers`
  — the same conflation as koan 00's equality block. Per FR-004
  per-substitution-parity, the same vocabulary correction applies:
  the sentence is reworded to use Cowlishaw's normal-comparison
  vocabulary (an analogous re-label, mirroring the koan-side
  layered prose's REXX-mechanism paragraph). Surrounding
  "pilgrim's first instrument" framing is preserved.
- Solution difference block (lines 24–27): no vocabulary terms in
  scope; preserved verbatim.
- Solution truth block (lines 33–37): contains `the REXX boolean
  1` and `Comparisons` — both subject to substitution per FR-001.
  Substitute identically to koan ("Logical (Boolean) value '1'",
  "comparative operators").
- Solution type block (lines 44–47): contains `whole number`, `any
  number`, `alphanumeric` — subject to substitution. Substitute
  identically (Whole, Number, Alphanumeric).

The solution's structure (no FILL_ME_IN sentence, terser body) is
preserved. Only the vocabulary terms are unified across the pair.

## §4. Targeted re-labels in koans 01–05 (FR-002a)

Walking koans 01–05 for sentences that *conflate* a framework
verb with a REXX construct in one phrase surfaces exactly **one**
re-label point:

### 4.1 Koan 01 numbers block (FR-002a)

**Source (koan 01 lines 33–40):**

```
/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string the
 * interpreter recognises as numeric. The 'datatype' kind with code
 * 'N' (number) accepts numeric strings. The pilgrim fills in the
 * type code that declares '42' a number.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
```

**Re-labeled (proposed):**

```
/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string the
 * interpreter recognises as numeric. The framework's `datatype`
 * assertion verb passes when DATATYPE (the REXX built-in,
 * Cowlishaw §2.9, p. 91) returns true for the named type — code
 * 'N' (Number) accepts numeric strings. The pilgrim fills in the
 * type code that declares '42' a Number.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
```

**Source (solution 01 lines 29–36):**

```
/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string of digits the
 * interpreter happens to recognize as numeric. The 'datatype' kind
 * with code 'N' (number) accepts numeric strings; '42' and '3.14'
 * are numbers, 'pilgrim' is not.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
```

**Re-labeled (proposed):**

```
/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string of digits the
 * interpreter happens to recognize as numeric. The framework's
 * `datatype` assertion verb passes when DATATYPE (the REXX
 * built-in, Cowlishaw §2.9, p. 91) returns true for the named type
 * — code 'N' (Number) accepts numeric strings; '42' and '3.14' are
 * Numbers, 'pilgrim' is not.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
```

### 4.2 Other koans walked

- **Koan 02**: no framework verb appears in the prose body; no
  re-label needed.
- **Koan 03**: no framework verb appears in the prose body
  (framework verbs `eq`, `true` appear in the test code, not in
  the prose); no re-label needed.
- **Koan 04**: no framework verb appears in the prose body; no
  re-label needed.
- **Koan 05**: no framework verb appears in the prose body; no
  re-label needed.

The total scope of FR-002a re-labels is therefore **2 file edits**
(koan 01 and its solution). The bulk of the koan-prose work in §2
plus the framework-vs-REXX layering in §3 covers everything else.

## §5. FR-006 interpretation (in-prose Cowlishaw references)

The framework-vs-REXX layered prose in §3 (and the targeted
re-label in §4) introduce *new in-prose parenthetical Cowlishaw
citations* — e.g., `(Cowlishaw §2.3, p. 26)` for the comparative
operator in the equality block, `(Cowlishaw §2.9, p. 91)` for
DATATYPE in the type block. The trailing citations on each
teaching block are preserved verbatim.

Spec FR-006 says *"Citation lines (lines of the form
`Cowlishaw §N.N, p. NN[ — <heading>]`) MUST NOT be modified by
this feature."* The literal scope of this restriction is
*modifying* existing citation lines, not *adding* new in-prose
parenthetical references. The interpretation:

- **Permitted**: adding a new in-prose `(Cowlishaw §X.Y, p. NN)`
  parenthetical alongside existing prose. The new parenthetical
  is a new citation line by the M2.2 definition, but it is not a
  modification of any existing citation line.
- **Prohibited**: modifying any pre-feature trailing citation
  line — changing its section, page, or suffix; reformatting it;
  or moving it to a different position within the teaching
  block.

This interpretation is consistent with the spirit of FR-006
(citations-as-section/page anchoring is M2.2's frozen domain) and
necessary for FR-002 / FR-002a (the framework-vs-REXX layering
explicitly cites the REXX mechanism's index row, which requires
a new citation reference).

Each new in-prose parenthetical also satisfies
`bin/lint_citations`'s canonical-form check (per the M2.2
contract): the prefix is `Cowlishaw §<sec>, p. <page>`, the
suffix (if any) uses the canonical em-dash and a verbatim child
heading. The lint script is per-file, not per-line, so additional
canonical-form citations on a koan that already has a passing
citation are accepted without script changes (FR-010 holds —
`bin/lint_citations` is unmodified).

## §6. Index defects discovered

Walked the relevant index rows (§1.1, §2.1, §2.2 + child rows,
§2.3 + child rows, §2.4, §2.5 + child rows, §2.7, §2.7 SAY, §2.9
DATATYPE) against every substitution target and every layered-prose
proposal. **No index defects discovered.** Every canonical
replacement term in §2 is grounded in an existing
`docs/cowlishaw_index.md` row's `Vocabulary:` column or summary
prose; every in-prose parenthetical citation in §3 / §4 resolves
to an existing index row.

FR-007's defect-patch escape hatch is not exercised by this
feature.

## §7. Out-of-scope items confirmed

Final review against spec.md "Out of Scope" section confirms:

- **Citation lines (FR-006)**: No existing citation line is modified.
  New in-prose parenthetical references are additive (per §5
  interpretation).
- **Index modifications (FR-007)**: None needed (§6).
- **`bin/lint_citations` (FR-010)**: Unmodified. New in-prose
  parentheticals satisfy the M2.2 canonical-form check; no script
  change required.
- **`lib/meditation.rexx` and other framework code (FR-011)**:
  Unmodified. The framework-vs-REXX layering lands in koan
  teaching prose, not in the framework's own implementation.
- **Voice / pilgrimage flavor (FR-012)**: No voice-bearing prose
  is touched. File-header pilgrim-voice intros, station taglines,
  and the `Welcome, pilgrim` framing are preserved verbatim.
- **Runner stdout fixture (FR-008)**: Invariant by construction
  — every edit lands inside `/* ... */` comment blocks; comments
  are never echoed to stdout by the runner, the assertion library,
  or the station-display module.
- **Stages II–VI koans**: Do not exist; not edited.
- **Mechanical existence-check lint extension (M2.2 deferred
  FR-014)**: Out of scope per spec Out of Scope; tracked as M2.4
  in PLAN.md (added 2026-05-09).
- **Re-deriving the index from the PDF**: Not performed.
- **PDF-posture migration**: Not touched.

Phase 0 is complete. No NEEDS-CLARIFICATION markers remain.
