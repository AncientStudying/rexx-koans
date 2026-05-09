/* koans/00_about_asserts.rexx
 *
 * Station: The First Truths
 *
 * Welcome, pilgrim. Before you walk the path of REXX you must learn
 * the four kinds of assertion. Each kind asks a different question of
 * the world; each kind answers in the same voice when its question is
 * answered correctly.
 *
 * In this koan, anywhere you see the symbol FILL_ME_IN, replace it
 * with the value the teaching block names. The runner will stop at
 * the first blank it finds; fill it, run again, and the path opens.
 *
 * Cowlishaw §1.1, p. 1
 */

n = 0

/* Concept: equality.
 * The first kind of assertion is 'eq'. It passes when its two values
 * match. The first argument is the value the koan expects; the
 * second is the value the koan computes. They are compared as REXX
 * strings, with numeric coercion when both look like numbers.
 *
 * The expression  2 + 2  produces the string for the obvious sum.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'eq', FILL_ME_IN, 2 + 2, n
n = n + 1; CALL m 'eq', 'pilgrim', 'pilgrim', n

/* Concept: difference.
 * The 'neq' kind passes when its two values do NOT match. Here the
 * koan asserts that two distinct names are unequal.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'neq', 'pilgrim', 'wanderer', n

/* Concept: truth.
 * The 'true' kind passes when its first argument evaluates to the
 * REXX boolean 1. Comparisons such as 1 = 1 and 5 > 3 produce the
 * string '1' on success. The second argument is unused for 'true'.
 *
 * Cowlishaw §2.3, p. 26
 */
n = n + 1; CALL m 'true', (1 = 1), '', n
n = n + 1; CALL m 'true', (5 > 3), '', n

/* Concept: type.
 * The 'datatype' kind passes when the value's REXX type matches the
 * type code given. Common codes: W for whole number, N for any
 * number, A for alphanumeric. The pilgrim fills in the code that
 * declares 5 a whole number.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'datatype', 5, FILL_ME_IN, n
n = n + 1; CALL m 'datatype', 'pilgrim', 'A', n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/00_about_asserts.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
