/* lib/pilgrimage.rexx — minimal subprocess runner.
 *
 * For M1 the koan list is hard-coded to the single smoke koan. The runner:
 *
 *   1. Iterates the koan list.
 *   2. Invokes each koan as a Regina subprocess (Decision 1, research.md).
 *   3. Captures stdout/stderr to a temp file.
 *   4. Stops at the first non-zero exit; otherwise prints [  ok  ] per koan.
 *   5. Exits with the failing koan's exit code, or 0 on full pass.
 *
 * Output format follows specs/001-m1-smoke-test/contracts/runner.md.
 */

koans.0 = 1
koans.1 = 'koans/00_about_smoke.rexx'

SAY 'THE PATH OF REXX (SMOKE TEST)'
SAY ''

passed = 0
DO i = 1 TO koans.0
  koan = koans.i
  PARSE VAR koan 'koans/' seq '_' topic '.rexx'
  display = seq topic

  tmp = '/tmp/pilgrimage.'RANDOM(1, 99999)'.'TIME('S')'.out'
  ADDRESS SYSTEM 'regina' koan '>' tmp '2>&1'
  rc_koan = RC

  output = ''
  DO WHILE LINES(tmp) > 0
    output = output || LINEIN(tmp) || '0a'x
  END
  CALL STREAM tmp, 'C', 'CLOSE'
  ADDRESS SYSTEM 'rm -f' tmp

  IF rc_koan \= 0 THEN DO
    SAY '  [ here ]' display
    SAY ''
    DO WHILE output \= ''
      PARSE VAR output line '0a'x output
      IF line \= '' THEN SAY '  'line
    END
    SAY ''
    remain = koans.0 - passed
    IF remain = 1 THEN
      SAY '  You have walked' passed 'steps. 1 step remains.'
    ELSE
      SAY '  You have walked' passed 'steps.' remain 'steps remain.'
    EXIT rc_koan
  END

  passed = passed + 1
  SAY '  [  ok  ]' display
END

SAY ''
SAY '  The pilgrim has completed the smoke test. The path is clear.'
EXIT 0
