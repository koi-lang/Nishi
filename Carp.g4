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
line: comment | function | class;

comment: COMMENT | MULTI_COMMENT;

statement: print;
print: PRINT OPEN_BRACKET (value | ID) CLOSE_BRACKET;

// func my_func(name -> String) {}
function: FUNCTION ID OPEN_BRACKET (parameter)* CLOSE_BRACKET block;
class: (CLASS | OBJECT) ID block // class MyClass {}
       | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* block // class MyClass extends OtherClass {}
       | (CLASS | OBJECT) ID IMPLEMENTS ID (COMMA ID)* block // class MyClass implements MyInterface {}
       | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* IMPLEMENTS ID (COMMA ID)* block // class MyClass extends OtherClass implements MyInterface {}
       ;

block: OPEN_BLOCK statement (SEPARATOR statement)* CLOSE_BLOCK;

value: STRING | NUMBER | BOOLEAN;
type: 'String' | 'Integer' | 'Boolean' | 'List' LESS_THAN type MORE_THAN;

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
CLASS: 'class';
OBJECT: 'object';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;

STRING: ["] ~["\r\n]* ["];
NUMBER: [0-9]+;
BOOLEAN: 'true' | 'false';

DOT: '.';
COMMA: ',';
SEPARATOR: ';';
TYPE_SETTER: '->';
VARIABLE_SETTER: ':';
STAR: '*';
OPEN_BRACKET: '(';
CLOSE_BRACKET: ')';
OPEN_BLOCK: '{';
CLOSE_BLOCK: '}';
LESS_THAN: '<';
MORE_THAN: '>';

EXTENDS: 'extends';
IMPLEMENTS: 'implements';

ID: LOWERCASE (LETTER | NUMBER | '_')*;

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;