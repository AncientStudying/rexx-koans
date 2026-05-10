/* solutions/15_about_conversion_functions.rexx
 *
 * Station: Between One Form and Another
 *
 * REXX values may live as decimal digits, hex digits, binary
 * digits, or character bytes. The conversion built-ins translate
 * between these forms: D2X and X2D handle decimal-hex; C2X and X2C
 * handle character-hex; B2X and X2B handle binary-hex; D2C and C2D
 * cross between decimal and characters.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: D2X and X2D translate decimal and hex.
 * D2X(n) returns the hex representation of the non-negative
 * decimal n. X2D(h) returns the decimal value of the hex string h.
 * Round-tripping preserves the value.
 *
 * Cowlishaw §2.9, p. 95 — D2X
 */
CALL m 'eq', 'FF', D2X(255)
CALL m 'eq', 255, X2D('FF')

/* Concept: C2X and X2C translate characters and hex.
 * C2X(s) returns the hex representation of the byte sequence s
 * (two hex digits per character). X2C(h) reverses the conversion,
 * turning a hex string back into the corresponding bytes.
 *
 * Cowlishaw §2.9, p. 91 — C2X
 */
CALL m 'eq', '41', C2X('A')
CALL m 'eq', 'A', X2C('41')

/* Concept: B2X and X2B translate binary and hex.
 * B2X(b) returns the hex representation of the binary string b
 * (four bits per hex digit). X2B(h) reverses the conversion. The
 * built-ins are the bridge from bit-level to character-level work.
 *
 * Cowlishaw §2.9, p. 85 — B2X
 */
CALL m 'eq', 'A', B2X('1010')
CALL m 'eq', '1111', X2B('F')

/* Concept: D2C and C2D translate decimal and characters.
 * D2C(n) returns the character whose byte code is the decimal n.
 * C2D(s) returns the decimal code of the byte sequence s. The
 * pilgrim uses these to move between numeric codes and the symbols
 * those codes represent.
 *
 * Cowlishaw §2.9, p. 94 — D2C
 */
CALL m 'eq', 'A', D2C(65)
CALL m 'eq', 97, C2D('a')

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/15_about_conversion_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
