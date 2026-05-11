/* koans/14_about_arithmetic_functions.rexx
 *
 * Station: Of Numbers and Their Shape
 *
 * The arithmetic built-ins return strings of digits formatted under
 * the prevailing NUMERIC settings. ABS removes sign; MAX and MIN
 * choose among arguments; TRUNC drops fractional digits; FORMAT
 * lays out a number with explicit widths; SIGN reports the
 * polarity.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: ABS strips the sign.
 * ABS(n) returns the absolute value of n: the same digits without
 * a leading minus. The result is always non-negative. ABS(0) is
 * 0.
 *
 * Cowlishaw §2.9, p. 82 — ABS
 */
CALL m 'eq', FILL_ME_IN, ABS(-7)
CALL m 'eq', 0, ABS(0)

/* Concept: MAX and MIN choose among arguments.
 * MAX(a, b, ...) returns the largest of its arguments. MIN(a, b,
 * ...) returns the smallest. Both accept any number of numeric
 * arguments and order them by ordinary REXX number comparison;
 * the result is itself a number string.
 *
 * Scripture: numbers_are_strings_too
 * Cowlishaw §2.9, p. 102 — MAX
 */
CALL m 'eq', FILL_ME_IN, MAX(3, 9, 7)
CALL m 'eq', 1, MIN(3, 9, 1, 7)

/* Concept: TRUNC drops fractional digits.
 * TRUNC(n) returns the integer part of n. TRUNC(n, k) keeps k
 * digits after the decimal point (padding with zeros if needed).
 * Truncation is not rounding -- digits beyond the kept portion are
 * dropped, not adjusted.
 *
 * Cowlishaw §2.9, p. 111 — TRUNC
 */
CALL m 'eq', 3, TRUNC(3.789)
CALL m 'eq', FILL_ME_IN, TRUNC(3.789, 2)

/* Concept: SIGN reports polarity.
 * SIGN(n) returns -1 if n is negative, 0 if n is zero, and 1 if n
 * is positive. The result is itself a number; the pilgrim can
 * feed it back into further arithmetic.
 *
 * Cowlishaw §2.9, p. 104 — SIGN
 */
CALL m 'eq', -1, SIGN(-3)
CALL m 'eq', 0, SIGN(0)
CALL m 'eq', 1, SIGN(8)

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/14_about_arithmetic_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
