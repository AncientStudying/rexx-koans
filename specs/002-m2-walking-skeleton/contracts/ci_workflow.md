# Contract: CI Workflow (`.github/workflows/verify.yml`)

**Trigger**: Every push and every pull request to `main`.

GitHub Actions workflow extending the M1 baseline with a third
acceptance step: the runner smoke / fixture fingerprint (FR-017,
Decision 4 in research.md).

## Matrix

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, macos-latest]
```

`fail-fast: false` is preserved from M1 — a divergence between
platforms is informative, and we want both legs to report.

## Steps (per matrix leg)

1. **Checkout**: `actions/checkout@v4`.
2. **Install Regina**:
   - On `ubuntu-latest`: `sudo apt-get update && sudo apt-get install -y regina-rexx`.
   - On `macos-latest`: `brew install regina-rexx`.
3. **Show Regina version**: `regina --version` (diagnostic; one-line).
4. **Verify solutions**: `regina bin/verify_solutions`. Exit 0 required.
5. **Lint citations**: `regina bin/lint_citations`. Exit 0 required.
6. **Runner smoke + fingerprint** (NEW in M2):
   - Build a temporary `koans-solved/` working directory by copying
     `solutions/*.rexx` and the path manifest (with paths rewritten
     from `koans/...` to `koans-solved/...`).
   - Run `LC_ALL=C regina lib/pilgrimage.rexx` against the
     fully-solved curriculum, capturing stdout to `runner-out.txt`.
   - Assert exit 0.
   - Normalize line endings: `tr -d '\r' < runner-out.txt > runner-out.normalized`.
   - `diff -u tests/fixtures/runner_stdout.txt runner-out.normalized` — must produce no output.
   - On mismatch, the step fails and the `diff` output appears in the
     CI log so a contributor can see exactly what diverged.

## Acceptance

All six steps MUST exit 0 on both `ubuntu-latest` and `macos-latest`.
A failure on either leg blocks merge to `main` (Constitution Principle
IV).

## Implementation hint (sketch, non-binding)

```yaml
- name: Runner smoke (fully-solved walk against committed fingerprint)
  shell: bash
  run: |
    set -euo pipefail
    # Build a "solved curriculum" working dir from solutions/.
    rm -rf koans-solved
    mkdir koans-solved
    cp solutions/*.rexx koans-solved/
    # Mirror the manifest with rewritten paths.
    sed 's|koans/|koans-solved/|g' koans/path_to_enlightenment.rexx > koans-solved/path_to_enlightenment.rexx
    # Hand the runner a manifest path via env or symlink (runner reads
    # koans/path_to_enlightenment.rexx by convention; for this step we
    # symlink temporarily).
    cp koans/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx.bak
    cp koans-solved/path_to_enlightenment.rexx koans/path_to_enlightenment.rexx
    LC_ALL=C regina lib/pilgrimage.rexx > runner-out.txt
    mv koans/path_to_enlightenment.rexx.bak koans/path_to_enlightenment.rexx
    tr -d '\r' < runner-out.txt > runner-out.normalized
    diff -u tests/fixtures/runner_stdout.txt runner-out.normalized
```

The exact mechanics of presenting the solved curriculum to the runner
(symlink, file substitution, or a `--manifest` flag) are an
implementation choice; the contract is that the runner walks a
fully-solved Stage I and the captured stdout matches the fixture.

## Constraints

- MUST run on both `ubuntu-latest` and `macos-latest`.
- MUST run on every push and every pull request to `main`.
- The fixture (`tests/fixtures/runner_stdout.txt`) MUST be a single
  ASCII / LF file used unchanged by both matrix legs.
- The diff command MUST be `diff -u` (or `git diff --no-index`) to
  produce a readable diff in CI logs on mismatch.
- MUST NOT silently degrade a fingerprint mismatch into a warning —
  mismatch is hard fail.
