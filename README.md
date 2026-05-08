# rexx-koans

[![verify](https://github.com/AncientStudying/rexx-koans/actions/workflows/verify.yml/badge.svg)](https://github.com/AncientStudying/rexx-koans/actions/workflows/verify.yml)

REXX Koans is a self-paced, test-driven training course for the REXX
programming language, modeled on Edgecase's Ruby Koans.

This repository is at **M1 — Smoke Test and Design Validation**: a
deliberately throwaway prototype that proves the architecture before the
real curriculum is built on top of it. See `PLAN.md` for the milestone
plan and `docs/DESIGN_DECISIONS.md` for the architecture decisions M1
locked in.

## Prerequisites

Install Regina REXX (the only runtime dependency):

```sh
brew install regina-rexx                   # macOS
sudo apt-get install -y regina-rexx        # Ubuntu / Debian
```

Verify the install:

```sh
regina --version
```

## Smoke walkthrough

A five-step run to take the smoke koan from `FILL_ME_IN` to a clean pass.
Mirrors `specs/001-m1-smoke-test/quickstart.md`.

**1. Run the runner against the unfilled koan.** Expect a
diagnostic about the FILL_ME_IN symbol and a non-zero exit.

```sh
regina lib/pilgrimage.rexx
```

**2. Open `koans/00_about_smoke.rexx`.** The teaching comment at
the top describes the two values the pilgrim must fix: the FILL_ME_IN
symbol on one assertion and the deliberately wrong literal on the next.

**3. Re-run the runner.** With both values fixed, all assertions
pass and the runner exits zero.

```sh
regina lib/pilgrimage.rexx
```

**4. Verify the solution file directly.**

```sh
regina bin/verify_solutions
```

Expect `[verify] All solutions pass.` and exit zero.

**5. Lint the koan citation.**

```sh
regina bin/lint_citations
```

Expect `[lint] All citations valid.` and exit zero.

## CI

Every push and pull request to `main` runs `verify_solutions` and
`lint_citations` on both `ubuntu-latest` and `macos-latest` via
`.github/workflows/verify.yml`. Both jobs must pass green for any merge.

## Repository layout

```
lib/             pilgrimage runner + meditation assertion library
koans/           the smoke koan (more added in M2+)
solutions/       authoritative answer files (Solution-First, Constitution I)
bin/             verify_solutions + lint_citations (Regina REXX)
docs/            DESIGN_DECISIONS.md (M1 architecture record)
specs/           Spec Kit feature specs
.github/         CI workflows
PLAN.md          locked milestone plan
```

## Reference

The curriculum tracks Mike Cowlishaw, *The REXX Language* (2nd edition,
1990) — every koan cites a section and page. The book is not in the repo;
contributors source it from their own copy or via the Internet Archive.

## License

MIT. See `LICENSE`.
