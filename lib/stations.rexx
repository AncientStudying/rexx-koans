/* lib/stations.rexx -- station-display module.
 *
 * Contract: specs/002-m2-walking-skeleton/contracts/stations.md.
 *
 * Three verbs, dispatched by the first argument:
 *
 *   CALL 'lib/stations.rexx' 'subtitle', koan_path
 *     Returns the Station: directive value (RESULT) for the koan,
 *     or empty string if absent.
 *
 *   CALL 'lib/stations.rexx' 'list', records_blob, max_topic_width
 *     Side effect: SAYs the fixed-pitch station list followed by a
 *     blank line. records_blob is one record per line (LF-separated);
 *     each record is four TAB-separated fields:
 *       seq  topic  subtitle  status
 *     status is one of 'ok', 'here', 'blank'.
 *
 *   CALL 'lib/stations.rexx' 'summary', walked, total, failed_topic
 *     Side effect: SAYs the summary line. failed_topic is the empty
 *     string on a fully-passing run.
 *
 * Constitution Principle II -- Regina built-ins only.
 * Decision 4: ASCII only, LF only, spaces only (no tabs in output;
 * the TAB used in records_blob is internal serialisation, never
 * emitted).
 */

PARSE ARG verb, .

SELECT
  WHEN verb = 'subtitle' THEN DO
    PARSE ARG ., koan_path
    RETURN extract_subtitle(koan_path)
  END
  WHEN verb = 'list' THEN DO
    PARSE ARG ., records_blob, max_topic_width
    CALL render_list records_blob, max_topic_width
    RETURN ''
  END
  WHEN verb = 'summary' THEN DO
    PARSE ARG ., walked, total, failed_topic
    CALL render_summary walked, total, failed_topic
    RETURN ''
  END
  OTHERWISE RETURN ''
END

extract_subtitle: PROCEDURE
  PARSE ARG koan_path
  IF STREAM(koan_path, 'C', 'QUERY EXISTS') = '' THEN RETURN ''
  found = ''
  lines_seen = 0
  DO WHILE LINES(koan_path) > 0
    line = LINEIN(koan_path)
    lines_seen = lines_seen + 1
    IF lines_seen > 50 THEN LEAVE
    s = STRIP(line)
    IF s = '' THEN ITERATE
    /* Stop at the first non-comment, non-blank line. */
    IF \is_comment(s) THEN LEAVE
    /* Strip leading comment-prefix characters. */
    DO WHILE s \= ''
      c = LEFT(s, 1)
      IF c = '*' | c = '/' | c = ' ' | c = '09'x THEN s = SUBSTR(s, 2)
      ELSE LEAVE
    END
    IF POS('Station:', s) = 1 THEN DO
      rest = STRIP(SUBSTR(s, LENGTH('Station:') + 1))
      IF rest \= '' & found = '' THEN found = rest
    END
  END
  CALL STREAM koan_path, 'C', 'CLOSE'
  RETURN found

is_comment: PROCEDURE
  PARSE ARG s
  IF LEFT(s, 2) = '/*' THEN RETURN 1
  IF LEFT(s, 1) = '*' THEN RETURN 1
  IF RIGHT(s, 2) = '*/' THEN RETURN 1
  RETURN 0

render_list: PROCEDURE
  PARSE ARG records_blob, max_topic_width
  /* Each record: seq <TAB> topic <TAB> subtitle <TAB> status, LF-separated. */
  topic_col = max_topic_width + 2
  DO WHILE records_blob \= ''
    PARSE VAR records_blob record '0a'x records_blob
    IF record = '' THEN ITERATE
    PARSE VAR record seq '09'x topic '09'x subtitle '09'x status
    marker = format_marker(status)
    IF status = 'blank' THEN
      SAY '  ['marker']' seq topic
    ELSE
      SAY '  ['marker']' seq LEFT(topic, topic_col) || subtitle
  END
  SAY ''
  RETURN

format_marker: PROCEDURE
  PARSE ARG status
  SELECT
    WHEN status = 'ok'    THEN RETURN '  ok  '
    WHEN status = 'here'  THEN RETURN ' here '
    OTHERWISE                  RETURN '      '
  END

render_summary: PROCEDURE
  PARSE ARG walked, total, failed_topic
  IF failed_topic = '' THEN
    SAY '  Stations walked:' walked 'of' total'.'
  ELSE
    SAY '  Stations walked:' walked 'of' total'.  Karma damaged at:' failed_topic'.'
  RETURN
