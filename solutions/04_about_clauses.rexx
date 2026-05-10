/* solutions/04_about_clauses.rexx
 *
 * Station: The Shape of an Instruction
 *
 * Solution for koans/04_about_clauses.rexx.
 *
 * Cowlishaw §2.4, p. 31
 */

n = 0

/* Concept: a clause is one logical instruction.
 * In REXX a clause is the unit of execution. Normally each line
 * holds one clause, but a single line may carry several clauses by
 * separating them with semicolons.
 *
 * Cowlishaw §2.4, p. 31
 */
a = 1; b = 2
CALL m 'eq', 3, a + b

/* Concept: continuation.
 * A continuation character (a comma) at the end of a line continues
 * the clause onto the next line. The clause ends only when a
 * non-comma, non-comment line terminates it.
 *
 * Cowlishaw §2.2, p. 23
 */
total = ,
        10 + 20
CALL m 'eq', 30, total

/* Concept: comments.
 * A REXX comment opens with `/*` and closes with `*/`.
 * It may appear anywhere whitespace can and may span multiple lines.
 * It produces no value; the surrounding clause is unaffected. The
 * trailing comment beside the assignment below is invisible to the
 * interpreter.
 *
 * Cowlishaw §2.2, p. 18 — Comments
 */
greeting = 'hello' /* a trailing comment */
CALL m 'eq', 'hello', greeting

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/04_about_clauses.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
