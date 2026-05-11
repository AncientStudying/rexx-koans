/* koans/11_about_interpret.rexx
 *
 * Station: What is Spoken Becomes Done
 *
 * INTERPRET evaluates an expression and then executes the resulting
 * string of REXX as if it were a clause spoken into the program. The
 * interpreted clause shares the caller's variable scope; DO and
 * SELECT inside must begin and end inside.
 *
 * Cowlishaw §2.7, p. 55
 */

n = 0

/* Concept: INTERPRET executes a string as REXX.
 * INTERPRET evaluates an expression and treats the resulting
 * string as though it were a clause inserted into the program.
 * What the pilgrim writes into the string becomes a REXX
 * instruction at runtime; speech becomes execution.
 *
 * Cowlishaw §2.7, p. 55
 */
code = 'greeting = "hello"'
INTERPRET code
CALL m 'eq', FILL_ME_IN, greeting

/* Concept: variables set inside INTERPRET persist.
 * INTERPRET runs in the caller's variable scope: assignments made
 * inside the interpreted string remain visible after INTERPRET
 * returns. The interpreted text is a clause, not a routine, so no
 * variable scope is introduced.
 *
 * Cowlishaw §2.7, p. 55
 */
INTERPRET 'product = 6 * 7'
CALL m 'eq', 42, product

/* Concept: INTERPRET can run a constructed expression.
 * The interpreted string may be built from variables and
 * concatenation at runtime. The pilgrim composes the clause out
 * of pieces and INTERPRET runs whatever the pieces produce.
 *
 * Cowlishaw §2.7, p. 55
 */
verb = 'result'
op = '+'
clause = verb '=' '10' op '20'
INTERPRET clause
CALL m 'eq', FILL_ME_IN, result

/* Concept: INTERPRET requires complete constructs.
 * INTERPRET demands that DO and SELECT begin and end inside the
 * interpreted string. A naked DO without a matching END is a
 * SYNTAX condition. Complete constructs in, complete constructs
 * out.
 *
 * Cowlishaw §2.7, p. 55
 */
INTERPRET 'sum = 0; DO i = 1 TO 4; sum = sum + i; END'
CALL m 'eq', FILL_ME_IN, sum

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/11_about_interpret.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
