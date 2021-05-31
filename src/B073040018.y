/*
 * Author: Ernie Chu
 * Filename: B073040018.y
 * Description: Syntatic & semantic parser for JAVA programming language
 * Reference:
 *      http://db.cse.nsysu.edu.tw/~changyi/slides/compiler/lab/Java.doc
 *	https://introcs.cs.princeton.edu/java/11precedence/
 */

%{
    #define YYSTYPE char*
    #include "SymbolTable/SymbolTable.h"
    #include "lex.yy.c"
    #include <stdio.h>
    
    extern unsigned num_chars, num_lines;
    void yyerror();
%}


%token ABSTRACT BOOLEAN BREAK BYTE CASE CATCH CHAR CLASS CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTENDS FINAL FINALLY FLOAT FOR GOTO IF IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE LONG NATIVE NEW PACKAGE PRIVATE PROTECTED PUBLIC RETURN SHORT STATIC SUPER SWITCH SYNCHRONIZED THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LS_ASS RS_ASS URS_ASS EMP_ASS XOR_ASS OR_ASS LS RS URS EQ ASS NE LE GE LT GT AND OR NOT BOOL_LIT NULL_LIT CHAR_LIT STR_LIT INT_SUF HEX_INDI ID

%right ASS MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LS_ASS RS_ASS URS_ASS EMP_ASS XOR_ASS OR_ASS
%right '?' ':'
%left  OR
%left  AND
%left  '|'
%left  '^'
%left  '&'
%left  EQ NE
%nonassoc LE GE LT GT INSTANCEOF
%left  LS RS URS
%left  '+' '-'
%left  '*' '%' '/'
%right CAST NEW
%right PREINC PREDEC UPOS UNEG '!' '~'
%nonassoc POSTINC POSTDEC
%left  '[' ']' '.' '(' ')'

%%

/* Programs */
goal			: compilation_unit
			;
compilation_unit	: package_declaration import_declarations type_declarations
			;

/* Declarations */
package_declaration	: PACKAGE package_name ';'
			;
import_declarations	: import_declaration 
			| import_declarations import_declaration
			;
import_declaration	: single_type_import_declaration 
			| type_import_on_demand_declaration
			;
single_type_import_declaration : IMPORT type_name ';'
type_import_on_demand_declaration : IMPORT package_name '.' '*' ';'
type_declarations	: type_declaration 
			| type_declarations type_declaration
type_declaration	: class_declaration 
			| interface_declaration 
			| ';'
			;
class_declaration	: class_modifiers CLASS identifier super interfaces class_body
			;
class_modifiers		: class_modifier 
			| class_modifiers class_modifier
			;
class_modifier		: PUBLIC | ABSTRACT | FINAL
			;
super			: EXTENDS class_type
			;
interfaces		: IMPLEMENTS interface_type_list
			;
interface_type_list	: interface_type 
			| interface_type_list ',' interface_type
			;
class_body		: '{' class_body_declarations '}'
			;
class_body_declarations : class_body_declaration 
			| class_body_declarations class_body_declaration
			;
class_body_declaration	: class_member_declaration 
			| static_initializer 
			| constructor_declaration
			;
class_member_declaration: field_declaration 
			| method_declaration
			;
static_initializer	: STATIC block
			;
constructor_declaration : constructor_modifiers constructor_declarator throws constructor_body
			;
constructor_modifiers	: constructor_modifier 
			| constructor_modifiers constructor_modifier
			;
constructor_modifier	: PUBLIC | PROTECTED | PRIVATE
			;
constructor_declarator	: simple_type_name '(' formal_parameter_list ')'
			;
formal_parameter_list	: formal_parameter | formal_parameter_list ',' formal_parameter
			;
formal_parameter	: type variable_declarator_id
			;
throws			: THROWS class_type_list
			;
class_type_list		: class_type 
			| class_type_list ',' class_type
			;
constructor_body	: '{' explicit_constructor_invocation block_statements '}'
			;
explicit_constructor_invocation : THIS '(' argument_list ')' 
			| SUPER '(' argument_list ')'
			;
field_declaration	: field_modifiers type variable_declarators ';'
			;
field_modifiers		: field_modifier 
			| field_modifiers field_modifier
			;
field_modifier		: PUBLIC | PROTECTED | PRIVATE | STATIC | FINAL | TRANSIENT | VOLATILE
			;
variable_declarators	: variable_declarator 
			| variable_declarators ',' variable_declarator
			;
variable_declarator	: variable_declarator_id 
			| variable_declarator_id ASS variable_initializer
			;
variable_declarator_id	: identifier 
			| variable_declarator_id '[' ']'
			;
variable_initializer	: expression 
			| array_initializer
			;
method_declaration	: method_header method_body
			;
method_header		: method_modifiers result_type method_declarator throws
			;
result_type		: type 
			| VOID
			;
method_modifiers	: method_modifier 
			| method_modifiers method_modifier
			;
method_modifier		: PUBLIC | PROTECTED | PRIVATE | STATIC | ABSTRACT | FINAL | SYNCHRONIZED | NATIVE
			;
method_declarator	: identifier '(' formal_parameter_list ')'
			;
method_body		: block 
			| ';'
			;
interface_declaration	: interface_modifiers INTERFACE identifier extends_interfaces interface_body
			;
interface_modifiers	: interface_modifier 
			| interface_modifiers interface_modifier
			;
interface_modifier	: PUBLIC | ABSTRACT
extends_interfaces	: EXTENDS interface_type 
			| extends_interfaces ',' interface_type
			;
interface_body		: '{' interface_member_declarations '}'
interface_member_declarations : interface_member_declaration 
			| interface_member_declarations interface_member_declaration
			;
interface_member_declaration : constant_declaration 
			| abstract_method_declaration
			;
constant_declaration	: constant_modifiers type variable_declarator
			;
constant_modifiers	: PUBLIC | STATIC | FINAL
			;
abstract_method_declaration : abstract_method_modifiers result_type method_declarator throws ';'
			;
abstract_method_modifiers : abstract_method_modifier 
			| abstract_method_modifiers abstract_method_modifier
			;
abstract_method_modifier: PUBLIC | ABSTRACT
			;
array_initializer	: '{' variable_initializers ',' '}'
			;
variable_initializers	: variable_initializer 
			| variable_initializers ',' variable_initializer
			;
variable_initializer	: expression 
			| array_initializer
			;

/* Types */
type			: primitive_type 
			| reference_type
			;
primitive_type		: numeric_type 
			| BOOLEAN
			;
numeric_type		: integral_type 
			| floating_point_type
			;
integral_type		: BYTE | SHORT | INT | LONG | CHAR
			;
floating_point_type	: FLOAT | DOUBLE
			;
reference_type		: class_or_interface_type 
			| array_type
			;
class_or_interface_type : class_type 
			| interface_type
			;
class_type		: type_name
			;
interface_type		: type_name
			;
array_type		: type '[' ']'
			;

/* Blocks and Commands */
block			: '{' block_statements '}'
			;
block_statements	: block_statement 
			| block_statements block_statement 
			;
block_statement		: local_variable_declaration_statement 
			| statement
			;
local_variable_declaration_statement : local_variable_declaration ';'
			;
local_variable_declaration : type variable_declarators
			;
statement		: statement_without_trailing_substatement | labeled_statement 
			| if_then_statement | if_then_else_statement | while_statement 
			| for_statement 
			;
statement_no_short_if	: statement_without_trailing_substatement
			| labeled_statement_no_short_if
			| if_then_else_statement_no_short_if 
			| while_statement_no_short_if
			| for_statement_no_short_if
			;
statement_without_trailing_substatement : block | empty_statement | expression_statement 
			| switch_statement | do_statement | break_statement | continue_statement 
			| return_statement | synchronized_statement | throws_statement 
			| try_statement
			;
empty_statement		: ';'
			;
labeled_statement	: identifier ':' statement
			;
labeled_statement_no_short_if : identifier ':' statement_no_short_if
			;
expression_statement	: statement_expression ';'
			;
statement_expression	: assignment | preincrement_expression | postincrement_expression 
			| predecrement_expression | postdecrement_expression | method_invocation 
			| class_instance_creation_expression 
			;
if_then_statement	: IF '(' expression ')' statement
			;
if_then_else_statement	: IF '(' expression ')' statement_no_short_if ELSE statement 
			;
if_then_else_statement_no_short_if : IF '(' expression ')' statement_no_short_if ELSE statement_no_short_if
			;
switch_statement	: SWITCH '(' expression ')' switch_block
			;
switch_block		: '{' switch_block_statement_groups switch_labels '}' 
			;
switch_block_statement_groups : switch_block_statement_group
			| switch_block_statement_groups switch_block_statement_group
			;
switch_block_statement_group : switch_labels block_statements
			;
switch_labels		: switch_label
			| switch_labels switch_label
			;
switch_label		: CASE constant_expression ':'
			| DEFAULT ':'
			;
while_statement		: WHILE '(' expression ')' statement
			;
while_statement_no_short_if : WHILE '(' expression ')' statement_no_short_if
			;
do_statement		: DO statement WHILE '(' expression ')' ';'
			;
for_statement		: FOR '(' for_init ';' expression ';' for_update ')' statement
			;
for_statement_no_short_if : FOR '(' for_init ';' expression ';' for_update ')' statement_no_short_if
			;
for_init		: statement_expression_list 
			| local_variable_declaration
for_update		: statement_expression_list
			;
statement_expression_list : statement_expression 
			| statement_expression_list ',' statement_expression
			;
break_statement		: BREAK identifier ';'
			;
continue_statement	: CONTINUE identifier ';'
			;
return_statement	: RETURN expression ';'
			;
throws_statement	: THROW expression ';'
			;
synchronized_statement  : SYNCHRONIZED '(' expression ')' block
			;
try_statement		: TRY block catches 
			| TRY block catches finally
			;
catches			: catch_clause 
			| catches catch_clause
			;
catch_clause		: CATCH '(' formal_parameter ')' block
			;
finally			: FINALLY block

/* Expressions */
constant_expression	: expression
			;
expression		: assignment_expression
			;
assignment_expression	: conditional_expression 
			| assignment
			;
assignment		: left_hand_side assignment_operator assignment_expression
			;
left_hand_side		: expression_name 
			| field_access 
			| array_access
			;
assignment_operator	: ASS	 | MUL_ASS | DIV_ASS | MOD_ASS | ADD_ASS | SUB_ASS 
			| LS_ASS | RS_ASS  | URS_ASS | EMP_ASS | XOR_ASS | OR_ASS
			;
conditional_expression	: conditional_or_expression
			| conditional_or_expression expression ':' conditional_expression
			;
conditional_or_expression : conditional_and_expression 
			| conditional_or_expression OR conditional_and_expression
			;
conditional_and_expression : inclusive_or_expression 
			| conditional_and_expression AND inclusive_or_expression
			;
inclusive_or_expression : exclusive_or_expression 
			| inclusive_or_expression 
			;
exclusive_or_expression : and_expression 
			| exclusive_or_expression '^' and_expression
			;
and_expression		: equality_expression 
			| and_expression '&' equality_expression 
			;
equality_expression	: relational_expression
			| equality_expression EQ relational_expression 
			| equality_expression NE relational_expression
			;
relational_expression	: shift_expression
			| relational_expression LT shift_expression 
			| relational_expression GT shift_expression 
			| relational_expression LE shift_expression 
			| relational_expression GE shift_expression 
			| relational_expression INSTANCEOF shift_expression 
			;
shift_expression	: additive_expression 
			| shift_expression LS additive_expression 
			| shift_expression RS  additive_expression
			| shift_expression URS  additive_expression
			;
additive_expression	: multiplicative_expression
			| additive_expression '+' multiplicative_expression 
			| additive_expression '+' multiplicative_expression 
			| additive_expression '-' multiplicative_expression
			;
multiplicative_expression : unary_expression
			| multiplicative_expression '*' unary_expression
			| multiplicative_expression '/' unary_expression
			| multiplicative_expression '%' unary_expression
			;
cast_expression		: '(' primitive_type ')' unary_expression 
			| '(' reference_type ')' unary_expression_not_plus_minus 
			;
unary_expression	: preincrement_expression 
			| predecrement_expression
			| '+' unary_expression %prec UPOS
			| '-' unary_expression %prec UNEG
			| unary_expression_not_plus_minus
			;
predecrement_expression : '-' '-' unary_expression %prec PREDEC
			;
preincrement_expression : '+' '+' unary_expression %prec PREINC
			;
unary_expression_not_plus_minus : postfix_expression 
			| '~' unary_expression 
			| '!' unary_expression 
			| cast_expression
postdecrement_expression: postfix_expression '-' '-' %prec POSTDEC
			;
postincrement_expression: postfix_expression '+' '+' %prec POSTINC
			;
postfix_expression	: primary 
			| expression_name 
			| postincrement_expression 
			| postdecrement_expression
			;
method_invocation	: method_name '(' argument_list ')' 
			| primary '.' identifier '(' argument_list ')' 
			| SUPER '.' identifier '(' argument_list ')'
			;
field_access		: primary '.' identifier 
			| SUPER '.' identifier
			;
primary			: primary_no_new_array 
			| array_creation_expression
			;
primary_no_new_array	: literal 
			| THIS | '(' expression ')' | class_instance_creation_expression 
			| field_access | method_invocation | array_access
			;
class_instance_creation_expression : NEW class_type '(' argument_list ')'
argument_list		: expression 
			| argument_list ',' expression
			;
array_creation_expression : NEW primitive_type dim_exprs dims 
			| NEW class_or_interface_type dim_exprs dims
dim_exprs		: dim_expr 
			| dim_exprs dim_expr
			;
dim_expr		: '[' expression ']'
			;
dims			: '[' ']' 
			| dims '[' ']'
			;
array_access		: expression_name '[' expression ']' 
			| primary_no_new_array '[' expression ']'
			;

/* Tokens */
package_name		: identifier
			| package_name '.' identifier
			;
type_name		: identifier
			| package_name '.' identifier
			;
simple_type_name	: identifier
			;
expression_name		: identifier
			| ambiguous_name '.' identifier
			;
method_name		: identifier
			| ambiguous_name '.' identifier
			;
ambiguous_name		: identifier
			| ambiguous_name '.' identifier
			;
literal			: integer_literal 
			| floating_point_literal 
			| boolean_literal 
			| character_literal 
			| string_literal 
			| null_literal
			;
integer_literal		: decimal_integer_literal 
			| hex_integer_literal 
			| octal_integer_literal
			;
decimal_integer_literal : decimal_numeral integer_type_suffix
			;
hex_integer_literal	: hex_numeral integer_type_suffix
			;
octal_integer_literal	: octal_numeral integer_type_suffix
			;
integer_type_suffix	: INT_SUF
			;
decimal_numeral		: '0' 
			| non_zero_digit digits
			;
digits			: digit
			| digits digit
			;
digit			: '0' 
			| non_zero_digit
			;
non_zero_digit		: '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
			;
hex_numeral		: '0' HEX_INDI hex_digit 
			| hex_numeral hex_digit
			;
hex_digit		: '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' 
			| 'a' | 'b' | 'c' | 'd' | 'e' | 'f' 
			| 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
			;
octal_numeral		: '0' octal_digit 
			| octal_numeral octal_digit
			;
octal_digit		: '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7'
			;
floating_point_literal	: digits '.' digits exponent_part float_type_suffix
		        | '.' digits exponent_part float_type_suffix
		        | digits exponent_part float_type_suffix
			;
exponent_part		: exponent_indicator signed_integer
			;
exponent_indicator	: 'e' | 'E'
			;
signed_integer		: sign digits
			;
sign			: '+' %prec UPOS 
			| '-' %prec UNEG
			;
float_type_suffix	: 'f' | 'F' | 'd' | 'D'
			;
boolean_literal		: BOOL_LIT 
			;
character_literal	: CHAR_LIT
			;
string_literal		: STR_LIT
			;
null_literal		: NULL_LIT
			;
/*
keyword			: ABSTRACT | BOOLEAN | BREAK | BYTE | CASE | CATCH | CHAR | CLASS | CONST 
			| CONTINUE | DEFAULT | DO | DOUBLE | ELSE | EXTENDS | FINAL | FINALLY 
			| FLOAT | FOR | GOTO | IF | IMPLEMENTS | IMPORT | INSTANCEOF | INT 
			| INTERFACE | LONG | NATIVE | NEW | PACKAGE | PRIVATE | PROTECTED | PUBLIC 
			| RETURN | SHORT | STATIC | SUPER | SWITCH | SYNCHRONIZED | THIS | THROW 
			| THROWS | TRANSIENT | TRY | VOID | VOLATILE | WHILE
			;
*/
identifier		: ID
%%

int main() {
    yyparse();
    return 0;
}

void yyerror() {
    printf("syntax error at line %d\n", num_lines+1);
};
