grammar Carp;

options {
    language=Python3;
}

/*
    Parser Rules
 */

program: package code EOF;
package: PACKAGE ID (DOT ID)*;
code: (line (SEPARATOR line)*)+;
line: comment | function | class | statement;

comment: COMMENT | MULTI_COMMENT;

statement: print | assignment | if;
// print("Hello, World!")
print: PRINT OPEN_BRACKET ((value | ID) COMMA)* CLOSE_BRACKET;
// if a = "Hello" {}
if: IF value (comparison_operator value)+ block;

assignment: ID TYPE_SETTER type // arg -> Integer
          | ID TYPE_SETTER type VARIABLE_SETTER value // arg -> Integer: value
          | STAR ID TYPE_SETTER type // *arg -> Integer
          | ID VARIABLE_SETTER value // arg: value
          ;

// fun my_func(name -> String) {}
function: FUNCTION ID OPEN_BRACKET doc_block* (parameter)* CLOSE_BRACKET block;
class: (CLASS | OBJECT) ID class_block // class MyClass {}
     | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* class_block // class MyClass extends OtherClass {}
     | (CLASS | OBJECT) ID IMPLEMENTS ID (COMMA ID)* class_block // class MyClass implements MyInterface {}
     | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* IMPLEMENTS ID (COMMA ID)* class_block // class MyClass extends OtherClass implements MyInterface {}
     ;

block: OPEN_BLOCK code CLOSE_BLOCK;
variable_block: OPEN_BLOCK (assignment SEPARATOR)* CLOSE_BLOCK;

// public {}
public_block: PUBLIC variable_block;
// private {}
private_block: PRIVATE variable_block;
// doc {}
doc_block: DOC OPEN_BLOCK . CLOSE_BLOCK;

class_block: OPEN_BLOCK doc_block code CLOSE_BLOCK
           | OPEN_BLOCK doc_block public_block code CLOSE_BLOCK
           | OPEN_BLOCK doc_block private_block code CLOSE_BLOCK
           | OPEN_BLOCK doc_block public_block private_block code CLOSE_BLOCK
           ;

value: STRING | NUMBER | BOOLEAN | LIST | ID;
type: 'String' | 'Integer' | 'Boolean' | 'Void' | 'List' LESS_THAN type (COMMA type) MORE_THAN | ID;

parameter: ID TYPE_SETTER type // arg -> Integer
         | ID TYPE_SETTER type VARIABLE_SETTER value // arg -> Integer: value
         | STAR ID TYPE_SETTER type // *arg -> Integer
         | STAR ID TYPE_SETTER type VARIABLE_SETTER value // *arg -> Integer: value
         | ID VARIABLE_SETTER value // arg: value
         | STAR ID VARIABLE_SETTER value // *arg: value
         ;

comparison_operator: '=' | '<=' | '>=';
arithmatic_operator: '+' | '-' | '*' | '/';

/*
    Lexer Rules
 */

PACKAGE: 'package';

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' ~[-#]* '-#' -> skip;

PRINT: 'print';

IF: 'if';

FUNCTION: 'fun';
CLASS: 'class';
OBJECT: 'object';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;

STRING: ["] ~["\r\n]* ["];
NUMBER: [0-9]+;
BOOLEAN: 'true' | 'false';
LIST: OPEN_SQUARE (STRING | NUMBER | BOOLEAN | ID)* CLOSE_SQUARE;

ID: LOWERCASE (LETTER | NUMBER | '_')*;

DOT: '.';
COMMA: ',';
SEPARATOR: ';';
TYPE_SETTER: '->';
VARIABLE_SETTER: ':';
STAR: '*';
OPEN_BRACKET: '(';
CLOSE_BRACKET: ')';
OPEN_SQUARE: '[';
CLOSE_SQUARE: ']';
OPEN_BLOCK: '{';
CLOSE_BLOCK: '}';
LESS_THAN: '<';
MORE_THAN: '>';

EXTENDS: 'extends';
IMPLEMENTS: 'implements';

PRIVATE: 'private';
PUBLIC: 'public';
DOC: 'doc';

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;