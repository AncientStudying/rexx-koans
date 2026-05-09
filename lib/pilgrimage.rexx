/* lib/pilgrimage.rexx -- the pilgrimage runner.
 *
 * Contract: specs/002-m2-walking-skeleton/contracts/runner.md.
 *
 * 1. Source the manifest (stem koans.).
 * 2. Validate the manifest is non-empty.
 * 3. Verify each manifest entry resolves to an existing file.
 * 4. Print the banner.
 * 5. Walk each koan as a Regina subprocess (Decision 1, M1 ADR-001),
 *    capturing stdout+stderr to a temp file. Stop at first non-zero RC.
 * 6. Build (seq, topic, subtitle, status) records for every station
 *    -- subtitle from each koan's "Station:" directive via stations.rexx.
 * 7. Render the station list.
 * 8. On failure: emit captured koan stdout indented to align, then
 *    blank line, then the summary line; exit with the koan's RC.
 *    On full pass: emit the summary line, blank line, closing benediction;
 *    exit 0.
 *
 * Note: Regina's external CALL does not share variable scope with the
 * caller, so the manifest cannot be loaded by `CALL` despite what
 * research.md Decision 5 anticipated. The runner instead reads the
 * manifest file and INTERPRETs its contents in its own scope; the
 * contract intent (manifest is data; appending a koan touches one
 * file) is preserved.
 */

CALL load_manifest 'koans/path_to_enlightenment.rexx'

IF SYMBOL('koans.0') \= 'VAR' | DATATYPE(koans.0, 'W') = 0 | koans.0 < 1 THEN DO
  SAY 'The path is empty. No stations are defined.'
  EXIT 1
END

DO i = 1 TO koans.0
  IF \file_exists(koans.i) THEN DO
    base = basename(koans.i)
    PARSE VAR base seq '_' name
    PARSE VAR name topic '.rexx'
    SAY 'Station' seq topic 'is missing from the path.'
    EXIT 1
  END
END

SAY 'THE PATH OF REXX'
SAY ''

failed_idx = 0
failed_rc = 0
failed_output = ''

tmp = '/tmp/pilgrimage.'RANDOM(1, 99999)'.'TIME('S')'.out'
DO i = 1 TO koans.0
  ADDRESS SYSTEM 'regina' koans.i '>' tmp '2>&1'
  rc_koan = RC

  output = ''
  DO WHILE LINES(tmp) > 0
    output = output || LINEIN(tmp) || '0a'x
  END
  CALL STREAM tmp, 'C', 'CLOSE'

  IF rc_koan \= 0 THEN DO
    failed_idx = i
    failed_rc = rc_koan
    failed_output = output
    LEAVE
  END
END
ADDRESS SYSTEM 'rm -f' tmp

/* Build records. */
records_blob = ''
max_w = 0
DO i = 1 TO koans.0
  base = basename(koans.i)
  PARSE VAR base seq '_' name
  PARSE VAR name topic '.rexx'

  CALL 'lib/stations.rexx' 'subtitle', koans.i
  subtitle = RESULT

  SELECT
    WHEN failed_idx = 0 THEN status = 'ok'
    WHEN i < failed_idx THEN status = 'ok'
    WHEN i = failed_idx THEN status = 'here'
    OTHERWISE                   status = 'blank'
  END

  IF LENGTH(topic) > max_w THEN max_w = LENGTH(topic)
  records_blob = records_blob || seq || '09'x || topic || '09'x || subtitle || '09'x || status || '0a'x
END

CALL 'lib/stations.rexx' 'list', records_blob, max_w

IF failed_idx > 0 THEN DO
  /* Indent each line of captured koan output with two spaces. */
  DO WHILE failed_output \= ''
    PARSE VAR failed_output line '0a'x failed_output
    IF line \= '' THEN SAY '  'line
  END
  SAY ''
  /* Resolve failed topic for the summary line. */
  f_base = basename(koans.failed_idx)
  PARSE VAR f_base f_seq '_' f_name
  PARSE VAR f_name failed_topic '.rexx'
  walked = failed_idx - 1
  CALL 'lib/stations.rexx' 'summary', walked, koans.0, failed_topic
  EXIT failed_rc
END

CALL 'lib/stations.rexx' 'summary', koans.0, koans.0, ''
SAY ''
SAY '  The pilgrim has walked the foundation. The path opens further.'
EXIT 0

load_manifest:
  PARSE ARG manifest_path
  src = ''
  DO WHILE LINES(manifest_path) > 0
    src = src || LINEIN(manifest_path) || ';'
  END
  CALL STREAM manifest_path, 'C', 'CLOSE'
  INTERPRET src
  RETURN

file_exists: PROCEDURE
  PARSE ARG path
  IF STREAM(path, 'C', 'QUERY EXISTS') = '' THEN RETURN 0
  RETURN 1

basename: PROCEDURE
  PARSE ARG path
  p = LASTPOS('/', path)
  IF p = 0 THEN RETURN path
  RETURN SUBSTR(path, p + 1)
