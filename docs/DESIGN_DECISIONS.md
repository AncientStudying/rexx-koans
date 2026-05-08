# Design Decisions — M1

**Status**: Final for M1.
**Branch**: `001-m1-smoke-test`.
**Locked**: 2026-05-08.

The six records below answer the open architecture questions enumerated in
`PLAN.md` §10 (M1 Open Questions). Each was first answered from REXX
semantics knowledge in `specs/001-m1-smoke-test/research.md` and is now
backed by evidence from the working M1 prototype.

The prototype was exercised on macOS 25.4 (Darwin) with Regina REXX 3.9.7
(64-bit, build 18 Mar 2025) installed via Homebrew. CI parity on
`ubuntu-latest` is verified by `.github/workflows/verify.yml` and is the
basis of the cross-platform claim in Decision 5.

---

## ADR-001 — Koan Loading Strategy

**Question**: Does the runner load koans by INTERPRETing their text, by
CALLing them as subroutines, or by spawning each as a separate `regina`
process?

**Decision**: **Subprocess.** The runner invokes each koan as an independent
Regina process via `ADDRESS SYSTEM 'regina <koan>'`.

**Rationale**:
- Subprocess gives complete variable-space and error-recovery isolation
  between runner and koan, and between koans.
- A koan syntax error or runtime fault terminates only the koan
  subprocess, never the runner.
- `INTERPRET` would execute the koan's text in the runner's scope,
  requiring careful PROCEDURE wrappers around every eval site to prevent
  variable leakage. Any uncaught syntax error in the interpreted string
  would abort the runner.
- `CALL <label>` would force every koan to be structured as a labeled
  subroutine library, breaking the self-contained-file design and
  complicating PROCEDURE scoping.
- The subprocess startup cost is negligible (~20 ms per koan on the
  prototype) for an O(30) koan curriculum.

**Evidence**:
- `lib/pilgrimage.rexx` runs `koans/00_about_smoke.rexx` via
  `ADDRESS SYSTEM 'regina <koan> > <tmpfile> 2>&1'`, captures `RC`,
  reads the tempfile, and prints the contract output. Exits 1 on the
  unfilled koan, 0 on the filled-in koan. Verified locally on
  Regina 3.9.7 (macOS).
- The runner exits cleanly even when the koan exits non-zero — no
  variable leakage, no propagation of REXX-level errors.

**Alternatives considered**:
- **INTERPRET** — rejected. Scoping and error-recovery risks dominate the
  marginal speed benefit.
- **CALL <label>** — rejected. Constrains koan structure to labeled
  subroutines.

---

## ADR-002 — Shared Assertion State

**Question**: Can the assertion library maintain pass/fail counters that
survive across koan invocations without leaking runner internals into the
koan namespace? (Originally framed as a `PROCEDURE EXPOSE` question.)

**Decision**: **Not needed.** Under the subprocess model (ADR-001), each
koan runs in its own REXX process; counters are tracked inside the koan
subprocess and the only signal the runner needs is the exit code.

**Rationale**:
- There is no shared REXX variable space between runner and koan, so
  there is no surface across which to leak.
- The koan tracks its own assertion ordinal in a local variable `n` and
  passes it to `lib/meditation.rexx` so the diagnostic message can name
  which assertion failed.
- The runner reads the subprocess exit code to determine pass/fail (0 vs
  non-zero); it captures stdout for the diagnostic to surface to the user.
- `PROCEDURE EXPOSE` becomes relevant only *within* a koan if internal
  helpers need to access koan-level state, which is a koan-internal
  concern and not the runner/koan boundary.

**Evidence**:
- The smoke koan tracks `n` as a local counter and passes it to
  `lib/meditation.rexx` with each `CALL`. The library prints "The 2nd
  assertion of koans/00_about_smoke.rexx has damaged your karma..." with
  the correct ordinal — verified locally for the FILL_ME_IN case (n=2).
- The runner sees no koan-internal state at all. It only inspects `RC`
  from the `ADDRESS SYSTEM` invocation and the captured tempfile.

**Alternatives considered**:
- **Shared state via INTERPRET** — moot under ADR-001.
- **File-based state (counter in a temp file)** — unnecessary; the
  subprocess model gives strict isolation for free.

---

## ADR-003 — SIGNAL ON SYNTAX Behavior

**Question**: When a koan contains a syntax error, does `SIGNAL ON SYNTAX`
fire cleanly and let the runner report and continue, or does Regina abort
before the trap activates?

**Decision**: **Koan-internal concern only.** The runner never needs to
trap syntax errors because it does not execute koan code in-process. A
koan with a syntax error exits non-zero from the subprocess and the
runner reports it like any other failure.

**Rationale**:
- A REXX syntax error in a koan causes the Regina subprocess to exit
  non-zero and write a diagnostic to stderr. Both are captured by the
  runner's `2>&1` redirection into the tempfile, so the user sees the
  Regina parser's own message.
- `SIGNAL ON SYNTAX` inside a koan can still be useful for trapping
  runtime SYNTAX conditions (e.g., a malformed expression hit during an
  assertion); under the subprocess model this is purely a koan-internal
  decision.

**Evidence**:
- Inducing a syntax error in `bin/verify_solutions` (a stray `/*` inside
  a comment opened a nested comment that was never closed) produced
  Regina error 6 ("Unmatched comment delimiter") on stderr and a
  non-zero exit. Wrapping that file with the runner's subprocess
  invocation pattern would surface that diagnostic verbatim — the
  runner remains alive and reports the failure to the user.

**Alternatives considered**: None — the subprocess model removes the need
for any in-runner trap.

---

## ADR-004 — FILL_ME_IN Detection

**Question**: Does an uninitialized symbol reliably evaluate to its
uppercase name? Can the assertion library distinguish "not filled in"
from "filled in with the wrong value"?

**Decision**: **Yes, reliable.** REXX's uninitialized-simple-symbol
semantics (Cowlishaw §2.5) ARE the FILL_ME_IN mechanism. The assertion
library compares each argument to the literal string `'FILL_ME_IN'`; a
match produces the `fail_blank` diagnostic, a mismatch with non-equal
values produces the `fail_mismatch` diagnostic.

**Rationale**:
- An uninitialized simple symbol evaluates to its name in uppercase. So
  `FILL_ME_IN` in source (when never bound) yields the string
  `'FILL_ME_IN'`.
- A pilgrim who fills in a wrong literal value produces a string that
  is not `'FILL_ME_IN'`, so the mismatch path triggers — distinct
  diagnostic, distinct return code.
- A pilgrim who deliberately assigns `'FILL_ME_IN'` to a variable would
  trigger `fail_blank` erroneously; this is an accepted false positive
  outside any realistic curriculum scenario.

**Evidence**:
- `lib/meditation.rexx` line 27 returns 1 (fail_blank) when called with
  `expected='three', actual='FILL_ME_IN'`. The captured prototype run
  produced the verbatim message "This koan awaits your contribution.
  Replace the FILL_ME_IN symbol with the value the pilgrim must learn."
  followed by "Damaged at: koans/00_about_smoke.rexx, line 27."
- Replacing `FILL_ME_IN` in the koan with the literal `'wrong'` produced
  the fail_mismatch diagnostic instead, confirming the two states are
  distinguishable.

**Alternatives considered**:
- **Sentinel string** (e.g. `'__FILL__'`) — rejected. The
  uninitialized-symbol pattern is more idiomatic and forces no extra
  conventions on the koan author.

---

## ADR-005 — Cross-Platform Regina Parity

**Question**: Does `apt-get install regina-rexx` on `ubuntu-latest`
produce a Regina that behaves equivalently to Homebrew's macOS Regina
for the operations the project depends on?

**Decision**: **Empirically validated by CI.** The CI workflow runs
`verify_solutions` and `lint_citations` on both `ubuntu-latest` and
`macos-latest` matrix legs; both jobs must pass green for any merge to
`main`.

**Rationale**:
- Both distribution channels package Regina, an ANSI X3.274 conformant
  implementation. Core operations (symbols, strings, SIGNAL,
  PROCEDURE, stream I/O, `ADDRESS SYSTEM`) should be identical across
  conformant builds.
- Version skew is the primary risk. Homebrew currently ships Regina
  3.9.7 (macOS); Ubuntu 24.04 apt ships 3.9.x as well, but exact patch
  versions may differ over time.
- The right place to detect divergence is in CI on every push, not in
  a one-time audit.

**Evidence**:
- M1 local validation: Regina 3.9.7 on macOS executes the runner,
  meditation library, verify_solutions, and lint_citations cleanly.
- CI green status on both matrix legs is the primary acceptance signal
  per Constitution Principle IV.

**Alternatives considered**:
- **Pin a specific Regina version in CI** — rejected for M1. Pinning
  would mask the very divergence we want to detect. Reconsider only if
  CI-detected divergence proves persistent.
- **Constrain code to a documented common subset** — adopted implicitly:
  no Regina-specific extensions are used in `lib/`, `bin/`, or `koans/`
  (Constitution Principle II).

---

## ADR-006 — `lint_citations` in REXX

**Question**: Can REXX scan files and match the citation pattern
comfortably, or does awkwardness justify a non-REXX implementation?

**Decision**: **REXX is sufficient.** `bin/lint_citations` is implemented
in pure REXX using only Regina built-ins (`LINEIN`, `POS`, `SUBSTR`,
`DATATYPE`, `VERIFY`, `LEFT`, `RIGHT`).

**Rationale**:
- The citation pattern (`Cowlishaw §<sec>, p. <page>`) is a fixed-prefix
  literal followed by a small structured suffix. No regex required.
- REXX's string built-ins handle the scan in roughly 60 lines.
- A REXX implementation honors Constitution Principle II without
  qualification and dogfoods the language for a file-processing task —
  directly relevant to Stage VI of the curriculum.

**Evidence**:
- `bin/lint_citations` (~80 lines including comments) detects valid
  citations on the smoke koan and rejects three failure modes verified
  locally:
  - missing citation → `[lint] <file> ... MISSING`, exit 1.
  - malformed page (`p. abc` instead of digits) → MISSING, exit 1.
  - empty `koans/` → `koans/ is empty`, exit 1.
- The implementation needed no Regina-specific extensions and no
  workarounds for fundamental REXX limitations.

**Alternatives considered**:
- **Shell or Python implementation** — rejected. No technical
  impossibility was encountered, so Constitution Principle II applies.

---

## Summary

| ADR | Question | Decision | Confidence |
|-----|----------|----------|------------|
| 001 | Koan loading | Subprocess | High (verified locally) |
| 002 | Shared state | Not needed under subprocess | High |
| 003 | SIGNAL ON SYNTAX | Koan-internal only | High |
| 004 | FILL_ME_IN | Uninitialized-symbol comparison | High |
| 005 | Cross-platform parity | Verified by CI | Medium (CI is authoritative) |
| 006 | lint_citations in REXX | Sufficient | High (verified locally) |

All six M1 questions have written, evidence-backed answers. SC-002 is
satisfied: M2 can begin without re-investigating any of these decisions.
