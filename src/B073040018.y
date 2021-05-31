%{
    #include "SymbolTable/SymbolTable.h"
    #include <stdio.h>
    #define YYSTYPE char*
%}

%%



%%

#include "lex.yy.c"

int main() {
    yyparse();
    return 0;
}
