/* koans/13_about_word_functions.rexx
 *
 * Station: Of Words and Their Counting
 *
 * The word built-ins operate on blank-delimited words. A word is a
 * sequence of non-blank characters; multiple blanks are one
 * separator. WORD, WORDS, WORDPOS, WORDLENGTH, SUBWORD, and
 * WORDINDEX let the pilgrim count, find, and slice words.
 *
 * Cowlishaw §2.9, p. 81
 */

n = 0

/* Concept: WORDS counts the words in a string.
 * WORDS(s) returns the number of blank-delimited words in s.
 * Leading and trailing blanks are ignored; multiple internal
 * blanks count as one separator. An empty or all-blank string has
 * zero words.
 *
 * Cowlishaw §2.9, p. 115 — WORDS
 */
CALL m 'eq', FILL_ME_IN, WORDS('the pilgrim walks the path')
CALL m 'eq', 0, WORDS('   ')

/* Concept: WORD returns the n-th word.
 * WORD(s, n) returns the n-th word of s; if s has fewer than n
 * words, the built-in returns the null string. Words are numbered
 * from 1.
 *
 * Cowlishaw §2.9, p. 114 — WORD
 */
sentence = 'the pilgrim walks the path'
CALL m 'eq', FILL_ME_IN, WORD(sentence, 2)
CALL m 'eq', '', WORD(sentence, 99)

/* Concept: WORDPOS and WORDINDEX locate words.
 * WORDPOS(needle, haystack) returns the word-number where needle
 * begins in haystack (or 0 if not found). WORDINDEX(s, n) returns
 * the character-position where the n-th word of s begins.
 *
 * Cowlishaw §2.9, p. 114 — WORDPOS
 */
CALL m 'eq', 3, WORDPOS('walks', sentence)
CALL m 'eq', 5, WORDINDEX(sentence, 2)

/* Concept: SUBWORD and WORDLENGTH slice words.
 * SUBWORD(s, n, k) returns k words of s starting at word n;
 * WORDLENGTH(s, n) returns the length in characters of the n-th
 * word. SUBWORD with no k returns all words from n to the end.
 *
 * Cowlishaw §2.9, p. 107 — SUBWORD
 */
CALL m 'eq', FILL_ME_IN, SUBWORD(sentence, 3, 2)
CALL m 'eq', 7, WORDLENGTH(sentence, 2)

EXIT 0

m: PARSE ARG kind, arg1, arg2
   n = n + 1
   CALL 'lib/meditation.rexx' kind, arg1, arg2, 'koans/13_about_word_functions.rexx', n, SIGL
   IF RESULT \= 0 THEN EXIT RESULT
   RETURN
