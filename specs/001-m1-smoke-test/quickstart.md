# Quickstart: M1 Smoke Test — Running the Prototype

**Branch**: `001-m1-smoke-test` | **Date**: 2026-05-07
**Audience**: Contributor validating the M1 prototype on macOS.

---

## Prerequisites

Install Regina REXX via Homebrew:

```sh
brew install regina-rexx
```

Verify:

```sh
regina --version
```

Clone the repository (if not already done):

```sh
git clone <repo-url> rexx-koans
cd rexx-koans
git checkout 001-m1-smoke-test
```

---

## Step 1: Run the smoke koan (expected: FILL_ME_IN failure)

```sh
regina lib/pilgrimage.rexx
```

Expected output (approximate):

```
THE PATH OF REXX (SMOKE TEST)

  [ here ] 00 about_smoke

  This koan awaits your contribution. Replace the FILL_ME_IN symbol
  with the value the pilgrim must learn.

  Damaged at: koans/00_about_smoke.rexx, line <N>.
  You have walked 0 steps. <M> steps remain.
```

Exit code: non-zero.

---

## Step 2: Inspect the smoke koan

Open `koans/00_about_smoke.rexx`. Find the `FILL_ME_IN` symbol and replace
it with the correct value as indicated by the teaching comment above it.

---

## Step 3: Re-run after filling in (expected: pass)

```sh
regina lib/pilgrimage.rexx
```

Expected output (approximate):

```
THE PATH OF REXX (SMOKE TEST)

  [  ok  ] 00 about_smoke

  The pilgrim has completed the smoke test. The path is clear.
```

Exit code: 0.

---

## Step 4: Verify the solution

```sh
bin/verify_solutions
```

Expected output:

```
[verify] solutions/00_about_smoke.rexx ... PASS
[verify] All solutions pass.
```

Exit code: 0.

---

## Step 5: Lint citations

```sh
bin/lint_citations
```

Expected output:

```
[lint] koans/00_about_smoke.rexx ... OK
[lint] All citations valid.
```

Exit code: 0.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `regina: command not found` | Regina not installed | `brew install regina-rexx` |
| `SIGNAL ON SYNTAX` fires unexpectedly | Koan syntax error | Read the error line; fix the REXX syntax |
| lint_citations fails | Citation missing or malformed | Ensure koan has `Cowlishaw §N.N, p. NN` in a comment |
| verify_solutions fails | Solution has a wrong value | Check `solutions/00_about_smoke.rexx` |
| CI fails on Ubuntu but passes on macOS | Regina version difference | See `docs/DESIGN_DECISIONS.md` Decision 5 |

---

## Next Steps

After the smoke test passes locally and CI is green on both platforms:

1. Record all empirical findings in `docs/DESIGN_DECISIONS.md` (required M1 exit criterion).
2. Open a pull request to `main`.
3. Once merged, begin M2 (Walking Skeleton) based on the decisions recorded in M1.
