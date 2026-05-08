/* lib/meditation.rexx — REXX Koans assertion subroutine.

   Invoked from a koan file as an external routine:

     CALL 'lib/meditation.rexx' expected, actual, koan_file, n, line

   Arguments:
     expected   — the value the koan declares the pilgrim must produce
     actual     — the value the koan produced
     koan_file  — path to the koan, e.g. 'koans/00_about_smoke.rexx'
     n          — the ordinal of this assertion within the koan (1, 2, 3, ...)
     line       — the line number of the assertion in the koan (caller's SIGL)

   Returns:
     0 — assertion passed (no output)
     1 — fill_blank: at least one argument equals the literal 'FILL_ME_IN'
     2 — fail_mismatch: expected differed from actual

   On a non-zero return, the diagnostic and "Damaged at:" line are printed
   to stdout. The koan is responsible for propagating the non-zero result
   via EXIT.

   This file is the entire assertion library for M1. No third-party REXX
   dependencies; uses only Regina built-ins (Constitution Principle II).
*/

PARSE ARG expected, actual, koan_file, n, line

IF expected = 'FILL_ME_IN' | actual = 'FILL_ME_IN' THEN DO
  SAY 'This koan awaits your contribution. Replace the FILL_ME_IN symbol with the value the pilgrim must learn.'
  SAY 'Damaged at:' koan_file', line' line'.'
  RETURN 1
END

IF expected \= actual THEN DO
  SAY 'The' ordinal(n) 'assertion of' koan_file 'has damaged your karma. The pilgrim expected' quote(expected) 'but received' quote(actual)'.'
  SAY 'Damaged at:' koan_file', line' line'.'
  RETURN 2
END

RETURN 0

/* Render an integer as an English ordinal: 1 -> 1st, 2 -> 2nd, etc. */
ordinal: PROCEDURE
  PARSE ARG num
  IF DATATYPE(num, 'W') = 0 THEN RETURN num
  last_two = RIGHT(num, 2)
  IF last_two = 11 | last_two = 12 | last_two = 13 THEN RETURN num'th'
  last_one = RIGHT(num, 1)
  SELECT
    WHEN last_one = '1' THEN RETURN num'st'
    WHEN last_one = '2' THEN RETURN num'nd'
    WHEN last_one = '3' THEN RETURN num'rd'
    OTHERWISE RETURN num'th'
  END

/* Wrap a string in single quotes for diagnostic output. */
quote: PROCEDURE
  PARSE ARG s
  RETURN ''''s''''
