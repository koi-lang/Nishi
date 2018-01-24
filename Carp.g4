grammar Carp;

options {
    language=Python3;
}

/*
    Parser Rules
 */

program: code EOF;
code: line+;
line: comment;

comment: COMMENT | MULTI_COMMENT;

/*
    Lexer Rules
 */

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' ~[-#]* '-#' -> skip;

SPACE: [ \t\r\n] -> skip;

STRING: ["] ~["\r\n]* ["];

LETTER: ([a-z] | [A-Z])+;
NUMBER: [0-9]+;

ID: [a-z]+;

WS: [ \t\r\n\f]+ -> skip;