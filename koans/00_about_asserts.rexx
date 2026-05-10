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
 * The first assertion verb is `eq`. The koan framework defines `eq`
 * to pass when its two arguments compare equal — the first argument
 * is the value the koan expects, the second the value the koan
 * computes.
 *
 * The REXX mechanism `eq` exercises is the `=` comparative operator
 * (Cowlishaw §2.3, p. 26): a normal comparison that performs a
 * numeric comparison when both terms are numeric and otherwise
 * pads and compares them as strings. The expression  2 + 2  is
 * arithmetic and produces the numeric string for the obvious sum.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'eq', FILL_ME_IN, 2 + 2, n
n = n + 1; CALL m 'eq', 'pilgrim', 'pilgrim', n

/* Concept: difference.
 * The `neq` assertion verb is the framework's mirror of `eq`: it
 * passes when its two values do NOT match. Here the koan asserts
 * that two distinct names are unequal.
 *
 * The REXX mechanism `neq` exercises is the `\=` comparative
 * operator (Cowlishaw §2.3, p. 26) — the negation of `=`.
 *
 * Cowlishaw §2.5, p. 32
 */
n = n + 1; CALL m 'neq', 'pilgrim', 'wanderer', n

/* Concept: truth.
 * The `true` assertion verb passes when its first argument
 * evaluates to the Logical (Boolean) value '1'. The framework
 * uses '0' and '1' as its pass/fail signal because that is what
 * REXX's comparative and logical operators return.
 *
 * The REXX mechanism: comparative operators such as `=` and `>`
 * (Cowlishaw §2.3, p. 26) return the Logical (Boolean) values
 * '0' and '1' (Cowlishaw §2.3, p. 27 — Logical (Boolean)) on
 * success and failure respectively. The second argument is
 * unused for `true`.
 *
 * Cowlishaw §2.3, p. 26
 */
n = n + 1; CALL m 'true', (1 = 1), '', n
n = n + 1; CALL m 'true', (5 > 3), '', n

/* Concept: type.
 * The `datatype` assertion verb passes when the value's REXX type
 * matches the type code given. The framework's verb name borrows
 * from the REXX built-in.
 *
 * The REXX mechanism is the DATATYPE built-in function
 * (Cowlishaw §2.9, p. 91): with a type code as its second
 * argument it returns '1' or '0' according to whether the first
 * argument matches the named type. Common codes: W for Whole, N
 * for Number, A for Alphanumeric. The pilgrim fills in the code
 * that declares 5 a Whole.
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
