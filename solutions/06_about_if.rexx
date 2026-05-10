/* solutions/06_about_if.rexx
 *
 * Station: At the Branch of the Road
 *
 * IF is the fork in the path. Its expression must answer with '1' or
 * '0'; the THEN branch runs only on '1', and an optional ELSE supplies
 * the path for '0'. Nested IFs are read inside-out -- ELSE binds to
 * the nearest IF at the same source level.
 *
 * Cowlishaw §2.7, p. 54
 */

n = 0

/* Concept: IF/THEN selects one instruction when its expression is true.
 * The IF keyword evaluates an expression that must yield the Logical
 * value '1' or '0'. When the value is '1', the THEN clause runs; when
 * '0', the THEN is skipped. The path forks; the pilgrim travels only
 * one fork.
 *
 * Cowlishaw §2.7, p. 54
 */
IF 2 + 2 = 4 THEN result = 'truth'
ELSE result = 'lie'
CALL m 'eq', 'truth', result

/* Concept: IF/THEN/ELSE provides the alternative path.
 * Following THEN with ELSE supplies the instruction that runs when the
 * controlling expression yields '0'. Without ELSE, the THEN branch is
 * the only path the pilgrim may travel; with ELSE, exactly one of the
 * two paths is guaranteed.
 *
 * Cowlishaw §2.7, p. 54
 */
weather = 'rain'
IF weather = 'sun' THEN action = 'walk'
ELSE action = 'wait'
CALL m 'eq', 'wait', action

/* Concept: ELSE binds to the nearest IF.
 * Nested IFs bind their ELSE clauses to the innermost IF at the same
 * source level. When the outer expression is '0', the outer THEN
 * (including its inner IF and ELSE) is skipped entirely; the ELSE the
 * pilgrim sees here belongs to the inner IF.
 *
 * Cowlishaw §2.7, p. 54
 */
inside = 0
outer = 1
IF outer = 1 THEN
  IF inside = 1 THEN tag = 'inner-then'
  ELSE tag = 'inner-else'
ELSE tag = 'outer-else'
CALL m 'eq', 'inner-else', tag

/* Concept: the controlling expression must yield '1' or '0'.
 * REXX's comparative operators return the Logical values '1' (true)
 * and '0' (false). An IF expression that does not yield one of these
 * two values raises a SYNTAX condition; the koan asks the pilgrim to
 * verify that a comparison yields the boolean digit.
 *
 * Cowlishaw §2.3, p. 26
 */
is_true = (5 > 3)
CALL m 'eq', 1, is_true
IF is_true THEN report = 'yes'
ELSE report = 'no'
CALL m 'eq', 'yes', report

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/06_about_if.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
