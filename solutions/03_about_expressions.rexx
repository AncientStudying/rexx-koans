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
CALL m 'eq', 7, 3 + 4
CALL m 'eq', 6, 12 / 2

/* Concept: comparative operators.
 * The = operator performs a normal comparison: '5' = 5.0 is true
 * because both are the same number. The == operator is a strict
 * comparison and compares strings character-by-character without
 * padding: '5' == 5.0 is false because the strings differ. \= and
 * \== negate the two forms.
 *
 * Cowlishaw §2.3, p. 26
 */
CALL m 'true', ('5' = 5.0), ''
CALL m 'true', ('5' \== 5.0), ''

/* Concept: logical operators.
 * & is And, | is Inclusive or, \ is Logical not. The Logical
 * (Boolean) values are the strings '0' (false) and '1' (true).
 * Anything else passed to a logical operator is an error.
 *
 * Cowlishaw §2.3, p. 27 — Logical (Boolean)
 */
CALL m 'true', (1 & 1), ''
CALL m 'true', (0 | 1), ''

/* Concept: concatenation.
 * Two terms written next to each other with no operator between
 * them are concatenated by abuttal. With at least one blank
 * between them, the blank operator inserts exactly one blank in
 * the result. The || operator joins without a blank, regardless
 * of whitespace.
 *
 * Cowlishaw §2.3, p. 25 — Concatenation
 */
left = 'na'
right = 'maste'
CALL m 'eq', 'namaste', left||right
CALL m 'eq', 'na maste', left right

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/03_about_expressions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
