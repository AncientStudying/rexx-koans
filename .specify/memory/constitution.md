<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Bump type: MINOR — material expansion of Principle III's citation
form to permit an optional human-readable disambiguator suffix.

Modified principles:
  - Principle III (Every Koan Is Self-Teaching) — citation form
    relaxed from "the exact form `Cowlishaw §N.N, p. NN`" to the
    canonical form `Cowlishaw §N.N, p. NN`, optionally followed by
    ` — <heading>` for child-heading disambiguation. Rationale:
    M2.1 (specs/003-m2-1-cowlishaw-index) introduces a structural
    index whose child-heading rows may share both a parent §X.Y and
    a book page; the optional suffix disambiguates such rows in
    citations. The bare canonical form remains valid and preferred
    where it disambiguates on its own.
  - Principle IV (CI Is the Acceptance Gate) — enumerated CI jobs
    expanded from two (verify_solutions, lint_citations) to three
    (verify_solutions, lint_citations, runner-smoke) to match the
    actual matrix in `.github/workflows/verify.yml` (since M1.5).
    No change to the underlying CI; the constitution text now
    matches reality and the "6/6" check count cited elsewhere
    (plan.md, tasks.md T039) is now constitution-grounded.

Added sections: N/A
Removed sections: N/A

Template alignment:
  ✅ .specify/templates/plan-template.md — no impact.
  ✅ .specify/templates/spec-template.md — no impact.
  ✅ .specify/templates/tasks-template.md — no impact.
  ✅ specs/003-m2-1-cowlishaw-index/spec.md FR-004a — amended in
       coordination with this principle change.
  ✅ specs/003-m2-1-cowlishaw-index/contracts/index_format.md —
       citation-format wording loosened to match this principle.
  ⚠️ bin/lint_citations — current regex enforces the bare canonical
       form; extension to accept the optional suffix is M2.2 work
       per spec Out of Scope.

Deferred items: bin/lint_citations regex update (assigned to M2.2).

Prior reports retained in git history; see commit 5f1d0c2 ancestry
for the 1.0.0 (initial publication) report.
-->

# REXX Koans Constitution

## Core Principles

### I. Solution-First Development (NON-NEGOTIABLE)

Every koan MUST have a complete, passing solution file before it ships.
The mandated work order within each milestone:

1. Draft teaching comments (concept heading + prose + Cowlishaw citation).
2. Write the solution file and verify it passes under `bin/verify_solutions`.
3. Derive the koan from the solution by replacing answers with `FILL_ME_IN` symbols.
4. Run the runner against the koan and confirm it fails with a diagnostic message.
5. Re-apply the solution value and confirm the runner advances.

No koan ships without its corresponding `solutions/NN_about_x.rexx` file
verified green by `bin/verify_solutions`. The order may not be reversed or
shortcut. This order guarantees no koan ships with an assertion that has no
valid answer, and that every teaching comment matches code that actually passes.

### II. No Third-Party REXX Libraries

The project uses only language features and built-ins that ship with
Regina REXX. No external REXX libraries, frameworks, or host-specific
extensions are permitted in `koans/`, `solutions/`, or `lib/`.

This constraint is non-negotiable: it ensures every lesson translates
directly to z/OS TSO/E and VM/CMS environments without surprise for a
learner who moves from Regina to a mainframe. Utility scripts in `bin/`
MUST be written in REXX unless a technical impossibility is documented
in `docs/DESIGN_DECISIONS.md` with explicit rationale.

### III. Every Koan Is Self-Teaching

Each koan test MUST be preceded by a teaching comment block containing:

1. A short concept heading naming what the test reveals.
2. Two to six sentences of prose sufficient for the pilgrim to make the
   test pass without consulting the book.
3. A Cowlishaw citation in the canonical form `Cowlishaw §N.N, p. NN`,
   optionally followed by the disambiguator suffix ` — <heading>` when
   the citation refers to a child-heading row whose parent §N.N and
   book page do not by themselves uniquely identify it. The bare
   canonical form is preferred where it suffices.

Citations MUST be verified against the contributor's local copy of
*The REXX Language* (2nd edition, Cowlishaw, 1990) at writing time.
`bin/lint_citations` enforces citation format in CI; page-number accuracy
is a contributor responsibility, not a CI responsibility.

Scripture (`lib/scripture.rexx`) is invoked only when a Cowlishaw design
principle genuinely illuminates the koan. Decorative scripture is not permitted.

### IV. CI Is the Acceptance Gate

Every commit to `main` and every pull request MUST pass both CI jobs
defined in `.github/workflows/verify.yml`:

- **verify_solutions** (ubuntu-latest and macos-latest): All files in
  `solutions/` run green under the assertion machinery.
- **lint_citations** (ubuntu-latest and macos-latest): Every koan in
  `koans/` contains a well-formed citation in the canonical form
  defined by Principle III.
- **runner-smoke** (ubuntu-latest and macos-latest): A fully-solved
  walk through `lib/pilgrimage.rexx` produces stdout that matches
  `tests/fixtures/runner_stdout.txt` byte for byte (modulo CRLF
  normalization).

Six checks total — three named steps × two operating systems. No
merge proceeds with a failing CI run. Cross-platform parity between
the macOS Homebrew Regina and the Ubuntu apt Regina is a first-class
requirement; divergence is a bug, not an acceptable variance.

### V. Voice — Diagnostic First, Pilgrimage Flavor Second

Failure messages MUST state what went wrong before any atmospheric
language. The pilgrim MUST be able to read the failure and know
immediately what value was expected, what was received, and where.

Style rules:

- Address the learner as "the pilgrim" or in second person. Never "the user."
- Humor is permitted with restraint — one dry note lands; a sustained
  joke wears thin across thirty koans.
- The Mainframe Pilgrimage framing is light flavor, not a setting. No
  invented characters, no plot beyond the path and the pilgrim.
- Station display output (`lib/stations.rexx`) is monochrome by default,
  plain-style, modeled on mainframe operator console conventions.

## Tooling Constraints

**Primary interpreter**: Regina REXX (ANSI X3.274 / Cowlishaw definition).
No other interpreter is the development or CI target for the current plan.

**Primary development platform**: macOS, installed via Homebrew:
`brew install regina-rexx`. CI additionally validates on `ubuntu-latest`
via `sudo apt-get install -y regina-rexx`.

**No third-party REXX libraries.** See Principle II.

**CI tooling**: GitHub Actions (`.github/workflows/verify.yml`),
`bin/verify_solutions`, `bin/lint_citations`. The `bin/lint_citations`
script MUST be written in REXX (see Principle II).

**Reference materials**: The `reference/` directory is gitignored and
exists only on contributor machines. The repository MUST NOT contain
the Cowlishaw PDF. Contributors obtain it via the Internet Archive link
in `README.md`.

## Milestone Discipline

The project follows the locked milestone plan at `PLAN.md` (v1.1,
locked 2026-05-07). Development MUST respect this sequencing:

- **M1 (Smoke Test and Design Validation)** gates everything. Its exit
  criterion — a green end-to-end prototype and a completed
  `docs/DESIGN_DECISIONS.md` — MUST be met before M2 begins. Subsequent
  milestones build on M1's design decisions, not its prototype code.
- **M2–M7** each produce a runnable, tagged release. No stage's koans
  begin before the prior stage's CI is green.
- The standard work order in Principle I applies within every milestone.
  It MUST NOT be shortcut regardless of schedule pressure.

Amendments to the milestone sequence require a version bump to `PLAN.md`
following its existing format, with a rationale note documenting what
changed and why.

## Governance

This constitution supersedes all other project practices where they
conflict. Amendments MUST:

1. Increment `CONSTITUTION_VERSION` following semantic versioning:
   - MAJOR: removal or redefinition of any Core Principle.
   - MINOR: addition of a new principle or section, or material expansion.
   - PATCH: clarifications, wording, citation fixes, non-semantic changes.
2. Record rationale in the Sync Impact Report comment at the top of this file.
3. Not loosen Principles I through IV without explicit, documented approval
   and a migration plan for existing koans and CI.

All pull requests and code reviews MUST verify compliance with the Core
Principles above. Complexity MUST be justified against Principle II.

Runtime development guidance lives in `PLAN.md`. Design decisions
from M1 and later are recorded in `docs/DESIGN_DECISIONS.md`.

**Version**: 1.1.0 | **Ratified**: 2026-05-07 | **Last Amended**: 2026-05-09
