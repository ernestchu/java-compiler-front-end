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
    
    typedef struct levelStack {
	int level;
	struct levelStack* next;
    } LevelStack;

    int yydebug = !!DEBUG;
    int levelCounter = 0; /* scope level, only increment */
    int currentLevel = 0; /* jump back and forth as entering or leaving blocks */
    LevelStack* levelHead = NULL;
    
    extern unsigned num_chars, num_lines;
    void yyerror(const char* s);

    void pushLevel(const int level);
    int	 popLevel(void);
    void destroyLevel(void);
    void methodHeaderInserter(char* two, char* three);

    void enterBlock(void);
    void leaveBlock(void);


    void redefinitionError(const char* id);
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
CompilationUnit		    : PackageDeclaration ImportDeclarations TypeDeclarations
			    | ImportDeclarations TypeDeclarations
			    | PackageDeclaration TypeDeclarations
			    | TypeDeclarations
			    | PackageDeclaration ImportDeclarations
			    | ImportDeclarations
			    | PackageDeclaration
			    | /* empty */
			    ;
ImportDeclarations	    : ImportDeclaration
			    | ImportDeclarations ImportDeclaration
			    ;
TypeDeclarations	    : TypeDeclaration
			    | TypeDeclarations TypeDeclaration
			    ;
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
			    ;

/* Modifiers */
Modifiers		    : Modifier
			    | Modifiers Modifier
			    ;
Modifier		    : PUBLIC | PROTECTED | PRIVATE	| STATIC    | ABSTRACT 
			    | FINAL  | NATIVE	 | SYNCHRONIZED | TRANSIENT | VOLATILE
			    ;

/* Class Declaration */
ClassDeclaration	    : Modifiers CLASS Identifier Super Interfaces ClassBody
			    { Node n  = { strdup($3), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | CLASS Identifier Super Interfaces ClassBody
			    { Node n  = { strdup($2), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | Modifiers CLASS Identifier Interfaces ClassBody
			    { Node n  = { strdup($3), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | CLASS Identifier Interfaces ClassBody
			    { Node n  = { strdup($2), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | Modifiers CLASS Identifier Super ClassBody
			    { Node n  = { strdup($3), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | CLASS Identifier Super ClassBody
			    { Node n  = { strdup($2), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | Modifiers CLASS Identifier ClassBody
			    { Node n  = { strdup($3), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | CLASS Identifier ClassBody
			    { Node n  = { strdup($2), "", "class", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    ;
Super			    : EXTENDS ClassType
			    ;
Interfaces		    : IMPLEMENTS InterfaceTypeList
			    ;
InterfaceTypeList	    : InterfaceType
			    | InterfaceTypeList ',' InterfaceType
			    ;
ClassBody		    : '{' { enterBlock(); } ClassBodyDeclarations { leaveBlock(); } '}'
			    | '{' '}'
			    ;
ClassBodyDeclarations	    : ClassBodyDeclaration
			    | ClassBodyDeclarations ClassBodyDeclaration
			    ;
ClassBodyDeclaration	    : ClassMemberDeclaration
			    | StaticInitializer
			    | ConstructorDeclaration
			    | TypeDeclaration
			    ;
ClassMemberDeclaration	    : FieldDeclaration
			    | MethodDeclaration
			    ;

/* Field Declarations */
FieldDeclaration	    : Modifiers Type VariableDeclarators ';'	    
			    {
				char* brk1;
				char* variableDeclarator = strtok_r($3, "\r", &brk1);
				while (variableDeclarator != NULL) {
				    char* brk2;
				    Node n = {
					strdup(strtok_r(variableDeclarator, "\n", &brk2)),
					strdup(strtok_r(NULL, "\n", &brk2)),
					strdup($2), 
					0, 
					NULL 
				    }; 
				    void* p = insert(getScope(currentLevel), &n); 
				    if (!p) redefinitionError(n.key);
				    free(n.key); free(n.value); free(n.type);
				    variableDeclarator = strtok_r(NULL, "\r", &brk1);
				}
			    }    
			    | Type VariableDeclarators ';'
			    {
				char* brk1;
				char* variableDeclarator = strtok_r($2, "\r", &brk1);
				while (variableDeclarator != NULL) {
				    char* brk2;
				    Node n = {
					strdup(strtok_r(variableDeclarator, "\n", &brk2)),
					strdup(strtok_r(NULL, "\n", &brk2)),
					strdup($1), 
					0, 
					NULL 
				    }; 
				    void* p = insert(getScope(currentLevel), &n); 
				    if (!p) redefinitionError(n.key);
				    free(n.key); free(n.value); free(n.type);
				    variableDeclarator = strtok_r(NULL, "\r", &brk1);
				}
			    }    
			    | Modifiers Type error ';'
			    | Type error ';'
			    ;
VariableDeclarators	    : VariableDeclarator			    /* use \r and \n as delimiter */
			    | VariableDeclarators ',' VariableDeclarator    { sprintf($$, "%s\r%s", $1, $3); }
			    ;
VariableDeclarator	    : VariableDeclaratorId			    { sprintf($$, "%s\n%s", $1," "); }
			    | VariableDeclaratorId ASS VariableInitializer  { sprintf($$, "%s\n%s", $1, $3); }
			    ;
VariableDeclaratorId	    : Identifier
			    | VariableDeclaratorId '[' ']'		    { sprintf($$, "%s[]", $1); }
			    ;
VariableInitializer	    : Expression
			    | ArrayInitializer
			    ;

/* Method Declarations */
MethodDeclaration	    : MethodHeader MethodBody
			    ;
MethodHeader		    : Modifiers Type MethodDeclarator Throws	    { methodHeaderInserter($2, $3); }
			    | Type MethodDeclarator Throws		    { methodHeaderInserter($1, $2); } 
			    | Modifiers Type MethodDeclarator		    { methodHeaderInserter($2, $3); }
			    | Type MethodDeclarator			    { methodHeaderInserter($1, $2); }
			    | Modifiers VOID MethodDeclarator Throws	    { methodHeaderInserter($2, $3); }
			    | VOID MethodDeclarator Throws		    { methodHeaderInserter($1, $2); }
			    | Modifiers VOID MethodDeclarator		    { methodHeaderInserter($2, $3); }
			    | VOID MethodDeclarator			    { methodHeaderInserter($1, $2); }
			    ;
MethodDeclarator	    : Identifier '(' FormalParameterList ')'	    { sprintf($$, "%s\n(%s)", $1, $3); }
			    | Identifier '('  ')'			    { sprintf($$, "%s\n()", $1); }
			    | MethodDeclarator '[' ']'			    { sprintf($$, "%s[]", $1); }
			    ;
FormalParameterList	    : FormalParameter
			    | FormalParameterList ',' FormalParameter	    { sprintf($$, "%s, %s", $1,  $3); }
			    ;
FormalParameter		    : Type VariableDeclaratorId
			    {
				Node n = { strdup($2), "", strdup($1), 0, NULL }; 
				void* p = insert(getScope(currentLevel), &n); 
				if (!p) redefinitionError(n.key);
				free(n.key); free(n.type);
			    }
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
ConstructorDeclaration	    : Modifiers ConstructorDeclarator Throws ConstructorBody 
			    | ConstructorDeclarator Throws ConstructorBody 
			    | Modifiers ConstructorDeclarator ConstructorBody 
			    | ConstructorDeclarator ConstructorBody 
			    ;
ConstructorDeclarator	    : SimpleName '(' FormalParameterList ')'
			    | SimpleName '('  ')'
			    ;
ConstructorBody		    : '{' { enterBlock(); } ExplicitConstructorInvocation BlockStatements { leaveBlock(); } '}'
			    | '{' '}'
			    ;
ExplicitConstructorInvocation: THIS '(' ArgumentList ')' ';'
			    |  THIS '(' ')' ';'
			    | SUPER '(' ArgumentList ')' ';'
			    | SUPER '(' ')' ';'
			    ;

/* Interface Declaration */
InterfaceDeclaration	    : Modifiers INTERFACE Identifier ExtendsInterfaces InterfaceBody
			    { Node n = { strdup($3), "", "interface", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | INTERFACE Identifier ExtendsInterfaces InterfaceBody
			    { Node n = { strdup($2), "", "interface", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | Modifiers INTERFACE Identifier InterfaceBody
			    { Node n = { strdup($3), "", "interface", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    | INTERFACE Identifier InterfaceBody
			    { Node n = { strdup($2), "", "interface", 0, NULL }; void* p = insert(getScope(currentLevel), &n); if (!p) redefinitionError(n.key); free(n.key); }
			    ;
ExtendsInterfaces	    : EXTENDS InterfaceType
			    | ExtendsInterfaces ',' InterfaceType
			    ;
InterfaceBody		    : '{' { enterBlock(); } InterfaceMemberDeclarations { leaveBlock(); } '}'
			    | '{' '}'
			    ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration
			    | InterfaceMemberDeclarations InterfaceMemberDeclaration
			    ;
InterfaceMemberDeclaration  : ConstantDeclaration
			    | AbstractMethodDeclaration
			    | TypeDeclaration
			    ;
ConstantDeclaration	    : FieldDeclaration
			    ;
AbstractMethodDeclaration   : MethodHeader ';'
			    ;

/* Arrays */
ArrayInitializer	    : '{' VariableInitializers ',' '}'
			    | '{' ',' '}'
			    | '{' VariableInitializers '}'
			    | '{' '}'
			    ;
VariableInitializers	    : VariableInitializer
			    | VariableInitializers ',' VariableInitializer
			    ;

/* Blocks and Statements */
Block			    : '{' { enterBlock(); } BlockStatements { leaveBlock(); } '}'
			    | '{' '}'
			    | '{' error '}'
			    ;
BlockStatements		    : BlockStatement
			    | BlockStatements BlockStatement
			    ;
BlockStatement		    : LocalVariableDeclarationStatement
			    | Statement
			    | TypeDeclaration
			    ;
LocalVariableDeclarationStatement: LocalVariableDeclaration ';'
			    ;
LocalVariableDeclaration    : Type VariableDeclarators
			    {
				char* brk1;
				char* variableDeclarator = strtok_r($2, "\r", &brk1);
				while (variableDeclarator != NULL) {
				    char* brk2;
				    Node n = {
					strdup(strtok_r(variableDeclarator, "\n", &brk2)), 
					strdup(strtok_r(NULL, "\n", &brk2)), 
					strdup($1), 
					0, 
					NULL 
				    }; 
				    void* p = insert(getScope(currentLevel), &n); 
				    if (!p) redefinitionError(n.key);
				    variableDeclarator = strtok_r(NULL, "\r", &brk1);
				    free(n.key); free(n.value); free(n.type);
				}
			    }    
			    ;
Statement		    : StatementWithoutTrailingSubstatement
			    | LabeledStatement
			    | IfThenStatement
			    | IfThenElseStatement
			    | WhileStatement
			    | ForStatement
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
SwitchBlock		    : '{' SwitchBlockStatementGroups SwitchLabels '}' 
			    | '{' SwitchLabels '}' 
			    | '{' SwitchBlockStatementGroups '}' 
			    | '{' '}' 
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
			    : WHILE '(' error	   ')' Statement 
			    ;
WhileStatementNoShortIf	    : WHILE '(' Expression ')' StatementNoShortIf
			    ;
DoStatement		    : DO Statement WHILE '(' Expression ')' ';'
			    ;
ForStatement		    : FOR '(' ForInit ';' Expression ';' ForUpdate ')' Statement 
			    | FOR '(' ';' Expression ';' ForUpdate ')' Statement 
			    | FOR '(' ForInit ';' ';' ForUpdate ')' Statement 
			    | FOR '(' ';' ';' ForUpdate ')' Statement 
			    | FOR '(' ForInit ';' Expression ';' ')' Statement 
			    | FOR '(' ';' Expression ';' ')' Statement 
			    | FOR '(' ForInit ';' ';' ')' Statement 
			    | FOR '(' ';' ';' ')' Statement 
			    ;
ForStatementNoShortIf	    : FOR '(' ForInit ';' Expression ';' ForUpdate ')' StatementNoShortIf 
			    | FOR '(' ';' Expression ';' ForUpdate ')' StatementNoShortIf 
			    | FOR '(' ForInit ';' ';' ForUpdate ')' StatementNoShortIf 
			    | FOR '(' ';' ';' ForUpdate ')' StatementNoShortIf 
			    | FOR '(' ForInit ';' Expression ';' ')' StatementNoShortIf 
			    | FOR '(' ';' Expression ';' ')' StatementNoShortIf 
			    | FOR '(' ForInit ';' ';' ')' StatementNoShortIf 
			    | FOR '(' ';' ';' ')' StatementNoShortIf
			    ;
ForInit			    : StatementExpressionList
			    | LocalVariableDeclaration
			    ;
ForUpdate		    : StatementExpressionList
			    ;
StatementExpressionList	    : StatementExpression
			    | StatementExpressionList ',' StatementExpression
			    ;
BreakStatement		    : BREAK Identifier ';'
			    | BREAK ';'
			    ;
ContinueStatement	    : CONTINUE Identifier ';'
			    | CONTINUE ';'
			    ;
ReturnStatement		    : RETURN Expression ';'
			    | RETURN ';'
			    ;
ThrowStatement		    : THROW Expression ';'
			    ;
SynchronizedStatement	    : SYNCHRONIZED '(' Expression ')' Block
			    ;
TryStatement		    : TRY Block Catches
			    | TRY Block Catches Finally
			    | TRY Block Finally
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
ClassInstanceCreationExpression: NEW ClassType '(' ArgumentList ')'
			    | NEW ClassType '(' ')'
			    ;
ArgumentList		    : Expression
			    | ArgumentList ',' Expression
			    ;
ArrayCreationExpression	    : NEW PrimitiveType DimExprs Dims
			    | NEW PrimitiveType DimExprs
			    | NEW ClassOrInterfaceType DimExprs Dims
			    | NEW ClassOrInterfaceType DimExprs
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
			    ;
MethodInvocation	    : Name '(' ArgumentList ')'
			    | Name '(' ')'
			    | Primary '.' Identifier '(' ArgumentList ')'
			    | Primary '.' Identifier '(' ')'
			    | SUPER '.' Identifier '(' ArgumentList ')'
			    | SUPER '.' Identifier '(' ')'
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
CastExpression		    : '(' PrimitiveType Dims ')' UnaryExpression %prec CAST
			    | '(' PrimitiveType ')' UnaryExpression %prec CAST
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

%%

int main() {
    if (DEBUG)
	fprintf(stderr, "%6u  ", 1);
    yyparse();

    if (DEBUG)
	dump(stderr);
    /* free symbol table */
    destroy();
    /* free level stack */
    destroyLevel();
    return 0;
}

void yyerror(const char* s) {
    char* nonconstS = strdup(s);
    char* err = strtok(nonconstS, "\n");
    char* id  = strtok(NULL, "\n");

    fprintf(stderr, "\033[1m");
    fprintf(stderr, "\n%6u:%u: ", num_lines, num_chars);
    fprintf(stderr, "\033[0;31m");
    fprintf(stderr, "\033[1m");
    fprintf(stderr, "%s: ", err);
    fprintf(stderr, "\033[0m");
    fprintf(stderr, "\033[1m");
    if (id)
	fprintf(stderr, "%s", id);
    else
	fprintf(stderr, "`%s`", yytext);
    fprintf(stderr, "\033[22m");
    free(nonconstS);
};

void pushLevel(const int level) {
    if (levelHead) {
	LevelStack* temp = (LevelStack*)malloc(sizeof(LevelStack));
	temp->level = level;
	temp->next  = levelHead;
	levelHead   = temp;
	return;
    }
    levelHead = (LevelStack*)malloc(sizeof(LevelStack));
    levelHead->level = level;
    levelHead->next  = NULL;
}

int popLevel(void) {
    if (!levelHead) {
	fprintf(stderr, "Try to pop from a empty stack.\n");
	exit(1);
    }
    LevelStack* temp = levelHead;
    levelHead = levelHead->next;
    int level = temp->level;
    free(temp);
    return level;
}

void destroyLevel(void) {
    while(levelHead)
	popLevel();
}

void enterBlock(void) { 
    pushLevel(currentLevel);
    currentLevel = ++levelCounter;
} 

void leaveBlock(void) { 
    currentLevel = popLevel(); 
} 

void methodHeaderInserter(char* two, char* three) {
    Node n = {
	strdup(strtok(three, "\n")), 
	"", 
	strdup(strcat(two, strtok(NULL, "\n"))), 
	0, 
	NULL 
    }; 
    void* p = insert(getScope(currentLevel), &n); 
    if (!p) redefinitionError(n.key);
    free(n.key); free(n.type);
}

void redefinitionError(const char* id) {
    char buf[100];
    sprintf(buf, "semantic error\nredefinition of `%s`", id);
    yyerror(buf);
}
