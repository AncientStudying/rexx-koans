/* lib/meditation.rexx — REXX Koans assertion dispatcher.
 *
 * Invoked from a koan via the koan-local m: wrapper:
 *
 *   CALL 'lib/meditation.rexx' kind, arg1, arg2, koan_file, n, line
 *
 * Arguments (per contracts/meditation.md):
 *   kind       — one of 'eq', 'neq', 'true', 'datatype'
 *   arg1       — expected value (eq, neq) | boolean condition (true) | value to type-check (datatype)
 *   arg2       — actual value (eq, neq) | '' (true) | REXX type code (datatype)
 *   koan_file  — path to the koan, e.g. 'koans/01_about_strings.rexx'
 *   n          — 1-based ordinal of this assertion within the koan
 *   line       — caller's SIGL (line of the assertion in the koan source)
 *
 * Returns:
 *   0 — assertion passed (no output)
 *   1 — fail_blank: arg1 (or, where applicable, arg2) equals literal 'FILL_ME_IN'
 *   2 — fail_mismatch: kind-specific check failed
 *
 * On non-zero RC the diagnostic and "Damaged at:" line are printed to stdout.
 * The koan-side m: wrapper is responsible for EXIT'ing on non-zero RC.
 *
 * Constitution Principle II — Regina built-ins only.
 */

PARSE ARG kind, arg1, arg2, koan_file, n, line

SELECT
  WHEN kind = 'eq' THEN DO
    IF arg1 = 'FILL_ME_IN' | arg2 = 'FILL_ME_IN' THEN DO
      CALL say_blank koan_file, line
      RETURN 1
    END
    IF arg1 \= arg2 THEN DO
      SAY 'The' ordinal(n) 'assertion of' koan_file 'has damaged your karma. The pilgrim expected' quote(arg1) 'but received' quote(arg2)'.'
      SAY 'Damaged at:' koan_file', line' line'.'
      RETURN 2
    END
  END
  WHEN kind = 'neq' THEN DO
    IF arg1 = 'FILL_ME_IN' | arg2 = 'FILL_ME_IN' THEN DO
      CALL say_blank koan_file, line
      RETURN 1
    END
    IF arg1 = arg2 THEN DO
      SAY 'The' ordinal(n) 'assertion of' koan_file 'has damaged your karma. The pilgrim expected a value other than' quote(arg1) 'but received the same value.'
      SAY 'Damaged at:' koan_file', line' line'.'
      RETURN 2
    END
  END
  WHEN kind = 'true' THEN DO
    IF arg1 = 'FILL_ME_IN' THEN DO
      CALL say_blank koan_file, line
      RETURN 1
    END
    IF arg1 \= 1 THEN DO
      SAY 'The' ordinal(n) 'assertion of' koan_file 'has damaged your karma. The pilgrim expected a true condition but received' quote(arg1)'.'
      SAY 'Damaged at:' koan_file', line' line'.'
      RETURN 2
    END
  END
  WHEN kind = 'datatype' THEN DO
    IF arg1 = 'FILL_ME_IN' | arg2 = 'FILL_ME_IN' THEN DO
      CALL say_blank koan_file, line
      RETURN 1
    END
    IF DATATYPE(arg1, arg2) \= 1 THEN DO
      SAY 'The' ordinal(n) 'assertion of' koan_file 'has damaged your karma. The pilgrim expected' quote(arg1) 'to be of REXX type' quote(arg2) 'but it is not.'
      SAY 'Damaged at:' koan_file', line' line'.'
      RETURN 2
    END
  END
  OTHERWISE DO
    SAY 'The' ordinal(n) 'assertion of' koan_file 'invoked an unknown assertion kind' quote(kind)'.'
    SAY 'Damaged at:' koan_file', line' line'.'
    RETURN 2
  END
END

RETURN 0

say_blank: PROCEDURE
  PARSE ARG koan_file, line
  SAY 'This koan awaits your contribution. Replace the FILL_ME_IN symbol with the value the pilgrim must learn.'
  SAY 'Damaged at:' koan_file', line' line'.'
  RETURN

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

quote: PROCEDURE
  PARSE ARG s
  RETURN ''''s''''
