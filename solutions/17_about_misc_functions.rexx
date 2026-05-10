/* solutions/17_about_misc_functions.rexx
 *
 * Station: Of Time and Chance
 *
 * The miscellaneous built-ins reach outside the koan's strict
 * world. DATATYPE classifies a value; DATE and TIME read the wall
 * clock; RANDOM yields a pseudo-random whole number; the built-in
 * ADDRESS reports the current external environment.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: DATATYPE classifies a value.
 * DATATYPE(s) returns 'NUM' if s is a valid REXX number and 'CHAR'
 * otherwise. DATATYPE(s, code) returns '1' if s matches the named
 * type and '0' otherwise. Common codes: W (whole), N (number), A
 * (alphanumeric), M (mixed-case alphabetic).
 *
 * Cowlishaw §2.9, p. 91 — DATATYPE
 */
CALL m 'eq', 'NUM', DATATYPE(42)
CALL m 'eq', 'CHAR', DATATYPE('hello')
CALL m 'eq', 1, DATATYPE(7, 'W')
CALL m 'eq', 0, DATATYPE('hello', 'W')

/* Concept: DATE and TIME yield wall-clock strings.
 * DATE() with no argument returns today's date in 'dd Mon yyyy'
 * form. DATE('S') returns 'yyyymmdd' -- an always-sortable
 * representation that is always eight digits long. TIME() with no
 * argument returns 'hh:mm:ss'; TIME('S') returns elapsed seconds
 * since midnight.
 *
 * Cowlishaw §2.9, p. 92 — DATE
 */
today = DATE('S')
CALL m 'eq', 8, LENGTH(today)
CALL m 'datatype', today, 'W'

/* Concept: RANDOM yields a pseudo-random whole number.
 * RANDOM(max) returns a whole number between 0 and max. RANDOM
 * with no arguments returns a number between 0 and 999. A seed
 * argument (RANDOM(min, max, seed)) makes the sequence
 * reproducible.
 *
 * Cowlishaw §2.9, p. 103 — RANDOM
 */
roll = RANDOM(1, 6)
CALL m 'true', (roll >= 1) & (roll <= 6), ''

/* Concept: ADDRESS reports the current environment name.
 * ADDRESS() with no arguments returns the name of the current
 * external command environment as a string. The pilgrim
 * recognises this is the built-in -- a function -- and not the
 * ADDRESS instruction, which routes commands.
 *
 * Cowlishaw §2.9, p. 82 — ADDRESS
 */
env = ADDRESS()
CALL m 'true', (LENGTH(env) > 0), ''

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'solutions/17_about_misc_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
