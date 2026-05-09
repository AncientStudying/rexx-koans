# Editorial Contract — Stage I Teaching Prose (M2.3)

This document is the editorial contract for the technical-term
vocabulary used in `koans/` and `solutions/` teaching comment
blocks (Stage I in this feature; the contract carries forward to
M3+ koan authoring). It is **not** enforced by tooling — the lint
script (`bin/lint_citations`) checks citation format, not prose
vocabulary. This contract is the authoring reference that
contributors and reviewers consult when adding or editing
teaching prose.

The rules below are the post-feature state of M2.3. They become
the project's house style for all subsequent teaching prose unless
explicitly amended.

## Rule T1 — Construct-naming terms use Cowlishaw vocabulary

A noun (or noun phrase) in a teaching comment block that *names*
a REXX construct in a subject/object identifier role MUST appear
literally in the `Vocabulary:` column of a row in
`docs/cowlishaw_index.md` whose subject matches the construct.

**Construct-naming role examples**:

- *"The = operator compares ..."* — names "operator" (✓ in §2.3
  vocab).
- *"The literal string 'pilgrim'"* — names "literal string" (✓
  in §2.2 Literal strings vocab).
- *"The Logical (Boolean) values '0' and '1'"* — names "Logical
  (Boolean)" (✓ in §2.3 Logical (Boolean) vocab).

**General-English description examples** (NOT subject to T1):

- *"Operands are converted to numbers as needed"* — "operands"
  describes; Cowlishaw uses the term in his own prose.
- *"The result is the obvious sum"* — "result" describes;
  general English.

**Resolution discipline when no `Vocabulary:` entry matches**:

1. Check whether the construct genuinely belongs to a different
   `docs/cowlishaw_index.md` row than the trailing-citation row of
   the teaching block (e.g., a SAY block citing §2.7 may need the
   §2.3 Comparative vocab for a comparison-related sentence).
2. If no row in the index covers the construct, this is an index
   defect (M2.1 escape hatch). File a one-row index correction
   under M2.1's authority before the prose edit proceeds.
3. **Never invent a Cowlishaw term not in the index.** The index
   is the authority.

## Rule T2 — Framework-vs-REXX layering pattern (koan 00)

`koans/00_about_asserts.rexx` is the pilgrim's introduction to
both the koan framework and REXX. Every concept block MUST
distinguish the two layers:

- **Framework layer**: the assertion verbs `eq`, `neq`, `true`,
  `datatype`; the umbrella term "assertion"; the per-test
  pass/fail mechanic; `FILL_ME_IN`. These are introduced as
  *framework vocabulary*.
- **REXX layer**: the underlying REXX construct each verb
  exercises (the `=` and `==` comparative operators, the Logical
  (Boolean) values `'0'` and `'1'`, the DATATYPE built-in
  function and its type codes). These are named with Cowlishaw's
  terms (Rule T1) and cited to the index.

**Worked pattern**:

> *"The first assertion verb is `eq`. The koan framework defines
> `eq` to pass when its two arguments compare equal — the first
> argument is the value the koan expects, the second the value
> the koan computes."*
>
> *"The REXX mechanism `eq` exercises is the `=` comparative
> operator (Cowlishaw §2.3, p. 26): a normal comparison that
> performs a numeric comparison when both terms are numeric and
> otherwise pads and compares them as strings."*

The two layers are named as two paragraphs (or two sentences)
rather than blended into one. The framework verb is in backticks;
the REXX mechanism is named with its Cowlishaw vocabulary noun
and parenthetically cited to the index row whose subject covers
the mechanism.

The trailing canonical citation on each block (the
`Cowlishaw §N.N, p. NN` line at the end of the comment) anchors
the broad context the test operates in (e.g., `Cowlishaw §2.5,
p. 32` for koan 00's equality block, since the test code includes
an assignment); the in-prose parenthetical citation anchors the
specific REXX mechanism the framework verb exercises.

## Rule T3 — Targeted re-label for non-koan-00 conflations

In `koans/01_about_*.rexx` through `koans/05_about_*.rexx` (and
matching solutions), Rule T2's full layering is NOT applied
uniformly. Instead, *targeted re-labels* are applied to sentences
that **conflate** a framework verb with a REXX construct in one
phrase.

**Conflation example (must re-label)**:

> *"The 'datatype' kind with code 'N' (number) accepts numeric
> strings."* — names the framework `datatype` verb in the same
> breath as the REXX DATATYPE built-in's type code.

**Re-labeled (canonical)**:

> *"The framework's `datatype` assertion verb passes when DATATYPE
> (the REXX built-in, Cowlishaw §2.9, p. 91) returns true for the
> named type — code 'N' (Number) accepts numeric strings."*

**Bare framework-verb mention (NOT subject to re-label)**:

> *"The `eq` kind passes when its two values match."* — names the
> framework verb without making any specific REXX claim around
> it. Acceptable as-is, even in koans 01–05.

The discipline: re-label sentences where a framework verb sits
alongside an *implicit* REXX claim that should be made explicit
(and cited). Don't add scaffolding to every framework-verb
mention; that bloats the prose.

## Rule T4 — Citation lines are read-only outside M2.2 territory

A line of the form `Cowlishaw §N.N, p. NN[ — <heading>]` (a
canonical citation line) MUST NOT be modified by any feature
other than M2.2 (citation rewrite) or M2.4 (mechanical
existence-check, when implemented).

**Permitted** for M2.3 and successor features:

- Adding new in-prose parenthetical Cowlishaw references inside
  prose body text (e.g., `(Cowlishaw §2.3, p. 26)`). These
  satisfy `bin/lint_citations`'s canonical-form check by
  construction (per the M2.2 contract).

**Prohibited** for M2.3 and successor features:

- Modifying a pre-feature trailing citation line (changing its
  section, page, or suffix; reformatting it; moving it within the
  block).
- Removing a pre-feature citation line.

## Rule T5 — Per-substitution parity across (koan, solution) pairs

For every (koan, solution) pair where koan is
`koans/NN_about_x.rexx` and solution is
`solutions/NN_about_x.rexx`, every vocabulary substitution applied
to a koan teaching block MUST be applied identically to every
occurrence of the same source-term in the matching solution
teaching prose, and vice versa.

The koan and solution teaching prose are NOT required to be
byte-identical (the M2.2-era assumption was wrong; corrected by
M2.3 in the spec's Clarifications session 2026-05-09). Legitimate
pre-feature divergences are preserved:

- Koan files carry pilgrim-instruction lines (e.g., *"The pilgrim
  fills in ..."*) that have no place in solutions.
- Solution file headers are terse (*"Solution for
  `koans/NN_about_x.rexx`."*) rather than the pilgrim-voice
  intros koans carry.
- Several Concept-block bodies have intentionally divergent
  wording (e.g., koan 00's equality body opens *"The first kind
  of assertion is `eq`"*; solution 00's opens *"The pilgrim's
  first instrument is assertion of equality. The dispatcher's
  `eq` kind ..."*).

Only the substituted *terms* must be uniformly canonical across
the pair; surrounding prose may continue to differ.

## Out of scope for this contract

- **Citation lint behavior**: governed by
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.
- **Pilgrim voice and pilgrimage flavor**: governed by
  Constitution Principle V.
- **Solution-first work order**: governed by Constitution
  Principle I.
- **Mechanical citation existence check (M2.4)**: when
  implemented, will add a separate contract for the lint
  extension. Until then, citation-to-index resolution is a
  contributor responsibility (Rule T4 + Constitution Principle III).
