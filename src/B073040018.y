/*
 * Author: Ernie Chu
 * Filename: B073040018.y
 * Description: Syntatic & semantic parser for JAVA programming language
 * Reference:
 *      https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
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


%token ABSTRACT BOOLEAN BREAK BYTE CASE CATCH CHAR CLASS CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTENDS FINAL FINALLY FLOAT FOR GOTO IF IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE LONG NATIVE NEW PACAKAGE PRIVATE PROTECTED PUBLIC RETURN SHORT STATIC SUPER SWITCH SYNCHRONIZED THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LS_ASS RS_ASS URS_ASS EMP_ASS XOR_ASS OR_ASS LS RS URS EQ ASS NE LE GE LT GT AND OR NOT INC DEC BOOL_LIT NULL_LIT INT_SUF FLT_SUF HEX_INDI EXP_INDI ID SING_CH_WO_SP ESC

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

/* Token */
single_character    : SING_CH_WO_SP
		    | ESC
		    ;
%%

int main() {
    yyparse();
    return 0;
}

void yyerror() {
    printf("syntax error at line %d\n", num_lines+1);
};
