/* solutions/04_about_clauses.rexx
 *
 * Station: The Shape of an Instruction
 *
 * Solution for koans/04_about_clauses.rexx.
 *
 * Cowlishaw §2.4, p. 38 -- Clauses
 */

n = 0

/* Concept: a clause is one logical instruction.
 * In REXX a clause is the unit of execution. Normally each line
 * holds one clause, but a single line may carry several clauses by
 * separating them with semicolons.
 *
 * Cowlishaw §2.4, p. 38 -- Clauses
 */
a = 1; b = 2
n = n + 1; CALL m 'eq', 3, a + b, n

/* Concept: continuation.
 * A comma at the end of a line continues the clause onto the next
 * line. The clause ends only when a non-comma, non-comment line
 * terminates it.
 *
 * Cowlishaw §2.4, p. 38 -- Continuation
 */
total = ,
        10 + 20
n = n + 1; CALL m 'eq', 30, total, n

/* Concept: comments.
 * A REXX comment opens with slash-star and closes with star-slash.
 * It may appear anywhere whitespace can and may span multiple lines.
 * It produces no value; the surrounding clause is unaffected. The
 * trailing comment beside the assignment below is invisible to the
 * interpreter.
 *
 * Cowlishaw §2.4, p. 39 -- Comments
 */
greeting = 'hello' /* a trailing comment */
n = n + 1; CALL m 'eq', 'hello', greeting, n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/04_about_clauses.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
