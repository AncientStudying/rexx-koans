/* Cowlishaw §2.1, p. 15 — Constants
 *
 * The Smoke Test Koan
 * -------------------
 * The pilgrim has arrived at the first station. This koan is a smoke test:
 * its only purpose is to prove that the runner, the assertion library, and
 * the FILL_ME_IN mechanism all work end to end.
 *
 * There are two things to fix in this koan:
 *
 *   1. A FILL_ME_IN symbol. In REXX, an uninitialized simple symbol
 *      evaluates to its own name in uppercase. So the symbol FILL_ME_IN,
 *      until you bind it to a value, simply evaluates to the string
 *      'FILL_ME_IN'. The assertion library detects this and asks the
 *      pilgrim to replace it with the value the koan expects.
 *
 *   2. A deliberately wrong literal value. The assertion library will
 *      report the karma damage and stop the pilgrimage at that line until
 *      the value is corrected.
 *
 * When both are fixed, every assertion holds and the runner exits zero.
 */

n = 0

n = n + 1; CALL aeq '4', 2 + 2, n
n = n + 1; CALL aeq 'three', FILL_ME_IN, n
n = n + 1; CALL aeq 'two', 'wrong', n

EXIT 0

aeq:
  PARSE ARG e, a, num
  CALL 'lib/meditation.rexx' e, a, 'koans/00_about_smoke.rexx', num, SIGL
  IF RESULT \= 0 THEN EXIT RESULT
  RETURN
