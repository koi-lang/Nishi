grammar Carp;

options {
    language=Python3;
}

/*
    Parser Rules
 */

program: package code EOF;
package: PACKAGE ID (DOT ID)*;
code: line+;
line: comment;

comment: COMMENT | MULTI_COMMENT;

/*
    Lexer Rules
 */

PACKAGE: 'package';

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' ~[-#]* '-#' -> skip;

STRING: ["] ~["\r\n]* ["];

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;
NUMBER: [0-9]+;
DOT: '.';

ID: LOWERCASE (LETTER | NUMBER)*;

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;