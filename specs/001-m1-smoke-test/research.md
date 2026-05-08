# Research: M1 — Smoke Test and Design Validation

**Branch**: `001-m1-smoke-test` | **Date**: 2026-05-07
**Purpose**: Resolve the six open architecture questions defined in PLAN.md §10 (M1 section)
before implementation begins, using REXX semantics knowledge and known Regina behavior.
The prototype will empirically verify or revise each finding and record the final answers
in `docs/DESIGN_DECISIONS.md`.

---

## Decision 1: Koan Loading Strategy (INTERPRET vs. CALL vs. subprocess)

**Question**: Does the runner load koans by INTERPRETing their text, by CALLing them as
subroutines, or by spawning each as a separate `regina` process?

**Decision**: Use **subprocess** (separate `regina` process per koan file).

**Rationale**:
- INTERPRET executes a string in the *current* scope. Variable isolation between runner and
  koan is impossible without careful PROCEDURE wrappers around every eval site. Any koan
  syntax error that is not caught by SIGNAL ON SYNTAX in the interpreted string would
  abort the runner process entirely.
- CALL (as a labeled internal subroutine) would require koans to be structured as subroutine
  libraries rather than standalone programs, breaking the "self-contained file" design and
  complicating PROCEDURE scoping.
- **Subprocess** (`ADDRESS SYSTEM "regina koans/00_about_smoke.rexx"` or equivalent) gives
  complete isolation: the koan runs in its own Regina process, with its own variable space
  and error recovery. The runner captures the exit code and reads stdout/stderr. Koan syntax
  errors kill only the koan subprocess, not the runner. Variable leakage between runner and
  koan is impossible by construction.
- Tradeoff: subprocess is slightly slower per koan (a new Regina startup per file), but
  for an interactive training tool running O(30) koans this is unnoticeable. The isolation
  benefit is decisive.

**Alternatives considered**:
- INTERPRET: rejected — scoping and error-recovery risks outweigh the speed benefit.
- CALL: rejected — requires koans to export a labeled entry point, constraining koan structure.

**Prototype verification**: M1 must confirm that `ADDRESS SYSTEM` (or `ADDRESS COMMAND`)
correctly invokes `regina koanfile.rexx` on both macOS and Ubuntu, captures exit code, and
that the runner can distinguish a failing koan (non-zero exit) from a passing one (exit 0).

---

## Decision 2: Shared Assertion State (PROCEDURE EXPOSE)

**Question**: Can the assertion library maintain pass/fail counters that survive across koan
invocations without leaking runner internals into the koan namespace?

**Decision**: **Not needed for subprocess model.** Each koan subprocess maintains its own
assertion counters internally and communicates outcome to the runner via exit code and stdout.

**Rationale**:
- Under the subprocess model (Decision 1), each koan runs in an isolated process. There is no
  shared REXX variable space between runner and koan. The runner does not need to expose any
  state to the koan.
- The koan file itself calls assertion routines from `lib/meditation.rexx` (included via some
  mechanism — either copied inline or loaded via a relative path convention). The assertion
  library tracks pass/fail internally within the koan subprocess.
- When the koan subprocess exits, the runner reads the exit code (0 = all pass, 1 = at least
  one failure) and any failure output from stdout.
- PROCEDURE EXPOSE becomes relevant *within* a koan if internal functions need to access
  the assertion counter, but this is a koan-internal concern, not a runner/koan boundary concern.

**Alternatives considered**:
- Shared state via INTERPRET: rejected with Decision 1.
- File-based state (writing counters to a temp file): unnecessary under subprocess model.

**Prototype verification**: Confirm that the koan subprocess can include or call `meditation.rexx`
routines and maintain assertion counters within the subprocess lifetime.

---

## Decision 3: SIGNAL ON SYNTAX Behavior

**Question**: When a koan contains a syntax error, does the trap fire cleanly and let the runner
report and continue, or does Regina abort before the trap activates?

**Decision**: Under the subprocess model, **SIGNAL ON SYNTAX is a koan-internal concern only.**
The runner does not need to trap syntax errors — the koan subprocess either exits non-zero
(syntax error kills the process) or exits zero.

**Rationale**:
- If a koan file has a REXX syntax error, Regina will detect it at parse time (before execution)
  and exit with a non-zero code and an error message to stderr. The runner subprocess call
  captures this as a non-zero exit code and surfaces the stderr output as the failure message.
- The runner never executes the koan code in-process, so the runner itself is never exposed
  to koan syntax errors.
- Within the koan subprocess, `SIGNAL ON SYNTAX` can be used to trap runtime syntax conditions.
  The M1 prototype should test whether `SIGNAL ON SYNTAX` within `lib/meditation.rexx` correctly
  traps a REXX syntax condition raised during an assertion (e.g., a koan that calls assert with
  a malformed expression).

**Prototype verification**: Write one smoke test case that triggers a SYNTAX condition inside
the koan subprocess and confirm: (a) the runner receives a non-zero exit, (b) stderr contains
a useful message, (c) the runner continues to the next koan (or exits gracefully as designed).

---

## Decision 4: FILL_ME_IN Detection

**Question**: Does an uninitialized symbol reliably evaluate to its uppercase name? Can the
library distinguish "not filled in" from "filled in with the wrong value"?

**Decision**: **Yes, reliable.** REXX's uninitialized symbol semantics are the FILL_ME_IN mechanism.

**Rationale**:
- The REXX language specification (Cowlishaw §2.5) defines that an uninitialized simple symbol
  evaluates to its own name, uppercased. `FILL_ME_IN` → the string `"FILL_ME_IN"`.
- The assertion library checks whether either argument to an assertion equals the literal string
  `"FILL_ME_IN"` (case-insensitive, since REXX comparison is case-sensitive by default but the
  symbol name is always uppercased). If so, it emits the "awaits your contribution" message
  instead of a value-mismatch message.
- Distinction is reliable: a pilgrim who fills in the wrong value produces a string that differs
  from `"FILL_ME_IN"`, triggering the standard mismatch message. A pilgrim who has not yet
  filled in the blank produces exactly `"FILL_ME_IN"`, triggering the blank-detection message.
- Edge case: a pilgrim who intentionally sets a variable to the string `"FILL_ME_IN"` would
  trigger the blank-detection message erroneously. This is accepted as an acceptable false
  positive — it is not a realistic REXX value in a curriculum context.

**Prototype verification**: The smoke koan uses `FILL_ME_IN` (uninitialized) as one argument
to `assert_equal`. Confirm the library produces the "awaits your contribution" message, distinct
from the mismatch message produced when a wrong value is supplied.

---

## Decision 5: Cross-Platform Regina Parity

**Question**: Does `apt-get install regina-rexx` on ubuntu-latest produce a Regina that behaves
equivalently to Homebrew's macOS Regina for the operations the project depends on?

**Decision**: **Empirically verify via CI.** Current expectation is high parity for ANSI X3.274
core operations; version differences are the primary risk.

**Rationale**:
- Both Homebrew and Ubuntu apt distribute Regina REXX, implementing the ANSI X3.274 standard.
  Core language operations (symbols, strings, SIGNAL, PROCEDURE, stream I/O) should be
  identical across standard-compliant builds.
- Known risk: Ubuntu apt may package an older Regina version than Homebrew. Version-specific
  behavior differences (e.g., `ADDRESS SYSTEM` syntax, stream I/O defaults) could cause CI to
  behave differently from local macOS development.
- The CI workflow runs the *same* scripts on both platforms. If any test passes on macOS but
  fails on Linux (or vice versa), the CI run will surface it immediately.

**Prototype verification**: M1 CI is the direct test. If divergence appears, document the specific
operation and the version difference in `docs/DESIGN_DECISIONS.md` and decide whether to:
(a) constrain the code to the common subset, (b) use platform detection, or (c) pin a specific
Regina version in CI.

---

## Decision 6: REXX File Scanning for lint_citations

**Question**: Can REXX scan files and match the citation pattern comfortably, or does awkwardness
justify a non-REXX implementation?

**Decision**: **REXX is sufficient.** Implement `bin/lint_citations` in REXX.

**Rationale**:
- The citation pattern to match is `Cowlishaw §N.N, p. NN` (where N.N is a section number like
  `2.3` and NN is a page number like `27`). This is a specific, fixed-prefix string with numeric
  suffix — not a complex regex.
- REXX's built-in string functions are well-suited: `LINEIN` reads lines, `POS` finds substrings,
  `DATATYPE` checks numeric characters, `WORD` and `SUBSTR` extract components. A REXX scanner
  that checks each line of each koan for this pattern is straightforward — roughly 30–40 lines.
- The REXX approach also dogfoods the language, demonstrating that REXX is practical for
  file-processing tasks (relevant to Stage VI of the curriculum).
- A shell or Python implementation would compromise Constitution Principle II (REXX-only in `bin/`)
  without a documented technical impossibility. No such impossibility exists here.

**Prototype verification**: Implement `bin/lint_citations` in REXX for M1. If the implementation
takes more than ~60 lines or requires workarounds for fundamental REXX limitations, document the
specific difficulty in `docs/DESIGN_DECISIONS.md` and decide whether to switch languages.

---

## Summary Table

| Question | Decision | Confidence | Verify in M1 |
|----------|----------|------------|--------------|
| Koan loading | Subprocess (`ADDRESS SYSTEM/COMMAND`) | High | ✅ Required |
| Shared state | Not needed (subprocess model) | High | ✅ Confirm subprocess isolation |
| SIGNAL ON SYNTAX | Koan-internal only; runner sees exit code | High | ✅ Test error koan |
| FILL_ME_IN detection | String comparison to `"FILL_ME_IN"` | High | ✅ Smoke koan exercises it |
| Cross-platform parity | Empirically via CI | Medium | ✅ CI is the test |
| lint_citations in REXX | REXX is sufficient | Medium-high | ✅ Implement and assess |
