# Contract: Station Display Module (`lib/stations.rexx`)

**Invocation**: Called by `lib/pilgrimage.rexx` either as an external
routine (e.g., `CALL 'lib/stations.rexx' 'render', station_records...`)
or as a sourced subroutine library. Implementation choice is internal
to the runner.

The contract below specifies the public surface and output format.

## Public functions

### `extract_subtitle(koan_path) → String`

Reads the koan file at `koan_path` and returns the subtitle from its
`Station: <text>` directive.

**Algorithm**:
1. Open `koan_path` with `LINEIN`.
2. Read lines until the first non-comment, non-blank line, or up to a
   safety bound of 50 lines (whichever first).
3. Within those lines, find the first stripped line matching the regex
   pattern `^[ \t*/]*Station:[ ]+(.+)$` — implemented in REXX with
   `POS('Station:', stripped) = 1` after stripping comment-prefix
   characters.
4. Return `text` with leading/trailing whitespace stripped.
5. If no directive is found, return the empty string.

### `render(station_records, total)` → side effect (writes to stdout)

Renders the fixed-pitch station list and summary line.

**Inputs**: `station_records` is an indexed structure (stem) where each
record carries `seq`, `topic`, `subtitle`, `status`, and a 1-based
position. `total` is the number of stations in the manifest.

**Output format** — the body of the runner's stdout below the
`THE PATH OF REXX` banner:

```
  [<status>] <seq> <topic, left-padded to width T>  <subtitle>
  [<status>] <seq> <topic, left-padded to width T>  <subtitle>
  ...

  Stations walked: <walked> of <total>.<damage_clause>
```

Where:

- `<status>` is exactly `  ok  ` (two spaces + `ok` + two spaces) for
  passed, ` here ` (one space + `here` + one space) for the failure
  station, or six spaces (blank) for not-attempted.
- `<seq>` is the koan's two-digit numeric prefix.
- `<topic>` is the koan's snake-case topic name (e.g., `about_strings`),
  left-justified and padded with spaces to the maximum topic width
  across all stations in the manifest plus two trailing spaces.
- `<subtitle>` is the pilgrim-voice subtitle from the koan's
  `Station:` directive. Empty for blank-status stations (subtitle is
  not shown for stations the pilgrim has not yet walked).
- `<damage_clause>` is empty on a fully-passing run, or
  `  Karma damaged at: <topic>.` (two spaces of separator + sentence)
  on a failing run.

## Constraints

- MUST emit ASCII characters only.
- MUST emit LF line endings only (no CR).
- MUST NOT include color/ANSI escapes (FR-008; deferred to future
  work per `PLAN.md` §11).
- MUST NOT include timestamps, PIDs, or temp file paths.
- Spaces only — no tabs.
- The "Stations walked: X of Y." sentence MUST always appear.
- The `[ here ]` marker MUST appear at most once across the full
  station list.
