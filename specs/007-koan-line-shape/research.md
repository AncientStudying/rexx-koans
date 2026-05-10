# Research — M2.5

This document captures the design decisions made during Phase 0
of `/speckit-plan` for M2.5 — Koan Assertion-Line Shape Cleanup.
The spec post-`/speckit-clarify` had no NEEDS-CLARIFICATION
markers; research is the formal record of the (small number of)
mechanical and procedural decisions the implementation rests on.
Each section names the decision, the rationale, the alternatives
considered, and any UAT evidence available before implementation.

## §1 — Wrapper-shared variable scope

**Decision**: The koan-local `m:` wrapper increments the
assertion-ordinal `n` directly, in the caller's variable pool,
without `EXPOSE` or any other scoping declaration.

**Rationale**: REXX subroutines defined as a label (e.g., `m:
PARSE ARG ...`) without an explicit `PROCEDURE` instruction
share the caller's variable pool by default. The wrapper is
already declared this way (see `koans/00_about_asserts.rexx:84`
on `main` HEAD). It can read and write the koan's `n`
transparently. `EXPOSE` only matters when `PROCEDURE` is in
play; here there is no `PROCEDURE` to expose past.

**Alternatives considered**:

- *Add `PROCEDURE EXPOSE n` to the wrapper.* Rejected:
  unnecessary ceremony; the current shape works without
  `PROCEDURE` and the cleanup does not introduce one.
- *Pass `n` into the wrapper from each call site.* Rejected:
  that is the legacy shape, which is precisely what the
  cleanup removes.
- *Store `n` in an external store (a stem variable indexed by
  filename, a state file, etc.).* Rejected: vastly more
  complex than the current direct-share, and offers no benefit.

**UAT evidence**: The spike at `stash@{0}` applied this
mechanic to `koans/00_about_asserts.rexx` and was UAT'd against
`bin/pilgrimage` in both unsolved (FILL_ME_IN-stop) and solved
(advance-to-next-koan) states. Behavior matched the pre-change
version exactly.

## §2 — Top-of-file `n = 0` initializer retention

**Decision**: Keep the `n = 0` line at the top of every koan
and solution file, immediately above the first concept block.
Do not move it into the wrapper or remove it.

**Rationale**: REXX raises a `NOVALUE` condition when an
uninitialized symbol is used in arithmetic. The wrapper's
`n = n + 1` would error on the first invocation if `n` were
not initialized. The top-of-file `n = 0` is the simplest
guard: one visible line, executed once when the koan is
loaded, before any assertion can be reached. It is also
honest — the pilgrim sees the counter exists, and sees that
the file starts with `n` at zero, even if they never see the
counter again.

**Alternatives considered**:

- *Lazy initialization inside the wrapper via SYMBOL guard:*
  ```rexx
  m: PARSE ARG kind, arg1, arg2
     IF SYMBOL('n') = 'LIT' THEN n = 0
     n = n + 1
     ...
  ```
  Rejected: the SYMBOL guard adds magic to the wrapper, hides
  the initialization from the pilgrim's reading order, and
  saves only one line of file-top boilerplate. The honesty
  cost outweighs the line saved.
- *Initialize via `NUMERIC` or via assignment in a procedure
  preamble.* Rejected: REXX has no concept of file-load
  preamble distinct from "lines above the first executable
  clause." The top-of-file assignment IS the preamble.
- *Remove the initializer and rely on the pilgrim never
  deleting it.* Rejected: nonsensical — there would be
  nothing to rely on.

**UAT evidence**: The spike kept the `n = 0` line at the top.
First-call-after-load worked correctly.

## §3 — `SIGL` semantics under in-wrapper assignment

**Decision**: The wrapper's in-body `n = n + 1` does not
perturb `SIGL`, and the external CALL to `lib/meditation.rexx`
receives the koan's `CALL m` line number as its sixth argument.
The "Damaged at: …, line N" diagnostic still names the
pilgrim-editable assertion line.

**Rationale**: In Regina REXX (the project's reference
interpreter per the constitution), `SIGL` is set whenever a
label-based transfer happens — `CALL <label>`, function call,
`SIGNAL <label>`. It is set *at the call site*, before
control transfers to the labeled subroutine. So when the
koan does `CALL m 'eq', ...`, `SIGL` is set to that line's
line number; control then transfers to `m:`. Inside `m:`,
the in-wrapper `n = n + 1` is a plain assignment expression
— it does not call any label and does not trigger `SIGL`
update. When the wrapper subsequently does `CALL
'lib/meditation.rexx' kind, arg1, arg2, '<path>', n, SIGL`,
the argument list is evaluated *before* the external CALL
transfers control, so the value of `SIGL` at that moment is
still the koan's `CALL m` line. The external CALL receives
that line number as its sixth argument.

**Alternatives considered** (only briefly, since the answer
is mechanical):

- *Pass `SIGL()` instead of `SIGL`.* Identical behavior;
  the bare symbol form is the existing convention.
- *Capture `SIGL` to a named local before the increment, then
  pass the local.* Defensive but unnecessary; the increment
  does not perturb `SIGL`.

**UAT evidence**: The spike's stdout fixture under
`bin/pilgrimage` matched the pre-change run exactly,
including the `Damaged at: <file>, line N` line numbers in
the unsolved-state probe. The Damaged-at line numbers were
on the assertion lines (e.g., line 33 for the first
FILL_ME_IN in `koans/00_about_asserts.rexx`), not on any
wrapper-internal line.

## §4 — Per-file path literal in the wrapper

**Decision**: Each koan and solution file's `m:` wrapper
hard-codes its own relative path as a string literal in the
third argument to `CALL 'lib/meditation.rexx' ...`. For
example:

```rexx
# In koans/00_about_asserts.rexx:
CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/00_about_asserts.rexx', n, SIGL

# In solutions/00_about_asserts.rexx:
CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/00_about_asserts.rexx', n, SIGL
```

**Rationale**: `lib/meditation.rexx` uses the path string in
failure messages ("the 5th assertion of <path> has damaged
your karma…"). The dispatcher needs the path; the cleanest
way to give it the path is for each file to know its own
name. This is already the legacy shape; the cleanup does not
change it.

**Alternatives considered**:

- *Use `PARSE SOURCE` to resolve the running file's path at
  runtime.* Rejected: `PARSE SOURCE` returns implementation-
  variable strings — full absolute path on macOS Regina,
  sometimes a shorter relative form on Linux Regina, and the
  exact string depends on how the runner invokes the file.
  Passing the result through to the dispatcher would expose
  the dispatcher's failure messages to platform-divergent
  paths, breaking the runner stdout fixture's byte-identity.
  The literal is the safe choice.
- *Store the path in a variable at the top of the file
  (e.g., `koan_path = 'koans/00_about_asserts.rexx'`) and
  reference it from the wrapper.* Defensible (avoids
  duplicating the literal between top and wrapper) but the
  legacy shape uses the inline literal in the wrapper, and
  changing it is out of scope for this cleanup.

## §5 — Validation procedure (bit-identity probe)

**Decision**: Validate behavior preservation via a two-state
probe, run pre- and post-change.

**State A — unsolved corpus**: every koan retains at least
one `FILL_ME_IN`. `bin/pilgrimage` stops at the first blank
and prints `Damaged at: <file>, line N`. The line number is
the assertion line containing the blank.

**State B — fully-solved corpus**: every `FILL_ME_IN` is
filled with the canonical value from the matching solution.
`bin/pilgrimage` walks the full path and prints the success
summary. Stdout matches `tests/fixtures/runner_stdout.txt`
byte-for-byte (modulo CRLF normalization).

The probe is run on `main` HEAD (pre-change baseline), then
on the feature branch HEAD (post-change). The expected
output of each state is the same on both. Differences are
defects.

**Rationale**: SC-004 (fixture byte-identity), SC-007 (CI
matrix green), and SC-010 (line-number identity in failure
messages) are the three quantitative acceptance gates.
State A drives SC-010; State B drives SC-004; both feed
into SC-007 via the runner-smoke step. A single probe
covering both states ensures the gates land together, not
sequentially.

**Alternatives considered**:

- *Programmatic diff via `bin/verify_solutions` only.*
  Insufficient: `verify_solutions` only confirms solutions
  pass; it does not exercise the failure path nor the
  unsolved state.
- *Synthetic-failure tests.* Rejected: the unsolved-state
  probe IS a synthetic-failure test (one FILL_ME_IN), and
  is real. No further synthesis needed.

**UAT evidence**: The spike's two-state probe under
`bin/pilgrimage` produced output indistinguishable from the
pre-change run. The success-state output matched the
fixture; the unsolved-state output named line 33 (the
correct line) for the FILL_ME_IN on the first assertion of
koan 00.

## §6 — Implementation order (spike-replay vs hand-edit)

**Decision**: For `koans/00_about_asserts.rexx`, replay the
spike via `git stash apply stash@{0}` (or hand-edit
identically; the spec governs, the spike is reference). For
the remaining eleven files (koans 01–05 and solutions 00–05),
hand-edit from the spec's wrapper template (FR-003 body) and
the FR-001 / FR-002 line-shape rule.

**Rationale**: The spike already encodes the validated
recipe for koan 00; replaying it costs nothing and gets
that file's UAT'd state back without re-doing the work.
For the remaining eleven files, hand-editing keeps the
contributor's eye on each file individually — the project
assumes uniform shape across the corpus (every file uses
the legacy `n = n + 1; ... , n` shape on every assertion
line and a 4-arg `m:` wrapper at the foot), but that
assumption is not yet independently verified for files
01–05 and the solutions tree. A fresh attentive read per
file is the cheapest way to catch any pre-existing
divergence and guarantees the cleanup is faithful per
file.

**Alternatives considered**:

- *Bulk regex/sed replacement across all 12 files.*
  Rejected: the per-file path literal in the wrapper is
  hard to template safely; a regex on assertion lines
  risks unintended matches in teaching prose (the prose
  contains text like "n = n + 1" or "CALL m" only as
  illustration in citations); even if the regex is
  precise, the wrapper rewrite (4 lines → 5 lines, with a
  per-file path literal in line 3) is awkward to script
  reliably across 12 files.
- *Replay the spike across all 12 files via a single
  patch.* Not applicable — the spike is a single-file
  change to koan 00; no equivalent multi-file patch
  exists.

**Risk**: If files 01–05 (or solutions 00–05) deviate
from the legacy shape in some way (extra assertion-line
patterns, alternative wrapper signatures, etc.), the
recipe needs adjustment for those files. Mitigation:
tasks.md will pre-grep the corpus to confirm shape
uniformity before edits begin; if divergence is found,
the spec's FR-001 / FR-002 still specify the *target*
shape, and the implementation simply applies the recipe
appropriate for whatever the pre-state is.

## §7 — Forward enforcement (review-only vs lint check)

**Decision**: Forward enforcement of the cleaned shape on
M3+ koans is review-only, gated by the §8 PLAN.md style
bullet (codified at commit `9a5de4a`). M2.5 does not
extend `bin/lint_citations` or add a new lint script.

**Rationale**: The legacy pattern is currently in 12
files; after M2.5, it is in zero. M3+ contributors
authoring new koans receive the §8 bullet as guidance
("Assertion lines stay single-statement"); reviewers
catch regressions during PR review. Adding a mechanical
lint check now would solve a hypothetical problem
(contributor regression) at the cost of more REXX in
`bin/lint_citations` or a new script. The spec's Out of
Scope section defers automation explicitly; if regression
proves common, a successor feature can add a
"n_pattern_lint" check whose mechanical pattern is
trivial (zero-match grep on `n = n + 1;` followed by
`CALL m`, plus zero-match grep on trailing-`n`
arguments).

**Alternatives considered**:

- *Add a check to `bin/lint_citations` now.* Rejected
  per the spec's Out of Scope; M2.4 just shipped and
  re-extending the same script in M2.5 risks scope
  creep. Defer.
- *Add a separate `bin/lint_assertion_shape` script.*
  Rejected: another tool to maintain, another CI step,
  for a problem that has not occurred yet.
- *Add a pre-commit hook that greps the corpus.*
  Rejected: hooks are contributor-side and not enforced
  by CI; the §8 style bullet plus PR review is the
  enforcement plane.

## §8 — Solution-koan edit ordering

**Decision**: Edit koans and solutions in lockstep within
one PR. Both trees converge on the cleaned shape together.
No partial-corpus commits where one tree is post-cleanup
and the other is pre-cleanup.

**Rationale**: SC-009 establishes the parity invariant —
the diff between any koan and its matching solution shows
only FILL_ME_IN ↔ value substitutions. That invariant
should hold at every commit on the feature branch, not
just at the PR's HEAD. Splitting into "koans first, then
solutions" would break the invariant on intermediate
commits, force the reviewer to track two divergent
states, and risk a CI failure window where
`verify_solutions` (running the *old* solutions against
the dispatcher contract) might surface unexpected
interactions. The dispatcher contract is unchanged so the
risk is theoretical, but lockstep eliminates it.

**Alternatives considered**:

- *Koans first, then solutions in a second PR or second
  commit.* Rejected per the parity-invariant argument.
- *Per-file commits in pairs (koan NN + solution NN
  together).* Acceptable — preserves the parity invariant
  per commit. This is the recommended granularity in
  `quickstart.md`. The spec does not mandate it; bulk
  commit is also acceptable.

**Implementation guidance**: Per-file pair commits give
the cleanest `git log` story for review. tasks.md
recommends this granularity.

---

## Summary

The eight decisions above resolve all design questions for
M2.5. None introduces NEEDS-CLARIFICATION; none requires
follow-up beyond implementation. The plan proceeds to
Phase 1.
