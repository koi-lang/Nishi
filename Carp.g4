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
line: comment | function | class_ | statement | expression;

comment: COMMENT | MULTI_COMMENT;

statement: print_ | assignment | arithmatic_assign | if_stmt | try_catch | switch | return_;
// print("Hello, World!")
print_: PRINT OPEN_BRACKET (value COMMA)* (value)* CLOSE_BRACKET;
// return 5
return_: RETURN value;
// if a = "Hello" {}
if_: IF value (comparison_operator value)+ block;
// elf a = "World" {}
elif_: ELIF value (comparison_operator value)+ block;
// else {}
else_: ELSE block;
// if_ a = "Hello" {} elf a = "World" {} else {}
if_stmt: if_ elif_*
       | if_ elif_* else_
       ;

try_catch: TRY block (CATCH ID block)*;

switch: SWITCH value OPEN_BLOCK (CASE (value | arithmatic_expression) block)* CLOSE_BLOCK // switch 5 { case 5 { print_("Five") } }
      | SWITCH value OPEN_BLOCK (CASE (value | arithmatic_expression) block)* else_ CLOSE_BLOCK // switch 5 { case 5 { print_("Five") } else_ { print_("Not five!") } }
      ;

assignment: ID TYPE_SETTER type_ // arg -> Integer
          | ID TYPE_SETTER type_ VARIABLE_SETTER value // arg -> Integer: value
          | STAR ID TYPE_SETTER type_ // *arg -> Integer
          | ID VARIABLE_SETTER value // arg: value
          ;

function: FUNCTION ID OPEN_BRACKET doc_block* (parameter)* CLOSE_BRACKET block // fun my_func(name -> String) {}
        | FUNCTION ID OPEN_BRACKET doc_block* (parameter)* TYPE_SETTER type_ CLOSE_BRACKET block // fun my_func(name -> String) -> Void {}
        ;

class_: (CLASS | OBJECT) ID class_block // class_ MyClass {}
      | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* class_block // class_ MyClass extends OtherClass {}
      | (CLASS | OBJECT) ID IMPLEMENTS ID (COMMA ID)* class_block // class_ MyClass implements MyInterface {}
      | (CLASS | OBJECT) ID EXTENDS ID (COMMA ID)* IMPLEMENTS ID (COMMA ID)* class_block // class_ MyClass extends OtherClass implements MyInterface {}
      ;

block: OPEN_BLOCK code CLOSE_BLOCK;
variable_block: OPEN_BLOCK (assignment SEPARATOR)* CLOSE_BLOCK;

// public {}
public_block: PUBLIC variable_block;
// private {}
private_block: PRIVATE variable_block;
// doc {}
doc_block: DOC OPEN_BLOCK .*? CLOSE_BLOCK;

class_block: OPEN_BLOCK (doc_block | private_block | public_block)* code CLOSE_BLOCK;

value: STRING | NUMBER | BOOLEAN | list_ | ID;
type_: 'String' | 'Integer' | 'Boolean' | 'Void' | 'List' LESS_THAN type_ (COMMA type_) MORE_THAN | ID;
list_: OPEN_SQUARE (value COMMA)* (value)* CLOSE_SQUARE;

parameter: ID TYPE_SETTER type_ // arg -> Integer
         | ID TYPE_SETTER type_ VARIABLE_SETTER value // arg -> Integer: value
         | STAR ID TYPE_SETTER type_ // *arg -> Integer
         | STAR ID TYPE_SETTER type_ VARIABLE_SETTER value // *arg -> Integer: value
         | ID VARIABLE_SETTER value // arg: value
         | STAR ID VARIABLE_SETTER value // *arg: value
         ;

comparison_operator: '=' | '<=' | '<' | '>=' | '>' | '!=';
arithmatic_operator: '+' | '-' | '*' | '/' | '%';
arithmatic_assign: arithmatic_operator VARIABLE_SETTER;

expression: arithmatic_expression | post_increment | post_decrement;

post_increment: value INCREMENT;
post_decrement: value DECREMENT;

arithmatic_expression: NUMBER (arithmatic_operator NUMBER)+;

/*
    Lexer Rules
 */

PACKAGE: 'package';

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' .*? '-#' -> skip;

PRINT: 'print';
RETURN: 'return';

IF: 'if';
ELIF: 'elf';
ELSE: 'else';

TRY: 'try';
CATCH: 'catch';

SWITCH: 'switch';
CASE: 'case';

FUNCTION: 'fun';
CLASS: 'class';
OBJECT: 'object';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;

STRING: ["] ~["\r\n]* ["];
NUMBER: [0-9]+;
BOOLEAN: 'true' | 'false';

ID: (LETTER | '_') (LETTER | NUMBER | '_')*;

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

INCREMENT: '++';
DECREMENT: '--';

EXTENDS: 'extends';
IMPLEMENTS: 'implements';

PRIVATE: 'private';
PUBLIC: 'public';
DOC: 'doc';

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;