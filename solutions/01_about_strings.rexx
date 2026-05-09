/* solutions/01_about_strings.rexx
 *
 * Station: Of the Word Made String
 *
 * Solution for koans/01_about_strings.rexx.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */

n = 0

/* Concept: single quotes and double quotes both make literal strings.
 * REXX has no separate "character" type; every literal is a string.
 * 'pilgrim' and "pilgrim" denote the same value.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */
n = n + 1; CALL m 'eq', 'pilgrim', "pilgrim", n

/* Concept: LENGTH counts characters.
 * The built-in LENGTH returns the number of characters in a string.
 * The empty string has length 0.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */
n = n + 1; CALL m 'eq', 6, LENGTH('koans:'), n
n = n + 1; CALL m 'eq', 0, LENGTH(''), n

/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string of digits the
 * interpreter happens to recognize as numeric. The 'datatype' kind
 * with code 'N' (number) accepts numeric strings; '42' and '3.14'
 * are numbers, 'pilgrim' is not.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
n = n + 1; CALL m 'datatype', '42', 'N', n
n = n + 1; CALL m 'eq', '5', 2 + 3, n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/01_about_strings.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
