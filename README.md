# rexx-koans

[![verify](https://github.com/AncientStudying/rexx-koans/actions/workflows/verify.yml/badge.svg)](https://github.com/AncientStudying/rexx-koans/actions/workflows/verify.yml)

REXX Koans is a self-paced, test-driven training course for the REXX
programming language, modeled on EdgeCase's Ruby Koans. You are the
pilgrim. The path is roughly thirty koans, each a small REXX file
with one or more assertions and the teaching prose you need to make
them pass. M2 ships **Stage I — The Foundation**: six koans that
cover strings, variables, expressions, clauses, and `SAY`.

## Install Regina

The only runtime dependency is the Regina REXX interpreter:

```sh
brew install regina-rexx                   # macOS
sudo apt-get install -y regina-rexx        # Ubuntu / Debian
```

Verify the install:

```sh
regina --version
```

## Walk the path

From the repository root:

```sh
./bin/pilgrimage
```

On the first run the runner stops at the first `FILL_ME_IN` symbol
in `koans/00_about_asserts.rexx` and prints a diagnostic naming the
file and line. Open the koan, read the teaching block above the
failing assertion, replace `FILL_ME_IN` with the value the prose
names, and re-run. The runner advances to the next blank or the next
station; when every koan in `koans/path_to_enlightenment.rexx` passes
its assertions, the runner prints the closing benediction and exits
zero.

The runner re-derives state from the source files on every run:
there is no save file, no resume command — the path itself is the
record of where the pilgrim has been. Solving koans 00–02 and
re-running stops at koan 03; correcting your edits and running once
more advances past it.

## Read further

The curriculum tracks Mike Cowlishaw, *The REXX Language* (2nd
edition, 1990) — every koan cites a section and page. The book is
not bundled here; contributors source it from their own copy or from
the Internet Archive scan:

  https://archive.org/details/rexxlanguage0000cowl

The locked milestone plan lives in `PLAN.md`; the M1 architecture
record lives in `docs/DESIGN_DECISIONS.md`.

## CI

Every push and pull request to `main` runs `verify_solutions`,
`lint_citations`, and a runner-smoke step that asserts the runner's
stdout for a fully-solved Stage I walk is byte-identical to the
fixture in `tests/fixtures/runner_stdout.txt`. The matrix covers
`ubuntu-latest` and `macos-latest`. All steps must pass green for
any merge.

## Repository layout

```
lib/             pilgrimage runner, meditation assertion library, stations module
koans/           the Stage I curriculum + path_to_enlightenment.rexx manifest
solutions/       authoritative answer files (Solution-First, Constitution I)
bin/             pilgrimage launcher, verify_solutions, lint_citations
tests/fixtures/  runner_stdout.txt — committed cross-platform stdout fingerprint
docs/            DESIGN_DECISIONS.md (M1 architecture record)
specs/           Spec Kit feature specs
.github/         CI workflow
PLAN.md          locked milestone plan
```

## License

MIT. See `LICENSE`.
