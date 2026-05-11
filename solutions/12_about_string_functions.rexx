/* solutions/12_about_string_functions.rexx
 *
 * Station: Of Letters and Their Manipulation
 *
 * The string built-ins operate on character strings -- which, in
 * REXX, is every value. LENGTH counts characters; SUBSTR, LEFT, and
 * RIGHT carve out substrings; POS finds them; COPIES and TRANSLATE
 * build and recolour them.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: LENGTH measures a string in characters.
 * LENGTH returns the count of characters in its argument. The
 * count of the empty string is 0; the count of 'hello' is 5. The
 * built-in works on every value because, in REXX, every value is
 * already a string.
 *
 * Scripture: everything_is_string
 * Cowlishaw §2.9, p. 98 — LENGTH
 */
CALL m 'eq', 5, LENGTH('hello')
CALL m 'eq', 0, LENGTH('')

/* Concept: SUBSTR, LEFT, and RIGHT carve substrings.
 * SUBSTR(s, n, k) returns k characters of s starting at position n.
 * LEFT(s, k) returns the first k; RIGHT(s, k) returns the last k.
 * Position numbering starts at 1; out-of-range positions pad with
 * blanks rather than failing.
 *
 * Cowlishaw §2.9, p. 107 — SUBSTR
 */
sentence = 'pilgrim walks the path'
CALL m 'eq', 'walks', SUBSTR(sentence, 9, 5)
CALL m 'eq', 'pilgrim', LEFT(sentence, 7)
CALL m 'eq', 'path', RIGHT(sentence, 4)

/* Concept: POS finds a substring's position.
 * POS(needle, haystack) returns the position of needle in haystack
 * (1-based) or 0 if not found. The pilgrim uses POS to detect
 * presence and to anchor SUBSTR, LEFT, and RIGHT operations.
 *
 * Cowlishaw §2.9, p. 102 — POS
 */
CALL m 'eq', 9, POS('walks', sentence)
CALL m 'eq', 0, POS('horse', sentence)

/* Concept: COPIES and TRANSLATE build strings.
 * COPIES(s, n) returns n concatenated copies of s. TRANSLATE(s)
 * with no other argument upper-cases s; TRANSLATE(s, out, in) maps
 * each character of s found in `in` to the corresponding character
 * of `out`.
 *
 * Cowlishaw §2.9, p. 90 — COPIES
 */
CALL m 'eq', '......', COPIES('.', 6)
CALL m 'eq', 'PILGRIM', TRANSLATE('pilgrim')

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/12_about_string_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
