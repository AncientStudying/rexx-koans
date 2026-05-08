# Design Decisions — M2

**Status**: Final for M2.
**Branch**: `002-m2-walking-skeleton`.
**Locked**: 2026-05-08.

M1's six ADRs (`docs/DESIGN_DECISIONS.md`, ADR-001 through ADR-006)
are inherited verbatim and are not re-litigated here. The design
records below cover M2-specific decisions that were finalized during
implementation, beyond what the M2 research document
(`specs/002-m2-walking-skeleton/research.md`) anticipated.

The prototype was exercised on macOS 25.4 (Darwin) with Regina REXX
3.9.7 (64-bit, build 18 Mar 2025) installed via Homebrew.
Cross-platform parity on `ubuntu-latest` is enforced by the runner
smoke + fixture step in `.github/workflows/verify.yml` (FR-017,
SC-006).

---

## ADR-007 — Manifest Loading via LINEIN + INTERPRET

**Question**: How does the runner consume
`koans/path_to_enlightenment.rexx` so that the `koans.` stem the
manifest assigns is visible in the runner's own variable scope?

**Decision**: **The runner reads the manifest line-by-line with
`LINEIN`, concatenates the lines into a single string with `;`
clause separators, and `INTERPRET`s that string in its own scope.**
External `CALL` is NOT used — see "Why not external CALL" below.

Concretely (`lib/pilgrimage.rexx`):

```rexx
load_manifest:
  PARSE ARG manifest_path
  src = ''
  DO WHILE LINES(manifest_path) > 0
    src = src || LINEIN(manifest_path) || ';'
  END
  CALL STREAM manifest_path, 'C', 'CLOSE'
  INTERPRET src
  RETURN
```

The manifest itself is a plain REXX source file — only stem
assignments, comments, and a trailing `RETURN`:

```rexx
/* koans/path_to_enlightenment.rexx — master ordering. */
koans.0 = 6
koans.1 = 'koans/00_about_asserts.rexx'
...
koans.6 = 'koans/05_about_say.rexx'
RETURN
```

After `INTERPRET` returns, `koans.0` and `koans.1`..`koans.6` are
populated in the runner's variable space, and the runner walks them
as if they had been assigned inline.

**Why not external CALL**:
The earlier design draft (Decision 5 of `research.md`, before its
M2-implementation revision) called for `CALL
'koans/path_to_enlightenment.rexx'` on the assumption that an
external file invoked via `CALL`, with no `PROCEDURE` declaration in
the target, would share the caller's variable scope. **This is
false** in Regina REXX 3.9.7 and in the ANSI X3.274-1996 standard:
external routines (whether invoked by `CALL` or by function call
syntax) always have their own variable space; only internal labels
honor scope sharing rules around `PROCEDURE`. Verified by direct
test during M2 implementation:

```rexx
/* caller.rexx */
CALL '/tmp/callee.rexx'
SAY 'after CALL: SYMBOL(arr.0)='SYMBOL('arr.0')   /* prints LIT */

/* callee.rexx */
arr.0 = 3
RETURN
```

The `LIT` (literal) result confirms the stem assigned by the callee
does not reach the caller. `INTERPRET` of the callee's source in the
caller's clause stream does — that is the mechanism M2 uses.

**Rationale**:
- Preserves the original intent of Decision 5: the manifest is data,
  not behavior; appending a koan in M3+ touches one line in one file
  and nothing in the runner.
- Keeps the manifest a real REXX file (a stage author can run
  `regina koans/path_to_enlightenment.rexx` for syntax-check
  purposes, even if its main use is via INTERPRET).
- Uses only Regina built-ins (`LINEIN`, `LINES`, `STREAM`,
  `INTERPRET`) — Constitution Principle II.
- A malformed manifest (syntax error in the assignments, empty
  stem, etc.) surfaces as a REXX-level error inside `INTERPRET`,
  which the runner can detect (`SYMBOL('koans.0') \= 'VAR'` after
  load) and surface as "The path is empty. No stations are defined."

**Tradeoff**: `INTERPRET` of attacker-controlled REXX is a code
injection vector. The manifest is project-controlled (committed to
the repo, reviewed in PRs, scanned by `lint_citations`-adjacent
checks). Trusting it is equivalent to trusting any other file under
`koans/`; the trust boundary is the repository, not the file format.

**Alternatives considered**:
- **External `CALL` with shared scope** — rejected as factually
  unsupported (see "Why not external CALL" above). The original
  Decision 5 prose has been corrected.
- **Plain text manifest, one path per line** — rejected. Adds an I/O
  parser the runner does not otherwise need; loses the
  syntax-check-by-running benefit; each future stage's "add a koan"
  diff becomes a magic string instead of a typed assignment.
- **Hardcoded list inside `lib/pilgrimage.rexx`** — rejected per
  original Decision 5 rationale: edits to curriculum order would
  become edits to the runner; violates the curriculum/runner
  separation `PLAN.md` §4 implies.
- **Subprocess invocation that prints the manifest as data** —
  rejected. Adds a second Regina process per run for a result the
  in-process INTERPRET delivers in microseconds.

**Forward applicability — guidance for M3+**:
- The "manifest is data, sourced via `LINEIN` + `INTERPRET`" pattern
  is the project's standard for any future cross-module data file
  whose contents must be visible in the consuming module's scope.
  Candidates include a future scripture index, a stage manifest, or
  a configuration table.
- Future modules that deliver **behavior** (not data) — assertions,
  station rendering, scripture rendering — continue to use external
  `CALL` and accept the no-shared-scope semantic, communicating
  through arguments and `RESULT`.
- Any future doc that describes a cross-file mechanism MUST NOT
  claim "external `CALL` shares variable scope". The Regina /
  ANSI REXX behavior is that it does not.

**Evidence**:
- `lib/pilgrimage.rexx` — `load_manifest` label (the implementation
  of this ADR). Inline comment in the runner cross-references this
  decision.
- M2 CI matrix run (FR-014, FR-017): the runner-smoke step on both
  `ubuntu-latest` and `macos-latest` exercises `LINEIN` +
  `INTERPRET` against the committed manifest and produces the
  fixture-matching stdout. A regression in this mechanism would
  surface as a fingerprint mismatch and block merge.
