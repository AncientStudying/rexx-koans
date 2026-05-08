# Contract: Pilgrimage Runner (`lib/pilgrimage.rexx`)

**Invocation**: `regina lib/pilgrimage.rexx`

## Behavior

1. Reads the koan list (for M1: only `koans/00_about_smoke.rexx`).
2. Runs each koan file as a subprocess (`ADDRESS SYSTEM/COMMAND "regina koans/NN_about_topic.rexx"`).
3. Stops at the first koan that exits non-zero.
4. Prints progress and failure details to stdout.
5. Exits with the code of the failing koan subprocess, or 0 if all pass.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All koans passed |
| 1 | At least one koan failed (first failure reported) |

## Output Format (stdout)

On failure:
```
THE PATH OF REXX

  [ here ] NN about_topic

  <assertion failure message from the koan subprocess>

  Damaged at: koans/NN_about_topic.rexx, line <L>.
  You have walked <P> steps. <R> steps remain.
```

On full pass:
```
THE PATH OF REXX

  [  ok  ] 00 about_smoke

  The pilgrim has completed the smoke test. The path is clear.
```

## Constraints

- The runner MUST NOT execute koan code in-process (no INTERPRET of koan text).
- The runner MUST pass koan subprocess stdout through to the user's terminal.
- The runner MUST NOT continue to subsequent koans after the first failure.
