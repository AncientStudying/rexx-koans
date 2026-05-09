# Feature Specification: M2.2 — Citation Rewrite Against the Index

**Feature Branch**: `004-m2-2-citation-rewrite`
**Created**: 2026-05-09
**Status**: Draft
**Input**: User description: "M2.2 — Citation Rewrite Against the Index as documented in PLAN.md"

## Background

M2.1 (`specs/003-m2-1-cowlishaw-index`) delivered the structural
ground-truth index of *The REXX Language* (2nd edition, 1990) at
`docs/cowlishaw_index.md`. The index is the authority for every
Cowlishaw citation in the curriculum.

M2.2 applies that authority to the existing Stage I corpus. The M2 UAT
audit recorded in `docs/M2_FOLLOWUP.md` (Audit findings 2026-05-08)
found that 9 of the 11 unique Cowlishaw section/page pairs cited in
the Stage I koans were wrong — often by ten or more pages, with
several pointing at the wrong section entirely. Those defects remain
in the Stage I koans and matching solutions today. M2.2's deliverable
is to walk every citation in `koans/00_about_asserts.rexx`,
`koans/01_about_strings.rexx`, `koans/02_about_variables.rexx`,
`koans/03_about_expressions.rexx`, `koans/04_about_clauses.rexx`,
`koans/05_about_say.rexx`, and the parallel files under `solutions/`,
and replace each citation with one that points at an existing row in
`docs/cowlishaw_index.md`.

The current corpus contains roughly 50 citation occurrences across
koans + solutions, drawn from approximately 14 distinct citation
strings; most distinct strings appear in both a koan and its matching
solution. The audit table in `docs/M2_FOLLOWUP.md` is the canonical
list of *which* of these the rewrite must close — eleven rows, of
which two are already correct (`§1.1, p. 1` and `§2.3, p. 27`) and
nine require replacement.

The teaching prose surrounding each citation — vocabulary, framing,
the koan-framework-vs-REXX distinction — is **out of scope** here. That
is M2.3's deliverable (vocabulary review against the index).
M2.2 changes citation lines; M2.3 changes everything else.

This feature also closes the deferred lint-update item recorded in the
M2.1 spec's Sync Impact Report: `bin/lint_citations` is brought into
alignment with the constitution's canonical citation form (Principle III)
to whatever extent the rewrite's citations require.

## Clarifications

### Session 2026-05-09

- Q: Should the optional existence-check lint extension (FR-014, US5)
  — `bin/lint_citations` parses `docs/cowlishaw_index.md` and validates
  every citation by §N.N + book page join — be included in M2.2's
  scope or deferred to a follow-up? → A: Defer. M2.2 ships only the
  canonical-form regex tightening (FR-008) and the rewrite itself. The
  existence-check extension is documented future work; it is not in
  M2.2's deliverable, and acceptance does not gate on it.
- Q: Should the rewrite carry a trailing label on every citation
  (matching the current corpus shape), or follow Constitution
  Principle III's "bare-preferred" guidance and strip trailing labels
  except where disambiguation actually requires the suffix? → A:
  Bare-preferred. The bare form `Cowlishaw §N.N, p. NN` MUST be used
  when (§N.N, book page) uniquely identifies an index row; the
  suffix `— <child heading>` (with the index row's verbatim heading)
  MUST be used only when (§N.N, book page) does not uniquely
  identify a row. Pre-existing trailing labels are stripped or
  replaced accordingly. A present suffix carries semantic weight: it
  signals "this is the specific child heading the bare form can't
  pick out."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Pilgrim follows a citation to the book and lands on the right material (Priority: P1)

A pilgrim reading a Stage I koan encounters a teaching block ending
with a `Cowlishaw §N.N, p. NN` citation. The pilgrim opens *The REXX
Language* (2nd edition) — typically via the Internet Archive scan
linked from `README.md` — and turns to that book page in that section.
The page they land on must visibly cover the concept the koan is
teaching. Today, for nine of the eleven distinct concepts cited, this
trip produces material on the wrong topic, sometimes the wrong section
entirely.

**Why this priority**: This is the user-facing point of the citation
mechanism. A wrong citation actively misleads the pilgrim — worse than
no citation. M2.2 exists to make every Stage I citation deliver on the
promise made by Constitution Principle III ("Every Koan Is
Self-Teaching, with a verified Cowlishaw citation").

**Independent Test**: With the gitignored PDF (or the Internet Archive
scan) open, walk every citation line in `koans/00_about_asserts.rexx`
through `koans/05_about_say.rexx`. For each, turn to the cited book
page in the cited section. The visible content there must cover the
concept the surrounding teaching block teaches.

**Acceptance Scenarios**:

1. **Given** a pilgrim reading the koan that teaches comma-continuation,
   **When** they follow the citation to the book page, **Then** they
   land on the "Implied semicolons and continuations" material in §2.2
   on the page recorded in `docs/cowlishaw_index.md` — not on §2.4 p. 38
   (one of the audit-wrong citations).
2. **Given** a pilgrim reading the koan that teaches the SAY
   instruction, **When** they follow the citation, **Then** they land
   on the SAY material in §2.7 on the page the index records — not on
   p. 56, which the audit found to be mid-INTERPRET.
3. **Given** any of the eleven concepts in the audit table, **When**
   the pilgrim follows the rewritten citation, **Then** the cited page
   covers the audit-correct concept.

---

### User Story 2 — Every audit defect is closed (Priority: P1)

The eleven-row audit table in `docs/M2_FOLLOWUP.md` is the explicit
defect record that prompted M2.1–M2.3. M2.2's completion criterion is
that every row is closed: the citation the audit calls out as wrong
is replaced by a citation that the index supports, and the two rows
the audit calls out as already correct (`§1.1, p. 1 — Introduction`,
`§2.3, p. 27 — Logical (Boolean)`) remain unchanged in section + page
(the trailing heading wording is governed separately by FR-006).

**Why this priority**: The audit is the proximate motivation for the
work. An incomplete rewrite that fixes most but not all rows leaves
the project still demonstrably defective. The audit table is small
enough (eleven rows) that "all of them" is the only sensible bar.

**Independent Test**: Walk the audit table in `docs/M2_FOLLOWUP.md`
top to bottom. For each row, locate the corresponding citation in the
koan or solution. Confirm the section + page now matches what the
index records for that audit row's concept (or, for rows 1 and 6,
confirm it matches what the audit already approves).

**Acceptance Scenarios**:

1. **Given** the audit-wrong row "`§2.1, p. 15 — Literal strings`",
   **When** the rewritten citation in `koans/01_about_strings.rexx`
   and `solutions/01_about_strings.rexx` is inspected, **Then** it
   references the §2.2 — "Literal strings" row in
   `docs/cowlishaw_index.md` and matches that row's book page.
2. **Given** the audit-wrong row "`§2.4, p. 38 — Clauses`", **When**
   the rewritten citations in `koans/04_about_clauses.rexx` and
   `solutions/04_about_clauses.rexx` are inspected, **Then** the
   citation that anchors comma-continuation references the §2.2 —
   "Implied semicolons and continuations" row, and the citation that
   anchors comments references the §2.2 — "Comments" row, each at
   the index's recorded book page.
3. **Given** the audit-correct row "`§2.3, p. 27 — Logical
   operators`", **When** the citation in
   `koans/03_about_expressions.rexx` is inspected, **Then** §2.3
   and p. 27 are unchanged, and the trailing label is resolved per
   FR-005/FR-006 — the bare form `Cowlishaw §2.3, p. 27` if the
   pair uniquely identifies an index row, otherwise the suffixed
   form `Cowlishaw §2.3, p. 27 — Logical (Boolean)` with the
   verbatim child heading from the index.
4. **Given** every row in the audit table, **When** the rewrite is
   complete, **Then** no audit row is unaddressed.

---

### User Story 3 — Koan and solution stay byte-aligned (Priority: P1)

The solution-first work order in Constitution Principle I produces a
solution file for every koan, with the same teaching prose duplicated
in both. Each Cowlishaw citation therefore appears twice — once in
`koans/NN_about_x.rexx` and once in `solutions/NN_about_x.rexx`. After
the rewrite, the citation lines for a given (koan, concept) MUST be
byte-identical between the koan and its matching solution.

**Why this priority**: Drift between koan and solution citations is a
silent defect — neither file is alone wrong, but the pair is
inconsistent. Catching this is cheap (a diff) and the cost of letting
it through is high (the project ships two answers to the same
question). The solution-first work order makes citation parity a
direct property of the deliverable, not an after-the-fact check.

**Independent Test**: For each pair `(koans/NN_about_x.rexx,
solutions/NN_about_x.rexx)` where NN is 00–05, extract every line
matching the citation pattern. The two extracted sequences must be
identical line-for-line.

**Acceptance Scenarios**:

1. **Given** any matched (koan, solution) pair, **When** the citation
   lines from each are diffed, **Then** the diff is empty.
2. **Given** a citation that appears multiple times within a single
   file, **When** the rewrite is applied, **Then** every occurrence
   of that citation string is updated identically.

---

### User Story 4 — CI stays green and the runner fixture is unchanged (Priority: P2)

`verify_solutions`, `lint_citations`, and `runner-smoke` constitute
the constitution-mandated 6/6 CI matrix (Principle IV: three named
checks × ubuntu-latest + macos-latest). All six MUST pass on the
feature branch and on merge to `main`. Citations live in koan
comments and are never echoed to stdout, so
`tests/fixtures/runner_stdout.txt` MUST remain byte-identical;
divergence indicates an unintended side-effect that warrants
investigation, not silent re-baselining.

**Why this priority**: P2 because the CI gate is a guarantee on
correctness, not a user-facing behavior. The pilgrim never sees the
runner stdout fixture; they see the citations directly. But the
fixture is the project's anchor for "the runner output the rewrite
did not change," and CI is the project's contract with itself.

**Independent Test**: Push the feature branch. Inspect the GitHub
Actions run: all six checks (verify_solutions × 2 OS, lint_citations
× 2 OS, runner-smoke × 2 OS) green. Locally, diff the freshly
captured runner stdout against `tests/fixtures/runner_stdout.txt` —
empty diff.

**Acceptance Scenarios**:

1. **Given** the feature branch with all citations rewritten, **When**
   GitHub Actions runs the verify workflow, **Then** all six checks
   pass on both ubuntu-latest and macos-latest.
2. **Given** a fully-solved local walk through `lib/pilgrimage.rexx`,
   **When** stdout is compared to `tests/fixtures/runner_stdout.txt`,
   **Then** the comparison is byte-identical (modulo the standard
   CRLF normalization the existing fixture comparator already
   applies).

---

### User Story 5 — Mechanical enforcement that every citation matches an index row (Deferred to follow-up)

*Resolved in Clarifications session 2026-05-09: deferred. Retained
here as documented future work; not part of M2.2's deliverable.*

`bin/lint_citations` could be extended to perform a mechanical
existence check: every citation it finds in `koans/*.rexx` must
correspond to a row in `docs/cowlishaw_index.md`. This goes beyond
the current format-only check and would prevent future regression —
a contributor in M3+ who invents a citation that does not match an
index row would be rejected at lint time. PLAN.md §M2.2 records this
as "Optionally extend `bin/lint_citations`".

**Why deferred**: The citation rewrite is correct and complete
without it (US1–US4 establish that). The extension guards against
*future* drift, not the current audit defect. It is real work —
parsing the index, defining the join key, building positive and
negative test cases — that grows M2.2's blast radius alongside the
already-real lint changes in FR-007 and FR-008. Future contributor
drift in M3+ is caught by the same audit-style review that produced
`docs/M2_FOLLOWUP.md`. Move to a separate, named follow-up feature
if and when audit overhead demonstrates a need for the mechanical
guard.

**Carried-forward future-test sketch** (not in scope for M2.2): a
deliberately fabricated citation (e.g., `Cowlishaw §99.99, p. 999`)
introduced into a sandbox koan would be reported by the extended
lint as unresolved against `docs/cowlishaw_index.md`, with a
non-zero exit. Reverting the change would restore green lint.

---

### Edge Cases

- **Two child headings of the same parent §X.Y begin on the same
  book page.** The bare `Cowlishaw §X.Y, p. NN` form is ambiguous;
  the citation MUST use the optional disambiguator suffix
  ` — <child heading>` permitted by Constitution Principle III
  (em-dash, single space on each side, child-heading text verbatim
  from the index row).
- **An audit-correct citation is unchanged in section and page but
  currently carries a trailing label.** Under the bare-preferred
  policy (FR-005, FR-006), the trailing label is stripped if (§N.N,
  book page) uniquely identifies the index row, or replaced by the
  verbatim child-heading from the index if not. Section and page
  remain unchanged either way. This is a small, traceable diff and
  brings the citation into the canonical form.
- **The existing trailing heading uses the ASCII separator `--` (two
  hyphens) where the constitution's canonical form specifies an
  em-dash `—`.** The rewrite normalizes the separator on every
  citation line it touches; lint is updated accordingly. See FR-007.
- **A teaching block's concept is broader than any single index row
  (e.g., "expressions in general").** The citation references the
  closest matching numbered §X.Y SECTION row rather than a fabricated
  child row. The index, not the koan, decides which rows exist.
- **The concept a teaching block teaches has no row in the index at
  all.** This indicates an M2.1 omission, not an M2.2 problem. The
  index is corrected first (a narrowly-scoped patch under M2.1's
  authority); M2.2 then proceeds to reference the new row. M2.2
  must not invent a citation that the index does not support.
- **The runner fixture diverges unexpectedly.** Investigate before
  re-baselining. Citations live in koan comments and are never
  echoed; an observed change implies an unintended side effect of
  the rewrite (e.g., accidental edit outside a comment block).
- **An optional disambiguator suffix is added to a previously-bare
  citation.** This requires `bin/lint_citations` to accept the
  suffix; the rewrite includes the lint update needed to keep CI
  green.
- **`bin/lint_citations` does not yet recognize the canonical
  separator (em-dash) or the disambiguator suffix.** Extending lint
  to enforce the canonical form per Constitution III is in scope as
  a precondition for landing the rewrite without CI failures. The
  existence-check against the index (US5) is a separate, deferred
  extension and is **not** in scope for M2.2 (Clarifications session
  2026-05-09).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every Cowlishaw citation in `koans/00_about_asserts.rexx`
  through `koans/05_about_say.rexx` and in the parallel files under
  `solutions/` MUST reference an existing row in
  `docs/cowlishaw_index.md`. "Reference" means the citation's §N.N
  identifier and book page match a row's identifier and `Page:` field
  in the index.
- **FR-002**: Every one of the eleven rows in the
  `docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)" table MUST be
  closed by this feature: the audit-wrong citations (rows 2, 3, 4, 5,
  7, 8, 9, 10, 11) are replaced by citations the index supports; the
  audit-correct citations (rows 1 and 6) retain their §N.N and book
  page (their trailing heading text is governed by FR-006).
- **FR-003**: For every (koan, solution) pair where koan is
  `koans/NN_about_x.rexx` and solution is
  `solutions/NN_about_x.rexx`, the sequence of citation lines in the
  two files MUST be byte-identical.
- **FR-004**: Within a single file, every occurrence of a given
  citation string MUST be updated identically; no occurrence may be
  left in its old form when others are rewritten.
- **FR-005**: Every citation MUST conform to the canonical form
  defined by Constitution Principle III: the bare form
  `Cowlishaw §N.N, p. NN`, optionally followed by the disambiguator
  suffix ` — <child heading>` (em-dash `—`, single space on each
  side; `<child heading>` verbatim from the index row's `###`
  heading text). Per the Clarifications session 2026-05-09
  bare-preferred resolution, the bare form MUST be used when the
  pair (§N.N, book page) uniquely identifies a row in
  `docs/cowlishaw_index.md`; the suffix MUST be used only when that
  pair does not uniquely identify a row (e.g., two child-heading
  rows of the same parent §X.Y begin on the same book page). The
  presence of the suffix is therefore a semantic signal that
  disambiguation is required.
- **FR-006**: When the bare form is used per FR-005, any
  pre-existing trailing label on a citation line MUST be stripped.
  When the suffix is used, the trailing heading text MUST match the
  index row's `###` heading verbatim, including casing and
  punctuation (parentheses, slashes, hyphens). Pre-existing trailing
  labels — present on the entire current corpus, drawn from
  pre-canonical author memory — are dropped (most cases) or replaced
  with the verbatim child-heading text (the few that remain after
  bare/suffix selection). Worked example: an audit-correct row
  6 reads `Cowlishaw §2.3, p. 27 -- Logical operators` today; under
  this feature it becomes either bare `Cowlishaw §2.3, p. 27` (if
  §2.3 + p. 27 uniquely identifies an index row) or suffixed
  `Cowlishaw §2.3, p. 27 — Logical (Boolean)` (if not, with the
  child heading taken verbatim from the index).
- **FR-007**: The pre-existing ASCII separator `--` (two hyphens)
  used in current koan citation lines MUST be replaced with the
  canonical em-dash `—` on every citation line that this feature
  touches. New citations written by this feature MUST use the
  em-dash. This brings the corpus into alignment with the canonical
  form defined in Constitution Principle III.
- **FR-008**: `bin/lint_citations` MUST accept the canonical form as
  defined in FR-005, including the optional disambiguator suffix
  with the em-dash separator. If the existing lint regex is too
  permissive (currently it ignores any text after the page number),
  it MUST be tightened to enforce the canonical form. The lint
  contract document MUST be updated to reflect the new behavior.
- **FR-009**: The rewrite MUST NOT modify `docs/cowlishaw_index.md`.
  If a citation cannot be supported by an existing index row, the
  index is patched first under M2.1's authority (a narrowly-scoped
  one-row correction, with a separate commit), and the rewrite then
  proceeds. Bulk additions to the index are not in scope here.
- **FR-010**: The rewrite MUST NOT change `tests/fixtures/runner_stdout.txt`.
  If observed runner output changes, the rewrite has caused an
  unintended side effect (e.g., accidental edit outside a comment
  block); investigate and revert before re-baselining.
- **FR-011**: All six CI checks (verify_solutions × 2 OS,
  lint_citations × 2 OS, runner-smoke × 2 OS) MUST pass on the
  feature branch and on merge to `main`, per Constitution Principle IV.
- **FR-012**: Teaching prose body — vocabulary, sentence structure,
  the koan-framework-vs-REXX framing — is OUT OF SCOPE for this
  feature; it is M2.3's deliverable. M2.2 may modify the citation
  line itself (including its trailing heading text per FR-006) but
  MUST NOT modify other lines of the surrounding teaching block.
- **FR-013**: The implementation phase of this feature MUST modify
  only the following source-tree files: `koans/00_about_asserts.rexx`
  through `koans/05_about_say.rexx`,
  `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx`, and `bin/lint_citations` (per
  FR-008). The M2.2 lint contract
  (`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`) is
  authored by `/speckit-plan` as part of feature design and is **not
  further modified during implementation**; it is documented here for
  completeness, not as an implementation edit target. No other
  source-tree, fixture, or documentation file may be modified by
  implementation tasks.
- **FR-014** *(deferred — see User Story 5 and Clarifications session
  2026-05-09)*: The mechanical existence-check lint extension —
  `bin/lint_citations` parsing `docs/cowlishaw_index.md` and
  validating every citation by §N.N + book page join (and trailing
  heading when the suffix is present) — is **out of scope** for
  M2.2. Contributor responsibility for citation correctness remains
  as defined in Constitution Principle III. The retained future-work
  description in User Story 5 documents the extension's intended
  shape if a successor feature picks it up.

### Key Entities

- **Citation line**: a single line in a `koans/` or `solutions/`
  file that carries a `Cowlishaw §N.N, p. NN[ — <heading>]` reference,
  typically inside a leading-comment teaching block. The unit of
  edit. Approximately 50 occurrences across the Stage I corpus today.
- **Distinct citation string**: the unique text of a citation,
  abstracting over the line numbers it appears on. Approximately 14
  distinct strings in the current corpus (e.g.,
  `Cowlishaw §2.5, p. 42 -- Assignments`,
  `Cowlishaw §2.3, p. 27 -- Logical operators`). Drives the rewrite
  bulk-edit operation; updates are applied per distinct string.
- **Audit row** (`docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)"
  table): one of the eleven entries that motivated this feature.
  Each row maps an originally-cited concept to the audit's
  determination of correctness and to the canonical concept the
  index supports. The rewrite is complete when every audit row is
  closed.
- **Index row** (`docs/cowlishaw_index.md`): a §X.Y SECTION row
  (`##`) or named child-heading row (`###`) carrying `Page:`,
  `Summary:`, and `Vocabulary:` bullets. The lookup target for every
  citation. The index is the authority; citations cite *the index*,
  which cites the book.
- **Lint script** (`bin/lint_citations`): the existing REXX script
  that enforces citation format in CI. Updated by this feature to
  enforce the canonical form including the optional disambiguator
  suffix (FR-008). Mechanical existence against the index is a
  documented future extension and is not modified by this feature
  (FR-014, deferred).
- **Lint contract** (`specs/002-m2-walking-skeleton/contracts/lint_citations.md`,
  or this feature's contracts file if a new one is produced): the
  documented behavior of `bin/lint_citations`. Updated alongside the
  change to lint behavior under FR-008.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Cowlishaw citations in `koans/00_about_asserts.rexx`
  through `koans/05_about_say.rexx` resolve to an existing row in
  `docs/cowlishaw_index.md` by §N.N + book page.
- **SC-002**: 100% of Cowlishaw citations in
  `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx` resolve to an existing row in
  `docs/cowlishaw_index.md` by §N.N + book page.
- **SC-003**: For each of the six (koan, solution) pairs in Stage I,
  the diff of citation lines between the two files is empty
  (byte-identical sequences).
- **SC-004**: Every one of the eleven rows in the
  `docs/M2_FOLLOWUP.md` "Audit findings (2026-05-08)" audit table
  is closed: rows 2, 3, 4, 5, 7, 8, 9, 10, 11 have new citations
  that match an index row; rows 1 and 6 retain §N.N + page.
- **SC-005**: All six CI checks (verify_solutions × 2 OS,
  lint_citations × 2 OS, runner-smoke × 2 OS) are green on the
  feature branch's HEAD commit prior to merge.
- **SC-006**: `tests/fixtures/runner_stdout.txt` is byte-identical
  (modulo CRLF normalization) before and after the rewrite. If
  intentional changes are made and re-baselined, the change is
  documented in the merge commit.
- **SC-007**: A reviewer with the Internet Archive scan open can
  verify any randomly chosen rewritten citation by turning to its
  cited book page in its cited section in under 30 seconds; the
  page visibly covers the concept the surrounding teaching block
  teaches.
- **SC-008**: `docs/cowlishaw_index.md` is unmodified by this
  feature, with the narrow exception of one-row defect corrections
  necessitated by lookups that surface index errors. Each such
  correction is in its own commit and is justified in the commit
  message by a specific citation it unblocks.
- **SC-009**: `bin/lint_citations` enforces the canonical form per
  FR-008. Adding a malformed citation (e.g., the legacy ASCII `--`
  separator, or a missing space around the em-dash, or any
  non-canonical separator) to a sandbox koan causes lint to fail
  with a specific, actionable message.

## Assumptions

- **M2.1 is complete and committed.** `docs/cowlishaw_index.md`
  exists at HEAD of `main` after the M2.1 merge (PR #3) and has
  passed the M2.1 UAT review. M2.2 treats the committed index as
  authoritative; no re-derivation from the PDF is performed by
  this feature. (Verified: `docs/cowlishaw_index.md` exists at the
  start of this feature.)
- **The Stage I koan set is `koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx`** and their matching `solutions/`
  files. Stages II–VI do not yet exist. This is the complete edit
  target for this feature.
- **The audit table in `docs/M2_FOLLOWUP.md` is the canonical defect
  list.** It will not be revised during M2.2; new defects, if any,
  are discovered and tracked separately.
- **Citations live in koan/solution comment blocks and are never
  echoed to stdout.** This is what allows the rewrite to leave
  `tests/fixtures/runner_stdout.txt` byte-identical and is recorded
  in `docs/M2_FOLLOWUP.md` Task 2 step 5.
- **The constitution's canonical citation form (Principle III) is
  authoritative.** The em-dash separator `—` and the optional
  disambiguator suffix ` — <heading>` are normative going forward.
  The current corpus's ASCII `--` separator is treated as
  pre-canonical and normalized by this feature (FR-007).
- **The M2.1 spec's deferred lint-update item applies here.** The
  M2.1 Sync Impact Report explicitly assigned the lint regex
  extension (to accept the canonical form including the optional
  suffix) to M2.2. FR-008 codifies this.
- **Existence-check lint extension (FR-014) is deferred.**
  Resolved by Clarifications session 2026-05-09: the extension is
  not in M2.2 scope and is recorded as documented future work in
  User Story 5. PLAN.md §M2.2's "Optionally" wording is the source
  of authority for treating it as separable. The rewrite is
  complete without it.
- **No tooling re-derives the index from the PDF in this feature.**
  Per M2.1 Out of Scope and PLAN.md §M2.2, the index is consulted
  by humans (or by lint, if FR-014 is implemented), not regenerated.
- **The `lint_citations` contract file lives at
  `specs/002-m2-walking-skeleton/contracts/lint_citations.md`** as
  the most recent governing contract. Any further updates can
  either amend that file or introduce a successor contract under
  this feature's `contracts/` directory; the planning phase decides.

## Dependencies

- **Upstream (blocking)**: M2.1 (`specs/003-m2-1-cowlishaw-index`).
  The committed `docs/cowlishaw_index.md` is the lookup authority
  for every citation rewritten here.
- **Upstream (informational)**: M2 (`specs/002-m2-walking-skeleton`).
  Defines the lint-citations contract that FR-008 amends and
  established the runner stdout fixture FR-010 protects.
- **Downstream**: M2.3 (vocabulary review). M2.3 may run in parallel
  with M2.2 per PLAN.md §M2.3, but the cleanest cadence is
  M2.2 → M2.3 sequential to keep the diff blast radius narrow per
  feature. The decision is M2.3's, not M2.2's.
- **Downstream**: M3 (Stages II–III koans). Every new koan's
  citation will look up the index using exactly the procedure
  M2.2 establishes here; the lint canonical-form enforcement of
  FR-008 (and, if shipped, the existence check of FR-014) catches
  citation drift in M3+ at lint time.

## Out of Scope

- **Teaching prose body changes (vocabulary review).** Substituting
  "Comparisons" with "Comparative" *in the surrounding prose*,
  reframing "assertion" as koan-framework vocabulary distinct from
  REXX, and similar pedagogical edits are M2.3 (`docs/M2_FOLLOWUP.md`
  Task 3). The trailing heading text of a citation line *is* in
  scope here (FR-006); the body of the teaching block is not.
- **Index modifications.** The index is read-only for this feature
  except for narrowly-scoped one-row corrections to defects
  surfaced during lookup (FR-009, SC-008). Bulk index work is M2.1.
- **Stages II–VI koans.** They do not yet exist; M2.2's edit target
  is Stage I only.
- **Runner stdout fixture refresh.** The fixture must remain
  byte-identical (FR-010, SC-006). If a future change deliberately
  alters runner output, that is a separate decision recorded in
  its own commit and supported by a re-capture across the CI
  matrix.
- **Mechanical existence-check lint extension** (FR-014, US5).
  Resolved by Clarifications session 2026-05-09 as deferred:
  `bin/lint_citations` parsing `docs/cowlishaw_index.md` and
  validating every citation by §N.N + book page join is **not** in
  M2.2 scope. PLAN.md §M2.2 records the option as "Optionally
  extend `bin/lint_citations`"; M2.2 takes the non-extending path.
  Documented as future work in User Story 5; a successor feature
  may pick it up.
- **Re-deriving the index from the PDF.** Per M2.1 Out of Scope.
- **Migrating away from the gitignored-PDF posture.** The PDF
  remains in `reference/`, gitignored, contributor-supplied. The
  citation links in `README.md` to the Internet Archive scan
  remain the public path to the source.
