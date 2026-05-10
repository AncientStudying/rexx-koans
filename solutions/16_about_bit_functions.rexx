/* solutions/16_about_bit_functions.rexx
 *
 * Station: Down to the Bits
 *
 * The bit built-ins operate on character strings as if they were
 * sequences of bits, one byte at a time. BITAND, BITOR, and BITXOR
 * pair their arguments byte-by-byte and apply the boolean
 * operation. The bit level is the lowest the pilgrim goes.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: BITAND combines bits with AND.
 * BITAND(s1, s2) returns a string whose every bit is 1 only where
 * both s1 and s2 have a 1 at that position. Strings of unequal
 * length are aligned at the left; the shorter is padded with the
 * pad byte (default '00'x).
 *
 * Cowlishaw §2.9, p. 84 — BITAND
 */
CALL m 'eq', '01'x, BITAND('03'x, '05'x)
CALL m 'eq', '00'x, BITAND('FF'x, '00'x)

/* Concept: BITOR combines bits with OR.
 * BITOR(s1, s2) returns a string whose every bit is 1 wherever
 * either s1 or s2 has a 1 at that position. Inclusive or, byte by
 * byte.
 *
 * Cowlishaw §2.9, p. 84 — BITOR
 */
CALL m 'eq', '07'x, BITOR('03'x, '05'x)
CALL m 'eq', 'FF'x, BITOR('F0'x, '0F'x)

/* Concept: BITXOR combines bits with XOR.
 * BITXOR(s1, s2) returns a string whose every bit is 1 only where
 * s1 and s2 differ at that position. Exclusive or; applying
 * BITXOR twice with the same key restores the original byte.
 *
 * Cowlishaw §2.9, p. 85 — BITXOR
 */
CALL m 'eq', '06'x, BITXOR('03'x, '05'x)
plain = '7A'x
key = '5C'x
ciphered = BITXOR(plain, key)
restored = BITXOR(ciphered, key)
CALL m 'eq', plain, restored

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/16_about_bit_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
