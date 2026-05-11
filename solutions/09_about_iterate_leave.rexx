/* solutions/09_about_iterate_leave.rexx
 *
 * Station: Of Skipping and Leaving
 *
 * ITERATE skips the rest of the current iteration and re-tests the
 * loop. LEAVE exits the loop entirely. Both accept an optional loop
 * name to select an outer DO from within a nest. After LEAVE, the
 * control variable holds the value it had when LEAVE ran.
 *
 * Cowlishaw §2.7, p. 57
 */

n = 0

/* Concept: ITERATE skips to the next iteration.
 * Inside a repetitive DO, ITERATE stops the current iteration and
 * returns control to the DO clause as though END had been reached:
 * the control variable steps and the loop's condition is
 * re-evaluated. The remaining body is skipped for that pass.
 *
 * Cowlishaw §2.7, p. 57
 */
sum_odd = 0
DO i = 1 TO 6
  IF i // 2 = 0 THEN ITERATE
  sum_odd = sum_odd + i
END
CALL m 'eq', 9, sum_odd

/* Concept: LEAVE exits the loop entirely.
 * LEAVE causes immediate exit from the innermost repetitive DO,
 * transferring control to the clause following the matching END.
 * The control variable retains the value it held at the moment
 * LEAVE executed.
 *
 * Cowlishaw §2.7, p. 58
 */
found_at = 0
DO j = 1 TO 10
  IF j = 4 THEN DO
    found_at = j
    LEAVE
  END
END
CALL m 'eq', 4, found_at

/* Concept: ITERATE and LEAVE accept a loop name.
 * Both ITERATE and LEAVE accept an optional name that selects a
 * specific outer loop. Without a name, the innermost active loop
 * is the target; with a name, nested loops can be controlled from
 * within without lifting the control variable out by hand.
 *
 * Cowlishaw §2.7, p. 58
 */
outer_pairs = ''
DO outer = 1 TO 3
  DO inner = 1 TO 3
    IF inner = 2 THEN ITERATE outer
    outer_pairs = outer_pairs || outer || '-' || inner || ' '
  END
END
CALL m 'eq', '1-1 2-1 3-1 ', outer_pairs

/* Concept: the control variable survives LEAVE.
 * After LEAVE, the control variable holds the value it had at the
 * moment LEAVE ran -- not the next step's value, not the limit
 * value, but the captured value. The pilgrim may inspect it after
 * the loop exits.
 *
 * Cowlishaw §2.7, p. 58
 */
DO k = 1 TO 100
  IF k > 5 THEN LEAVE
END
CALL m 'eq', 6, k

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/09_about_iterate_leave.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
