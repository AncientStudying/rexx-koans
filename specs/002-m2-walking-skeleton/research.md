# Research: M2 — Walking Skeleton

**Branch**: `002-m2-walking-skeleton` | **Date**: 2026-05-08
**Purpose**: Resolve the M2-specific design unknowns that the spec did
not nail down by reference to existing docs. M1's six architecture
questions are already answered in `docs/DESIGN_DECISIONS.md` (ADR-001
through ADR-006) and are inherited here verbatim — they are not
re-litigated.

---

## Decision 1: Assertion-call shape — how koans invoke the four assertion kinds

**Question**: M1 shipped a single assertion (`assert_equal`) called
through a thin koan-side `aeq:` wrapper that delegated to
`lib/meditation.rexx`. M2 needs four kinds: `assert`, `assert_equal`,
`assert_not_equal`, `assert_datatype` (FR-005). How do koans invoke
them without each koan duplicating four wrapper labels?

**Decision**: **Single-file dispatcher with a koan-side `m:` wrapper
that takes the assertion kind as the first argument.**

The library is one file — `lib/meditation.rexx` — invoked via the
existing M1 pattern `CALL 'lib/meditation.rexx' kind, arg1, arg2,
koan_file, n, line`. The library `PARSE`s the kind and dispatches
internally to the right diagnostic. Each koan defines exactly ONE
local label (`m:`) that wraps the call and exits non-zero on a damaged
karma return. The shape:

```rexx
n = 0
n = n + 1; CALL m 'eq', '4', 2 + 2, n
n = n + 1; CALL m 'neq', 'a', 'b', n
n = n + 1; CALL m 'true', (1 = 1), '', n
n = n + 1; CALL m 'datatype', 5, 'W', n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/01_about_strings.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
```

**Rationale**:
- Preserves M1's external-routine pattern exactly — minimal cognitive
  load on contributors who walked M1.
- One local wrapper per koan, not four. Citation-rich teaching comments
  stay the focus.
- The koan author chooses an assertion kind by passing one of four short
  tokens (`'eq'`, `'neq'`, `'true'`, `'datatype'`), not by selecting a
  routine name — keeps the koan source visually uniform.
- `arg2` is unused for `'true'` kind (passed as `''`); the dispatcher
  ignores it. The cost of one ignored argument is acceptable for the
  uniformity it buys.
- Per ADR-004, the library compares against the literal string
  `'FILL_ME_IN'`. This continues to work for `eq`, `neq`, and
  `datatype`. For `'true'`, the FILL_ME_IN check operates on `arg1`
  only — a koan with `CALL m 'true', FILL_ME_IN, '', n` triggers the
  blank diagnostic when `arg1` evaluates to `'FILL_ME_IN'`.

**Alternatives considered**:
- **One file per kind** (`lib/meditation/aeq.rexx`, `aneq.rexx`,
  `at.rexx`, `adt.rexx`) — rejected. Spreads the diagnostic vocabulary
  across four files; doubles the surface lint and test must cover; no
  meaningful gain in readability.
- **No dispatcher; koan defines four local labels** — rejected. Every
  koan would carry ~20 lines of identical boilerplate. Constitution V
  ("voice") is harder to honor when boilerplate dominates the file.
- **INTERPRET to load shared boilerplate at koan top** — rejected.
  ADR-001 standardizes on subprocess and the koan-internal
  `INTERPRET` would just re-introduce the scoping risks ADR-001 paid
  to remove.

---

## Decision 2: Subtitle extraction format

**Question** (Clarification 2 from spec): Each koan declares its
pilgrim-voice subtitle in its own header. What is the structured
header convention `lib/stations.rexx` parses?

**Decision**: **A single-line directive in a top-of-file comment of the
form `Station: <subtitle text>`.** The directive may appear anywhere
in the leading comment block of the koan, on its own line, with any
amount of leading whitespace and comment-prefix characters.

Concretely the parse rule:
1. `lib/stations.rexx` reads the koan file line by line until the
   first non-comment, non-blank line (the first executable REXX clause).
2. Within those leading lines, find the first line whose stripped form
   matches `Station: <text>` (case-sensitive on `Station:`).
3. The subtitle is everything to the right of `Station:` after one
   space, with leading/trailing whitespace stripped.
4. If no such directive exists, the station displays with an empty
   subtitle and `bin/lint_citations` reports the koan as missing a
   subtitle (FR-007 then forces the build red — see ADR extension below).

Example header:

```rexx
/* 01_about_strings.rexx
 *
 * Station: Of the Word Made String
 *
 * Cowlishaw §2.1, p. 15 — Constants
 *
 * ...teaching comment for the first concept group...
 */
```

**Rationale**:
- One-line directive in a comment block costs nothing in REXX
  source — it is just a comment from the interpreter's view.
- A line-prefix scan is the simplest possible parser; `lib/stations.rexx`
  needs ~10 lines of REXX to implement.
- Co-locating subtitle with citation in the same comment block
  reinforces that the koan file is self-contained metadata-wise
  (Constitution III spirit).
- Aligns with the existing M1 leading-comment convention in
  `koans/00_about_smoke.rexx`.

**Alternatives considered**:
- **Subtitle in `path_to_enlightenment.rexx`** — rejected. Drift
  between the manifest and the koan file is easy and undetectable;
  changing a subtitle would touch two files.
- **Hardcoded subtitle table in `lib/stations.rexx`** — rejected.
  Same drift risk; new koans require touching a separate file.
- **First non-`Cowlishaw` comment line treated as subtitle** —
  rejected. Too implicit; depends on writing convention rather than
  a parseable directive.

**Lint addition**: `bin/lint_citations` is extended in M2 to also
verify each koan has exactly one `Station: ...` directive in its
leading comment block. (The script's name is preserved despite the
expanded scope; renaming is a cosmetic change deferred to a future
milestone.) FR-013 covers citation; the subtitle check is a natural
companion that fits the same scan and adds two-to-three lines of REXX.

---

## Decision 3: Resume mechanic — pre-pass vs walk-and-discover

**Question**: Spec FR-002 + Story 2 require the runner to "resume at
the first unsolved koan." Does the runner do a pre-pass to determine
state for all stations before rendering, or does it walk-and-discover
(execute in order, mark each station as it goes, render at the end)?

**Decision**: **Walk-and-discover, single pass.** The runner executes
each koan in order; on the first non-zero exit, it stops and renders
the station list with `[  ok  ]` for every koan it executed
successfully so far, `[ here ]` for the failing koan, and blank for
every koan it has not yet reached.

**Rationale**:
- Matches the literal display in `PLAN.md` §11 (only three states; no
  "would-pass" state for unattempted-but-solved koans).
- Avoids running the curriculum twice. SC-002 ("under one second on a
  fully solved Stage I") is comfortable with one pass; with a pre-pass
  we'd double the work for marginal UX gain.
- The pilgrim's mental model is simpler: the runner walks; what it
  walked, you see. A "blank" marker means "not walked yet in this run,"
  which is true and unambiguous.
- The closing benediction is printed only when the loop completes
  without stopping — i.e., when every station was actually walked and
  passed. This is the same single-pass invariant.

**Implementation note**: The runner accumulates a list of
`(seq, topic, status)` tuples as it walks. On stop or completion, it
hands the list (plus remaining-from-manifest stations as blank) to
`lib/stations.rexx` for rendering. Fixed-pitch alignment is computed
from the maximum-width topic across all stations in the manifest.

**Alternatives considered**:
- **Pre-pass to mark `[ok]` for all currently-passing koans then
  render "here" + blanks** — rejected. Doubles work; surfaces
  "would-pass" status that doesn't match `PLAN.md` §11.
- **Persist last-good state across runs in a state file** — rejected.
  `PLAN.md` §5 explicitly says "no state file is required because
  correctness is re-derived from the sources on each run" — re-deriving
  every run is the design.

---

## Decision 4: Cross-platform stdout byte-equivalence — what the fixture covers

**Question** (Clarification 3 from spec): FR-017 requires the runner's
stdout for a fully-solved Stage I walk to be byte-identical across
macOS and Ubuntu, asserted against a committed reference fixture. What
sources of platform divergence does the fixture need to dodge or
control?

**Decision**: **Constrain runner output to ASCII-only, LF line endings,
no timestamps, no PIDs, no temp-file paths, no locale-sensitive
formatting.** The fixture is a literal copy of expected stdout.

Concrete rules adopted by `lib/pilgrimage.rexx` and `lib/stations.rexx`:
1. **Encoding**: ASCII only in all human-facing strings. The `§`
   character in Cowlishaw citations is *not* in runner output —
   citations live in koan teaching comments only and are never echoed
   by the runner. The runner's UI vocabulary is restricted to ASCII.
2. **Line endings**: LF only. The runner uses `SAY` (which on Regina
   emits the platform newline); the CI smoke step normalizes the
   captured output with `tr -d '\r'` before comparison to defend
   against any future Regina build that emits CRLF.
3. **No volatile values**: no timestamps, no PIDs, no temp file paths
   in stdout. The temp-file plumbing M1 used for capturing koan output
   is preserved but the path itself is never printed.
4. **Locale**: the runner sets `LC_ALL=C` in `bin/pilgrimage` before
   exec'ing `regina` to defend against locale-driven number/date
   formatting differences.
5. **Fixed-pitch alignment**: spaces only — no tabs.
6. **Subprocess output**: when a koan fails, the runner pipes the
   subprocess stdout through; for a fully-solved walk, no koan fails,
   so subprocess output never lands in the captured stream. The
   fixture covers only the runner's own SAY output.

**Rationale**:
- These rules collectively reduce the cross-platform divergence
  surface to "Regina's `SAY` produces the same characters when given
  the same string, modulo line endings" — which is well within the
  ANSI X3.274 conformance both Homebrew and apt Regina builds carry.
- ASCII-only avoids UTF-8 vs. ISO-8859-1 file encoding ambiguity in
  the fixture.
- `LC_ALL=C` in the launcher is one line; large insurance against
  future locale-driven flakiness.

**Alternatives considered**:
- **Capture a hash of stdout instead of full text** — rejected. A hash
  fixture is opaque on diff; when the fixture is wrong the contributor
  cannot tell what changed. Plain-text fixture under git diff is
  self-explanatory.
- **Use a "redaction" filter** (sed-replace timestamps to placeholders)
  — rejected. The runner has no timestamps to redact in the first
  place; banning them in source is simpler than redacting in CI.
- **Permit Unicode** — rejected. The §-symbol in citations is the
  only Unicode candidate, and citations are a koan-content concern,
  not runner output.

---

## Decision 5: Path manifest format

**Question**: `koans/path_to_enlightenment.rexx` is the master ordering
manifest. Is it executable REXX (loaded as a stem) or a static data
file? How is it consumed?

**Decision**: **Executable REXX that populates a `koans.` stem and
`EXIT`s.** The runner loads it via `CALL`:

```rexx
/* koans/path_to_enlightenment.rexx — Stage I order. */
koans.0 = 6
koans.1 = 'koans/00_about_asserts.rexx'
koans.2 = 'koans/01_about_strings.rexx'
koans.3 = 'koans/02_about_variables.rexx'
koans.4 = 'koans/03_about_expressions.rexx'
koans.5 = 'koans/04_about_clauses.rexx'
koans.6 = 'koans/05_about_say.rexx'
RETURN
```

The runner does:

```rexx
CALL 'koans/path_to_enlightenment.rexx'
DO i = 1 TO koans.0
  ...
END
```

**Rationale**:
- A REXX stem is the natural in-language data structure; the runner
  already speaks REXX.
- Stages append to the manifest by adding lines and bumping `koans.0`
  — trivial diff in future milestones.
- A `CALL`'d file shares variable scope with the runner (no
  PROCEDURE), so the stem is directly accessible. This is the one
  place we deliberately use shared-scope semantics; the manifest is
  data, not behavior.
- Makes a missing or malformed manifest produce a clear REXX-level
  error (uninitialized stem, empty stem) that the runner can detect
  and surface in pilgrim voice.

**Alternatives considered**:
- **Plain text file, one path per line** — rejected. Requires a parser
  and adds an I/O code path the runner does not otherwise need.
- **Hardcoded list inside `lib/pilgrimage.rexx`** — rejected. Edits to
  the curriculum order become edits to the runner; violates the
  separation `PLAN.md` §4 implies between curriculum and runner.

---

## Decision 6: Onboarding — what the first invocation looks like

**Question**: Spec FR-016 says `README.md` start instructions must be
sufficient for a first run. What does the pilgrim see on the very
first invocation — bare failure dump, or a welcome banner?

**Decision**: **A minimal banner above the station list, no separate
welcome screen.** The runner always prints:

```
THE PATH OF REXX

  [ here ] 00 about_asserts        The First Truths

  This koan awaits your contribution. Replace the FILL_ME_IN symbol
  with the value the pilgrim must learn.

  Damaged at: koans/00_about_asserts.rexx, line <L>.
  You have walked 0 stations. 6 stations remain.
```

The header line `THE PATH OF REXX` (kept verbatim from M1) is the
banner. There is no separate "welcome, pilgrim" screen on the first
run — the path itself is the welcome.

**Rationale**:
- Constitution V ("Diagnostic First, Pilgrimage Flavor Second"): a
  separate welcome screen is flavor-first. The diagnostic is what the
  pilgrim needs.
- A pilgrim who runs the runner a hundred times wants the same lean
  output every time. Special-casing first run adds state we don't
  want.
- The README onboarding (separate from runner output) carries the
  conceptual framing: "you are the pilgrim; run `bin/pilgrimage`; fix
  the FILL_ME_IN; run again."

**Alternatives considered**:
- **First-run welcome banner that suppresses on subsequent runs** —
  rejected. Requires state.
- **Welcome banner every run** — rejected. Becomes noise in the
  100th run.
- **Include the closing benediction's tone in the on-failure output**
  — rejected. The benediction is the reward for completion; emitting
  it on failure cheapens it.

---

## Decision 7: README onboarding length and structure

**Question**: FR-016 says `README.md` must be sufficient for first
run with no other lookups. What's in it for M2?

**Decision**: A focused four-section README (no marketing fluff):

1. **What this is** — one paragraph: REXX Koans is a self-paced,
   test-driven training course; you are the pilgrim; the path is
   thirty-plus koans; M2 ships Stage I.
2. **Install Regina** — `brew install regina-rexx` for macOS,
   `sudo apt-get install -y regina-rexx` for Ubuntu, with a
   `regina --version` verification.
3. **Walk the path** — `./bin/pilgrimage`, what to expect on the
   first run, how to find FILL_ME_IN in the koan, how to re-run.
4. **Read further** — link to the Internet Archive scan of *The REXX
   Language* (2nd edition), pointer to `PLAN.md` and
   `docs/PHILOSOPHY.md`.

**Rationale**:
- Mirrors the four-step pilgrim flow: orient → install → walk → read.
- Keeps marketing-to-mechanics ratio low (PLAN.md §12).
- Internet Archive link is required by `PLAN.md` §12; included
  prominently because Stage I citations reference page numbers in that
  scan.

**Alternatives considered**:
- **Prose-heavy README with project history and philosophy** —
  rejected. PLAN.md §12 explicitly cautions against this; philosophy
  belongs in `docs/PHILOSOPHY.md` (deferred to a later milestone) and
  history belongs in commit messages.

---

## Decision 8: Solution-first work order for six koans simultaneously

**Question**: Constitution Principle I requires solution-first
development per koan. With six koans in M2, what's the practical
ordering — six full vertical slices, or write all six solutions then
all six koans?

**Decision**: **Six independent vertical slices, in curriculum order
(00 → 05).** Each koan goes solution → koan → runner-passes-it →
lint-passes-it before the next slice begins.

**Rationale**:
- Vertical slices ground the assertion library design choices in real
  teaching content earlier — if `assert_datatype` turns out to be
  awkward in practice, we discover it at koan 02, not at koan 05.
- Curriculum order matches the runner's resume mechanic: a partially
  shipped Stage I (e.g., 00–02 done, 03–05 stubbed) is still a
  walkable pilgrimage that fails at 03 cleanly. This is useful for
  intermediate validation.
- Constitution Principle I says "solution → koan" within each koan;
  it doesn't mandate a horizontal phase. The vertical slice is
  consistent.

**Implementation note**: Tasks (Phase 2) will reflect this — six
slice-shaped task groups, plus shared infrastructure tasks (path
manifest, station display, launcher, fixture, CI workflow) that bracket
the slices.

**Alternatives considered**:
- **All six solutions in one phase, then all six koans** — rejected.
  Defers the runner-end-to-end check until late; finds problems with
  the assertion library only after all six teaching contents are
  written.

---

## Inherited M1 Decisions (NOT re-litigated in M2)

These are recorded in `docs/DESIGN_DECISIONS.md` (M1) and are adopted
verbatim by M2:

- **ADR-001** — Koan loading via subprocess. M2 keeps subprocess.
- **ADR-002** — No shared assertion state across runner/koan. M2
  keeps subprocess isolation; the path manifest is the only deliberate
  shared-scope `CALL` (Decision 5 above; manifest is data, not code).
- **ADR-003** — `SIGNAL ON SYNTAX` is a koan-internal concern only.
- **ADR-004** — FILL_ME_IN detection by literal string comparison
  to `'FILL_ME_IN'` continues unchanged. M2's expanded vocabulary
  (Decision 1) preserves the same comparison.
- **ADR-005** — Cross-platform Regina parity verified by CI matrix.
  M2 extends the matrix obligations to include the runner smoke step
  (FR-017) and the byte-fingerprint fixture (Decision 4).
- **ADR-006** — `lint_citations` written in REXX. M2 extends
  `lint_citations` to also verify the `Station:` directive (Decision
  2).

---

## Summary

| # | Question | Decision |
|---|---|---|
| 1 | Multi-kind assertion call shape | Single-file dispatcher + one koan-side `m:` wrapper |
| 2 | Subtitle extraction format | `Station: <text>` directive in koan leading comment |
| 3 | Resume mechanic | Walk-and-discover, single pass |
| 4 | Cross-platform stdout fingerprint | ASCII-only, LF, no volatiles, `LC_ALL=C` in launcher |
| 5 | Path manifest format | Executable REXX populating a `koans.` stem |
| 6 | First-run onboarding | Banner + station list, no separate welcome |
| 7 | README structure | Four sections: what it is / install / walk / read further |
| 8 | Solution-first work order | Six vertical slices in curriculum order |

All open M2-specific design questions are resolved. Phase 1 may
proceed with full design artifacts.
