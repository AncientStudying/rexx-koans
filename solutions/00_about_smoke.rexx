/* Cowlishaw §2.1, p. 15 — Constants
 *
 * Solution for koans/00_about_smoke.rexx.
 *
 * The smoke-test koan exercises three things:
 *   - the assertion library passes when expected equals actual;
 *   - the FILL_ME_IN mechanism produces a fill_blank diagnostic;
 *   - the assertion library produces a fail_mismatch diagnostic on a wrong value.
 *
 * In this solution every assertion holds.
 */

n = 0

n = n + 1; CALL aeq '4', 2 + 2, n
n = n + 1; CALL aeq 'three', 'three', n
n = n + 1; CALL aeq 'two', 'two', n

EXIT 0

aeq:
  PARSE ARG e, a, num
  CALL 'lib/meditation.rexx' e, a, 'solutions/00_about_smoke.rexx', num, SIGL
  IF RESULT \= 0 THEN EXIT RESULT
  RETURN
