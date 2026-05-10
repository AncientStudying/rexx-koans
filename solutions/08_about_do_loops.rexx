/* solutions/08_about_do_loops.rexx
 *
 * Station: The Returning of the Path
 *
 * DO groups instructions and, optionally, repeats them. The pilgrim
 * walks the path and returns: a counter-controlled DO steps a control
 * variable, DO WHILE tests before each pass, DO UNTIL tests after.
 * Every DO is closed by a matching END.
 *
 * Cowlishaw §2.7, p. 47
 */

n = 0

/* Concept: DO ... END groups instructions.
 * A simple DO ... END block is a compound instruction: every
 * statement between DO and END runs once, in sequence. The DO
 * group is REXX's bracket; THEN and ELSE often need it when one
 * conditional branch must contain more than a single statement.
 *
 * Cowlishaw §2.7, p. 47
 */
total = 0
DO
  total = total + 1
  total = total + 2
  total = total + 3
END
CALL m 'eq', 6, total

/* Concept: controlled DO repeats over a counter.
 * The form DO name = expri TO exprt initialises name to expri and
 * repeats the body, stepping by 1 (or by exprb if BY is given) each
 * iteration, halting when name exceeds exprt. The control variable
 * is the surface that index-style loops expose to the pilgrim.
 *
 * Cowlishaw §2.7, p. 47
 */
sum = 0
DO i = 1 TO 5
  sum = sum + i
END
CALL m 'eq', 15, sum

/* Concept: DO WHILE tests before each iteration.
 * The form DO WHILE expr re-evaluates the controlling expression
 * before each pass; the body runs only while the expression yields
 * '1'. If the expression is '0' on entry, the body never runs at
 * all.
 *
 * Cowlishaw §2.7, p. 47
 */
counter = 0
DO WHILE counter < 3
  counter = counter + 1
END
CALL m 'eq', 3, counter

/* Concept: DO UNTIL tests after each iteration.
 * The form DO UNTIL expr evaluates the controlling expression
 * after each pass and halts when the value reaches '1'. The body
 * runs at least once even if the expression starts true; UNTIL is
 * the post-test counterpart to WHILE's pre-test.
 *
 * Cowlishaw §2.7, p. 47
 */
tries = 0
DO UNTIL tries >= 2
  tries = tries + 1
END
CALL m 'eq', 2, tries

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/08_about_do_loops.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
