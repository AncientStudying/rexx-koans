/* lib/scripture.rexx -- keyed lookup for Bathonian design-principle texts.
 *
 * Contract: specs/008-m3-the-path/contracts/scripture_library.md.
 *
 * Invocation:
 *
 *   CALL 'lib/scripture.rexx' 'fetch', key
 *   RESULT  -- one of:
 *             <principle> '09'x <citation>   for a known key
 *             ''                              for an unknown key
 *
 * The runner (lib/pilgrimage.rexx) consults this library on a
 * scripture-bound koan failure and emits the FR-012 two-line
 * Bathonian block by splitting RESULT on the TAB separator.
 *
 * Required keys per PLAN.md §9 and FR-010 (M3 spec):
 *
 *   humans_not_machines        least_astonishment
 *   everything_is_string       read_aloud
 *   consistency                whitespace_matters_just_enough
 *   numbers_are_strings_too
 *
 * Constitution Principle II -- Regina built-ins only. No external
 * CALLs, no file I/O, no top-level side effects.
 *
 * Citation hygiene: each citation below resolves against
 * docs/cowlishaw_index.md (this library is not scanned by
 * bin/lint_citations; the join is verified manually).
 *   - §1.3, p. 7  -> docs/cowlishaw_index.md:39  (Fundamental Language Concepts)
 *   - §1.4, p. 13 -> docs/cowlishaw_index.md:45  (Design Principles)
 *   - §2.3, p. 25 -> docs/cowlishaw_index.md:137 (Concatenation)
 *   - §2.11, p. 129 -> docs/cowlishaw_index.md:847 (Numbers)
 */

PARSE ARG verb, key

SELECT
  WHEN verb = 'fetch' THEN RETURN fetch(key)
  OTHERWISE RETURN ''
END

fetch: PROCEDURE
  PARSE ARG k
  tab = '09'x
  SELECT
    WHEN k = 'humans_not_machines' THEN
      RETURN 'REXX is tuned to the needs of its users; the language user is usually right.' || tab || 'Cowlishaw §1.4, p. 13'
    WHEN k = 'least_astonishment' THEN
      RETURN 'A program should behave the way its reader expects; ask whether a feature carries a high astonishment factor.' || tab || 'Cowlishaw §1.3, p. 7'
    WHEN k = 'everything_is_string' THEN
      RETURN 'All values in REXX are symbolic strings of characters; the language has no other internal data type.' || tab || 'Cowlishaw §1.3, p. 7'
    WHEN k = 'read_aloud' THEN
      RETURN 'The tokens of a REXX program may be written much as you would write them in English; readability is paramount.' || tab || 'Cowlishaw §1.3, p. 7'
    WHEN k = 'consistency' THEN
      RETURN 'A consistent language is predictable; the same construct should mean the same thing wherever it appears.' || tab || 'Cowlishaw §1.3, p. 7'
    WHEN k = 'whitespace_matters_just_enough' THEN
      RETURN 'The blank operator concatenates with one blank; abuttal concatenates without; whitespace is a real operator.' || tab || 'Cowlishaw §2.3, p. 25 — Concatenation'
    WHEN k = 'numbers_are_strings_too' THEN
      RETURN 'A REXX number is a character string of digits; precision is set by NUMERIC, not built into the type.' || tab || 'Cowlishaw §2.11, p. 129 — Numbers'
    OTHERWISE RETURN ''
  END
