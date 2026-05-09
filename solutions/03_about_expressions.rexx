/* solutions/03_about_expressions.rexx
 *
 * Station: Of Operators and Their Powers
 *
 * Solution for koans/03_about_expressions.rexx.
 *
 * Cowlishaw §2.3, p. 24
 */

n = 0

/* Concept: arithmetic.
 * REXX has the usual arithmetic operators: + - * / and ** (power).
 * Operands are converted to numbers as needed; the result is itself
 * a numeric string.
 *
 * Cowlishaw §2.3, p. 25 — Arithmetic
 */
n = n + 1; CALL m 'eq', 7, 3 + 4, n
n = n + 1; CALL m 'eq', 6, 12 / 2, n

/* Concept: comparison.
 * The = operator compares with numeric coercion: '5' = 5.0 is true
 * because both are the same number. The == operator is strict and
 * compares the literal characters: '5' == 5.0 is false because the
 * strings differ. \= and \== negate the two forms.
 *
 * Cowlishaw §2.3, p. 26
 */
n = n + 1; CALL m 'true', ('5' = 5.0), '', n
n = n + 1; CALL m 'true', ('5' \== 5.0), '', n

/* Concept: logical operators.
 * & is AND, | is OR, \ is NOT. The truth values of REXX are the
 * strings '0' (false) and '1' (true). Anything else passed to a
 * logical operator is an error.
 *
 * Cowlishaw §2.3, p. 27 — Logical (Boolean)
 */
n = n + 1; CALL m 'true', (1 & 1), '', n
n = n + 1; CALL m 'true', (0 | 1), '', n

/* Concept: concatenation.
 * Two values written next to each other with no operator between
 * them are concatenated. With at least one blank between them, the
 * result has exactly one blank inserted (blank concatenation). The
 * || operator forces concatenation regardless of whitespace.
 *
 * Cowlishaw §2.3, p. 25 — Concatenation
 */
left = 'na'
right = 'maste'
n = n + 1; CALL m 'eq', 'namaste', left||right, n
n = n + 1; CALL m 'eq', 'na maste', left right, n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/03_about_expressions.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
