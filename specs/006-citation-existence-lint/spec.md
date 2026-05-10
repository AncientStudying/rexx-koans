# Feature Specification: M2.4 — Mechanical Citation Existence Check

**Feature Branch**: `006-citation-existence-lint`
**Created**: 2026-05-10
**Status**: Draft
**Input**: User description: "M2.4 — Mechanical Citation Existence Check"

## Background

M2.2 (`specs/004-m2-2-citation-rewrite/`) tightened
`bin/lint_citations` to enforce a *canonical-form* check on every
citation in `koans/`: `Cowlishaw §<sec>, p. <page>` (bare) or the
suffixed form `Cowlishaw §<sec>, p. <page> — <heading>` with an
exact em-dash separator and a non-empty heading. The check is
purely syntactic: any citation that matches the canonical regex
passes, regardless of whether the cited (§N.N, page) pair actually
corresponds to a row in `docs/cowlishaw_index.md`.

M2.2 deliberately deferred the *existence* check (FR-014 / US5 in
the M2.2 spec) per its Clarifications session 2026-05-09 to keep
the citation-rewrite blast radius small. The deferral was correct
for M2.2; the extension itself remains valuable as a forward guard
for M3+ where new koans will introduce new citations whose only
check today is human review.

M2.4 implements the deferred guard. It extends `bin/lint_citations`
to parse `docs/cowlishaw_index.md` and validate, for every citation
it finds in `koans/*.rexx` and `solutions/*.rexx`, that the cited
(§N.N, book page) pair (and the trailing child-heading when the
canonical suffix is present) corresponds to an existing row. A
contributor in M3+ who invents a citation that does not resolve
against the index is rejected at lint time rather than at audit
time.

PLAN.md authority: §M2.4 (added 2026-05-09; supersedes the M2.2
deferral). Depends on M2.1 (the index is the join target) and M2.2
(the canonical-form check is the foundation the join sits on top
of). Independent of M2.3 (M2.3 edited teaching prose; M2.4 edits
the lint script and its contract — disjoint surfaces).

## Clarifications

### Session 2026-05-10

- Q: M2.3 introduced in-prose parenthetical citations like `(Cowlishaw §2.3, p. 26)` inside teaching-prose lines. These do NOT pass M2.2's strict canonical-form check (Rule C1's tail-check rejects the trailing `)` and following prose) — they're currently invisible to `bin/lint_citations`. Should M2.4's mechanical existence check validate them? → A: Broad — validate both. M2.4 introduces a second, more permissive citation-detection pattern (substring `Cowlishaw §<sec>, p. <page>` optionally followed by ` — <heading>`, with no tail constraint) used ONLY for the existence-check phase. M2.2's strict Rule C1 stays unchanged for the canonical-form / "is there an anchor" check. Every citation a contributor writes — trailing canonical AND in-prose parenthetical — is mechanically guarded against typos.
- Q: Should `bin/lint_citations` extend its file-scope to also scan `solutions/*.rexx` (where the existence check applies), or stay koans-only? → A: Extend to solutions. Lint scans both `koans/*.rexx` and `solutions/*.rexx`; the existence check applies to citations in either tree. The Station: directive check stays koans-only (solutions don't carry Station: directives by convention). Output expands from 6 to 12 per-file lines plus the summary. Matches PLAN.md §M2.4 literal language and catches solution-side citation typos directly rather than relying on the M2.3 per-substitution-parity grep alone.
- Q: When a single file contains multiple unresolved citations, how should `bin/lint_citations` report them? → A: Report all. For each file with unresolved citations, emit `[FAIL] <file>` once, then one `UNRESOLVED citation: <text> (...)` reason line per offending citation in source order. A contributor fixes all typos in one pass rather than lint-fix-lint round-tripping. Matches the M2.2 contract's per-failure-mode pattern (one reason per failure).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Mechanical existence enforcement at lint time (Priority: P1) 🎯 MVP

A contributor authoring a new koan in M3+ writes a citation
`Cowlishaw §99.99, p. 999` (whether by typo, by drawing from a
draft index, or by misremembering a section number). They run
`bin/lint_citations` locally, or push and let CI run it. Today
(post-M2.2) the citation passes lint because it satisfies the
canonical regex, and the error is caught only when a human
reviewer notices the citation does not resolve. After M2.4, the
citation is rejected at lint time with a specific actionable
error naming the file, the citation text, and the reason (no row
in `docs/cowlishaw_index.md` matches §99.99 + page 999).

**Why this priority**: The existence check is the entire point of
the feature. Without it, the lint surface is unchanged from M2.2
and the project gains nothing. P1 because the M3+ koan-authoring
work is imminent and benefits directly from this guard;
shipping M2.4 before M3 is the natural order.

**Independent Test**: A "negative spot-check": introduce a
fabricated citation `Cowlishaw §99.99, p. 999` into a sandbox
koan or solution; run `bin/lint_citations`; confirm the script
exits non-zero and prints a failure line that names the file,
the fabricated citation, and identifies the reason as "citation
does not resolve against `docs/cowlishaw_index.md`". Revert the
fabrication; confirm lint returns to green. This delivers the
guard's user-visible value end to end with no other M2.4 work
required.

**Acceptance Scenarios**:

1. **Given** a koan or solution file containing only canonical
   citations that resolve against `docs/cowlishaw_index.md`
   (i.e., the post-M2.3 corpus state), **When**
   `bin/lint_citations` runs, **Then** the script prints
   `[ ok ] <file>` for each scanned file and exits 0 with the
   one-line summary established by the M2.4 lint contract
   (the success-output shape unchanged from M2.2:
   `<passed>/<total> ... passed lint.`).
2. **Given** a koan or solution file with a citation whose §N.N
   + page pair does not match any row in
   `docs/cowlishaw_index.md`, **When** `bin/lint_citations`
   runs, **Then** the script prints `[FAIL] <file>` followed by
   a reason line of the form `UNRESOLVED citation: <citation
   text> (no §<sec> + p. <page> row in
   docs/cowlishaw_index.md)`, and exits non-zero.
3. **Given** a citation in suffixed form whose §N.N + page pair
   resolves but whose trailing ` — <heading>` suffix does not
   match the verbatim child-heading text of the resolving row,
   **When** `bin/lint_citations` runs, **Then** the script
   prints `[FAIL] <file>` followed by `UNRESOLVED citation:
   <citation text> (heading "<suffix>" does not match index row
   "<verbatim>")` and exits non-zero.
4. **Given** a bare-form citation `Cowlishaw §<sec>, p. <page>`
   whose (§<sec>, <page>) pair appears on multiple index rows
   (parent §X.Y row and one or more `###` children share that
   pair, or two `###` children share it), **When**
   `bin/lint_citations` runs, **Then** the script accepts the
   citation (the bare form passes when ANY matching row exists;
   the suffix is OPTIONAL disambiguation per the index
   conventions in `docs/cowlishaw_index.md`).
5. **Given** a single file with multiple unresolved citations
   (e.g., two fabricated §+page typos in different concept
   blocks), **When** `bin/lint_citations` runs, **Then** the
   script prints `[FAIL] <file>` exactly once followed by one
   `UNRESOLVED citation: ...` reason line per offending
   citation in source order, and exits non-zero (per FR-016).

---

### User Story 2 - Stage I corpus passes the new check on first run (Priority: P1)

The Stage I corpus (`koans/00–05_about_*.rexx` and the parallel
`solutions/00–05_about_*.rexx`) was rewritten in M2.2 (citations
to canonical form) and M2.3 (vocabulary), and at HEAD of `main`
every citation in the corpus has been verified by human review
to resolve against `docs/cowlishaw_index.md`. M2.4 adds the
mechanical guard. The first lint run after the M2.4 changes land
MUST report every koan and every solution as `[ ok ]` with no
[FAIL] lines, because no fabricated citations exist in the
at-rest corpus.

**Why this priority**: The same atomic delivery — the lint
extension — is the substantive change. US2 is the *positive*
acceptance gate (no false rejections of the existing corpus);
US1's negative spot-check is the *negative* acceptance gate
(real rejections when a fabricated citation is present). Both
gates ship together; the corpus is invariant under M2.4.

**Independent Test**: After the M2.4 changes land, run
`bin/lint_citations` on a clean checkout of the feature branch.
Confirm every koan and every solution scanned reports `[ ok ]`
and the script exits 0.

**Acceptance Scenarios**:

1. **Given** the post-M2.3 corpus (committed at HEAD of `main`)
   plus the M2.4 lint extension, **When**
   `bin/lint_citations` runs, **Then** every scanned file
   prints `[ ok ]`, the summary reports `<N>/<N> ... passed
   lint`, and the exit code is 0.

---

### User Story 3 - The new lint behavior is documented in a contract (Priority: P1)

A contributor reading the new lint contract at
`specs/006-citation-existence-lint/contracts/lint_citations.md`
can in under five minutes understand:

- The new join behavior (parsing `docs/cowlishaw_index.md`,
  building a (§N.N, page) → row lookup, and validating each
  citation against it).
- The expanded failure-mode taxonomy (the new `UNRESOLVED
  citation` failure mode, with sub-reasons for the absent-row
  case and the suffix-mismatch case).
- The acceptance and rejection cases (positive and negative
  test tables, parallel to the M2.2 contract's structure).
- The cross-platform parity constraints (UTF-8 byte-level
  matching for em-dash and §-prefix on both Regina builds in
  CI).
- What is unchanged (M2.2 Rule C1's canonical-form check, the
  Station: directive check on koans, output format shape, exit
  codes).

**Why this priority**: M2.4's only behavioral change is the
lint extension; the contract is the documented surface that
successor features (M3+) and human reviewers consult. Without
the contract, the script is the spec, which violates the
project's contract-driven discipline.

**Independent Test**: Open the new lint contract post-feature;
confirm it documents (a) the index-parser scope and
heading-row format, (b) the (§N.N, page) lookup procedure,
(c) the new `UNRESOLVED citation` failure mode and its
sub-reasons, (d) positive and negative case tables, (e)
cross-platform parity constraints, and (f) what carries forward
unchanged from
`specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.

**Acceptance Scenarios**:

1. **Given** a contributor needing to understand whether a
   proposed new citation will pass lint, **When** they consult
   the M2.4 lint contract, **Then** they can determine the
   citation's lint outcome from the contract alone without
   reading the script.

---

### User Story 4 - CI acceptance gate stays green (Priority: P2)

The CI matrix is the project's merge gate per Constitution
Principle IV. M2.4 changes only `bin/lint_citations` and ships
a new contract document; the script change is purely additive
(new check on top of the M2.2 canonical-form check, no
regression in any prior behavior). The CI matrix MUST remain
green on the feature branch's HEAD prior to merge, including
`verify_solutions` (unchanged), the new tightened
`lint_citations` (now also performs the index join), and
`runner-smoke` (the runner stdout fixture is unchanged because
no koan or solution prose is touched).

**Why this priority**: P2 because it's the project-level
acceptance gate, automatic given the P1 deliverables, and the
CI matrix exists. CI green is a *consequence* of US1 + US2 +
US3 landing correctly, not a separable user-facing story; it
ships in the same atomic delivery.

**Independent Test**: Push the feature branch; observe GitHub
Actions reports green on both `ubuntu-latest` and `macos-latest`
for all three workflow steps (`Verify solutions`, `Lint
citations`, `Runner smoke`).

**Acceptance Scenarios**:

1. **Given** the M2.4 changes pushed to
   `origin/006-citation-existence-lint`, **When** GitHub
   Actions runs the `verify` workflow, **Then** both matrix
   jobs (ubuntu-latest, macos-latest) complete with conclusion
   `success`, and all three steps within each job pass.

---

### Edge Cases

- **Index parser encounters an unexpected line shape** (e.g.,
  a malformed `**Page:**` bullet, a `###` heading without a
  Page bullet, a `## §X.Y` heading whose Page bullet has
  non-numeric content): the parser MUST report a specific
  bootstrap error (file, line number, expected shape) and
  `bin/lint_citations` MUST exit non-zero. The current index
  passes a baseline parse; the baseline parse is captured
  during M2.4 implementation and becomes the regression canary.
- **Bare form `Cowlishaw §X.Y, p. NN` where (§X.Y, NN) appears
  on multiple index rows** (e.g., a §X.Y row and a `###`
  child both have page NN, or two `###` children share the
  pair): per `docs/cowlishaw_index.md`'s conventions,
  (§X.Y, page) is the lookup key — the bare form passes when
  ANY row matches. Disambiguation via the suffixed form is
  OPTIONAL per the index documentation. This is consistent
  with the M2.2 bare-preferred policy (FR-008 in M2.2 spec).
- **Suffixed form whose (§X.Y, NN) resolves but whose suffix
  is not a valid child heading at that key** — e.g., the
  suffix names a different child, or a typo: rejected with
  reason `heading "<suffix>" does not match index row
  "<verbatim list>"` (or `heading "<suffix>" does not match
  any §<sec>+p.<page> row; use bare form` if the resolved key
  has no `###` children at all).
- **Citation appears in an in-prose parenthetical** (M2.3
  added these — e.g., `(Cowlishaw §2.3, p. 26)`) rather than
  on its own line: validated by the M2.4 existence check, per
  the Clarifications session 2026-05-10 (broad detection
  scope). M2.2's strict Rule C1 still rejects the line as a
  canonical-anchor candidate (because of the trailing `)` and
  prose), but M2.4's separate, more permissive
  citation-detection pattern picks up the substring and joins
  it against the index. A typo in an in-prose parenthetical
  (e.g., `(Cowlishaw §99.99, p. 999)`) surfaces as
  `UNRESOLVED citation: ...` even though M2.2 would have
  silently ignored it.
- **Single file contains multiple unresolved citations**:
  per FR-016, lint emits `[FAIL] <file>` once and one
  `UNRESOLVED citation: ...` reason line per offending
  citation in source order. A contributor with three typos
  in three concept blocks gets three reason lines and can
  fix all in one pass.
- **A koan or solution file contains zero citations**: the
  pre-existing `MISSING citation` failure mode applies
  (unchanged from M2.2). The existence check has no work to
  do for files with no citation matches.
- **`docs/cowlishaw_index.md` is missing or empty when lint
  runs**: lint MUST exit non-zero with a clear bootstrap-error
  message naming the missing/empty file. The index is the
  lookup authority; without it, lint cannot enforce the
  existence check. No file is reported as `[ ok ]` until the
  index is present and parses.
- **Cross-platform: §-prefix character (U+00A7) and em-dash
  (U+2014) byte sequences differ from naive ASCII in UTF-8**:
  the M2.2 parity rules carry forward — both Regina builds in
  CI read files as raw byte streams; byte-level matching
  applies. M2.4 adds index parsing (the index file is also
  UTF-8); the same byte-level rules govern the `## §X.Y`
  heading and the `### Child Heading` rows.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `bin/lint_citations` MUST parse
  `docs/cowlishaw_index.md` once at startup and build an
  in-memory lookup table keyed by `(§<sec>, <page>)` whose
  values are the set of `### <heading>` child-heading texts
  (verbatim, including case and punctuation) that share that
  key, plus an indication of whether the parent `## §<sec>`
  row itself has that key.
- **FR-002**: For every citation occurrence in any file scanned
  by lint, `bin/lint_citations` MUST extract the (§<sec>, <page>)
  key and the optional ` — <heading>` suffix, and validate
  against the lookup table. The citation-detection pattern for
  the existence check is a more permissive substring match than
  M2.2's Rule C1 (per the Clarifications session 2026-05-10
  resolution): it matches `Cowlishaw §<sec>, p. <page>`
  optionally followed by ` — <heading>` (canonical em-dash
  separator, non-empty heading), with NO tail constraint after
  the page digits or heading. This permits in-prose parenthetical
  citations (e.g., `(Cowlishaw §2.3, p. 26)`) and other
  embedded forms to be validated. M2.2's strict Rule C1 carries
  forward UNCHANGED for the canonical-form / "is there an anchor
  citation in this file" check (FR-007).
- **FR-003**: A citation with a (§<sec>, <page>) key that does
  not appear in the lookup table MUST be rejected with the new
  failure mode `UNRESOLVED citation: <citation text>
  (no §<sec> + p. <page> row in docs/cowlishaw_index.md)`. The
  containing file is reported `[FAIL]`.
- **FR-004**: A citation in suffixed form whose (§<sec>,
  <page>) key resolves but whose suffix-heading does not match
  any `### <heading>` text associated with that key MUST be
  rejected with the failure mode `UNRESOLVED citation:
  <citation text> (heading "<suffix>" does not match index row
  "<verbatim>")`, where `<verbatim>` is the comma-joined list
  of valid heading alternatives. If no `###` children sit
  under the resolved key (i.e., the citation refers to a
  `## §X.Y` row directly), the failure mode reads `UNRESOLVED
  citation: <citation text> (heading "<suffix>" does not
  match any §<sec>+p.<page> row; use bare form)`.
- **FR-005**: A citation in bare form whose (§<sec>, <page>)
  key resolves to ANY row (parent `## §X.Y` and/or any of its
  `###` children) MUST pass the existence check. Bare form is
  documented as canonical when (§X.Y, page) is unique per the
  index conventions.
- **FR-006**: `bin/lint_citations` MUST scan
  `koans/*.rexx` AND `solutions/*.rexx` for citations
  (extending M2.2's koans-only scope). The path manifest
  `koans/path_to_enlightenment.rexx` is excluded as before.
- **FR-007**: The M2.2 canonical-form check (Rule C1: bare
  form, suffixed form with em-dash separator, no garbage tail)
  MUST carry forward unchanged. M2.4 adds checks; it does not
  relax any.
- **FR-008**: The Station: directive check (exactly one
  `Station: <text>` line in the leading comment block of each
  koan file) MUST carry forward unchanged from M2.2 for koan
  files. The Station: check is **NOT** extended to solution
  files (solutions do not carry Station: directives by
  convention). M2.4 expands citation-checking scope to
  solutions without expanding the Station: scope.
- **FR-009**: `bin/lint_citations` output format on success
  MUST remain `[ ok ] <file>` per file plus a one-line summary,
  with exit code 0 for full pass and exit code 1 for any
  failure or missing/empty index. The exact summary wording
  adapts to the expanded scope (the M2.4 lint contract sets
  the final wording — e.g., `<N>/<N> files passed lint.` or
  similar).
- **FR-010**: If `docs/cowlishaw_index.md` is missing, empty,
  or fails to parse cleanly, `bin/lint_citations` MUST print a
  bootstrap-error line naming the file and the parse failure,
  and exit non-zero without reporting any file as `[ ok ]`.
- **FR-011**: The M2.4 lint extension MUST be implemented in
  REXX (Constitution Principle II). No new third-party REXX
  libraries are introduced.
- **FR-012**: The runner stdout fixture
  `tests/fixtures/runner_stdout.txt` MUST be byte-identical
  before and after this feature's changes. M2.4 does not edit
  any koan, solution, framework, or fixture file.
- **FR-013**: `docs/cowlishaw_index.md` MUST be byte-identical
  before and after this feature's changes. The index is the
  lookup authority; this feature consults it, never modifies
  it. M2.1 remains the only feature that delivers or amends
  the index. (M2.1's escape-hatch for one-row defect
  corrections is still available to a successor feature if
  needed; M2.4 does not exercise it.)
- **FR-014**: A new lint contract MUST be authored at
  `specs/006-citation-existence-lint/contracts/lint_citations.md`
  documenting: the index-parser format expectations, the
  lookup-table schema, the new failure modes and their reason
  strings, positive and negative case tables, and what carries
  forward unchanged from
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.
  The new contract supersedes the M2.2 contract.
- **FR-015**: No file under `koans/` or `solutions/` is modified
  by this feature. The negative spot-checks (SC-003, SC-004)
  introduce a fabricated citation temporarily; the
  introduction is reverted before commit. Mechanically:
  `git diff main -- koans/ solutions/` returns no output on
  the feature branch's HEAD prior to merge.
- **FR-016**: When a single scanned file contains multiple
  unresolved citations, `bin/lint_citations` MUST emit
  `[FAIL] <file>` once and then one `UNRESOLVED citation:
  <text> (<reason>)` reason line per offending citation in
  source order (line-number ascending; if multiple unresolved
  citations share a line, in column order). The file is
  reported once; the reasons accumulate underneath. Per the
  Clarifications session 2026-05-10 resolution.

### Key Entities

- **Index row**: a `## §X.Y — <title>` heading or a
  `### <child heading>` heading in `docs/cowlishaw_index.md`.
  Each row is followed by exactly three bullets — `**Page:**`,
  `**Summary:**`, `**Vocabulary:**` — in that order. The row's
  *(section, page)* pair is the lookup key M2.4 builds. The
  row's *child heading text* (for `###` rows) or the row's
  *parent heading title* (for `##` rows) is the value
  associated with the key.
- **Lookup table**: an in-memory data structure
  `bin/lint_citations` builds at startup, mapping
  `(§<sec>, <page>)` → list of `### <heading>` texts. Built
  once per lint invocation by walking
  `docs/cowlishaw_index.md`. The parent `## §X.Y` row's key is
  also entered (with no associated child heading) so that
  bare-form citations to a §X.Y row whose page differs from
  any `###` child still resolve. A key may point to multiple
  headings (when (§X.Y, page) is shared by a §X.Y row and a
  `###` child, or by two `###` children).
- **Citation** (M2.4 detection scope, per Clarifications session
  2026-05-10): a substring matching `Cowlishaw §<sec>, p. <page>`
  optionally followed by ` — <heading>` (canonical em-dash
  separator, non-empty heading) in any line of `koans/*.rexx` or
  `solutions/*.rexx`. NO tail constraint applies — the substring
  may be embedded in prose, parentheticals, or any other context.
  This is broader than M2.2's Rule C1 (which requires a clean
  tail) but the broader scope applies ONLY to the M2.4 existence
  check; M2.2's Rule C1 still gates the canonical-form / anchor
  check unchanged. The unit of join. Trailing canonical citation
  lines (e.g., `* Cowlishaw §2.5, p. 32`) and in-prose
  parentheticals (e.g., `(Cowlishaw §2.3, p. 26)`) are both
  validated.
- **Failure mode**: a one-line indented reason string emitted
  under a `[FAIL] <file>` line. M2.4 introduces:
  - `UNRESOLVED citation: <text> (no §<sec> + p. <page> row
    in docs/cowlishaw_index.md)`
  - `UNRESOLVED citation: <text> (heading "<suffix>" does not
    match index row "<verbatim list>")`
  - `UNRESOLVED citation: <text> (heading "<suffix>" does not
    match any §<sec>+p.<page> row; use bare form)`

  Pre-existing M2.2 modes (`MISSING citation`, `MISSING
  Station: directive`, `MULTIPLE Station: directives`) carry
  forward.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of citations in
  `koans/00_about_asserts.rexx` through
  `koans/05_about_say.rexx` resolve to an existing row in
  `docs/cowlishaw_index.md` by §<sec> + page join (and by
  suffix-heading match where the suffix is present), as
  enforced by the new `bin/lint_citations` existence check.
  The script reports `[ ok ]` for every koan.
- **SC-002**: 100% of citations in
  `solutions/00_about_asserts.rexx` through
  `solutions/05_about_say.rexx` resolve identically. The
  script reports `[ ok ]` for every solution.
- **SC-003**: A negative spot-check (a fabricated citation
  `Cowlishaw §99.99, p. 999` introduced into a sandbox koan
  or solution) is rejected at lint time with a specific,
  actionable failure-mode line that names the file, quotes
  the fabricated citation, and identifies the reason as "no
  §99.99 + p. 999 row in docs/cowlishaw_index.md". Reverting
  the fabrication restores the green run.
- **SC-004**: A second negative spot-check (a citation in
  suffixed form whose §+page resolves but whose suffix-heading
  is fabricated, e.g., `Cowlishaw §2.5, p. 32 — Bogus
  Heading`) is rejected at lint time with the suffix-mismatch
  reason; reverting restores the green run.
- **SC-005**: All 6 CI workflow checks (the matrix
  `verify_solutions` × {ubuntu-latest, macos-latest},
  `lint_citations` × {ubuntu-latest, macos-latest},
  `runner-smoke` × {ubuntu-latest, macos-latest}, counted as
  2 jobs × 3 steps = 6 named checks; reported by GitHub as
  2 jobs in the PR Checks UI) are green on the feature
  branch's HEAD commit prior to merge.
- **SC-006**: `tests/fixtures/runner_stdout.txt` is
  byte-identical (modulo CRLF normalization) before and
  after the feature.
- **SC-007**: `docs/cowlishaw_index.md` is byte-identical
  before and after the feature. Mechanically:
  `git diff main -- docs/cowlishaw_index.md` returns no
  output on the feature branch's HEAD.
- **SC-008**: No file under `koans/` or `solutions/` is
  modified by this feature (the negative spot-checks are
  reverted before merge). Mechanically:
  `git diff main -- koans/ solutions/` returns no output on
  the feature branch's HEAD.
- **SC-009**: `bin/lint_citations`'s output format for the
  success path remains `[ ok ] <file>` per file plus a
  one-line summary, with exit code 0. The summary text adapts
  to the expanded scope per the M2.4 lint contract; the
  *shape* of the success output is unchanged from M2.2's
  `<N>/<N> ... passed lint.`.
- **SC-010**: A contributor consulting
  `specs/006-citation-existence-lint/contracts/lint_citations.md`
  can determine, for any candidate citation string, whether
  `bin/lint_citations` will accept it — without running the
  script and without reading its source — in under 90
  seconds. The contract carries the lookup procedure, the
  failure-mode table, and positive/negative case tables.

## Assumptions

- **M2.1 is complete and committed**, providing
  `docs/cowlishaw_index.md` at HEAD of `main` with the
  index-row format documented in the index file's preamble
  (single `## §X.Y — <title>` heading per section, single
  `### <child heading>` per child row, exactly three bullets
  per row). M2.4 trusts the format documented at HEAD;
  non-conforming rows would surface as parser errors during
  M2.4 implementation (see Edge Cases).
- **M2.2 is complete and committed**, providing the
  canonical-form Rule C1 check in `bin/lint_citations`. M2.4
  sits on top of Rule C1 — every citation that reaches the
  existence check has already passed the canonical-form
  check.
- **M2.3 is complete and committed**, providing the
  post-rewrite corpus where every citation has been verified
  by human review to resolve against
  `docs/cowlishaw_index.md`. M2.4's existence check on the
  corpus is therefore expected to pass on first run (US2).
  The new in-prose parenthetical citations introduced by
  M2.3 (e.g., `(Cowlishaw §2.3, p. 26)`) are subject to the
  same existence check as trailing canonical citations.
- **The lint scope is extended to `solutions/*.rexx`** in
  addition to `koans/*.rexx` for the citation-checking pass,
  per PLAN.md §M2.4's literal language and confirmed in the
  Clarifications session 2026-05-10. The Station: directive
  check is **not** extended to solutions (solutions do not
  carry Station: directives by convention).
- **The M2.4 existence check uses a more permissive
  citation-detection pattern than M2.2's Rule C1** (per the
  Clarifications session 2026-05-10): substring `Cowlishaw
  §<sec>, p. <page>` optionally followed by ` — <heading>`
  with no tail constraint. This permits in-prose
  parenthetical citations to be validated. M2.2's strict
  Rule C1 carries forward unchanged for the canonical-form
  / "is there an anchor citation" check (FR-007).
- **`bin/lint_citations` runs in well under 1 second on the
  current corpus** (12 files, ~50 citations, ~80 index rows).
  Performance is not a constraint at this scale; no caching
  or incremental parsing is needed. The index is parsed once
  per invocation.
- **The negative spot-checks (SC-003, SC-004) are performed
  manually during implementation**, with explicit
  introduce-and-revert procedure tracked in the M2.4
  quickstart (added by `/speckit-plan`). They are not
  committed to the feature branch; they exercise the guard
  end to end without leaving artifacts.
- **The M2.4 lint contract supersedes the M2.2 contract** at
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`
  — it documents both the unchanged M2.2 behavior (Rule C1,
  the Station: check, output format, exit codes) and the new
  M2.4 behavior (the index join). The M2.2 contract is left
  in place as historical record; new contributors are
  pointed at the M2.4 contract.
- **No other files are modified.** The only edits are
  `bin/lint_citations` (script extension) and the new
  contract document. No koan, solution, fixture, framework,
  library, or index file is touched.

## Out of Scope

- **Modifying `docs/cowlishaw_index.md`.** M2.4 consults the
  index, never modifies it. M2.1 is the authoring feature.
  If M2.4 implementation surfaces an index-row defect that
  prevents a corpus citation from resolving, the defect is
  escalated as a one-row M2.1 amendment in a separate commit
  (matching M2.2 / M2.3's escape-hatch convention); M2.4
  itself does not contain the amendment.
- **Modifying any koan or solution file.** The negative
  spot-checks (SC-003, SC-004) introduce a fabricated
  citation temporarily; the introduction is reverted before
  commit. No permanent koan or solution edit lands in M2.4.
- **Modifying `tests/fixtures/runner_stdout.txt`** (FR-012).
  Comments are never echoed; lint behavior is tooling-only.
- **Modifying `lib/meditation.rexx` or any other framework
  code.** M2.4's surface is `bin/lint_citations` only.
- **Re-deriving `docs/cowlishaw_index.md` from the PDF.**
  The index is human-curated; M2.1 is the authoring feature.
  M2.4 consumes the index as data.
- **Caching or incremental parsing.** The corpus is small
  enough that one pass per lint invocation is fine. If a
  future corpus scale-up changes that, a successor feature
  can revisit.
- **Stages II–VI koans (`koans/06_*.rexx` onward).** They do
  not exist yet. M2.4 is the lint guard that validates them
  when M3+ ships them; M2.4 itself does not author them.
- **Validating in-prose Cowlishaw mentions that do not match
  Rule C1.** Free-form prose like "Cowlishaw discusses this
  in chapter two" is not a citation; M2.4 only checks
  substrings matched by Rule C1's canonical form (the same
  scope as M2.2).
- **Rewriting `bin/verify_solutions`** or any other CI
  script. M2.4's surface is the lint script.
- **Pilgrim voice and pilgrimage flavor.** No prose is
  touched. Constitution Principle V is preserved by
  construction.
- **The `Station:` directive check on solution files.** Per
  M2.2 convention, Station: lives in koans only. M2.4
  expands citation scope but not Station: scope.

## Dependencies

- **Upstream (blocking)**: M2.1
  (`specs/003-m2-1-cowlishaw-index/`) committed at HEAD of
  `main`. The index file `docs/cowlishaw_index.md` is the
  lookup target M2.4 joins against.
- **Upstream (blocking)**: M2.2
  (`specs/004-m2-2-citation-rewrite/`) committed at HEAD of
  `main`. The canonical-form check in `bin/lint_citations`
  is the foundation M2.4 sits on top of; M2.4 invokes
  Rule C1's match as its citation-detection step.
- **Upstream (informational)**: M2.3
  (`specs/005-vocab-review/`) committed at HEAD of `main`.
  M2.3 adds in-prose parenthetical citations subject to the
  same existence check as trailing citations. M2.4 inherits
  the cleaner post-M2.3 corpus.
- **Downstream (informational)**: M3 — when Stages II + III
  koans (06–17) ship, every new citation they introduce
  will be validated by M2.4 at lint time, catching
  contributor citation drift mechanically rather than at
  human-review time.

## Out-of-band Considerations

- **The lint contract location precedent.** The M2-era lint
  contract lived at
  `specs/002-m2-walking-skeleton/contracts/lint_citations.md`.
  M2.2 superseded it with
  `specs/004-m2-2-citation-rewrite/contracts/lint_citations.md`.
  M2.4 follows the same pattern: the new contract at
  `specs/006-citation-existence-lint/contracts/lint_citations.md`
  becomes the active reference; older contracts remain as
  historical record. The supersession-vs-amend-in-place choice
  was decided in `/speckit-plan` (see `research.md` §5):
  supersession with a new file. The M2.2 contract is preserved
  unchanged.
