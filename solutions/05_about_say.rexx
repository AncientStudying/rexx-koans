/* solutions/05_about_say.rexx
 *
 * Station: The Pilgrim Speaks
 *
 * Solution for koans/05_about_say.rexx.
 *
 * Cowlishaw §2.7, p. 70
 */

n = 0

/* Concept: SAY evaluates an expression and writes the result.
 * The keyword SAY takes one expression as its argument, evaluates
 * it, and emits the resulting string to the default character
 * output stream followed by a newline. The expression follows
 * ordinary REXX rules; if you can compute it into a variable, you
 * can SAY it.
 *
 * Cowlishaw §2.7, p. 70
 */
greeting = 'pilgrim'
message = 'Hello,' greeting
CALL m 'eq', 'Hello, pilgrim', message

/* Concept: the blank operator in SAY context.
 * SAY's argument is one expression -- the same kind any other clause
 * accepts. Two terms separated by whitespace are joined by the
 * blank operator with exactly one blank between them. The same rule
 * applies whether you SAY the expression or assign it.
 *
 * Cowlishaw §2.7, p. 70
 */
left = 'one'
right = 'two'
together = left right
CALL m 'eq', 'one two', together

/* Concept: an empty SAY emits a blank line.
 * SAY with no expression is shorthand for SAY ''. The null string
 * has length zero; SAY of it produces just the trailing newline.
 *
 * Cowlishaw §2.7, p. 70
 */
empty = ''
CALL m 'eq', '', empty
CALL m 'eq', 0, LENGTH(empty)

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/05_about_say.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
