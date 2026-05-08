# Data Model: M2 — Walking Skeleton

**Branch**: `002-m2-walking-skeleton` | **Date**: 2026-05-08

The project's data model is files. There is no database, no
serialization format beyond plain REXX source and a single ASCII
fixture. The entities below describe the logical structures the
runner, assertion library, station-display module, lint, and CI
operate on.

---

## Entity: Koan File

**Path convention**: `koans/NN_about_topic.rexx`

| Attribute | Type | Description |
|---|---|---|
| filename | String | e.g. `01_about_strings.rexx` |
| sequence_number | Integer | Two-digit prefix (01–05 for Stage I; 00 reserved for `about_asserts`) |
| topic | String | Snake-case topic name (e.g. `about_strings`) |
| station_subtitle | String | Pilgrim-voice subtitle from the `Station: <text>` directive in the leading comment block |
| concept_groups | List\<ConceptGroup\> | Ordered groups of related assertions sharing one teaching block |
| assertions | List\<Assertion\> | Flat list of assertion calls (across all concept groups) |
| citations | List\<String\> | One `Cowlishaw §N.N, p. NN` citation per concept group |
| fill_me_in_count | Integer | Number of distinct `FILL_ME_IN` blanks (≥ 1) |

**Invariants**:
- MUST contain exactly one `Station: <text>` directive in its leading comment block.
- MUST contain at least one `Cowlishaw §N.N, p. NN` citation (one per concept group, ≥ 1 group).
- MUST contain at least one `FILL_ME_IN` blank.
- The koan-local `m:` dispatcher wrapper MUST be defined exactly once and MUST forward to `lib/meditation.rexx`.
- The runner determines pass/fail by exit code only — exit 0 = pass, non-zero = fail.

---

## Entity: Concept Group (within a Koan File)

A logical cluster of related assertions on one named concept. Has one
teaching comment block ahead of its first assertion; subsequent
assertions in the same group share that teaching context.

| Attribute | Type | Description |
|---|---|---|
| concept_heading | String | Short name of the concept (e.g. "Concatenation by abuttal vs. by blank") |
| teaching_prose | String | 2–6 sentences sufficient to make the test pass without consulting the book |
| citation | String | `Cowlishaw §N.N, p. NN` for this concept |
| assertions | List\<Assertion\> | One or more `CALL m '<kind>', ...` lines |

**Invariants**:
- The teaching block precedes the FIRST assertion of the group.
- Subsequent assertions in the group do NOT repeat the teaching block.
- Citation accuracy (page number) is verified at writing time by the koan author against `reference/REXX_Language_2nd_Edition.pdf`. CI verifies citation **format** only.

---

## Entity: Assertion

A single `CALL m '<kind>', arg1, arg2, n` line within a koan. The koan
maintains a local counter `n` incremented before each assertion; the
counter is passed to the dispatcher and surfaces in the diagnostic.

| Attribute | Type | Description |
|---|---|---|
| kind | Enum | `'eq'`, `'neq'`, `'true'`, `'datatype'` |
| arg1 | Value | Expected value (for `eq`/`neq`/`datatype`) or the boolean condition (for `'true'`) |
| arg2 | Value | Actual value (for `eq`/`neq`); type code such as `'W'`, `'N'`, `'A'` (for `'datatype'`); ignored (for `'true'`) |
| ordinal (n) | Integer | 1-based position of this assertion within the koan |

**Diagnostic dispositions** (from `lib/meditation.rexx`):

| RC | Disposition | Trigger |
|---|---|---|
| 0 | pass | All checks pass for the kind |
| 1 | fail_blank | `arg1` or `arg2` (where applicable) equals literal `'FILL_ME_IN'` |
| 2 | fail_mismatch | Kind-specific check fails; not a blank |

---

## Entity: Solution File

**Path convention**: `solutions/NN_about_topic.rexx`

| Attribute | Type | Description |
|---|---|---|
| filename | String | Same name as corresponding koan file |
| concept_groups | List\<ConceptGroup\> | Same teaching content as the koan; same citations |
| assertions | List\<Assertion\> | All assertions pass; no `FILL_ME_IN` blanks remain |

**Invariants**:
- 1:1 with Koan File by filename.
- MUST pass `bin/verify_solutions` with zero failures.
- MUST be written and verified BEFORE the corresponding koan derives `FILL_ME_IN` blanks (Constitution Principle I).
- The `koan_file` argument in the dispatcher CALL inside the solution file uses the `solutions/...` path so diagnostics, if any, name the right file.

---

## Entity: Path Manifest (`koans/path_to_enlightenment.rexx`)

A REXX source file that, when `CALL`'d by the runner, populates the
`koans.` stem in the runner's variable space.

| Attribute | Type | Description |
|---|---|---|
| koans.0 | Integer | Count of stations in the manifest |
| koans.i (1..koans.0) | String | Path to the i-th koan file relative to repo root |

**Invariants**:
- M2 ships with `koans.0 = 6`, populating slots 1–6 with the Stage I koans in curriculum order.
- Every `koans.i` MUST resolve to an existing file in `koans/`.
- The runner's resume/walk semantics depend on this ordering; it is the single source of truth.

---

## Entity: Station Record (in-memory, runner-side)

The runner's internal accumulator. One record per koan in the
manifest.

| Attribute | Type | Description |
|---|---|---|
| seq | String | Two-digit sequence prefix |
| topic | String | Snake-case topic |
| subtitle | String | From the koan's `Station:` directive |
| status | Enum | `ok` | `here` | `blank` |

**State transitions** (per run, single pass):
- All stations start as `blank`.
- After each successful koan execution: that station's status → `ok`.
- On the first failing koan execution: that station's status → `here`; remaining stations stay `blank`; the runner stops.

---

## Entity: Runner Smoke Fixture

**Path**: `tests/fixtures/runner_stdout.txt`

A literal byte-for-byte copy of the expected stdout produced by
`lib/pilgrimage.rexx` when invoked against the fully-solved Stage I
curriculum.

| Attribute | Type | Description |
|---|---|---|
| encoding | ASCII (no Unicode) | Per Decision 4, research.md |
| line endings | LF only | Per Decision 4 |
| content | Plain text | Banner + per-station lines + closing benediction |

**Invariants**:
- MUST be byte-identical on `macos-latest` and `ubuntu-latest`. CI verifies this.
- MUST be regenerated by hand and re-committed any time the runner's stdout vocabulary changes (banner, station markers, benediction wording).
- Contributors regenerate via: temporarily symlink `solutions/` content into a fresh `koans-solved/` working directory, run the runner against it, capture stdout, diff against the fixture, and update if intended.

---

## Relationships

```
PathManifest (1) --references--> (6) KoanFile
KoanFile (1) <--matches by filename--> (1) SolutionFile
KoanFile (1) --contains--> (≥1) ConceptGroup --contains--> (≥1) Assertion
KoanFile (1) --declares--> (1) StationSubtitle
Runner --reads--> PathManifest --invokes--> KoanFile (subprocess)
Runner --collects--> StationRecord (in-memory) --renders via--> StationsModule --reads subtitles from--> KoanFile
verify_solutions --invokes--> SolutionFile (subprocess)
lint_citations --reads--> KoanFile (citations + Station: directive)
CI runner-smoke --invokes--> Runner --produces--> stdout --compared to--> RunnerSmokeFixture
```
