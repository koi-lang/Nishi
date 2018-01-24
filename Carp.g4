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
line: comment | function;

comment: COMMENT | MULTI_COMMENT;

statement: print;
print: PRINT OPEN_BRACKET (value | ID) CLOSE_BRACKET;

function: FUNCTION ID OPEN_BRACKET (parameter)* CLOSE_BRACKET block;

block: OPEN_BLOCK statement (SEPARATOR statement)* CLOSE_BLOCK;

value: STRING | NUMBER | BOOLEAN;
type: 'String' | 'Integer' | 'Boolean';

parameter: ID TYPE_SETTER type // arg -> Integer
           | ID TYPE_SETTER type VARIABLE_SETTER value // arg -> Integer: value
           | STAR ID TYPE_SETTER type // *arg -> Integer
           | STAR ID TYPE_SETTER type VARIABLE_SETTER value // *arg -> Integer: value
           ;

/*
    Lexer Rules
 */

PACKAGE: 'package';

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' ~[-#]* '-#' -> skip;

PRINT: 'print';

FUNCTION: 'func';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;

STRING: ["] ~["\r\n]* ["];
NUMBER: [0-9]+;
BOOLEAN: 'true' | 'false';

DOT: '.';
SEPARATOR: ';';
TYPE_SETTER: '->';
VARIABLE_SETTER: ':';
STAR: '*';
OPEN_BRACKET: '(';
CLOSE_BRACKET: ')';
OPEN_BLOCK: '{';
CLOSE_BLOCK: '}';

ID: LOWERCASE (LETTER | NUMBER | '_')*;

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;