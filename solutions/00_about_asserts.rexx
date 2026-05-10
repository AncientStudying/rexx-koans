/* solutions/00_about_asserts.rexx
 *
 * Station: The First Truths
 *
 * Solution for koans/00_about_asserts.rexx.
 *
 * Cowlishaw §1.1, p. 1
 */

n = 0

/* Concept: equality.
 * The pilgrim's first instrument is assertion of equality. The
 * dispatcher's 'eq' kind passes when its two values match. The first
 * argument is the value the koan expects; the second is the value the
 * koan computes.
 *
 * The REXX mechanism `eq` exercises is the `=` comparative operator
 * (Cowlishaw §2.3, p. 26): a normal comparison that performs a
 * numeric comparison when both terms are numeric and otherwise pads
 * and compares them as strings.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'eq', '4', 2 + 2, n
n = n + 1; CALL m 'eq', 'pilgrim', 'pilgrim', n

/* Concept: difference.
 * The 'neq' kind passes when its two values do NOT match. It is the
 * mirror of 'eq' and is useful when the koan teaches that two values
 * must be different.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'neq', 'pilgrim', 'wanderer', n

/* Concept: truth.
 * The 'true' kind passes when its first argument evaluates to the
 * Logical (Boolean) value '1' (Cowlishaw §2.3, p. 27 — Logical
 * (Boolean)). Comparative operators (Cowlishaw §2.3, p. 26) such as
 * 1 = 1 and 5 > 3 produce the string '1' on success. The second
 * argument is unused for 'true' and is conventionally the empty
 * string.
 *
 * Cowlishaw §2.3, p. 26
 */
n = n + 1; CALL m 'true', (1 = 1), '', n
n = n + 1; CALL m 'true', (5 > 3), '', n

/* Concept: type.
 * The 'datatype' kind passes when the value's REXX type matches the
 * type code given by DATATYPE (Cowlishaw §2.9, p. 91). Common codes:
 * W for Whole, N for Number, A for Alphanumeric.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'datatype', 5, 'W', n
n = n + 1; CALL m 'datatype', 'pilgrim', 'A', n

EXIT 0

m: PARSE ARG kind, arg1, arg2, num
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/00_about_asserts.rexx', num, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
