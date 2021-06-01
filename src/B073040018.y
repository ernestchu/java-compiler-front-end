/*
 * Author: Ernie Chu
 * Filename: B073040018.y
 * Description: Syntatic & semantic parser for JAVA programming language
 * Reference:
 *      http://db.cse.nsysu.edu.tw/~changyi/slides/compiler/lab/Java.doc
 *	https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
 *	https://introcs.cs.princeton.edu/java/11precedence/
 */

%{
    #define YYSTYPE char*
    #ifndef DEBUG
    #define DEBUG 0
    #endif
    #include "SymbolTable/SymbolTable.h"
    #include "lex.yy.c"
    #include <stdio.h>
    
    int yydebug = !!DEBUG;

    extern unsigned num_chars, num_lines;
    void yyerror();
%}



%token ABSTRACT BOOLEAN BREAK BYTE CASE CATCH CHAR CLASS CONTINUE DEFAULT DO DOUBLE ELSE EXTENDS FINAL FINALLY FLOAT FOR IF IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE LONG NATIVE NEW PACKAGE PRIVATE PROTECTED PUBLIC RETURN SHORT STATIC SUPER SWITCH SYNCHRONIZED THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE ASS MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LS_ASS RS_ASS URS_ASS EMP_ASS XOR_ASS OR_ASS LS RS URS EQ NE LE GE LT GT AND OR NOT INC DEC BOOL_LIT NULL_LIT CHAR_LIT STR_LIT INT_LIT FLT_LIT ID

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
%right PREINC PREDEC UMINUS NOT '~'
%nonassoc POSTINC POSTDEC
%left  '[' ']' '.' '(' ')'

%%

/* Programs */
compilation_unit	: package_declaration_opt import_declarations_opt type_declarations_opt
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
			;
type_import_on_demand_declaration : IMPORT package_name '.' '*' ';'
			;
type_declarations	: type_declaration 
			| type_declarations type_declaration
			;
type_declaration	: class_declaration 
			| interface_declaration 
			| ';'
			;
class_declaration	: class_modifiers_opt CLASS identifier super_opt interfaces_opt class_body
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
class_body		: '{' class_body_declarations_opt '}'
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
constructor_declaration : constructor_modifiers_opt constructor_declarator throws_opt constructor_body
			;
constructor_modifiers	: constructor_modifier 
			| constructor_modifiers constructor_modifier
			;
constructor_modifier	: PUBLIC | PROTECTED | PRIVATE
			;
constructor_declarator	: simple_type_name '(' formal_parameter_list_opt ')'
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
constructor_body	: '{' explicit_constructor_invocation_opt block_statements_opt '}'
			;
explicit_constructor_invocation : THIS '(' argument_list_opt ')' 
			| SUPER '(' argument_list_opt ')'
			;
field_declaration	: field_modifiers_opt type variable_declarators ';'
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
method_declaration	: method_header method_body
			;
method_header		: method_modifiers_opt result_type method_declarator throws_opt
			;
result_type		: type 
			| VOID
			;
method_modifiers	: method_modifier 
			| method_modifiers method_modifier
			;
method_modifier		: PUBLIC | PROTECTED | PRIVATE | STATIC | ABSTRACT | FINAL | SYNCHRONIZED | NATIVE
			;
method_declarator	: identifier '(' formal_parameter_list_opt ')'
			;
method_body		: block 
			| ';'
			;
interface_declaration	: interface_modifiers_opt INTERFACE identifier extends_interfaces_opt interface_body
			;
interface_modifiers	: interface_modifier 
			| interface_modifiers interface_modifier
			;
interface_modifier	: PUBLIC | ABSTRACT
			;
extends_interfaces	: EXTENDS interface_type 
			| extends_interfaces ',' interface_type
			;
interface_body		: '{' interface_member_declarations_opt '}'
			;
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
abstract_method_declaration : abstract_method_modifiers result_type method_declarator throws_opt ';'
			;
abstract_method_modifiers : abstract_method_modifier 
			| abstract_method_modifiers abstract_method_modifier
			;
abstract_method_modifier: PUBLIC | ABSTRACT
			;
array_initializer	: '{' variable_initializers_opt ',' '}'
			| '{' variable_initializers_opt '}'
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
block			: '{' block_statements_opt '}'
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
switch_block		: '{' switch_block_statement_groups_opt switch_labels_opt '}' 
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
for_statement		: FOR '(' for_init_opt ';' expression_opt ';' for_update_opt ')' statement
			;
for_statement_no_short_if : FOR '(' for_init_opt ';' expression_opt ';' for_update_opt ')' statement_no_short_if
			;
for_init		: statement_expression_list 
			| local_variable_declaration
			;
for_update		: statement_expression_list
			;
statement_expression_list : statement_expression 
			| statement_expression_list ',' statement_expression
			;
break_statement		: BREAK identifier_opt ';'
			;
continue_statement	: CONTINUE identifier_opt ';'
			;
return_statement	: RETURN expression_opt ';'
			;
throws_statement	: THROW expression ';'
			;
synchronized_statement  : SYNCHRONIZED '(' expression ')' block
			;
try_statement		: TRY block catches 
			| TRY block catches_opt finally
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
			| conditional_or_expression '?' expression ':' conditional_expression
			;
conditional_or_expression : conditional_and_expression 
			| conditional_or_expression OR conditional_and_expression
			;
conditional_and_expression : inclusive_or_expression 
			| conditional_and_expression AND inclusive_or_expression
			;
inclusive_or_expression : exclusive_or_expression 
			| inclusive_or_expression '|' exclusive_or_expression
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
			| additive_expression '-' multiplicative_expression
			;
multiplicative_expression : unary_expression
			| multiplicative_expression '*' unary_expression
			| multiplicative_expression '/' unary_expression
			| multiplicative_expression '%' unary_expression
			;
cast_expression		: '(' primitive_type ')' unary_expression %prec CAST
			| '(' reference_type ')' unary_expression_not_plus_minus %prec CAST 
			;
unary_expression	: preincrement_expression 
			| predecrement_expression
			| '+' unary_expression %prec UMINUS
			| '-' unary_expression %prec UMINUS
			| unary_expression_not_plus_minus
			;
predecrement_expression : DEC unary_expression %prec PREDEC
			;
preincrement_expression : INC unary_expression %prec PREINC
			;
unary_expression_not_plus_minus : postfix_expression 
			| '~' unary_expression 
			| NOT unary_expression 
			| cast_expression
			;
postdecrement_expression: postfix_expression DEC %prec POSTDEC
			;
postincrement_expression: postfix_expression INC %prec POSTINC
			;
postfix_expression	: primary 
			| expression_name 
			| postincrement_expression 
			| postdecrement_expression
			;
method_invocation	: method_name '(' argument_list_opt ')' 
			| primary '.' identifier '(' argument_list_opt ')' 
			| SUPER '.' identifier '(' argument_list_opt ')'
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
class_instance_creation_expression : NEW class_type '(' argument_list_opt ')'
argument_list		: expression 
			| argument_list ',' expression
			;
array_creation_expression : NEW primitive_type dim_exprs dims_opt 
			| NEW class_or_interface_type dim_exprs dims_opt
			;
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
boolean_literal		: BOOL_LIT 
			;
null_literal		: NULL_LIT
			;
character_literal	: CHAR_LIT
			;
string_literal		: STR_LIT
			;
integer_literal		: INT_LIT
			;
floating_point_literal  : FLT_LIT
			;
identifier		: ID
			;

/* Optionals */
argument_list_opt : argument_list | /* empty */ ;
block_statements_opt : block_statements | /* empty */ ;
catches_opt : catches | /* empty */ ;
class_body_declarations_opt : class_body_declarations | /* empty */ ;
class_modifiers_opt : class_modifiers | /* empty */ ;
constructor_modifiers_opt : constructor_modifiers | /* empty */ ;
dims_opt : dims | /* empty */ ;
explicit_constructor_invocation_opt : explicit_constructor_invocation | /* empty */ ;
expression_opt : expression | /* empty */ ;
extends_interfaces_opt : extends_interfaces | /* empty */ ;
field_modifiers_opt : field_modifiers | /* empty */ ;
for_init_opt : for_init | /* empty */ ;
for_update_opt : for_update | /* empty */ ;
formal_parameter_list_opt : formal_parameter_list | /* empty */ ;
identifier_opt : identifier | /* empty */ ;
import_declarations_opt : import_declarations | /* empty */ ;
interface_member_declarations_opt : interface_member_declarations | /* empty */ ;
interface_modifiers_opt : interface_modifiers | /* empty */ ;
interfaces_opt : interfaces | /* empty */ ;
method_modifiers_opt : method_modifiers | /* empty */ ;
package_declaration_opt : package_declaration | /* empty */ ;
super_opt : super | /* empty */ ;
switch_block_statement_groups_opt : switch_block_statement_groups | /* empty */ ;
switch_labels_opt : switch_labels | /* empty */ ;
throws_opt : throws | /* empty */ ;
type_declarations_opt : type_declarations | /* empty */ ;
variable_initializers_opt : variable_initializers | /* empty */ ;

%%

int main() {
    if (DEBUG == 1)
	fprintf(stderr, "%6u  ", 1);
    yyparse();

    return 0;
}

void yyerror() {
    fprintf(stderr, "\033[1m");
    fprintf(stderr, "\n%6u:%u: ", num_lines, num_chars);
    fprintf(stderr, "\033[0;31m");
    fprintf(stderr, "\033[1m");
    fprintf(stderr, "syntax error: ");
    fprintf(stderr, "\033[0m");
    fprintf(stderr, "\033[1m");
    fprintf(stderr, "parsing error: `%s`", yytext);
    fprintf(stderr, "\033[22m");
};
