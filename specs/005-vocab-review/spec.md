# Feature Specification: M2.3 — Vocabulary Review Against the Index

**Feature Branch**: `005-vocab-review`
**Created**: 2026-05-09
**Status**: Draft
**Input**: User description: "M2.3 — Vocabulary Review Against the Index as documented in PLAN.md. Please also review any deferred tasks or decisions from M2.2"

## Background

M2.1 (`specs/003-m2-1-cowlishaw-index`) delivered the structural
ground-truth index of *The REXX Language* (2nd edition, 1990) at
`docs/cowlishaw_index.md`. Each row carries a `Vocabulary:` bullet
listing the canonical Cowlishaw terms for the topic — the *exact*
terms the book uses ("literal string", "symbol", "Comparative",
"Logical (Boolean)", "blank operator", "abuttal operator", and so
on).

M2.2 (`specs/004-m2-2-citation-rewrite`, merged 2026-05-09 in PR #4)
brought every Stage I citation into alignment with the index by
section + book page and tightened `bin/lint_citations` to enforce the
canonical citation form. The teaching prose surrounding each
citation — its vocabulary, framing, and the koan-framework-vs-REXX
distinction — was explicitly carved out of M2.2's scope (FR-012) and
deferred to this feature.

M2.3 closes that gap. The M2 UAT audit
(`docs/M2_FOLLOWUP.md` Task 3) recorded that Stage I koan teaching
prose uses non-Cowlishaw vocabulary in several places — "Comparisons"
where Cowlishaw writes "Comparative", "string literal" where
Cowlishaw writes "literal string", "boolean values" where Cowlishaw
writes "Logical (Boolean)" — and that the blanket "assertion"
framing in `koans/00_about_asserts.rexx` teaches the framework as if
it were REXX, blurring two layers a pilgrim must keep straight.

M2.3's deliverable is to walk every teaching comment block in
`koans/00_about_asserts.rexx` through `koans/05_about_say.rexx` (and
the byte-parallel files under `solutions/`) and substitute any
technical term that does not match the canonical vocabulary of the
relevant `docs/cowlishaw_index.md` row. Where a koan-framework
construct (the assertion verbs `eq`, `neq`, `true`, `datatype`, the
umbrella term "assertion") legitimately needs to live alongside a
REXX construct, the prose names both layers explicitly so the pilgrim
can tell which is which.

The central tension this feature resolves is the layering of
*koan-framework vocabulary* against *REXX vocabulary*:

- The framework verbs `eq`, `neq`, `true`, `datatype` defined in
  `lib/meditation.rexx`, and the umbrella term "assertion", are
  legitimately the framework's. They remain.
- The REXX mechanisms those verbs exercise — the `=` and `==`
  Comparative operators, the Logical (Boolean) values `'0'` and
  `'1'`, the DATATYPE built-in — must use Cowlishaw's terms in the
  teaching prose. Where both layers appear, the prose names them
  separately: *"the koan's assertion verb is `eq`; the REXX
  mechanism it exercises is the `=` comparative operator
  (Cowlishaw §2.3, p. 26)."*

### Carry-forward review of M2.2 deferred items

The user's invocation explicitly asked for a review of items
deferred from M2.2. The audit:

- **FR-014 / M2.2 User Story 5** — *Mechanical existence-check lint
  extension* (`bin/lint_citations` parses `docs/cowlishaw_index.md`
  and validates every citation by §N.N + book page join). Deferred
  per M2.2 Clarifications session 2026-05-09. **Carry-forward
  recommendation: remain deferred from M2.3; tracked as M2.4 in
  PLAN.md (added 2026-05-09).** The rationale: M2.3 is a content
  rewrite of teaching prose; the deferred extension is a
  lint/tooling enhancement that crosses a different boundary
  (parsing the index, defining the join key, positive and negative
  test cases) and would re-grow the blast radius M2.2 deliberately
  bounded. Grouping it with vocabulary work would conflate two
  unrelated concerns and weaken the acceptance gate for both. M2.4
  is the natural home and is now a planned milestone in PLAN.md
  §M2.4; it may run in parallel with M2.3. This is recorded in Out
  of Scope below.

No other M2.2 items were deferred. M2.2's three P1 user stories
(US1, US2, US3) shipped together; US4 (CI gate) shipped at merge.
US5 is the sole deferred element.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Pilgrim reads canonical Cowlishaw vocabulary throughout Stage I (Priority: P1)

A pilgrim walking Stage I encounters a teaching block that names a
REXX construct — "literal strings", "the comparative operators",
"the Logical (Boolean) values `'0'` and `'1'`", "the symbol", "the
DATATYPE built-in". Each named term is the *same* term Cowlishaw
uses in the book and the *same* term recorded in the corresponding
`docs/cowlishaw_index.md` row's `Vocabulary:` column. When the
pilgrim later reads the cited book page, the prose and the book
agree on what each thing is called. There is no two-name problem
where the koan teaches "string literal" and the book reinforces
"literal string", forcing the pilgrim to translate between
synonyms while learning.

**Why this priority**: Vocabulary alignment is the user-facing
point of this feature. Cowlishaw's terms are not arbitrary
synonyms — many are deliberate choices that distinguish REXX from
neighboring languages ("literal string" vs C's "string literal",
"symbol" vs "identifier", "Comparative" as a deliberate noun
rather than the verb-form "Comparisons"). A pilgrim taught the
wrong term carries a small confusion forward into every subsequent
section.

**Independent Test**: For each of the six Stage I koans, walk
every teaching comment block top to bottom. For each technical
term that names a REXX construct, locate the relevant index row
and confirm the term either appears literally in the
`Vocabulary:` column or is explicitly framed as koan-framework
vocabulary distinct from REXX (per US3).

**Acceptance Scenarios**:

1. **Given** a pilgrim reading `koans/03_about_expressions.rexx`,
   **When** they encounter the comparison family of operators,
   **Then** the prose calls them "Comparative" (or "comparative
   operators") rather than "Comparisons", matching the §2.3
   subsection title `Comparative` in `docs/cowlishaw_index.md`.
2. **Given** a pilgrim reading the same koan's logical-operator
   block, **When** they encounter the boolean values, **Then** the
   prose names them "Logical (Boolean) values `'0'` and `'1'`",
   matching the §2.3 subsection title `Logical (Boolean)`.
3. **Given** a pilgrim reading `koans/01_about_strings.rexx`,
   **When** they encounter quoted text, **Then** the prose names it
   "literal string" (Cowlishaw) rather than "string literal".
4. **Given** a pilgrim reading any concatenation prose,
   **When** they encounter the blank-separated form, **Then** the
   prose names it "the blank operator" and the no-blank
   adjacency form "abuttal" (or "the abuttal operator"), matching
   the §2.3 Concatenation row's vocabulary
   (`concatenation, blank operator, abuttal operator`).

---

### User Story 2 — Every UAT-flagged terminology gap is closed (Priority: P1)

PLAN.md §M2.3 lists five candidates flagged at M2 UAT. M2.3's
completion criterion is that every one is resolved: the
non-Cowlishaw term is replaced by Cowlishaw's, or, in the case of
the blanket "assertion" framing, the prose is restructured to
distinguish framework from REXX (US3 covers the latter mechanically).

The five flagged candidates:

1. "Literal string" (Cowlishaw §2.2) used over "string literal".
2. "Symbol" (Cowlishaw §2.5) used in proper distinction from
   "variable" — *symbol* is the formal term for the syntactic
   token; *variable* is what a symbol becomes once bound.
   "Identifier" / "variable name" (training-data terms) are
   eliminated wherever they appear in technical-naming roles.
3. "Comparative" (Cowlishaw §2.3 subsection title) used over
   "Comparisons" wherever the prose names the operator family
   itself; "comparative operator" used for the individual operator.
4. "Logical (Boolean)" (Cowlishaw §2.3 subsection title) used
   wherever the prose names the operator family itself; the
   parenthesized "(Boolean)" is part of Cowlishaw's heading and
   carried verbatim.
5. The blanket "assertion" framing in `koans/00_about_asserts.rexx`
   prose — addressed by US3's framework-vs-REXX restructuring.

**Why this priority**: The UAT-flagged list is the proximate
defect record. An incomplete review that fixes most but not all
flagged items leaves the project in a state where the recorded
audit is not closed — the same condition M2.2 was created to
resolve for citations. The list is small enough (five items) that
"all of them" is the only sensible bar.

**Independent Test**: Walk the five-item list top to bottom. For
each item, locate the corresponding term in the koan/solution
prose and confirm the substitution (or restructuring, for item 5)
has landed.

**Acceptance Scenarios**:

1. **Given** the flagged item "Literal string vs string literal",
   **When** every occurrence in `koans/01_about_strings.rexx` and
   `solutions/01_about_strings.rexx` is inspected, **Then** the
   construct is named "literal string" (Cowlishaw); the
   training-data form "string literal" does not appear in any
   technical-naming role.
2. **Given** the flagged item "Comparative vs Comparisons",
   **When** every occurrence in `koans/03_about_expressions.rexx`
   and the matching solution is inspected, **Then** the family
   noun is "Comparative" and individual operators are
   "comparative operators"; "Comparisons" does not appear in any
   technical-naming role.
3. **Given** the flagged item "Logical (Boolean)", **When** the
   logical-operator teaching block is inspected, **Then** the
   prose names the family "Logical (Boolean)" with the
   parenthesized clarifier preserved.
4. **Given** the flagged item "Symbol vs variable", **When**
   `koans/02_about_variables.rexx` and its solution are inspected,
   **Then** the prose distinguishes the syntactic *symbol* from
   the bound *variable* per Cowlishaw §2.5; "identifier" and
   "variable name" are absent.
5. **Given** every flagged item, **When** the review is complete,
   **Then** no item remains unaddressed.

---

### User Story 3 — Framework-vs-REXX layering is explicit in koan 00 (Priority: P1)

`koans/00_about_asserts.rexx` is the pilgrim's first encounter with
both the framework and REXX. Today its prose says things like
*"The first kind of assertion is `eq`"* — true of the framework,
silent on REXX — and *"The 'true' kind passes when its first
argument evaluates to the REXX boolean 1"* — which conflates the
framework's pass/fail mechanic with REXX's Logical (Boolean) value
domain.

After this feature, koan 00's teaching prose explicitly names the
two layers and which terms belong to which:

- **Framework layer**: the assertion verbs `eq`, `neq`, `true`,
  `datatype`; the umbrella term "assertion"; the per-test
  pass/fail mechanic. These are the framework's vocabulary and are
  introduced as such.
- **REXX layer**: the `=` and `==` *comparative operators*; the
  Logical (Boolean) values `'0'` and `'1'`; the DATATYPE built-in
  function and its type codes. These are named with Cowlishaw's
  terms and cited to the index.

A teaching block worked example, in the style PLAN.md §M2.3
recommends: *"the koan's assertion verb is `eq`; the REXX
mechanism it exercises is the `=` comparative operator
(Cowlishaw §2.3, p. 26)."*

**Why this priority**: The layering matters most where the pilgrim
first meets it. A pilgrim who leaves koan 00 thinking "assertion"
is REXX vocabulary, or that "boolean" is REXX's term for `'0'`/`'1'`,
carries that mistake into every subsequent koan. Fixing koan 00 is
disproportionately load-bearing for the rest of Stage I.

**Independent Test**: Read `koans/00_about_asserts.rexx` cover to
cover. For each technical term in the prose, identify whether the
prose presents it as framework or REXX vocabulary. The
classification must be unambiguous in every case; no term may be
silently presented as both or as neither.

**Acceptance Scenarios**:

1. **Given** a pilgrim reading koan 00's `eq` teaching block,
   **When** they read the prose, **Then** they can name (a) the
   framework verb (`eq`) and (b) the REXX mechanism it exercises
   (the `=` comparative operator, with citation), as two distinct
   things.
2. **Given** the `true` teaching block, **When** the pilgrim reads
   the prose, **Then** the framework term "the `true` kind" is
   named alongside the REXX term "Logical (Boolean) value `'1'`"
   (Cowlishaw §2.3, p. 27); "boolean" alone (lowercase, unframed)
   does not appear as the REXX term for `'1'`.
3. **Given** the `datatype` teaching block, **When** the pilgrim
   reads the prose, **Then** the framework verb "datatype" is
   named alongside the REXX function "the DATATYPE built-in"
   (Cowlishaw §2.9, p. 91), with the type codes named from the
   DATATYPE index row's vocabulary (Whole, Number, Alphanumeric).
4. **Given** any koan-framework term anywhere in koan 00's prose,
   **When** the term first appears, **Then** it is introduced
   explicitly as framework vocabulary.

---

### User Story 4 — CI stays green and the runner fixture is unchanged (Priority: P2)

`verify_solutions`, `lint_citations`, and `runner-smoke` constitute
the constitution-mandated 6/6 CI matrix (Principle IV: three named
checks × `ubuntu-latest` + `macos-latest`). All six MUST pass on
the feature branch and on merge to `main`. Teaching prose lives in
koan comments and is never echoed to stdout, so
`tests/fixtures/runner_stdout.txt` MUST remain byte-identical.
Divergence indicates an unintended side-effect (e.g., an edit that
slipped outside a comment block) and warrants investigation, not
silent re-baselining.

**Why this priority**: P2 because the CI gate is a guarantee on
correctness, not a user-facing behavior. The pilgrim never sees
the runner stdout fixture; they see the teaching prose directly.
But the fixture is the project's anchor for "the runner output the
rewrite did not change", and CI is the project's contract with
itself.

**Independent Test**: Push the feature branch. Inspect the GitHub
Actions run: all six checks (`verify_solutions` × 2 OS,
`lint_citations` × 2 OS, `runner-smoke` × 2 OS) green. Locally,
diff the freshly captured runner stdout against
`tests/fixtures/runner_stdout.txt` — empty diff.

**Acceptance Scenarios**:

1. **Given** the feature branch with vocabulary substitutions
   landed, **When** GitHub Actions runs the verify workflow,
   **Then** all six checks pass on both `ubuntu-latest` and
   `macos-latest`.
2. **Given** a fully-solved local walk through `lib/pilgrimage.rexx`,
   **When** stdout is compared to `tests/fixtures/runner_stdout.txt`,
   **Then** the comparison is byte-identical (modulo the standard
   CRLF normalization the existing fixture comparator already
   applies).

---

### Edge Cases

- **A koan term has no entry in any index row's `Vocabulary:`
  column.** Two sub-cases:
  - The term names a real REXX construct that the index simply
    omitted (M2.1 gap). The index is patched first under M2.1's
    authority — a narrowly-scoped one-row correction in its own
    commit — and M2.3 then proceeds. M2.3 must not invent a
    Cowlishaw term that the index does not record. (Mirror of
    M2.2's FR-009 escape hatch.)
  - The term is koan-framework vocabulary that legitimately has
    no Cowlishaw equivalent (e.g., "FILL_ME_IN", "the runner",
    "the pilgrim"). It is left unchanged. The framework-vs-REXX
    framing in US3 covers this case explicitly for the
    framework's own vocabulary; pilgrim-voice flourishes are
    governed by Constitution Principle V (Voice).
- **A koan term could plausibly be either framework or REXX
  vocabulary.** Disambiguate explicitly in the prose per US3 — the
  layer the term belongs to is not left to the pilgrim to infer.
- **A vocabulary substitution would change a citation line.**
  Citations are M2.2's deliverable (FR-006). M2.3 must not modify
  citation lines. If a substitution implies a citation change, the
  citation-side change is out of scope here and is recorded as a
  follow-up against M2.2 (a one-row M2.2 patch) or against the
  index (a one-row M2.1 patch), depending on the root cause.
- **Teaching prose drifts between a koan and its matching
  solution.** Both files carry the same teaching prose by
  construction (Constitution Principle I, solution-first work
  order). The substitution is applied identically to both files
  and verified by a per-pair diff. (Mirror of M2.2's FR-003
  byte-parity invariant, applied to teaching prose rather than to
  citation lines.)
- **The runner fixture diverges unexpectedly.** Investigate before
  re-baselining. Teaching prose lives in koan comments and is
  never echoed; an observed change implies an edit that slipped
  outside a comment block.
- **A substitution removes a pilgrim-voice flourish that the
  Constitution Principle V "Voice" tone depends on.** Voice
  prose (the pilgrim, the path, the Bathonian) is not technical
  vocabulary and is not in scope for substitution. M2.3 changes
  technical terms; it does not edit pilgrimage flavor.
- **Lower-case "boolean" appears legitimately in pilgrim-voice
  prose.** Not in scope — pilgrim voice is governed by Principle V.
  The substitution rule applies only where "boolean" is being
  used as the technical name for the REXX construct (in which
  case Cowlishaw's "Logical (Boolean)" replaces it).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every technical term in the teaching comment blocks
  of `koans/00_about_asserts.rexx` through `koans/05_about_say.rexx`
  and the parallel files under `solutions/` MUST EITHER (a) appear
  literally in the `Vocabulary:` column of the relevant
  `docs/cowlishaw_index.md` row, OR (b) be explicitly framed as
  koan-framework vocabulary distinct from REXX vocabulary
  (per FR-002). "Relevant index row" is the row whose §N.N + book
  page matches the teaching block's citation, or, for prose not
  immediately tied to a citation, the row whose subject the prose
  is teaching.
- **FR-002**: The teaching prose in `koans/00_about_asserts.rexx`
  (and its matching solution) MUST distinguish the koan-framework
  layer from the REXX layer at every point both layers appear:
  - The framework verbs `eq`, `neq`, `true`, `datatype`, the
    umbrella term "assertion", and the per-test pass/fail
    mechanic are introduced as *framework vocabulary*.
  - The underlying REXX mechanisms — the `=` and `==` comparative
    operators, the Logical (Boolean) values `'0'` and `'1'`, the
    DATATYPE built-in function and its type codes — are named
    using Cowlishaw's terms (per FR-001) and cited to the index.
  Where both layers appear in the same teaching block, the prose
  names them as two distinct things rather than as one.
- **FR-003**: Each of the five UAT-flagged terminology candidates
  recorded in PLAN.md §M2.3 MUST be addressed:
  1. "Literal string" (Cowlishaw) replaces "string literal" wherever
     the latter is used as the technical name for the construct.
  2. "Symbol" (Cowlishaw §2.5) is used in distinction from
     "variable" per Cowlishaw's §2.5 distinction; "identifier"
     and "variable name" are eliminated as technical names.
  3. "Comparative" (Cowlishaw §2.3 subsection title) replaces
     "Comparisons" wherever the latter names the operator family;
     "comparative operator" names the individual operator.
  4. "Logical (Boolean)" (Cowlishaw §2.3 subsection title)
     replaces "boolean" / "boolean values" wherever the latter
     names the operator family or its value domain.
  5. The blanket "assertion" framing in koan 00's teaching prose
     is restructured per FR-002.
- **FR-004**: For every (koan, solution) pair where koan is
  `koans/NN_about_x.rexx` and solution is
  `solutions/NN_about_x.rexx`, the teaching comment blocks (every
  block of the form `/* Concept: ... */` and the file-header
  block) MUST be byte-identical between the two files after this
  feature lands.
- **FR-005**: Within a single file, every occurrence of a given
  non-Cowlishaw technical term MUST be substituted identically; no
  occurrence may be left in its old form when others are
  rewritten. (Mirror of M2.2's FR-004.)
- **FR-006**: Citation lines (lines of the form
  `Cowlishaw §N.N, p. NN[ — <heading>]`) MUST NOT be modified by
  this feature. Citations are governed by M2.2's deliverable; any
  citation-touching change here would re-open M2.2 territory and
  break the boundary that kept M2.2's blast radius small.
- **FR-007**: `docs/cowlishaw_index.md` MUST NOT be modified by
  this feature. If a koan needs a vocabulary term that has no
  index entry, the index is patched first under M2.1's authority
  (a narrowly-scoped one-row correction, with a separate commit),
  and M2.3 then proceeds. Bulk additions to the index are not in
  scope here. (Mirror of M2.2's FR-009.)
- **FR-008**: `tests/fixtures/runner_stdout.txt` MUST NOT change.
  If observed runner output changes, the rewrite has caused an
  unintended side effect (e.g., accidental edit outside a comment
  block); investigate and revert before re-baselining. (Mirror of
  M2.2's FR-010.)
- **FR-009**: All six CI checks (`verify_solutions` × 2 OS,
  `lint_citations` × 2 OS, `runner-smoke` × 2 OS) MUST pass on
  the feature branch and on merge to `main`, per Constitution
  Principle IV. (Mirror of M2.2's FR-011.)
- **FR-010**: `bin/lint_citations` MUST NOT be modified by this
  feature. The script remains in the canonical-citation-form
  enforcement state delivered by M2.2 (FR-008 of that feature).
  Any vocabulary-related lint extension is documented future
  work, not in scope here. (See Out of Scope for the carry-forward
  of M2.2's deferred FR-014.)
- **FR-011**: The implementation phase of this feature MUST modify
  only the following source-tree files:
  `koans/00_about_asserts.rexx` through `koans/05_about_say.rexx`
  and `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx`. No other source-tree, fixture,
  documentation, contract, or build file may be modified by
  implementation tasks. (`lib/meditation.rexx` is *not* on the
  edit list — the framework's own implementation file is not the
  vehicle for the framework-vs-REXX distinction; the koan
  teaching prose is.)
- **FR-012**: Voice-bearing prose — pilgrim-voice second-person
  framing, the Bathonian's voice, the Mainframe Pilgrimage flavor
  — is OUT OF SCOPE for this feature. Voice is governed by
  Constitution Principle V. M2.3 substitutes technical
  vocabulary; it does not edit pilgrimage flavor. Where a single
  sentence carries both technical content and voice, only the
  technical noun(s) are subject to substitution; the surrounding
  voice is preserved.

### Key Entities

- **Teaching comment block**: a contiguous `/* ... */` REXX
  comment block in a koan or solution file that introduces the
  next test. Each block contains a `Concept:` heading line, a
  short prose body (typically 2–6 sentences), and a trailing
  `Cowlishaw §N.N, p. NN[ — <heading>]` citation. There are
  approximately 24 such blocks across Stage I koans (file headers
  + per-test concept blocks). The unit of edit for this feature.
- **Technical term**: a noun (or noun phrase) in a teaching
  comment block that names a REXX construct or a koan-framework
  construct. Examples: "literal string" (REXX), "symbol" (REXX),
  "comparative operator" (REXX), "the `eq` assertion verb"
  (framework), "FILL_ME_IN" (framework). Voice-bearing nouns
  ("pilgrim", "the path", "the Bathonian") are NOT technical
  terms and are not subject to FR-001.
- **Index vocabulary entry**: an item in a `Vocabulary:` bullet
  on a row of `docs/cowlishaw_index.md`. The lookup target for
  every REXX-naming technical term in koan teaching prose. The
  index is the authority; teaching prose cites *the index*, which
  cites the book.
- **UAT-flagged candidate** (`PLAN.md` §M2.3): one of the five
  named terminology gaps recorded at M2 UAT. Each is closed when
  the corresponding substitution (or, for item 5, the
  restructuring) is in place.
- **Framework verb** (`lib/meditation.rexx`): one of the four
  assertion entry points (`eq`, `neq`, `true`, `datatype`)
  defined by the assertion library. Framework vocabulary; not
  subject to substitution. Mentioned in koan teaching prose as
  framework, not as REXX.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of technical terms in the teaching comment
  blocks of `koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx` either (a) appear literally in the
  `Vocabulary:` column of the relevant `docs/cowlishaw_index.md`
  row, or (b) are explicitly framed as koan-framework
  vocabulary per FR-002.
- **SC-002**: 100% of technical terms in the matching files
  under `solutions/` satisfy the same condition (SC-001 mirror
  for solutions).
- **SC-003**: All five UAT-flagged candidates recorded in
  PLAN.md §M2.3 are resolved (no item left in its pre-feature
  form anywhere in `koans/` or `solutions/`).
- **SC-004**: For each of the six (koan, solution) pairs in
  Stage I, the diff of teaching comment blocks between the two
  files is empty (byte-identical sequences).
- **SC-005**: All six CI checks (`verify_solutions` × 2 OS,
  `lint_citations` × 2 OS, `runner-smoke` × 2 OS) are green on
  the feature branch's HEAD commit prior to merge.
- **SC-006**: `tests/fixtures/runner_stdout.txt` is byte-identical
  (modulo CRLF normalization) before and after the rewrite.
- **SC-007**: Citation lines are byte-identical pre/post: the
  output of `grep -nE 'Cowlishaw §' koans/0?_about_*.rexx
  solutions/0?_about_*.rexx` is the same set of (file, line,
  text) triples after this feature as it was at the M2.2 merge
  commit. (No M2.2 work is re-opened.)
- **SC-008**: `docs/cowlishaw_index.md` is unmodified by this
  feature, with the narrow exception of one-row corrections
  necessitated by lookups that surface index defects (per
  FR-007). Each such correction is in its own commit and is
  justified in the commit message by a specific koan term it
  unblocks.
- **SC-009**: `bin/lint_citations` is unmodified by this feature
  (per FR-010).
- **SC-010**: A reviewer reading `koans/00_about_asserts.rexx`
  cover to cover can in under 60 seconds correctly identify
  which technical terms are framework vocabulary and which are
  REXX vocabulary, with no ambiguous cases (per FR-002).

## Assumptions

- **M2.1 is complete and committed.** `docs/cowlishaw_index.md`
  exists at HEAD of `main` after the M2.1 merge (PR #3) and has
  passed UAT. M2.3 treats the committed index as authoritative;
  no re-derivation from the PDF is performed by this feature.
- **M2.2 is complete and committed.** Citation rewrites and the
  canonical-form lint tightening shipped on `main` at PR #4
  (merged 2026-05-09). M2.3 starts from a corpus where every
  Stage I citation already references a valid index row; the
  vocabulary substitutions sit on top of that surface.
- **The Stage I koan set is `koans/00_about_asserts.rexx`
  through `koans/05_about_say.rexx`** and their matching files
  under `solutions/`. Stages II–VI do not yet exist. This is the
  complete edit target for this feature.
- **The five UAT-flagged candidates in PLAN.md §M2.3 are the
  canonical scope-list.** They will not be revised during M2.3;
  if a new candidate surfaces during the walk it is recorded as
  a follow-up against M2.3 (or the audit doc), not silently
  added to the in-flight feature.
- **Teaching prose lives in koan/solution comment blocks and is
  never echoed to stdout.** This is what allows the rewrite to
  leave `tests/fixtures/runner_stdout.txt` byte-identical and is
  the same invariant M2.2 relied on.
- **Constitution Principle V (Voice) is authoritative for
  pilgrim-voice prose.** The pilgrim, the path, and the
  Bathonian's voice are not technical vocabulary and are not
  subject to substitution under FR-001.
- **The koan-framework vocabulary is bounded by
  `lib/meditation.rexx`'s public surface.** The framework verbs
  (`eq`, `neq`, `true`, `datatype`), the umbrella term
  "assertion", and the `FILL_ME_IN` mechanism are the framework's
  named constructs. Anything else in koan teaching prose that
  names a construct names a REXX construct.
- **No tooling re-derives the index from the PDF in this feature.**
  Per M2.1 Out of Scope and PLAN.md §M2.3, the index is consulted
  by humans (or by lint, if a future extension implements it),
  not regenerated.

## Dependencies

- **Upstream (blocking)**: M2.1
  (`specs/003-m2-1-cowlishaw-index`). The committed
  `docs/cowlishaw_index.md` and especially its `Vocabulary:`
  columns are the lookup authority for every REXX-naming term
  rewritten here.
- **Upstream (recommended-sequential)**: M2.2
  (`specs/004-m2-2-citation-rewrite`). PLAN.md §M2.3 permits M2.3
  to run in parallel with M2.2; M2.2 in fact shipped first
  (PR #4, merged 2026-05-09). M2.3 inherits the canonical
  citation form M2.2 established and is responsible for not
  re-touching any citation line (FR-006).
- **Downstream**: M3 (Stages II–III koans). Every new koan's
  teaching prose will use the same vocabulary discipline M2.3
  establishes here. The framework-vs-REXX framing pattern from
  US3 becomes the project's house style for any future koan that
  layers framework constructs on top of REXX constructs.

## Out of Scope

- **Citation lines.** Out of scope per FR-006. Citations are
  M2.2's deliverable; M2.3 does not modify them. If a vocabulary
  substitution implies a citation change, the citation-side
  change is recorded as a follow-up against M2.2 or against the
  index (depending on the root cause), not folded into M2.3.
- **Index modifications.** The index is read-only for this
  feature except for narrowly-scoped one-row corrections to
  defects surfaced during lookup (FR-007). Bulk index work is
  M2.1.
- **Stages II–VI koans.** They do not yet exist; M2.3's edit
  target is Stage I only.
- **`lib/meditation.rexx`.** The framework's own implementation
  file is not the vehicle for the framework-vs-REXX distinction.
  M2.3 lands the distinction in koan teaching prose (per FR-002).
  Any future improvements to the framework's own internal
  documentation are separate work.
- **Voice / pilgrimage flavor edits.** Constitution Principle V
  governs the pilgrim's voice, the Bathonian's voice, and
  pilgrimage flavor. M2.3 substitutes technical vocabulary; it
  does not edit voice. Where a single sentence carries both,
  only the technical noun is touched.
- **Runner stdout fixture refresh.** The fixture must remain
  byte-identical (FR-008, SC-006). If a future change
  deliberately alters runner output, that is a separate decision
  in its own commit.
- **Mechanical existence-check lint extension** (the
  carry-forward of M2.2's deferred FR-014 / US5).
  `bin/lint_citations` parsing `docs/cowlishaw_index.md` and
  validating every citation by §N.N + book page join is the
  deliverable of PLAN.md §M2.4 (added 2026-05-09), not M2.3.
  M2.4 may run in parallel with M2.3 since they edit disjoint
  surfaces (the lint script vs koan teaching prose). M2.3 takes
  the vocabulary-only path; the lint script is unmodified by
  this feature (FR-010, SC-009). Rationale: M2.3 is a content
  rewrite of teaching prose, and folding a lint/tooling
  extension into it would conflate two unrelated concerns and
  re-grow the blast radius M2.2 deliberately bounded.
- **Mechanical lint enforcement of vocabulary.** No realistic
  static check can determine whether a noun in REXX comment
  prose names a Cowlishaw construct or a framework construct or
  pilgrim voice. The vocabulary discipline is enforced by author
  and reviewer, not by lint. (PLAN.md §M2.3 implicitly accepts
  this by listing only `verify_solutions` and `lint_citations`
  in the acceptance section, with no new check proposed.)
- **Re-deriving the index from the PDF.** Per M2.1 Out of Scope.
- **Migrating away from the gitignored-PDF posture.** The PDF
  remains in `reference/`, gitignored, contributor-supplied. The
  citation links in `README.md` to the Internet Archive scan
  remain the public path to the source.
