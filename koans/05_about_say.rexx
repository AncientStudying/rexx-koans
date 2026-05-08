/* koans/05_about_say.rexx
 *
 * Station: The Pilgrim Speaks
 *
 * SAY is how a REXX program speaks. The keyword takes one expression
 * as its argument, evaluates it, and emits the result to standard
 * output. Whatever the pilgrim can compute into a variable, the
 * pilgrim can SAY.
 *
 * Cowlishaw §2.7, p. 56 -- The SAY instruction
 */

n = 0

/* Concept: SAY evaluates an expression and writes the result.
 * The keyword SAY takes one expression as its argument, evaluates
 * it, and emits the resulting string to standard output followed by
 * a newline. The expression follows ordinary REXX rules; if you can
 * compute it into a variable, you can SAY it. With  greeting set to
 * 'pilgrim', the expression  'Hello,' greeting  blank-concatenates
 * to a familiar greeting.
 *
 * Cowlishaw §2.7, p. 56 -- The SAY instruction
 */
greeting = 'pilgrim'
message = 'Hello,' greeting
n = n + 1; CALL m 'eq', FILL_ME_IN, message, n

/* Concept: blank concatenation in SAY context.
 * SAY's argument is one expression -- the same kind any other clause
 * accepts. Two operands separated by whitespace concatenate with
 * exactly one blank between them. The same rule applies whether you
 * SAY the expression or assign it.
 *
 * Cowlishaw §2.7, p. 56 -- The SAY instruction
 */
left = 'one'
right = 'two'
together = left right
n = n + 1; CALL m 'eq', 'one two', together, n

/* Concept: an empty SAY emits a blank line.
 * SAY with no expression is shorthand for SAY ''. The empty string
 * has length zero; SAY of it produces just the trailing newline.
 *
 * Cowlishaw §2.7, p. 56 -- The SAY instruction
 */
empty = ''
n = n + 1; CALL m 'eq', '', empty, n
n = n + 1; CALL m 'eq', 0, LENGTH(empty), n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/05_about_say.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
