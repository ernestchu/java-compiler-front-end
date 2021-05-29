/*
 * Author: Ernie Chu
 * Filename: B073040018.l
 * Description: Lexical scanner for JAVA programming language in F(lex)
 * Reference:
 *     https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
 *     http://westes.github.io/flex/manual/index.html
 */

%{
    #include <stdio.h>
    #include <string.h>
    #include "SymbolTable.h"

    typedef char* string;
    unsigned num_chars = 1, num_ids = 0, num_lines = 1;

    void stamp(const string s);
    void stamp_comment(string s);
%}

SYMBOL      [,:;\(\)\[\]\{\}]
OPERATOR    \+\+|\-\-|<=|>=|==|!=|&&|\|\||[\+\-\*\/%=<>!]
RESERVED    boolean|break|byte|case|char|catch|class|const|continue|default|do|double|else|extends|false|final|finally|float|for|if|implements|int|long|main|new|print|private|protected|public|return|short|static|string|switch|this|true|try|void|while
ID          ([a-zA-Z_$])([a-zA-Z0-9_$])*
INV_ID      ([a-zA-Z0-9_$^#])+
SIGN        [\+\-]
DIGIT       [0-9]
UINT        {DIGIT}+
INT         {SIGN}?{UINT}
INV_FLOAT   \.
FLOAT       {INT}?\.{UINT}?([e|E]{INT})?[f|F|d|D]?
STR_CH      [^\"\\\n]|(\\[tbnrf\'\"\\])
STRING      \"{STR_CH}*\"
INV_STR     [\"\']{STR_CH}*[\'\n]
COMMENT     (\/\/.*\n)|(\/\*([^\*]|\*+[^\*\/])*\*+\/)
SPACE       [ \t]
EOL         \n

%%

{SYMBOL}    stamp("a  Symbol");
{OPERATOR}  stamp("an Operator");
{RESERVED}  stamp("a  Reserved words");
{ID}        stamp("an ID");
{INT}       stamp("an Integer");
{INV_FLOAT} stamp("an invalid Float");
{FLOAT}     stamp("a  Float");
{STRING}    stamp("a  String");
{INV_STR}   stamp_comment("an invalid String");
{COMMENT}   stamp_comment("a Comment");
{SPACE}     num_chars++;
{EOL}       num_chars=1; num_lines++;
{INV_ID}    stamp("an invalid ID");
. {
            printf("%3d:%-3d", num_lines, num_chars);
            printf(" Redundant character `%s`\n", yytext);
            num_chars += yyleng;
}

%%

int main() {
    if (create()==-1) perror("malloc");
    yylex();
    dump();
    destroy();
    return 0;
}

void stamp(const string s) {
    string ticked = (string) malloc(strlen(yytext)+5);
    sprintf(ticked, "`%s`", yytext);
    printf("%3d:%-3d", num_lines, num_chars);
    printf(" %-10s is %s\n", ticked, s);
    num_chars += yyleng;
    free(ticked);
    if (!strcmp("an ID", s))
        insert(yytext);
}

void stamp_comment(string s) {
    string ticked = (string) malloc(strlen(yytext)+5);
    sprintf(ticked, "`%s`", yytext);
    unsigned int len, i, contain_eol=0;
    printf("%3d:%-3d", num_lines, num_chars);
    for (len=0, i=1; ticked[i+1]; len++, i++) {
        if (ticked[i]=='\n') {
            num_lines++;
            len=0;
            ticked[i]=' ';
            contain_eol = 1;
        }
    }
    printf(" %-10s is %s\n", ticked, s);
    if (!contain_eol)
        num_chars += yyleng;
    else
        num_chars = len;
    free(ticked);
}
