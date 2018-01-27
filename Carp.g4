grammar Carp;

options {
    language=Python3;
}

/*
    Parser Rules
 */

program: code EOF
       | package code EOF
       ;
package: PACKAGE ID (DOT ID)*;

code: (line (SEPARATOR (line)*)*)*;
interface_code: (interface_line (SEPARATOR (interface_line)*)*)*;

line: comment | function | class_ | object_ | interface | statement | expression;
interface_line: comment | interface_function;

import_: IMPORT ID (DOT ID)*;

comment: COMMENT | MULTI_COMMENT;

statement: print_ | import_ | call_function | assignment | arithmatic_assign | if_stmt | try_catch | for_loop | switch | return_;
// print("Hello, World!")
print_: PRINT OPEN_BRACKET (value COMMA)* (value)* CLOSE_BRACKET;
// return 5
return_: RETURN (value | expression);
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

for_loop: FOR ID IN value block;

switch: SWITCH value OPEN_BLOCK (CASE (value | arithmatic_expression) block)* CLOSE_BLOCK // switch 5 { case 5 { print_("Five") } }
      | SWITCH value OPEN_BLOCK (CASE (value | arithmatic_expression) block)* else_ CLOSE_BLOCK // switch 5 { case 5 { print_("Five") } else_ { print_("Not five!") } }
      ;

assignment: ID TYPE_SETTER type_ // arg -> Integer
          | ID TYPE_SETTER type_ VARIABLE_SETTER value // arg -> Integer: value
          | STAR ID TYPE_SETTER type_ // *arg -> Integer
          | ID VARIABLE_SETTER value // arg: value
          ;

function: FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET function_block #NormalFunction // fun my_func(name -> String) {}
        | OVERRIDE FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET function_block #OverrideFunction // override fun my_func(name -> String) {}
        | FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET TYPE_SETTER type_ function_block #FunctionSetter // fun my_func(name -> String) -> Void {}
        | OVERRIDE FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET TYPE_SETTER type_ function_block #OverrideFunctionSetter // override fun my_func(name -> String) -> Void {}
        ;
call_function: ID OPEN_BRACKET (call_parameter COMMA)* call_parameter* CLOSE_BRACKET;

interface_function: FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET // fun my_func(name -> String) {}
                  | FUNCTION ID OPEN_BRACKET (parameter COMMA)* parameter* CLOSE_BRACKET TYPE_SETTER type_ // fun my_func(name -> String) -> Void {}
                  ;

class_: CLASS ID class_block #NormalClass // class MyClass {}
      | CLASS ID EXTENDS (ID COMMA)* ID* class_block #ExtendedClass // class MyClass extends OtherClass {}
      | CLASS ID IMPLEMENTS (ID COMMA)* ID* class_block #ImplementedClass // class MyClass implements MyInterface {}
      | CLASS ID EXTENDS (ID COMMA)* ID* IMPLEMENTS (ID COMMA)* ID* class_block #ExtendedImplementedClass // class MyClass extends OtherClass implements MyInterface {}
      ;
      
object_: OBJECT ID class_block #NormalObject // object MyObject {}
       | OBJECT ID EXTENDS (ID COMMA)* ID* class_block #ExtendedObject // object MyObject extends OtherObject {}
       | OBJECT ID IMPLEMENTS (ID COMMA)* ID* class_block #ImplementedObject // object MyObject implements MyInterface {}
       | OBJECT ID EXTENDS (ID COMMA)* ID* IMPLEMENTS (ID COMMA)* ID* class_block #ExtendedImplementedObject // object MyObject extends OtherObject implements MyInterface {}
       ;

interface: INTERFACE ID interface_block;

block: OPEN_BLOCK code CLOSE_BLOCK;
variable_block: OPEN_BLOCK (assignment (SEPARATOR (assignment)*)*)* CLOSE_BLOCK;
interface_variable_block: OPEN_BLOCK (ID (SEPARATOR (ID)*)*)* CLOSE_BLOCK
                        | OPEN_BLOCK (ID TYPE_SETTER type_ (SEPARATOR (ID TYPE_SETTER type_)*)*)* CLOSE_BLOCK
                        ;

// public {}
public_block: PUBLIC variable_block;
interface_public_block: PUBLIC interface_variable_block;
// private {}
private_block: PRIVATE variable_block;
interface_private_block: PRIVATE interface_variable_block;
// doc {}
doc_block: DOC OPEN_BLOCK ~CLOSE_BLOCK* CLOSE_BLOCK;

function_block: OPEN_BLOCK doc_block* code CLOSE_BLOCK
              | OPEN_BLOCK doc_block* code get_block CLOSE_BLOCK
              | OPEN_BLOCK doc_block* code set_block CLOSE_BLOCK
              | OPEN_BLOCK doc_block* code get_block set_block CLOSE_BLOCK
              ;
class_block: OPEN_BLOCK (doc_block | private_block | public_block)* code CLOSE_BLOCK;
interface_block: OPEN_BLOCK (doc_block | interface_private_block | interface_public_block)* interface_code CLOSE_BLOCK;

get_block: GET OPEN_BLOCK RETURN ID CLOSE_BLOCK;
set_block: SET OPEN_BLOCK assignment CLOSE_BLOCK;

value: STRING | NUMBER | BOOLEAN | list_ | ID;
type_: 'String' | 'Integer' | 'Boolean' | 'Void' | 'List' LESS_THAN (type_ COMMA)* type_* MORE_THAN | ID;
list_: OPEN_SQUARE (value COMMA)* value* CLOSE_SQUARE;

parameter: ID TYPE_SETTER type_ // arg -> Integer
         | ID TYPE_SETTER type_ VARIABLE_SETTER value // arg -> Integer: value
         | STAR ID TYPE_SETTER type_ // *arg -> Integer
         | STAR ID TYPE_SETTER type_ VARIABLE_SETTER value // *arg -> Integer: value
         | ID VARIABLE_SETTER value // arg: value
         | STAR ID VARIABLE_SETTER value // *arg: value
         ;

call_parameter: ID VARIABLE_SETTER value // arg: value
              | value
              ;

comparison_operator: '=' | '<=' | '<' | '>=' | '>' | '!=';
arithmatic_operator: '+' | '-' | '*' | '/' | '%';
arithmatic_assign: ID arithmatic_operator VARIABLE_SETTER value;

expression: arithmatic_expression | post_increment | post_decrement;

post_increment: value INCREMENT;
post_decrement: value DECREMENT;

arithmatic_expression: value (arithmatic_operator value)+;

/*
    Lexer Rules
 */

PACKAGE: 'package';

IMPORT: 'import';

COMMENT: '#' ~[\r\n]* -> skip;
MULTI_COMMENT: '#-' .*? '-#' -> skip;

PRINT: 'print';
RETURN: 'return';

IF: 'if';
ELIF: 'elf';
ELSE: 'else';

TRY: 'try';
CATCH: 'catch';

FOR: 'for';
IN: 'in';

SWITCH: 'switch';
CASE: 'case';

OVERRIDE: 'override';
FUNCTION: 'fun';
CLASS: 'class';
OBJECT: 'object';
INTERFACE: 'interface';

GET: 'get';
SET: 'set';

EXTENDS: 'extends';
IMPLEMENTS: 'implements';

PRIVATE: 'private';
PUBLIC: 'public';
DOC: 'doc';

THIS: 'this';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: (LOWERCASE | UPPERCASE)+;

STRING: ["] ~["\r\n]* ["];
NUMBER: [0-9]+;
BOOLEAN: 'true' | 'false';

ID: (LETTER | '_') (LETTER | NUMBER | '_')*
  | THIS DOT (LETTER | '_') (LETTER | NUMBER | '_')*
  ;

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

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;