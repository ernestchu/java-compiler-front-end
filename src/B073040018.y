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
    int level	= 0; /* scope level */

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
%right PRE UMINUS NOT '~'
%nonassoc POST
%left  '[' ']' '.' '(' ')'

%%

/* Program */
Goal			    : CompilationUnit
			    ;

/* Literals */
Literal			    : BooleanLiteral
			    | NullLiteral
			    | CharacterLiteral
			    | StringLiteral
			    | IntegerLiteral
			    | FloatingPointLiteral
			    ;
BooleanLiteral		    : BOOL_LIT
			    ;
NullLiteral		    : NULL_LIT
			    ;
CharacterLiteral	    : CHAR_LIT
			    ;
StringLiteral		    : STR_LIT
			    ;
IntegerLiteral		    : INT_LIT
			    ;
FloatingPointLiteral	    : FLT_LIT
			    ;

/* Types */
Type			    : PrimitiveType
			    | ReferenceType
			    ;
PrimitiveType		    : NumericType
			    | BOOLEAN
			    ;
NumericType		    : IntegralType
			    | FloatingPointType
			    ;
IntegralType		    : BYTE | SHORT | INT | LONG | CHAR
			    ;
FloatingPointType	    : FLOAT | DOUBLE
			    ;
ReferenceType		    : ClassOrInterfaceType
			    | ArrayType			{ sprintf($$, "%s[]", $1); }
			    ;
ClassOrInterfaceType	    : Name
			    ;
ClassType		    : ClassOrInterfaceType
			    ;
InterfaceType		    : ClassOrInterfaceType
			    ;
ArrayType		    : PrimitiveType '[' ']'
			    | Name '[' ']'
			    | ArrayType '[' ']'
			    ;

/* Names */
Name			    : SimpleName
			    | QualifiedName
			    ;
SimpleName		    : Identifier
			    ;
QualifiedName		    : Name '.' Identifier

/* Packages */
CompilationUnit		    : PackageDeclarationOpt ImportDeclarationsOpt TypeDeclarationsOpt
			    ;
ImportDeclarations	    : ImportDeclaration
			    | ImportDeclarations ImportDeclaration
			    ;
TypeDeclarations	    : TypeDeclaration
			    | TypeDeclarations TypeDeclaration
PackageDeclaration	    : PACKAGE Name ';'
			    ;
ImportDeclaration	    : SingleTypeImportDeclaration
			    | TypeImportOnDemandDeclaration
			    ;
SingleTypeImportDeclaration : IMPORT Name ';'
			    ;
TypeImportOnDemandDeclaration: IMPORT Name '.' '*' ';'
			    ;
TypeDeclaration		    : ClassDeclaration
			    | InterfaceDeclaration
			    | ';'
			    ;

/* Modifiers */
Modifiers		    : Modifier
			    | Modifiers Modifier
			    ;
Modifier		    : PUBLIC | PROTECTED | PRIVATE	| STATIC    | ABSTRACT 
			    | FINAL  | NATIVE	 | SYNCHRONIZED | TRANSIENT | VOLATILE
			    ;

/* Class Declaration */
ClassDeclaration	    : ModifiersOpt CLASS Identifier SuperOpt InterfacesOpt ClassBody
			    ;
Super			    : EXTENDS ClassType
			    ;
Interfaces		    : IMPLEMENTS InterfaceTypeList
			    ;
InterfaceTypeList	    : InterfaceType
			    | InterfaceTypeList ',' InterfaceType
			    ;
ClassBody		    : '{' ClassBodyDeclarationsOpt '}'
			    ;
ClassBodyDeclarations	    : ClassBodyDeclaration
			    | ClassBodyDeclarations ClassBodyDeclaration
			    ;
ClassBodyDeclaration	    : ClassMemberDeclaration
			    | StaticInitializer
			    | ConstructorDeclaration
			    ;
ClassMemberDeclaration	    : FieldDeclaration
			    | MethodDeclaration
			    ;

/* Field Declarations */
FieldDeclaration	    : ModifiersOpt Type VariableDeclarators ';'	    
			    {
				char* brk1;
				char* variableDeclarator = strtok_r($3, "\r", &brk1);
				while (variableDeclarator != NULL) {
				    char* brk2;
				    Node n = {
					strtok_r(variableDeclarator, "\n", &brk2), 
					strtok_r(NULL, "\n", &brk2), 
					$2, 
					0, 
					NULL 
				    }; 
				    insert(getScope(level), &n); 
				    variableDeclarator = strtok_r(NULL, "\r", &brk1);
				}
			    }    
VariableDeclarators	    : VariableDeclarator			    /* use \r and \n as delimiter */
			    | VariableDeclarators ',' VariableDeclarator    { sprintf($$, "%s\r%s", $1, $3); }
			    ;
VariableDeclarator	    : VariableDeclaratorId			    { sprintf($$, "%s\n%s", $1," "); }
			    | VariableDeclaratorId ASS VariableInitializer  { sprintf($$, "%s\n%s", $1, $3); }
			    ;
VariableDeclaratorId	    : Identifier
			    | VariableDeclaratorId '[' ']'
			    ;
VariableInitializer	    : Expression
			    | ArrayInitializer
			    ;

/* Method Declarations */
MethodDeclaration	    : MethodHeader MethodBody
			    ;
MethodHeader		    : ModifiersOpt Type MethodDeclarator ThrowsOpt
			    {
				char *key, *type; 
				key = strtok($3, "\n"); 
				asprintf(&type, "%s%s", $2, strtok(NULL, "\n")); 
				Node n = { key, "", type, 0, NULL }; 
				insert(getScope(level), &n); 
			    }
			    | ModifiersOpt VOID MethodDeclarator ThrowsOpt
			    {
				char *key, *type; 
				key = strtok($3, "\n"); 
				asprintf(&type, "%s%s", $2, strtok(NULL, "\n")); 
				Node n = { key, "", type, 0, NULL }; 
				insert(getScope(level), &n); 
			    }
			    ;
MethodDeclarator	    : Identifier '(' FormalParameterListOpt ')'	    { sprintf($$, "%s\n(%s)"  , $1, $3); }
			    | MethodDeclarator '[' ']'			    { sprintf($$, "%s\n(%s)[]", $1, $3); }
			    ;
FormalParameterList	    : FormalParameter
			    | FormalParameterList ',' FormalParameter	    { sprintf($$, "%s, %s", $1,  $3); }
			    ;
FormalParameter		    : Type VariableDeclaratorId
			    ;
Throws			    : THROWS ClassTypeList
			    ;
ClassTypeList		    : ClassType
			    | ClassTypeList ',' ClassType
			    ;
MethodBody		    : Block
			    | ';'
			    ;

/* Static Initializers */
StaticInitializer	    : STATIC Block
			    ;

/* Constructor Declarations */
ConstructorDeclaration	    : ModifiersOpt ConstructorDeclarator ThrowsOpt ConstructorBody
			    ;
ConstructorDeclarator	    : SimpleName '(' FormalParameterListOpt ')'
			    ;
ConstructorBody		    : '{' ExplicitConstructorInvocationOpt BlockStatementsOpt '}'
			    ;
ExplicitConstructorInvocation: THIS '(' ArgumentListOpt ')' ';'
			    | SUPER '(' ArgumentListOpt ')' ';'

/* Interface Declaration */
InterfaceDeclaration	    : ModifiersOpt INTERFACE Identifier ExtendsInterfacesOpt InterfaceBody
			    ;
ExtendsInterfaces	    : EXTENDS InterfaceType
			    | ExtendsInterfaces ',' InterfaceType
			    ;
InterfaceBody		    : '{' InterfaceMemberDeclarationsOpt '}'
			    ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration
			    | InterfaceMemberDeclarations InterfaceMemberDeclaration
			    ;
InterfaceMemberDeclaration  : ConstantDeclaration
			    | AbstractMethodDeclaration
			    ;
ConstantDeclaration	    : FieldDeclaration
			    ;
AbstractMethodDeclaration   : MethodHeader ';'
			    ;

/* Arrays */
ArrayInitializer	    : '{' VariableInitializersOpt ',' '}'
			    | '{' VariableInitializersOpt '}'
			    ;
VariableInitializers	    : VariableInitializer
			    | VariableInitializers ',' VariableInitializer
			    ;

/* Blocks and Statements */
Block			    : '{' BlockStatementsOpt '}'
			    ;
BlockStatements		    : BlockStatement
			    | BlockStatements BlockStatement
			    ;
BlockStatement		    : LocalVariableDeclarationStatement
			    | Statement
			    ;
LocalVariableDeclarationStatement: LocalVariableDeclaration ';'
			    ;
LocalVariableDeclaration    : Type VariableDeclarators
			    ;
Statement		    : StatementWithoutTrailingSubstatement
			    | LabeledStatement
			    | IfThenStatement
			    | IfThenElseStatement
			    | WhileStatement
			    | ForStatement
			    | error ';' { yyerrok; }
			    ;
StatementNoShortIf	    : StatementWithoutTrailingSubstatement
			    | LabeledStatementNoShortIf
			    | IfThenElseStatementNoShortIf
			    | WhileStatementNoShortIf
			    | ForStatementNoShortIf
			    ;
StatementWithoutTrailingSubstatement: Block
			    | EmptyStatement
			    | ExpressionStatement
			    | SwitchStatement
			    | DoStatement
			    | BreakStatement
			    | ContinueStatement
			    | ReturnStatement
			    | SynchronizedStatement
			    | ThrowStatement
			    | TryStatement
			    ;
EmptyStatement		    : ';'
			    ;
LabeledStatement	    : Identifier ':' Statement
			    ;
LabeledStatementNoShortIf   : Identifier ':' StatementNoShortIf
			    ;
ExpressionStatement	    : StatementExpression ';'
			    ;
StatementExpression	    : Assignment
			    | PreIncrementExpression
			    | PreDecrementExpression
			    | PostIncrementExpression
			    | PostDecrementExpression
			    | MethodInvocation
			    | ClassInstanceCreationExpression
			    ;
IfThenStatement		    : IF '(' Expression ')' Statement
			    ;
IfThenElseStatement	    : IF '(' Expression ')' StatementNoShortIf ELSE Statement
			    ;
IfThenElseStatementNoShortIf: IF '(' Expression ')' StatementNoShortIf ELSE StatementNoShortIf
			    ;
SwitchStatement		    : SWITCH '(' Expression ')' SwitchBlock
			    ;
SwitchBlock		    : '{' SwitchBlockStatementGroupsOpt SwitchLabelsOpt '}'
			    ;
SwitchBlockStatementGroups  : SwitchBlockStatementGroup
			    | SwitchBlockStatementGroups SwitchBlockStatementGroup
			    ;
SwitchBlockStatementGroup   : SwitchLabels BlockStatements
			    ;
SwitchLabels		    : SwitchLabel
			    | SwitchLabels SwitchLabel
			    ;
SwitchLabel		    :
			    | CASE ConstantExpression ':'
			    | DEFAULT ':'
			    ;
WhileStatement		    : WHILE '(' Expression ')' Statement
			    ;
WhileStatementNoShortIf	    : WHILE '(' Expression ')' StatementNoShortIf
			    ;
DoStatement		    : DO Statement WHILE '(' Expression ')' ';'
			    ;
ForStatement		    : FOR '(' ForInitOpt ';' ExpressionOpt ';' ForUpdateOpt ')' Statement
			    ;
ForStatementNoShortIf	    : FOR '(' ForInitOpt ';' ExpressionOpt ';' ForUpdateOpt ')' StatementNoShortIf
			    ;
ForInit			    : StatementExpressionList
			    | LocalVariableDeclaration
			    ;
ForUpdate		    : StatementExpressionList
			    ;
StatementExpressionList	    : StatementExpression
			    | StatementExpressionList ',' StatementExpression
			    ;
BreakStatement		    : BREAK IdentifierOpt ';'
			    ;
ContinueStatement	    : CONTINUE IdentifierOpt ';'
			    ;
ReturnStatement		    : RETURN ExpressionOpt ';'
			    ;
ThrowStatement		    : THROW Expression ';'
			    ;
SynchronizedStatement	    : SYNCHRONIZED '(' Expression ')' Block
			    ;
TryStatement		    : TRY Block Catches
			    | TRY Block CatchesOpt Finally
			    ;
Catches			    : CatchClause
			    | Catches CatchClause
			    ;
CatchClause		    : CATCH '(' FormalParameter ')' Block
			    ;
Finally			    : FINALLY Block
			    ;

/* Expressions */
Primary			    : PrimaryNoNewArray
			    | ArrayCreationExpression
			    ;
PrimaryNoNewArray	    : Literal
			    | THIS
			    | '(' Expression ')'
			    | ClassInstanceCreationExpression
			    | FieldAccess
			    | MethodInvocation
			    | ArrayAccess
			    ;
ClassInstanceCreationExpression: NEW ClassType '(' ArgumentListOpt ')'
			    ;
ArgumentList		    : Expression
			    | ArgumentList ',' Expression
			    ;
ArrayCreationExpression	    : NEW PrimitiveType DimExprs DimsOpt
			    | NEW ClassOrInterfaceType DimExprs DimsOpt
			    ;
DimExprs		    : DimExpr
			    | DimExprs DimExpr
			    ;
DimExpr			    : '[' Expression ']'
			    ;
Dims			    : '[' ']'
			    | Dims '[' ']'
			    ;
FieldAccess		    : Primary '.' Identifier
			    | SUPER '.' Identifier
MethodInvocation	    : Name '(' ArgumentListOpt ')'
			    | Primary '.' Identifier '(' ArgumentListOpt ')'
			    | SUPER '.' Identifier '(' ArgumentListOpt ')'
			    ;
ArrayAccess		    : Name '[' Expression ']'
			    | PrimaryNoNewArray '[' Expression ']'
			    ;
PostfixExpression	    : Primary
			    | Name
			    | PostIncrementExpression
			    | PostDecrementExpression
			    ;
PostIncrementExpression	    : PostfixExpression INC %prec POST
			    ;
PostDecrementExpression	    : PostfixExpression DEC %prec POST
			    ;
UnaryExpression		    : PreIncrementExpression
			    | PreDecrementExpression
			    | '+' UnaryExpression %prec UMINUS
			    | '-' UnaryExpression %prec UMINUS
			    | UnaryExpressionNotPlusMinus
			    ;
PreIncrementExpression	    : INC UnaryExpression %prec PRE
			    ;
PreDecrementExpression	    : DEC UnaryExpression %prec PRE
			    ;
UnaryExpressionNotPlusMinus : PostfixExpression
			    | '~' UnaryExpression
			    | NOT UnaryExpression
			    | CastExpression
			    ;
CastExpression		    : '(' PrimitiveType DimsOpt ')' UnaryExpression %prec CAST
			    | '(' Expression ')' UnaryExpressionNotPlusMinus %prec CAST
			    | '(' Name Dims ')' UnaryExpressionNotPlusMinus %prec CAST
			    ;
MultiplicativeExpression    : UnaryExpression
			    | MultiplicativeExpression '*' UnaryExpression
			    | MultiplicativeExpression '/' UnaryExpression
			    | MultiplicativeExpression '%' UnaryExpression
			    ;
AdditiveExpression	    : MultiplicativeExpression
			    | AdditiveExpression '+' MultiplicativeExpression
			    | AdditiveExpression '-' MultiplicativeExpression
			    ;
ShiftExpression		    : AdditiveExpression
			    | ShiftExpression LS AdditiveExpression
			    | ShiftExpression RS AdditiveExpression
			    | ShiftExpression URS AdditiveExpression
			    ;
RelationalExpression	    : ShiftExpression
			    | RelationalExpression LT ShiftExpression
			    | RelationalExpression GT ShiftExpression
			    | RelationalExpression LE ShiftExpression
			    | RelationalExpression GE ShiftExpression
			    | RelationalExpression INSTANCEOF ReferenceType
			    ;
EqualityExpression	    : RelationalExpression
			    | EqualityExpression EQ RelationalExpression
			    | EqualityExpression NE RelationalExpression
			    ;
AndExpression		    : EqualityExpression
			    | AndExpression '&' EqualityExpression
			    ;
ExclusiveOrExpression	    : AndExpression
			    | ExclusiveOrExpression '^' AndExpression
			    ;
InclusiveOrExpression	    : ExclusiveOrExpression
			    | InclusiveOrExpression '|' ExclusiveOrExpression
			    ;
ConditionalAndExpression    : InclusiveOrExpression
			    | ConditionalAndExpression AND InclusiveOrExpression
			    ;
ConditionalOrExpression	    : ConditionalAndExpression
			    | ConditionalOrExpression OR ConditionalAndExpression
			    ;
ConditionalExpression	    : ConditionalOrExpression
			    | ConditionalOrExpression '?' Expression ':' ConditionalExpression
			    | error ';' { yyerrok; }
			    ;
AssignmentExpression	    : ConditionalExpression
			    | Assignment
			    ;
Assignment		    : LeftHandSide AssignmentOperator AssignmentExpression
			    ;
LeftHandSide		    : Name
			    | FieldAccess
			    | ArrayAccess
			    ;
AssignmentOperator	    : ASS    | MUL_ASS | DIV_ASS | MOD_ASS | ADD_ASS | SUB_ASS 
			    | LS_ASS | RS_ASS  | URS_ASS | EMP_ASS | XOR_ASS | OR_ASS
			    ;
Expression		    : AssignmentExpression
			    ;
ConstantExpression	    : Expression
			    ;

/* Identifier */
Identifier		    : ID
			    ;

/* Optinals */
ArgumentListOpt : ArgumentList | /* empty */ ;
BlockStatementsOpt : BlockStatements | /* empty */ ;
CatchesOpt : Catches | /* empty */ ;
ClassBodyDeclarationsOpt : ClassBodyDeclarations | /* empty */ ;
DimsOpt : Dims | /* empty */ ;
ExplicitConstructorInvocationOpt : ExplicitConstructorInvocation | /* empty */ ;
ExpressionOpt : Expression | /* empty */ ;
ExtendsInterfacesOpt : ExtendsInterfaces | /* empty */ ;
ForInitOpt : ForInit | /* empty */ ;
ForUpdateOpt : ForUpdate | /* empty */ ;
FormalParameterListOpt : FormalParameterList | /* empty */ { $$ = ""; };
IdentifierOpt : Identifier | /* empty */ ;
ImportDeclarationsOpt : ImportDeclarations | /* empty */ ;
InterfaceMemberDeclarationsOpt : InterfaceMemberDeclarations | /* empty */ ;
InterfacesOpt : Interfaces | /* empty */ ;
ModifiersOpt : Modifiers | /* empty */ ;
PackageDeclarationOpt : PackageDeclaration | /* empty */ ;
SuperOpt : Super | /* empty */ ;
SwitchBlockStatementGroupsOpt : SwitchBlockStatementGroups | /* empty */ ;
SwitchLabelsOpt : SwitchLabels | /* empty */ ;
ThrowsOpt : Throws | /* empty */ ;
TypeDeclarationsOpt : TypeDeclarations | /* empty */ ;
VariableInitializersOpt : VariableInitializers | /* empty */ ;

%%

int main() {
    if (DEBUG)
	fprintf(stderr, "%6u  ", 1);
    yyparse();

    if (DEBUG)
	dump(stderr);
    /* free symbol table */
    destroy();
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
