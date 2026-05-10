/* solutions/02_about_variables.rexx
 *
 * Station: The Naming of Things
 *
 * Solution for koans/02_about_variables.rexx.
 *
 * Cowlishaw §2.5, p. 32
 */

n = 0

/* Concept: assignment.
 * The form  symbol = expression  binds the symbol to the value of
 * the expression. After the assignment the symbol evaluates to that
 * value wherever it appears.
 *
 * Cowlishaw §2.5, p. 32
 */
greeting = 'namaste'
n = n + 1; CALL m 'eq', 'namaste', greeting, n

/* Concept: uninitialized variables.
 * A simple symbol that has never been assigned evaluates to its own
 * name in uppercase. There is no separate "undefined" value -- the
 * variable is its name until you bind it. This is also why the
 * FILL_ME_IN mechanism works: until you replace it, FILL_ME_IN
 * evaluates to the literal string 'FILL_ME_IN'.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'eq', 'NEVER_SET', NEVER_SET, n

/* Concept: case folding of symbols.
 * REXX simple symbols are case-insensitive. Whether you write
 * greeting, Greeting, or GREETING, you reference the same variable.
 * Literal strings are case-sensitive: the variable greeting can hold
 * 'namaste' while still being equal to itself when written as
 * GREETING.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'eq', 'namaste', GREETING, n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/02_about_variables.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
