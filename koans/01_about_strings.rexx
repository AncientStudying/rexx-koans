/* koans/01_about_strings.rexx
 *
 * Station: Of the Word Made String
 *
 * In REXX every value is a string. There is no separate character
 * type, no separate number type beneath the surface; numbers are
 * strings the interpreter recognises as numeric. To learn REXX is
 * first to learn the string.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */

n = 0

/* Concept: single quotes and double quotes both make literal strings.
 * REXX has no separate character type. 'pilgrim' and "pilgrim"
 * denote the same value -- they are equal under both = and ==.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */
CALL m 'eq', 'pilgrim', "pilgrim"

/* Concept: LENGTH counts characters.
 * The built-in LENGTH returns the number of characters in a string.
 * The empty string has length 0. The pilgrim fills in the length of
 * the literal 'koans:'.
 *
 * Cowlishaw §2.2, p. 19 — Literal strings
 */
CALL m 'eq', FILL_ME_IN, LENGTH('koans:')
CALL m 'eq', 0, LENGTH('')

/* Concept: numbers are strings.
 * Everything in REXX is a string. A number is a string the
 * interpreter recognises as numeric. The framework's `datatype`
 * assertion verb passes when DATATYPE (the REXX built-in,
 * Cowlishaw §2.9, p. 91) returns true for the named type — code
 * 'N' (Number) accepts numeric strings. The pilgrim fills in the
 * type code that declares '42' a Number.
 *
 * Cowlishaw §2.3, p. 27 — Numbers
 */
CALL m 'datatype', '42', FILL_ME_IN
CALL m 'eq', '5', 2 + 3

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/01_about_strings.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
