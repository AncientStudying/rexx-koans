/* solutions/10_about_signal.rexx
 *
 * Station: When the Path Bends
 *
 * SIGNAL labelname terminates every active DO, IF, SELECT, and
 * INTERPRET in the current routine and jumps to the named label.
 * SIGNAL VALUE computes the label at runtime. The path bends and does
 * not unbend; the special variable SIGL records where it bent from.
 *
 * Cowlishaw §2.7, p. 72
 */

n = 0

/* Concept: SIGNAL labelname transfers control to a label.
 * SIGNAL terminates every active DO, IF, SELECT, and INTERPRET in
 * the current routine and jumps to the named label. Unlike CALL,
 * no return is possible: the path bends and does not unbend.
 *
 * Cowlishaw §2.7, p. 72
 */
visited = ''
SIGNAL skip_first
visited = visited || 'A'
skip_first:
visited = visited || 'B'
CALL m 'eq', 'B', visited

/* Concept: SIGNAL out of a DO group does not unwind.
 * Active DO loops, IF branches, and SELECT constructs are
 * terminated by SIGNAL -- their END clauses are not reached and
 * their post-loop bookkeeping is skipped. The pilgrim treats
 * SIGNAL as the last instruction the surrounding construct will
 * see.
 *
 * Cowlishaw §2.7, p. 72
 */
count = 0
DO i = 1 TO 5
  count = count + 1
  IF i = 3 THEN SIGNAL after_loop
END
count = count + 100
after_loop:
CALL m 'eq', 3, count

/* Concept: SIGNAL VALUE computes the label name at runtime.
 * SIGNAL VALUE expr evaluates the expression and SIGNALs to the
 * label whose name is the resulting string. The pilgrim can
 * choose the destination at runtime from a string rather than
 * naming it in source.
 *
 * Cowlishaw §2.7, p. 72
 */
where = 'second_label'
SIGNAL VALUE where
target_reached = 'first'
SIGNAL after_value
second_label:
target_reached = 'second'
SIGNAL after_value
after_value:
CALL m 'eq', 'second', target_reached

/* Concept: SIGNAL sets the special variable SIGL.
 * When SIGNAL transfers control, REXX writes the source line
 * number of the SIGNAL clause into the special variable SIGL.
 * The koan framework's m: wrapper already reads SIGL on each
 * assertion entry; here the pilgrim observes that SIGL after a
 * jump is always a whole number.
 *
 * Cowlishaw §2.7, p. 72
 */
SIGNAL probe_sigl
last_line = 'unreached'
probe_sigl:
last_line = SIGL
CALL m 'datatype', last_line, 'W'

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/10_about_signal.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
