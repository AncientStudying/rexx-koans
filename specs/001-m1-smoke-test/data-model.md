# Data Model: M1 — Smoke Test and Design Validation

**Branch**: `001-m1-smoke-test` | **Date**: 2026-05-07

This project uses **files as its data model** — there is no database, no serialization
format beyond plain REXX source files. The entities below describe the logical structures
that the runner, assertion library, and CI scripts operate on.

---

## Entity: Koan File

**Path convention**: `koans/NN_about_topic.rexx`

| Attribute | Type | Description |
|-----------|------|-------------|
| filename | String | e.g. `00_about_smoke.rexx` |
| sequence_number | Integer | Two-digit prefix (e.g. `00`) — defines curriculum order |
| topic | String | Snake-case topic name (e.g. `about_smoke`) |
| assertions | List\<Assertion\> | One or more assert_equal (or similar) calls |
| teaching_comment | String | Comment block preceding each assertion (concept heading + prose) |
| citation | String | `Cowlishaw §N.N, p. NN` — one per koan (required) |
| fill_me_in_count | Integer | Count of uninitialized FILL_ME_IN symbols in the koan |

**Invariants**:
- Every koan file MUST contain exactly one well-formed `Cowlishaw §N.N, p. NN` citation.
- A koan MUST have at least one assertion.
- For the smoke koan: MUST contain at least one passing assertion, at least one FILL_ME_IN, and at least one failing assertion.

---

## Entity: Solution File

**Path convention**: `solutions/NN_about_topic.rexx`

| Attribute | Type | Description |
|-----------|------|-------------|
| filename | String | Same name as corresponding koan file |
| assertions | List\<Assertion\> | All assertions pass; no FILL_ME_IN symbols |
| citation | String | Same citation as the corresponding koan |

**Invariants**:
- Every solution file MUST pass `bin/verify_solutions` with zero failures.
- A solution file is derived from its koan by replacing every FILL_ME_IN with its correct value.
- The solution file MUST exist before the koan file is considered complete (Principle I).

**Relationship**: One-to-one with Koan File (same `NN_about_topic.rexx` filename, different directory).

---

## Entity: Assertion

**Logical structure within a koan or solution file**:

| Attribute | Type | Description |
|-----------|------|-------------|
| kind | Enum | `assert_equal` (only kind required for M1) |
| expected | Value | The value the pilgrim is expected to produce |
| actual | Value | The expression the koan evaluates |
| message | String (optional) | Custom failure message |
| is_blank | Boolean | True if either `expected` or `actual` is an uninitialized FILL_ME_IN symbol |

**State transitions**:
```
FILL_ME_IN (blank)  →  incorrect value (wrong)  →  correct value (pass)
```

---

## Entity: Assertion Result

**Produced by `lib/meditation.rexx` during a koan run**:

| Attribute | Type | Description |
|-----------|------|-------------|
| status | Enum | `pass` / `fail_blank` / `fail_mismatch` |
| expected | String | The expected value (stringified) |
| actual | String | The actual value (stringified) |
| koan_file | String | Filename of the koan being run |
| line_number | Integer | Line in the koan where the assertion is defined |
| message | String | Human-readable diagnostic |

**`fail_blank` message format**:
> "This koan awaits your contribution. Replace the FILL_ME_IN symbol with the value the pilgrim must learn."

**`fail_mismatch` message format**:
> "The [Nth] assertion of [koan_file] has damaged your karma. The pilgrim expected '[expected]' but received '[actual]'."

---

## Entity: Runner Outcome

**Produced by `lib/pilgrimage.rexx` after executing all koans**:

| Attribute | Type | Description |
|-----------|------|-------------|
| first_failed_koan | String (nullable) | Filename of first koan with a failure |
| first_failed_line | Integer (nullable) | Line number of first failing assertion |
| first_failed_message | String (nullable) | The assertion result message |
| koans_passed | Integer | Count of koans that passed fully before the stop |
| total_koans | Integer | Total koans in the pilgrimage |
| exit_code | Integer | 0 = all pass; 1 = at least one failure |

**Behavior**: The runner stops at the first failing assertion in the first failing koan.
It does not continue to subsequent koans. All progress is re-derived from sources on each run.

---

## Entity: Design Decision Record

**Path**: `docs/DESIGN_DECISIONS.md`

Each of the six M1 design questions produces one record:

| Attribute | Type | Description |
|-----------|------|-------------|
| question_id | String | Short tag (e.g. `koan-loading`, `fill-me-in`) |
| question | String | The open question from PLAN.md |
| decision | String | The answer derived from M1 prototype |
| rationale | String | Why this answer was chosen |
| evidence | String | What the prototype demonstrated |
| alternatives_considered | List\<String\> | Other options evaluated |

**Invariants**:
- All six questions from PLAN.md §10 (M1 section) MUST have a completed record before M1 closes.
- "Evidence" MUST reference a concrete result from the prototype (e.g., "runner exited 0 on
  both Ubuntu and macOS with Regina 3.9.1 / 3.9.3 respectively").

---

## Entity: CI Workflow Run

**Not stored — ephemeral GitHub Actions state**:

| Attribute | Type | Description |
|-----------|------|-------------|
| trigger | Enum | `push` or `pull_request` targeting `main` |
| jobs | List | `verify-ubuntu`, `verify-macos` |
| steps | List | Install Regina → run verify_solutions → run lint_citations |
| status | Enum | `pass` / `fail` |

**Invariants**:
- Both jobs MUST pass for a run to be considered green (Constitution Principle IV).
- A failing job MUST surface the failing script's output in the Actions log.
