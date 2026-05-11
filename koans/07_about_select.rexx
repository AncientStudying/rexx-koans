/* koans/07_about_select.rexx
 *
 * Station: Of Many Ways
 *
 * SELECT chooses one of several alternative WHEN branches: each WHEN
 * expression is evaluated in turn, and the first to yield '1' selects
 * its THEN. OTHERWISE supplies the fallback path; without it, an
 * unmatched SELECT raises SYNTAX. The pilgrim walks exactly one way.
 *
 * Cowlishaw §2.7, p. 71
 */

n = 0

/* Concept: SELECT chooses one of several alternative WHEN branches.
 * The SELECT keyword evaluates each WHEN expression in order; the
 * first WHEN that yields '1' executes its THEN clause and the rest
 * are skipped. SELECT is a multi-way branch; the pilgrim walks
 * exactly one of many possible ways.
 *
 * Cowlishaw §2.7, p. 71
 */
fruit = 'apple'
SELECT
  WHEN fruit = 'apple'  THEN colour = 'red'
  WHEN fruit = 'banana' THEN colour = 'yellow'
  WHEN fruit = 'plum'   THEN colour = 'purple'
  OTHERWISE colour = 'unknown'
END
CALL m 'eq', FILL_ME_IN, colour

/* Concept: OTHERWISE supplies the fallback path.
 * If no WHEN yields '1' and no OTHERWISE clause is present, REXX
 * raises a SYNTAX condition. The OTHERWISE clause guarantees the
 * SELECT always selects something; the pilgrim who omits it and is
 * surprised by a runtime error is the exact moment this principle
 * illuminates.
 *
 * Scripture: least_astonishment
 * Cowlishaw §2.7, p. 71
 */
fruit = 'durian'
SELECT
  WHEN fruit = 'apple'  THEN colour = 'red'
  WHEN fruit = 'banana' THEN colour = 'yellow'
  OTHERWISE colour = 'unknown'
END
CALL m 'eq', 'unknown', colour

/* Concept: the first matching WHEN wins.
 * When more than one WHEN expression yields '1', the earliest in
 * source order selects; later matches are not evaluated. The
 * pilgrim orders WHENs from most specific to most general so that
 * narrower conditions are not shadowed.
 *
 * Cowlishaw §2.7, p. 71
 */
number = 6
SELECT
  WHEN number > 0 THEN tag = 'positive'
  WHEN number > 5 THEN tag = 'big-positive'
  OTHERWISE tag = 'non-positive'
END
CALL m 'eq', FILL_ME_IN, tag

/* Concept: WHEN expressions must yield '1' or '0'.
 * Like IF's controlling expression, each WHEN's controlling
 * expression must evaluate to the Logical value '1' or '0'. Any
 * other value raises a SYNTAX condition; the pilgrim writes WHEN
 * expressions as comparisons or logical combinations.
 *
 * Cowlishaw §2.3, p. 26
 */
score = 75
SELECT
  WHEN score >= 90 THEN grade = 'A'
  WHEN score >= 80 THEN grade = 'B'
  WHEN score >= 70 THEN grade = 'C'
  OTHERWISE grade = 'F'
END
CALL m 'eq', FILL_ME_IN, grade

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/07_about_select.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
