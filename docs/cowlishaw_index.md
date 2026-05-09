# Cowlishaw Ground-Truth Index

Structural index of M.F. Cowlishaw, *The REXX Language: A
Practical Approach to Programming*, 2nd edition (1990).
Authoritative reference for every Cowlishaw citation in this
project.

- **Source PDF**: `reference/REXX Language - 2nd Edition.pdf`
  (gitignored; obtained from the Internet Archive scan linked
  in `README.md`).
- **Page numbers**: book pages (the printed edition's pagination
  preserved in the scan), never PDF-viewer pages. PDF↔book
  offset: book p. N = PDF p. N+11.
- **Citation format**: canonical form `Cowlishaw §X.Y, p. NN`,
  where §X.Y identifies (Part X, SECTION Y); for child-heading
  rows the canonical form MAY be followed by an optional
  disambiguator suffix ` — <child heading>` when needed (e.g.,
  when two child rows share both a §X.Y and a book page).
- **Layout**: `#` Part / Appendix navigation wrappers (not
  rows); `##` per §X.Y SECTION and per Appendix top; `###` per
  named typographically distinct child heading. Each row is
  followed by exactly three bullets — `**Page:**`,
  `**Summary:**`, `**Vocabulary:**` — in that order.

# Part 1 — Background

## §1.1 — What Kind of a Language is REXX?

- **Page:** 1
- **Summary:** Positions REXX as a procedural language designed for clarity, structure, and ease of use by both professional and casual users, with strong symbolic-manipulation facilities and an explicit ability to issue commands to host environments; surveys the application areas it covers (personal programming, tailoring user commands, macros, prototype development).
- **Vocabulary:** procedural language, host environment, command, macro language

## §1.2 — Summary of the REXX Language

- **Page:** 3
- **Summary:** Walks through the language at a high level using small example programs (TOAST, GREET, JUSTONE, SHOWME) to introduce control constructs, expressions and operators, variables and compound symbols, parsing, calling mechanisms, exception handling, INTERPRET, character streams, built-in functions, and tracing.
- **Vocabulary:** clause, instruction, expression, control construct, compound variable, stem, parsing template, exception, condition trap, character stream, external data queue

## §1.3 — Fundamental Language Concepts

- **Page:** 7
- **Summary:** Lists and discusses the major guiding concepts that consciously shaped REXX's design — readability, natural data typing, manageable implementation limits, and similar principles — as a precursor to the formal language definition.
- **Vocabulary:** readability

## §1.4 — Design Principles

- **Page:** 13
- **Summary:** Describes the development practices behind REXX: heavy use of an internal communications network for user feedback, documenting language features before implementation, and a stance that the language user is usually right.
- **Vocabulary:** Communications, Documentation before implementation, The language user is usually right

## §1.5 — History

- **Page:** 15
- **Summary:** Traces REXX from its 1979–1982 origins as a personal project at IBM Hursley and Yorktown through the CMS System Product Interpreter, the 1985 first edition, the first non-IBM ports, the 1987 selection as the SAA Procedures Language, and the 1989 CMS REXX Compiler.
- **Vocabulary:** System Product Interpreter, Procedures Language for SAA, CMS REXX Compiler

# Part 2 — REXX Language Definition

## §2.1 — Characters and Encodings

- **Page:** 17
- **Summary:** Distinguishes the abstract character from its coded representation (encoding), notes that REXX is concerned with characters rather than their glyphs, and frames the language's relation to specific character sets such as ASCII and EBCDIC.
- **Vocabulary:** character, encoding, character set, ASCII, EBCDIC, glyph

### Character Sets

- **Page:** 18
- **Summary:** Identifies the two character sets that matter to REXX: the small fixed set used to write the program itself, and the (potentially larger) data character set determined by the implementation; explains why the language defines the first explicitly while leaving the second largely unrestricted.
- **Vocabulary:** character set, data character set

## §2.2 — Structure and General Syntax

- **Page:** 18
- **Summary:** Defines a REXX program as a series of clauses composed of optional blanks, a sequence of tokens, optional blanks, and a clause delimiter (semicolon, often implied); describes how clauses are scanned left-to-right with keyword recognition, comment removal, and blank reduction.
- **Vocabulary:** clause, token, blank, semicolon, line-end, keyword

### Comments

- **Page:** 18
- **Summary:** Comments are delimited by `/*` and `*/`, may appear anywhere, may be of any length, may nest (with paired delimiters), and act only as token separators.
- **Vocabulary:** comment, nested comment, `/*`, `*/`

### Tokens

- **Page:** 19
- **Summary:** Introduces the essential components of clauses; tokens may be of any length (subject to implementation limits) and are separated by blanks or by the nature of the tokens themselves.
- **Vocabulary:** token

### Literal strings

- **Page:** 19
- **Summary:** A sequence of characters delimited by single or double quotes; a doubled delimiter quote inside the string represents one such quote; literal strings are constants whose contents REXX never modifies, must be complete on a single line, and a zero-length string is the null string.
- **Vocabulary:** literal string, single quote, double-quote, null string

### Hexadecimal Strings

- **Page:** 20
- **Summary:** Zero or more hexadecimal digits paired into bytes, delimited by quotes and immediately followed by `X`; optional blanks at byte boundaries aid readability; the digits are packed into a literal string of bytes.
- **Vocabulary:** hexadecimal string, hexadecimal digit, byte boundary

### Binary Strings

- **Page:** 20
- **Summary:** Zero or more binary digits grouped in fours, delimited by quotes and immediately followed by `B`; optional blanks between groups aid readability; the bits are packed into a literal string.
- **Vocabulary:** binary string, binary digit

### Symbols

- **Page:** 21
- **Summary:** Groups of alphabetic, numeric, period, exclamation, question-mark, and underscore characters, with lower case translated to upper case before use; meaning depends on context (constant, keyword, or variable name); a symbol starting with a digit or period may include an `E`-form exponent.
- **Vocabulary:** symbol, constant symbol, simple symbol, compound symbol, stem, exponential notation

### Operator characters

- **Page:** 22
- **Summary:** Lists the characters `+ - * / % | & = ¬ \ > <` used (sometimes in combination) to denote operations in expressions, parsing templates, and the assignment equal-sign; explains that blanks adjacent to operator characters are removed and that `¬` and `\` are interchangeable.
- **Vocabulary:** operator character, not symbol, backslash

### Special characters

- **Page:** 22
- **Summary:** Names the additional special characters `, ; : ) (` which together with the operator characters act as token delimiters and trigger blank-stripping rules; closes with a worked example showing how a clause is composed of tokens.
- **Vocabulary:** special character, token delimiter

### Implied semicolons and continuations

- **Page:** 23
- **Summary:** REXX implies a semicolon at the end of every line except when the line ends inside a comment or after a trailing comma (which becomes a continuation, replaced by a blank); semicolons are also implied after a label colon and after the keywords ELSE, OTHERWISE, and THEN.
- **Vocabulary:** implied semicolon, continuation character, label, ELSE, OTHERWISE, THEN

## §2.3 — Expressions and Operators

- **Page:** 24
- **Summary:** General mechanism that combines one or more terms (literal strings, symbols, function calls, or sub-expressions) using prefix and dyadic operators to produce a typeless character-string result; outlines evaluation order (left to right, modified by parentheses and operator precedence) and groups operators into concatenation, arithmetic, comparative, and logical.
- **Vocabulary:** expression, term, dyadic operator, prefix operator, sub-expression, function call, typeless character string

### Concatenation

- **Page:** 25
- **Summary:** Combines two strings end-to-end; the blank operator inserts one intervening blank, `||` joins without a blank, and abuttal (two adjacent terms with no operator) joins without a blank.
- **Vocabulary:** concatenation, blank operator, abuttal operator

### Arithmetic

- **Page:** 25
- **Summary:** Operates on numeric strings using `+`, `-`, `*`, `/`, `%` (integer divide), `//` (remainder), `**` (power), and prefix `+`/`-`; full numeric rules and precision live in §2.11.
- **Vocabulary:** arithmetic operator, add, subtract, multiply, divide, integer divide, remainder, power, prefix plus, prefix minus

### Comparative

- **Page:** 26
- **Summary:** Returns `'1'` for true or `'0'` for false using two families: strict comparisons (with one of the operator characters doubled) that compare strings character-by-character without padding, and normal comparisons that perform a numeric comparison when both terms are numeric and otherwise pad-and-compare as strings.
- **Vocabulary:** Comparative, comparative operator, strict comparison, normal comparison

### Logical (Boolean)

- **Page:** 27
- **Summary:** Operators `&` (And), `|` (Inclusive or), `&&` (Exclusive or), and prefix `¬`/`\` (Logical not) take operands restricted to `'0'` or `'1'` and return `'0'` or `'1'` accordingly.
- **Vocabulary:** Logical (Boolean), And, Inclusive or, Exclusive or, Logical not

### Numbers

- **Page:** 27
- **Summary:** A number is a character string of one or more decimal digits, optionally signed, optionally containing a single period as decimal point, and optionally suffixed by an `E`-form power-of-ten exponent; leading and trailing blanks are allowed but blanks may not be embedded among digits.
- **Vocabulary:** number, decimal digit, sign, decimal point, exponential notation, whole number

### Parentheses and operator precedence

- **Page:** 28
- **Summary:** Evaluation is left to right, modified by parentheses (which evaluate the bracketed sub-expression immediately) and by operator precedence; lists the canonical precedence ladder from prefix operators through power, multiplicative, additive, concatenation, comparative, And, and Or/exclusive-or.
- **Vocabulary:** operator precedence, parentheses

## §2.4 — Clauses and Instructions

- **Page:** 31
- **Summary:** Classifies clauses as null clauses (ignored), labels (a single symbol followed by `:` that names a CALL/SIGNAL/function target), and instructions; subdivides instructions into assignments (`symbol = expression`), keyword instructions (first token a keyword), and commands (an expression sent to the active environment).
- **Vocabulary:** clause, null clause, label, instruction, assignment, keyword instruction, command

## §2.5 — Assignments and Variables

- **Page:** 32
- **Summary:** Defines a variable as a named object whose value is a single character string of any length; describes assignment via `symbol = expression`, the four kinds of symbols used as terms (constant, simple, compound, stems), and the rule that a clause beginning with a symbol whose second token starts with `=` is an assignment rather than an expression.
- **Vocabulary:** variable, assignment, symbol, constant symbol, simple symbol, compound symbol, stem, uninitialized variable

### Constant symbols

- **Page:** 33
- **Summary:** Symbols whose first character is a digit (0-9) or a period; their value is the upper-cased text of the symbol itself, and they cannot be assigned a new value.
- **Vocabulary:** constant symbol

### Simple symbols

- **Page:** 33
- **Summary:** Symbols that contain no periods and do not start with a digit; their default value is the upper-cased characters of the symbol, and once assigned the symbol names a variable whose value is the assigned string.
- **Vocabulary:** simple symbol, variable

### Compound symbols

- **Page:** 33
- **Summary:** Symbols containing at least one period and at least two other characters, not starting with a digit or period; the part up to and including the first period is the stem, the parts after are the tail, and at reference time simple symbols in the tail are substituted to form a derived name supporting arbitrary indexing.
- **Vocabulary:** compound symbol, stem, tail, derived name, substitution

### Stems

- **Page:** 35
- **Summary:** Symbols whose only period is the last character; assigning to a stem gives every possible compound variable sharing that stem the same value, and DROP and PROCEDURE EXPOSE accept stems to act on whole collections.
- **Vocabulary:** stem, compound variable, collection of variables

## §2.6 — Commands to External Environments

- **Page:** 37
- **Summary:** A command is a clause consisting solely of an expression; the expression is evaluated to a character string and submitted to the currently addressed environment, which returns a return code placed in the special variable RC and may also raise the ERROR or FAILURE conditions interpreted by SIGNAL/CALL ON and by TRACE Error/Failure.
- **Vocabulary:** command, environment, ADDRESS, return code, RC, ERROR, FAILURE

## §2.7 — Keyword Instructions

- **Page:** 39
- **Summary:** A keyword instruction is one or more clauses whose first clause begins with a keyword that identifies it; some control flow, others provide services, and a few (such as DO) wrap nested instructions; introduces the syntax-diagram conventions used throughout the book and notes that keywords and sub-keywords are recognised only in their instruction-specific contexts.
- **Vocabulary:** keyword instruction, sub-keyword

### ADDRESS

- **Page:** 40
- **Summary:** Routes commands to a named external environment — either temporarily by giving an environment name plus a single-command expression, or permanently by giving the name alone — and toggles between two saved environments when invoked with no arguments; a VALUE form computes the new environment name from an expression at runtime.
- **Vocabulary:** ADDRESS, environment, VALUE, RC

### ARG

- **Page:** 42
- **Summary:** Retrieves the argument string(s) passed to a program or internal routine, translates them to upper case, and parses them into variables according to the parsing rules; equivalent to `PARSE UPPER ARG [template]`.
- **Vocabulary:** ARG, template, PARSE UPPER ARG, argument string

### CALL

- **Page:** 43
- **Summary:** Invokes an internal routine, built-in function, or external routine, passing argument expressions and receiving an optional result via the special variable RESULT; with ON or OFF, controls the trapping of conditions instead, and saves NUMERIC, ADDRESS, OPTIONS, trace, and condition state across the call.
- **Vocabulary:** CALL, ON, OFF, NAME, condition, trapname, RESULT, recursive call

### DO

- **Page:** 47
- **Summary:** Groups instructions between DO and END and optionally executes them repetitively, with a repetitor that may be a controlled `name = expri TO exprt BY exprb FOR exprf`, a numeric repeat count, or FOREVER, optionally further bounded by a WHILE or UNTIL conditional; the END may name the control variable to verify nesting.
- **Vocabulary:** DO, repetitor, conditional, control variable, TO, BY, FOR, FOREVER, WHILE, UNTIL, END

### DROP

- **Page:** 53
- **Summary:** Un-assigns the named variables, restoring them to their original uninitialised state; a name in parentheses is a variable reference whose value supplies a subsidiary variable list, and dropping a stem drops every compound variable that shares it.
- **Vocabulary:** DROP, variablelist, variable reference, stem

### EXIT

- **Page:** 54
- **Summary:** Unconditionally terminates the program (even from within an internal routine), optionally returning the value of an evaluated expression to the caller; running off the end of the program is equivalent to a bare `EXIT;`.
- **Vocabulary:** EXIT

### IF

- **Page:** 54
- **Summary:** Conditionally executes one instruction (which may be a complex construct or another IF) when the controlling expression evaluates to `'1'`, with an optional ELSE alternative for the `'0'` case; ELSE binds to the nearest IF at the same level.
- **Vocabulary:** IF, THEN, ELSE

### INTERPRET

- **Page:** 55
- **Summary:** Evaluates an expression and then executes the resulting string of REXX as though it were a line inserted into the program (bracketed by DO; ... END;); supports nested INTERPRETs but requires complete DO/SELECT constructs and forbids label clauses in the interpreted text.
- **Vocabulary:** INTERPRET

### ITERATE

- **Page:** 57
- **Summary:** Inside a repetitive DO loop, stops execution of the current iteration and returns control to the DO clause as if END had been reached so the control variable is stepped and the loop re-tested; an optional name selects a specific outer loop and terminates any active loops nested inside it.
- **Vocabulary:** ITERATE, control variable, active loop

### LEAVE

- **Page:** 58
- **Summary:** Causes immediate exit from one or more repetitive DO loops, transferring control to the clause following the matching END; the control variable retains the value it held when LEAVE executed, and an optional name selects a specific outer loop.
- **Vocabulary:** LEAVE, control variable, active loop

### NOP

- **Page:** 59
- **Summary:** A dummy instruction that has no effect; useful as the target of a THEN or ELSE clause (or a WHEN clause) where REXX requires an instruction rather than a null clause.
- **Vocabulary:** NOP, dummy instruction

### NUMERIC

- **Page:** 59
- **Summary:** Changes how arithmetic operations are carried out: NUMERIC DIGITS sets precision (default 9), NUMERIC FORM chooses SCIENTIFIC or ENGINEERING exponential notation (default scientific), and NUMERIC FUZZ specifies how many digits to ignore during numeric comparisons (default 0).
- **Vocabulary:** NUMERIC, DIGITS, FORM, SCIENTIFIC, ENGINEERING, FUZZ, VALUE

### OPTIONS

- **Page:** 61
- **Summary:** Passes special requests to the language processor (interpreter or compiler); words in the evaluated expression that the processor recognises are obeyed and unrecognised words are silently ignored.
- **Vocabulary:** OPTIONS

### PARSE

- **Page:** 62
- **Summary:** Assigns data from a chosen source (ARG, LINEIN, PULL, SOURCE, VALUE … WITH, VAR name, or VERSION) to variables according to the parsing rules; the optional UPPER sub-keyword translates the source string to upper case before parsing.
- **Vocabulary:** PARSE, UPPER, ARG, LINEIN, PULL, SOURCE, VALUE, WITH, VAR, VERSION, template

### PROCEDURE

- **Page:** 65
- **Summary:** Inside an internal routine, hides all the caller's variables and gives the routine a fresh local-variable environment that is dropped on RETURN; the optional EXPOSE list (which accepts variable references in parentheses and stems) makes selected caller variables visible and modifiable.
- **Vocabulary:** PROCEDURE, EXPOSE, variablelist, variable reference, stem

### PULL

- **Page:** 67
- **Summary:** Reads the head of the external data queue (or a line from the default input stream if the queue is empty), translates it to upper case, and parses it into variables; equivalent to `PARSE UPPER PULL [template]`.
- **Vocabulary:** PULL, template, external data queue, PARSE UPPER PULL

### PUSH

- **Page:** 68
- **Summary:** Evaluates the expression and stacks the resulting string LIFO (Last In, First Out) onto the external data queue; a missing expression stacks the null string.
- **Vocabulary:** PUSH, external data queue, LIFO

### QUEUE

- **Page:** 69
- **Summary:** Evaluates the expression and adds the resulting string FIFO (First In, First Out) to the external data queue; a missing expression queues the null string.
- **Vocabulary:** QUEUE, external data queue, FIFO

### RETURN

- **Page:** 69
- **Summary:** Returns control from a REXX program or internal routine to the point of its invocation; the optional expression supplies the routine's result (mandatory for functions, stored in the special variable RESULT for subroutines), and the saved settings of the caller are restored.
- **Vocabulary:** RETURN, RESULT

### SAY

- **Page:** 70
- **Summary:** Writes the value of the expression as a line to the default character output stream (typically the user's display); equivalent to `CALL LINEOUT , [expression]` except that SAY does not affect the special variable RESULT.
- **Vocabulary:** SAY, default character output stream, LINEOUT

### SELECT

- **Page:** 71
- **Summary:** Conditionally executes one of several alternative instructions: each WHEN expression is evaluated in turn (must yield `'0'` or `'1'`) and the first that yields `'1'` selects its THEN instruction; an OTHERWISE clause supplies the fallback path and an END terminates the construct.
- **Vocabulary:** SELECT, WHEN, THEN, OTHERWISE, END

### SIGNAL

- **Page:** 72
- **Summary:** Causes an abnormal change in the flow of control by terminating all active DO loops, IF, SELECT, and INTERPRET constructs in the current routine and branching to the named label (constant or VALUE-evaluated); with ON or OFF, controls the trapping of conditions instead.
- **Vocabulary:** SIGNAL, labelname, VALUE, ON, OFF, NAME, condition, trapname, SIGL

### TRACE

- **Page:** 73
- **Summary:** Controls the tracing of program execution for debugging, accepting an alphabetic setting (A, C, E, F, I, L, N, O, R), an optional `?` prefix that toggles interactive tracing, or a whole number that skips or suppresses traced clauses; a missing setting resets tracing to the default.
- **Vocabulary:** TRACE, tracesetting, All, Commands, Error, Failure, Intermediates, Labels, Normal, Off, Results, interactive tracing

## §2.8 — Function Calls

- **Page:** 77
- **Summary:** Defines a function call as `functionname(...)` (the opening parenthesis must abut the name with no intervening blank), describes how argument expressions are evaluated left-to-right and the routine returns a single character string used in place of the call, and identifies the routine sources REXX considers: internal labels, built-in functions, and external routines.
- **Vocabulary:** function call, function, internal routine, built-in function, external routine

### The search order for functions

- **Page:** 79
- **Summary:** REXX searches internal labels first, then built-in functions, then external routines, except that quoting the function name as a literal string skips the internal-label step so the built-in or external implementation may be invoked even when a same-name internal label exists.
- **Vocabulary:** Internal, Built-in, External

## §2.9 — Built-in Functions

- **Page:** 81
- **Summary:** Introduces the rich set of always-available functions for character manipulation, conversion, and information; lists the general conventions (parenthesis abutment, argument validation, NUMERIC handling internal to most functions, sub-option selection by first letter, and EBCDIC examples used in this section).
- **Vocabulary:** built-in function, pad, sub-option

### ABBREV

- **Page:** 82
- **Summary:** Returns 1 if `info` matches the leading characters of `information` and is not shorter than the optional minimum length, otherwise 0; the default minimum is the length of `info`.
- **Vocabulary:** ABBREV, information, info

### ABS

- **Page:** 82
- **Summary:** Returns the absolute value of `number`, formatted according to the current NUMERIC settings.
- **Vocabulary:** ABS, absolute value

### ADDRESS

- **Page:** 82
- **Summary:** Returns the name of the environment to which commands are currently being submitted.
- **Vocabulary:** ADDRESS, environment

### ARG

- **Page:** 83
- **Summary:** Returns the count of argument strings, or the nth argument string, or — with an `option` of E (Exists) or O (Omitted) — whether the nth argument string exists or was omitted.
- **Vocabulary:** ARG, Exists, Omitted, argument string

### BITAND

- **Page:** 84
- **Summary:** Returns the bitwise logical AND of the encodings of two input strings; the result has the length of the longer string and the shorter is padded (with `pad` or by appending the unprocessed tail) as needed.
- **Vocabulary:** BITAND, AND, pad

### BITOR

- **Page:** 84
- **Summary:** Returns the bitwise logical inclusive OR of the encodings of two input strings; the result has the length of the longer string and the shorter is padded (with `pad` or by appending the unprocessed tail) as needed.
- **Vocabulary:** BITOR, OR, pad

### BITXOR

- **Page:** 85
- **Summary:** Returns the bitwise logical exclusive OR of the encodings of two input strings; the result has the length of the longer string and the shorter is padded (with `pad` or by appending the unprocessed tail) as needed.
- **Vocabulary:** BITXOR, eXclusive OR, pad

### B2X

- **Page:** 85
- **Summary:** Binary to Hexadecimal: converts a string of binary digits to an equivalent string of hexadecimal characters, padding the leading group on the left with `'0'` digits if its length is not a multiple of four.
- **Vocabulary:** B2X, Binary to Hexadecimal

### CENTER

- **Page:** 86
- **Summary:** Returns `string` centred in a result of length `length`, padded with `pad` (default blank) on both sides as needed or truncated at both ends if longer; American spelling, identical in effect to CENTRE.
- **Vocabulary:** CENTER, length, pad

### CENTRE

- **Page:** 86
- **Summary:** Returns `string` centred in a result of length `length`, padded with `pad` (default blank) on both sides as needed or truncated at both ends if longer; British spelling, identical in effect to CENTER.
- **Vocabulary:** CENTRE, length, pad

### CHARIN

- **Page:** 86
- **Summary:** Returns up to `length` characters read from the named character input stream (or the default input stream), advancing the read position; supports an explicit `start` for persistent streams and raises NOTREADY if the read cannot complete.
- **Vocabulary:** CHARIN, character input stream, NOTREADY, persistent stream, transient stream

### CHAROUT

- **Page:** 87
- **Summary:** Writes `string` to the named character output stream (or the default output stream) and returns the residual count of characters that could not be written; supports an explicit `start` for persistent streams.
- **Vocabulary:** CHAROUT, character output stream, NOTREADY, residual count

### CHARS

- **Page:** 88
- **Summary:** Returns the total count of characters remaining in the named character input stream (or the default input stream), measured from the current read position for persistent streams.
- **Vocabulary:** CHARS, character input stream

### COMPARE

- **Page:** 88
- **Summary:** Returns 0 if two strings are equal (after pad-extending the shorter to match), otherwise the position of the first character that differs.
- **Vocabulary:** COMPARE, pad

### CONDITION

- **Page:** 89
- **Summary:** Returns information about the current trapped condition: option C returns the condition name, D the descriptive string, I the trapping instruction (CALL or SIGNAL, the default), and S the trap state (ON, OFF, or DELAY).
- **Vocabulary:** CONDITION, Condition name, Description, Instruction, State, ON, OFF, DELAY

### COPIES

- **Page:** 90
- **Summary:** Returns `n` directly concatenated copies of `string`; `n` must be 0 or positive.
- **Vocabulary:** COPIES

### C2D

- **Page:** 90
- **Summary:** Character to Decimal: returns the decimal value of the binary representation (encoding) of `string`; with `n`, treats the string as a signed number expressed in `n` characters using two's-complement.
- **Vocabulary:** C2D, Character to Decimal, two's complement

### C2X

- **Page:** 91
- **Summary:** Character to Hexadecimal: returns the hexadecimal representation of the encoding of `string` (unpacks), using upper-case A–F and no embedded blanks.
- **Vocabulary:** C2X, Character to Hexadecimal

### DATATYPE

- **Page:** 91
- **Summary:** With one argument, returns 'NUM' if `string` is a valid REXX number and 'CHAR' otherwise; with two arguments, returns 1 or 0 according to whether `string` matches the named type — Alphanumeric, Binary, Lower, Mixed, Number, Symbol, Upper, Whole number, or heXadecimal.
- **Vocabulary:** DATATYPE, NUM, CHAR, Alphanumeric, Binary, Lower, Mixed, Number, Symbol, Upper, Whole, heXadecimal

### DATE

- **Page:** 92
- **Summary:** Returns the local date in a chosen format selected by the first letter of `option`: default `dd Mmm yyyy`, B (Base, days since 1 Jan 0001), D (Days into year), E (European), M (full Month name), N (Normal), O (Ordered `yy/mm/dd`), S (Standard `yyyymmdd`), U (USA `mm/dd/yy`), or W (Week day name).
- **Vocabulary:** DATE, Base, Days, European, Month, Normal, Ordered, Standard, USA, Week day

### DELSTR

- **Page:** 93
- **Summary:** Deletes the substring of `string` that begins at character `n` and is of length `length` (or to the end of the string if `length` is omitted).
- **Vocabulary:** DELSTR

### DELWORD

- **Page:** 94
- **Summary:** Deletes the substring of `string` that starts at the nth blank-delimited word and spans `length` words (or all remaining words if `length` is omitted), including any trailing blanks of the deleted span.
- **Vocabulary:** DELWORD

### DIGITS

- **Page:** 94
- **Summary:** Returns the current setting of NUMERIC DIGITS (default 9).
- **Vocabulary:** DIGITS

### D2C

- **Page:** 94
- **Summary:** Decimal to Character: returns the character string whose encoding is the binary representation of `whole-number` (which must be non-negative unless `n` is supplied); with `n`, the result is sign-extended or truncated to `n` characters.
- **Vocabulary:** D2C, Decimal to Character

### D2X

- **Page:** 95
- **Summary:** Decimal to Hexadecimal: returns a string of hexadecimal characters representing `whole-number` (which must be non-negative unless `n` is supplied); with `n`, the result is sign-extended or truncated to `n` characters.
- **Vocabulary:** D2X, Decimal to Hexadecimal

### ERRORTEXT

- **Page:** 95
- **Summary:** Returns the REXX error message text associated with error number `n` (which must be in 0–99); a null string is returned for an in-range but unused number.
- **Vocabulary:** ERRORTEXT

### FORM

- **Page:** 96
- **Summary:** Returns the current setting of NUMERIC FORM, either 'SCIENTIFIC' or 'ENGINEERING' (default scientific).
- **Vocabulary:** FORM, SCIENTIFIC, ENGINEERING

### FORMAT

- **Page:** 96
- **Summary:** Rounds and formats `number`, optionally fixing the integer-part width via `before`, the decimal-part width via `after`, and (with two further arguments) the exponent width via `expp` and the exponential-notation trigger via `expt`.
- **Vocabulary:** FORMAT, before, after, expp, expt

### FUZZ

- **Page:** 97
- **Summary:** Returns the current setting of NUMERIC FUZZ (default 0).
- **Vocabulary:** FUZZ

### INSERT

- **Page:** 97
- **Summary:** Inserts `new` (padded or truncated to `length`) into `target` after the nth character; defaults: `n` is 0 (insert at the start), `length` is the length of `new`, `pad` is blank.
- **Vocabulary:** INSERT

### LASTPOS

- **Page:** 98
- **Summary:** Returns the position of the last occurrence of `needle` in `haystack`, scanning backwards from `start` (or from the end of `haystack` by default); 0 if `needle` is not found or is null.
- **Vocabulary:** LASTPOS, needle, haystack

### LEFT

- **Page:** 98
- **Summary:** Returns a string of length `length` containing the leftmost `length` characters of `string`, padded on the right with `pad` (default blank) or truncated as needed; equivalent to SUBSTR(string,1,length[,pad]).
- **Vocabulary:** LEFT

### LENGTH

- **Page:** 98
- **Summary:** Returns the length of `string`.
- **Vocabulary:** LENGTH

### LINEIN

- **Page:** 99
- **Summary:** Returns `count` (0 or 1) lines read from the named character input stream (or the default), advancing the read position; supports an explicit `line` for persistent streams and raises NOTREADY if a complete line cannot be read.
- **Vocabulary:** LINEIN, character input stream, NOTREADY

### LINEOUT

- **Page:** 100
- **Summary:** Writes `string` as a line to the named character output stream (or the default) and returns the residual line count (0 success, 1 failure); supports an explicit `line` for persistent streams.
- **Vocabulary:** LINEOUT, character output stream, NOTREADY, residual count

### LINES

- **Page:** 101
- **Summary:** Returns the number of complete lines remaining in the named character input stream (or the default), counted from the current read position for persistent streams.
- **Vocabulary:** LINES, character input stream

### MAX

- **Page:** 102
- **Summary:** Returns the largest of the supplied numbers, formatted according to the current NUMERIC settings.
- **Vocabulary:** MAX

### MIN

- **Page:** 102
- **Summary:** Returns the smallest of the supplied numbers, formatted according to the current NUMERIC settings.
- **Vocabulary:** MIN

### OVERLAY

- **Page:** 102
- **Summary:** Overlays `new` (padded or truncated to `length`) onto `target` starting at the nth character, padding `target` on the right if `n` is past its end; defaults: `n` is 1, `length` is the length of `new`, `pad` is blank.
- **Vocabulary:** OVERLAY

### POS

- **Page:** 102
- **Summary:** Returns the position of `needle` in `haystack`, scanning forward from `start` (default 1); 0 if `needle` is not found or is null.
- **Vocabulary:** POS, needle, haystack

### QUEUED

- **Page:** 103
- **Summary:** Returns the number of lines currently in the external data queue.
- **Vocabulary:** QUEUED, external data queue

### RANDOM

- **Page:** 103
- **Summary:** Returns a quasi-random non-negative whole number in the inclusive range `min` to `max` (defaults 0 and 999, range capped at 100000); a `seed` argument starts a repeatable sequence.
- **Vocabulary:** RANDOM, seed

### REVERSE

- **Page:** 104
- **Summary:** Returns `string` swapped end for end.
- **Vocabulary:** REVERSE

### RIGHT

- **Page:** 104
- **Summary:** Returns a string of length `length` containing the rightmost `length` characters of `string`, padded on the left with `pad` (default blank) or truncated as needed.
- **Vocabulary:** RIGHT

### SIGN

- **Page:** 104
- **Summary:** Returns -1 if `number` is less than 0, 0 if it is 0, or 1 if it is greater than 0.
- **Vocabulary:** SIGN

### SOURCELINE

- **Page:** 105
- **Summary:** With no argument, returns the line number of the final line of the program (0 if no source is available); with `n`, returns the nth source line (or the null string if not available at runtime).
- **Vocabulary:** SOURCELINE

### SPACE

- **Page:** 105
- **Summary:** Reformats the blank-delimited words of `string` so that exactly `n` `pad` characters appear between successive words; leading and trailing blanks are always removed (defaults: `n` is 1, `pad` is blank).
- **Vocabulary:** SPACE, pad

### STREAM

- **Page:** 105
- **Summary:** Returns a string describing the state of, or the result of an operation upon, the named character stream; supports operation strings C (Command, takes a `streamcommand`), D (Description), and S (State, returning ERROR / NOTREADY / READY / UNKNOWN).
- **Vocabulary:** STREAM, Command, Description, State, ERROR, NOTREADY, READY, UNKNOWN

### STRIP

- **Page:** 107
- **Summary:** Removes leading, trailing, or both leading and trailing copies of `char` (default blank) from `string`, selected by option L, T, or B (default B).
- **Vocabulary:** STRIP, Leading, Trailing, Both

### SUBSTR

- **Page:** 107
- **Summary:** Returns the substring of `string` starting at character `n` and of length `length` (default to the end), padded with `pad` (default blank) if needed.
- **Vocabulary:** SUBSTR

### SUBWORD

- **Page:** 107
- **Summary:** Returns the substring of `string` that starts at the nth blank-delimited word and is up to `length` words long (default to the end); the result has no leading or trailing blanks but preserves blanks between selected words.
- **Vocabulary:** SUBWORD

### SYMBOL

- **Page:** 108
- **Summary:** Returns 'BAD' if `name` is not a valid REXX symbol, 'VAR' if it names an assigned variable, or 'LIT' otherwise (constant symbol or symbol that has not yet been assigned a value).
- **Vocabulary:** SYMBOL, BAD, VAR, LIT

### TIME

- **Page:** 108
- **Summary:** Returns the local time in a chosen format selected by the first letter of `option`: default `hh:mm:ss`, C (Civil), E (Elapsed), H (Hours since midnight), L (Long, with microseconds), M (Minutes since midnight), N (Normal), R (Reset elapsed clock), or S (Seconds since midnight).
- **Vocabulary:** TIME, Civil, Elapsed, Hours, Long, Minutes, Normal, Reset, Seconds, elapsed time clock

### TRACE

- **Page:** 110
- **Summary:** Returns the current trace setting and optionally alters it; the setting must be a valid `?` prefix and/or one of the alphabetic settings (A, C, E, F, I, L, N, O, R) accepted by the TRACE instruction, but unlike the instruction it accepts no numeric value.
- **Vocabulary:** TRACE, tracesetting

### TRANSLATE

- **Page:** 111
- **Summary:** Returns `string` with each character either unchanged or replaced according to a mapping defined by the input and output translate tables; with no tables supplied the string is translated to upper case.
- **Vocabulary:** TRANSLATE, tableo, tablei

### TRUNC

- **Page:** 111
- **Summary:** Returns the integer part of `number` followed by `n` decimal places (default 0), with trailing zeros if needed; the result is never in exponential form.
- **Vocabulary:** TRUNC

### VALUE

- **Page:** 112
- **Summary:** Returns the value of the variable named by `name` (which may be constructed dynamically) and optionally assigns it `newvalue`; with a `selector`, references an external variable pool rather than the REXX variables environment.
- **Vocabulary:** VALUE, selector, variable pool

### VERIFY

- **Page:** 113
- **Summary:** Returns the position of the first character of `string` not also in `reference` (or, with option Match, the position of the first character that is in `reference`); 0 if all characters meet the test, with optional `start` controlling the search position.
- **Vocabulary:** VERIFY, reference, Nomatch, Match

### WORD

- **Page:** 114
- **Summary:** Returns the nth blank-delimited word of `string`, or the null string if there are fewer than `n` words; equivalent to SUBWORD(string,n,1).
- **Vocabulary:** WORD

### WORDINDEX

- **Page:** 114
- **Summary:** Returns the character position within `string` at which the nth blank-delimited word begins, or 0 if there are fewer than `n` words.
- **Vocabulary:** WORDINDEX

### WORDLENGTH

- **Page:** 114
- **Summary:** Returns the length of the nth blank-delimited word of `string`, or 0 if there are fewer than `n` words.
- **Vocabulary:** WORDLENGTH

### WORDPOS

- **Page:** 114
- **Summary:** Searches `string` for the first occurrence of the blank-delimited word sequence `phrase` and returns the word number of the first matching word, or 0 if not found; multiple blanks compare equal, and an optional `start` overrides the starting word.
- **Vocabulary:** WORDPOS, phrase

### WORDS

- **Page:** 115
- **Summary:** Returns the number of blank-delimited words in `string`.
- **Vocabulary:** WORDS

### XRANGE

- **Page:** 115
- **Summary:** Returns a string of all valid character encodings in ascending order between and including `start` and `end` (defaults `'00'x` and `'FF'x`); when `start > end` the values wrap from `'FF'x` to `'00'x`.
- **Vocabulary:** XRANGE

### X2B

- **Page:** 115
- **Summary:** Hexadecimal to Binary: converts a string of hexadecimal characters to an equivalent string of binary digits; the result length is always a multiple of four.
- **Vocabulary:** X2B, Hexadecimal to Binary

### X2C

- **Page:** 116
- **Summary:** Hexadecimal to Character: converts a string of hexadecimal characters to character form (packs); odd-length input is left-padded with a leading `'0'`.
- **Vocabulary:** X2C, Hexadecimal to Character

### X2D

- **Page:** 116
- **Summary:** Hexadecimal to Decimal: converts a string of hexadecimal characters to its decimal value; with `n`, the string is treated as a signed number expressed in `n` hexadecimal characters using two's-complement.
- **Vocabulary:** X2D, Hexadecimal to Decimal

## §2.10 — Parsing for ARG, PARSE, and PULL

- **Page:** 118
- **Summary:** Three instructions (ARG, PARSE, and PULL) split a selected string and assign the parts to variables under the control of a template; templates may split by blank-delimited words, by literal-string patterns, or by absolute or relative positional patterns, and a comma in the template advances to the next argument string.
- **Vocabulary:** parsing template, pattern, positional pattern, literal pattern

### Introduction to parsing

- **Page:** 118
- **Summary:** Walks through worked examples that show how a template of variable names splits a string by words, how a literal-string pattern splits at the first matching occurrence, how positional numeric patterns split at column boundaries, how variable-reference patterns work, and how commas select successive argument strings.
- **Vocabulary:** template, blank-delimited word

### Parsing definition

- **Page:** 120
- **Summary:** Formalises a template as alternating pattern specifications and variable names: the value assigned to each variable is the input characters between the points matched by the patterns to its left and right, with implicit start/end patterns at the template ends.
- **Vocabulary:** template, variable name, pattern

### Parsing with literal patterns

- **Page:** 121
- **Summary:** A literal-string pattern (a quoted string) scans the data for a sequence matching the literal value and consumes it from the data; if the pattern is not found in the data it instead matches the end of the string.
- **Vocabulary:** literal pattern

### Parsing strings into words

- **Page:** 122
- **Summary:** When variables follow each other directly with no pattern between them, the substring is split into blank-delimited words and each variable in turn receives one word, except the final variable which receives the remainder of the substring.
- **Vocabulary:** blank-delimited word

### Use of the period as a placeholder

- **Page:** 122
- **Summary:** A single period acts as a placeholder behaving like a variable name except that no variable is set; useful as a dummy slot in a list of variables or to discard unwanted information at the end of a string.
- **Vocabulary:** placeholder, period

### Parsing with positional patterns

- **Page:** 123
- **Summary:** A whole number in a template specifies a column position: an unsigned (or `=`-prefixed) number is an absolute column, while a `+`- or `-`-prefixed number is relative to the last matched position; positional patterns may move backwards, allowing repeated assignments from the same data.
- **Vocabulary:** absolute positional pattern, relative positional pattern

### Parsing with variable patterns

- **Page:** 125
- **Summary:** A variable reference (a variable name in parentheses) supplies the value of the variable as either a literal pattern or a positional pattern depending on whether the parenthesis is preceded by `=`, `+`, or `-`.
- **Vocabulary:** variable reference, variable pattern

### Parsing multiple strings

- **Page:** 125
- **Summary:** A comma in the template instructs the parser to move on to the next input string; multiple input strings are only available to ARG (or PARSE ARG), and unused variables that follow a comma when no further strings exist are set to null.
- **Vocabulary:** comma, multiple strings

## §2.11 — Numbers and Arithmetic

- **Page:** 127
- **Summary:** REXX arithmetic follows the rules conventionally taught in schools and colleges, providing addition, subtraction, multiplication, division, integer division, remainder, and power; all numeric work is fully defined so that all correct implementations produce identical results.
- **Vocabulary:** number, arithmetic operator, NUMERIC DIGITS, NUMERIC FUZZ, NUMERIC FORM, exponential notation, whole number

### Introduction

- **Page:** 127
- **Summary:** Informally introduces REXX numbers (signed, decimal, optional exponent) and the operator set; outlines rounding to NUMERIC DIGITS (default 9), preservation of trailing zeros except for power and division, the rendering of zero as `'0'`, and the use of exponential form when results would otherwise be misleadingly long.
- **Vocabulary:** number, exponential notation, NUMERIC DIGITS, trailing zeros

### Definition

- **Page:** 129
- **Summary:** Heads the formal definition of REXX arithmetic that follows in the rest of this section.
- **Vocabulary:** definition

### Numbers

- **Page:** 129
- **Summary:** Formally defines a REXX number as a character string with one or more decimal digits and an optional decimal point, optional sign (with optional surrounding blanks), and optional outer leading and trailing blanks; a single period alone is not a valid number.
- **Vocabulary:** number, sign, digit, digits, numeric, decimal point

### Precision

- **Page:** 129
- **Summary:** NUMERIC DIGITS sets the maximum number of significant digits in arithmetic results; the default is 9, an implementation-dependent maximum (≥ 9) may apply, and small values are permitted but affect every computation including DO-loop stepping.
- **Vocabulary:** precision, NUMERIC DIGITS, significant digit

### Arithmetic operators

- **Page:** 130
- **Summary:** Lists the operators (`+`, `-`, `*`, `/`, `%`, `//`, `**`, plus prefix `+` and `-`) and describes the pre-operation processing — leading zeros stripped, terms truncated to DIGITS+1 significant digits, traditional 5-up rounding back to DIGITS at the end with a guard digit, trailing zeros retained except for power and division, and a zero result always rendered as `'0'`.
- **Vocabulary:** arithmetic operator, guard digit, rounding, trailing zeros

### Arithmetic operation rules - basic operators

- **Page:** 130
- **Summary:** Heads the operation rules for the basic operators — addition, subtraction, multiplication, and division.
- **Vocabulary:** basic operator

### Addition and subtraction

- **Page:** 130
- **Summary:** Aligns the two numbers on the left and on the right with zero padding to a maximum of DIGITS+1 digits, performs the operation, and rounds counting from the most significant digit; prefix `+` and prefix `-` are evaluated as `0+number` and `0-number` respectively.
- **Vocabulary:** addition, subtraction, prefix plus, prefix minus

### Multiplication

- **Page:** 131
- **Summary:** Performs long multiplication producing a result whose length may equal the sum of the operand lengths, then rounds the result to NUMERIC DIGITS digits counting from the first significant digit.
- **Vocabulary:** multiplication, long multiplication

### Division

- **Page:** 131
- **Summary:** Extends the dividend with trailing zeros until larger than the divisor, performs traditional long division up to DIGITS+1 digits, rounds the quotient, and removes any insignificant trailing zeros.
- **Vocabulary:** division, long division

### Arithmetic operation rules - additional operators

- **Page:** 132
- **Summary:** Heads the operation rules for the additional operators — power, integer divide, and remainder.
- **Vocabulary:** additional operator

### Power

- **Page:** 132
- **Summary:** `**` raises a number to a whole-number power (positive or negative) by left-to-right binary reduction at increased precision (DIGITS+L+1 digits, where L is the integer-part length of the exponent), then rounds to NUMERIC DIGITS and removes insignificant trailing zeros.
- **Vocabulary:** power, binary reduction

### Integer division

- **Page:** 133
- **Summary:** `%` divides two numbers and returns the integer part, defined as the result of repeatedly subtracting the absolute divisor from the absolute dividend; the operation fails if the result would have more digits than NUMERIC DIGITS.
- **Vocabulary:** integer division, integer divide

### Remainder

- **Page:** 133
- **Summary:** `//` returns the residue of the dividend after the integer-divide operation; a non-zero remainder takes the sign of the dividend, and the operation fails under the same conditions as integer division.
- **Vocabulary:** remainder

### Numeric comparisons

- **Page:** 134
- **Summary:** A numeric comparison subtracts the two numbers and compares the difference with `'0'`; the difference is computed under a precision temporarily reduced by NUMERIC FUZZ, allowing two numbers to be considered equal when within FUZZ digits of each other.
- **Vocabulary:** numeric comparison, NUMERIC FUZZ, fuzz

### Exponential notation

- **Page:** 135
- **Summary:** Extends the definition of a numeric to allow an `E` exponent suffix (optional sign and digits) representing a power of ten; results are rendered exponentially when the integer part exceeds NUMERIC DIGITS or the decimal part exceeds twice NUMERIC DIGITS, with NUMERIC FORM selecting scientific or engineering notation.
- **Vocabulary:** exponential notation, mantissa, scientific, engineering, NUMERIC FORM

### Whole numbers

- **Page:** 137
- **Summary:** A whole number is a REXX number whose decimal part is all zeros (or absent) and whose integer part can be expressed as digits within the precision set by NUMERIC DIGITS — anything larger would be expressed exponentially after rounding.
- **Vocabulary:** whole number

### Numbers used directly by REXX

- **Page:** 137
- **Summary:** Lists the contexts that require a whole-number value (with an implementation-dependent maximum of at least 9 digits): positional patterns in parsing templates, the right operand of `**`, the values of `exprr` and `exprf` in DO, the DIGITS and FUZZ values in NUMERIC, and any number in a TRACE setting.
- **Vocabulary:** whole number

### Errors

- **Page:** 138
- **Summary:** Two kinds of arithmetic error may occur: overflow/underflow when the exponent of the result exceeds the language processor's range (the language guarantees support for the range -999999999 through 999999999) and insufficient storage, treated as a terminating error rather than an arithmetical one.
- **Vocabulary:** Overflow, Underflow

## §2.12 — Input and Output Streams

- **Page:** 139
- **Summary:** REXX defines simple, character-oriented input and output: one or more character input streams, one or more character output streams, and one external data queue, all manipulated by the I/O instructions and built-in functions; stream errors are signalled via the NOTREADY condition.
- **Vocabulary:** character input stream, character output stream, external data queue, persistent stream, transient stream, NOTREADY

### Character output streams

- **Page:** 140
- **Summary:** Output streams are written via CHAROUT for character-level control or LINEOUT for line output (and the SAY instruction for the default output stream); a current write position is maintained per stream and may be repositioned in persistent streams.
- **Vocabulary:** character output stream, write position, CHAROUT, LINEOUT, SAY

### The STREAM built-in function

- **Page:** 140
- **Summary:** STREAM is used to determine the state of an input or output stream and to carry out implementation-defined stream commands such as opening, closing, or committing a change.
- **Vocabulary:** STREAM, stream command

### The external data queue

- **Page:** 140
- **Summary:** A queue of character strings accessed only by line operations, visible to other programs whenever REXX yields control; PUSH adds at the head, QUEUE adds at the tail, PULL/PARSE PULL remove at the head (falling back to the default input stream when the queue is empty), and QUEUED returns the line count.
- **Vocabulary:** external data queue, PUSH, QUEUE, PULL, PARSE PULL, QUEUED

### Errors During Input and Output

- **Page:** 142
- **Summary:** When an I/O error occurs the function continues without interruption and the implementation may raise the NOTREADY condition; depending on whether NOTREADY is being trapped (and by SIGNAL or CALL ON), execution may continue, branch, or be deferred via the delayed state.
- **Vocabulary:** NOTREADY, ERROR, FAILURE, delayed state

### Examples of input and output

- **Page:** 143
- **Summary:** Worked examples — FILECOPY copying one stream to another line-by-line, and COLLECTOR reading characters until a line-end character is found and queueing the assembled buffer — show how character and line operations are mixed; closes with a summary table of all I/O instructions and functions.
- **Vocabulary:** CHARIN, CHAROUT, LINEIN, LINEOUT, LINES, PULL, QUEUE, SAY

## §2.13 — Conditions and Condition Traps

- **Page:** 145
- **Summary:** CALL ON and SIGNAL ON enable per-condition traps that divert flow to a named label when one of the named conditions occurs (ERROR, FAILURE, HALT, NOVALUE, NOTREADY, SYNTAX), with CALL OFF and SIGNAL OFF disabling them; NOVALUE and SYNTAX may only be trapped via SIGNAL ON.
- **Vocabulary:** condition trap, ERROR, FAILURE, HALT, NOVALUE, NOTREADY, SYNTAX, CALL ON, SIGNAL ON

### Action taken when a condition is not trapped

- **Page:** 146
- **Summary:** When a condition trap is OFF and the condition occurs, HALT and SYNTAX terminate the program (usually with a descriptive message), while ERROR, FAILURE, NOVALUE, and NOTREADY are silently ignored and the trap remains OFF.
- **Vocabulary:** default action

### Action taken when a condition is trapped

- **Page:** 147
- **Summary:** When the trap is ON and the condition occurs, REXX automatically performs `CALL trapname` or `SIGNAL trapname`; SIGNAL terminates the current instruction and disables the trap, while CALL takes place at a clause boundary and puts the trap into the delayed state until RETURN or until the trap is reissued.
- **Vocabulary:** delayed state, trapname

### Condition Information

- **Page:** 149
- **Summary:** Each trap records condition information accessible via the CONDITION built-in function: the condition name, the trapping instruction (CALL or SIGNAL), the trap state, and a condition-specific descriptive string (e.g., the offending command for ERROR/FAILURE, the variable name for NOVALUE, the stream name for NOTREADY).
- **Vocabulary:** condition information, CONDITION, current trapped condition

### The special variable RC

- **Page:** 150
- **Summary:** When ERROR or FAILURE is trapped, RC is set to the command return code before control transfers to the target label; when SYNTAX is trapped via SIGNAL ON SYNTAX, RC is set to the syntax error number.
- **Vocabulary:** RC, return code, syntax error number

### The special variable SIGL

- **Page:** 150
- **Summary:** After any CALL or SIGNAL jump (including those caused by condition traps), SIGL holds the line number of the last clause executed at the current subroutine level before the jump, supporting error diagnosis and tools that locate the line in error.
- **Vocabulary:** SIGL

## §2.14 — Interactive Tracing

- **Page:** 151
- **Summary:** Switching the trace setting to one with a `?` prefix turns on interactive tracing: REXX pauses after most traced clauses and accepts user input — a null line steps to the next pause, `=` re-executes the last traced clause, or any other text is interpreted immediately as REXX clauses; condition traps are temporarily disabled during interactive input.
- **Vocabulary:** interactive tracing, TRACE, pause point

## §2.15 — Reserved Keywords and Language Extendibility

- **Page:** 154
- **Summary:** REXX reserves only those simple symbols that act as instruction keywords (when first in a clause and not followed by `=` or `:`) or as instruction-specific sub-keywords; discusses how to write programs that remain robust when keywords collide with command names — typically by quoting the first word of every command.
- **Vocabulary:** reserved keyword, sub-keyword, simple symbol

## §2.16 — Special Variables

- **Page:** 156
- **Summary:** Names the three special variables automatically maintained during execution — RC (the return code from any executed command, or the syntax error number when SIGNAL ON SYNTAX is trapped), RESULT (set by RETURN with an expression, dropped otherwise), and SIGL (the line number of the last instruction that caused a jump to a label).
- **Vocabulary:** special variable, RC, RESULT, SIGL

## §2.17 — Error Numbers and Messages

- **Page:** 157
- **Summary:** Lists the recommended REXX error numbers (1–99) used as the value placed in RC when SIGNAL ON SYNTAX traps a syntax error, along with the suggested message text and an explanatory description of each error's cause; the text itself is retrievable via the ERRORTEXT built-in function.
- **Vocabulary:** error number, error message, ERRORTEXT

# Appendices

## Appendix A: REXX Syntax Diagrams

- **Page:** 165
- **Summary:** Collects the syntax diagrams of all REXX instructions presented earlier in the book in one place for ease of reference, with cross-references to the pages defining the general terms (expression, instruction, name, pattern, string, symbol, template).
- **Vocabulary:** syntax diagram, expression, instruction, name, pattern, string, symbol, template

## Appendix B: A Sample REXX Program

- **Page:** 171
- **Summary:** Presents QT, a complete sample REXX program that displays the current time in natural English, illustrating control constructs, parsing, SAY, EXIT, internal subroutines, conditional formatting, and continuation.
- **Vocabulary:** sample REXX program

## Appendix C: Language Changes since First Edition

- **Page:** 175
- **Summary:** Summarises the significant differences between the first-edition language definition (version 3.60) and the second-edition definition (version 4.00) by relevant page number, covering enhancements such as binary literal strings, the symbol-character rationalisation, CALL ON / CALL OFF, condition information, and the new error numbers.
- **Vocabulary:** version 4.00, version 3.60

## Appendix D: Glossary

- **Page:** 179
- **Summary:** Describes (without re-defining) the technical terms used in the REXX language definition as a single alphabetical list of headwords, supporting reading of the rest of the book.
- **Vocabulary:** glossary, technical term, headword
