/*
 * Author: Ernie Chu
 * Filename: B073040018.l
 * Description: Lexical scanner for JAVA programming language
 * Reference:
 *      https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
 *      http://db.cse.nsysu.edu.tw/~changyi/slides/compiler/lab/Java.doc
 */

%{
    #define YYSTYPE char*
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    unsigned num_chars = 1, num_lines = 1;
%}

boolean_literal		true|false
null_literal		null
integer_type_suffix	[lL]
float_type_suffix	[fFdD]
hex_indicator		[xX]
exponent_indicator	[eE]
identifier		([a-zA-Z_$])([a-zA-Z0-9_$])*
single_character_wo_sp	[^\"\\\n \t]
escape_sequence		\\[tbnrf\'\"\\]
comment			(\/\/.*\n)|(\/\*([^\*]|\*+[^\*\/])*\*+\/)
space			[ \t]
EOL			\n

%%


abstract	{ /* keyward */
                  yylval=strdup(yytext); num_chars+=yyleng; return ABSTRACT;     }
boolean		{ yylval=strdup(yytext); num_chars+=yyleng; return BOOLEAN;      }
break		{ yylval=strdup(yytext); num_chars+=yyleng; return BREAK;        }
byte		{ yylval=strdup(yytext); num_chars+=yyleng; return BYTE;         }
case		{ yylval=strdup(yytext); num_chars+=yyleng; return CASE;         }
catch		{ yylval=strdup(yytext); num_chars+=yyleng; return CATCH;        }
char		{ yylval=strdup(yytext); num_chars+=yyleng; return CHAR;         }
class		{ yylval=strdup(yytext); num_chars+=yyleng; return CLASS;        }
const		{ yylval=strdup(yytext); num_chars+=yyleng; return CONST;        }
continue	{ yylval=strdup(yytext); num_chars+=yyleng; return CONTINUE;     }
default		{ yylval=strdup(yytext); num_chars+=yyleng; return DEFAULT;      }
do		{ yylval=strdup(yytext); num_chars+=yyleng; return DO;           }
double		{ yylval=strdup(yytext); num_chars+=yyleng; return DOUBLE;       }
else		{ yylval=strdup(yytext); num_chars+=yyleng; return ELSE;         }
extends		{ yylval=strdup(yytext); num_chars+=yyleng; return EXTENDS;      }
final		{ yylval=strdup(yytext); num_chars+=yyleng; return FINAL;        }
finally		{ yylval=strdup(yytext); num_chars+=yyleng; return FINALLY;      }
float		{ yylval=strdup(yytext); num_chars+=yyleng; return FLOAT;        }
for		{ yylval=strdup(yytext); num_chars+=yyleng; return FOR;          }
goto		{ yylval=strdup(yytext); num_chars+=yyleng; return GOTO;         }
if		{ yylval=strdup(yytext); num_chars+=yyleng; return IF;           }
implements	{ yylval=strdup(yytext); num_chars+=yyleng; return IMPLEMENTS;   }
import		{ yylval=strdup(yytext); num_chars+=yyleng; return IMPORT;       }
instanceof	{ yylval=strdup(yytext); num_chars+=yyleng; return INSTANCEOF;   }
int		{ yylval=strdup(yytext); num_chars+=yyleng; return INT;          }
interface	{ yylval=strdup(yytext); num_chars+=yyleng; return INTERFACE;    }
long		{ yylval=strdup(yytext); num_chars+=yyleng; return LONG;         }
native		{ yylval=strdup(yytext); num_chars+=yyleng; return NATIVE;       }
new		{ yylval=strdup(yytext); num_chars+=yyleng; return NEW;          }
pacakage	{ yylval=strdup(yytext); num_chars+=yyleng; return PACAKAGE;     }
private		{ yylval=strdup(yytext); num_chars+=yyleng; return PRIVATE;      }
protected	{ yylval=strdup(yytext); num_chars+=yyleng; return PROTECTED;    }
public		{ yylval=strdup(yytext); num_chars+=yyleng; return PUBLIC;       }
return		{ yylval=strdup(yytext); num_chars+=yyleng; return RETURN;       }
short		{ yylval=strdup(yytext); num_chars+=yyleng; return SHORT;        }
static		{ yylval=strdup(yytext); num_chars+=yyleng; return STATIC;       }
super		{ yylval=strdup(yytext); num_chars+=yyleng; return SUPER;        }
switch		{ yylval=strdup(yytext); num_chars+=yyleng; return SWITCH;       }
synchronized    { yylval=strdup(yytext); num_chars+=yyleng; return SYNCHRONIZED; }
this		{ yylval=strdup(yytext); num_chars+=yyleng; return THIS;         }
throw	    	{ yylval=strdup(yytext); num_chars+=yyleng; return THROW;        }
throws	    	{ yylval=strdup(yytext); num_chars+=yyleng; return THROWS;       }
transient	{ yylval=strdup(yytext); num_chars+=yyleng; return TRANSIENT;    }
try	        { yylval=strdup(yytext); num_chars+=yyleng; return TRY;          }
void	    	{ yylval=strdup(yytext); num_chars+=yyleng; return VOID;         }
volatile	{ yylval=strdup(yytext); num_chars+=yyleng; return VOLATILE;     }
while	    	{ yylval=strdup(yytext); num_chars+=yyleng; return WHILE;        }

"*="            { /* assignment operator */
                  yylval=strdup(yytext); num_chars+=yyleng; return MUL_ASS;	 }
"/="            { yylval=strdup(yytext); num_chars+=yyleng; return DIV_ASS;	 }
"%="            { yylval=strdup(yytext); num_chars+=yyleng; return MOD_ASS;	 }
"+="            { yylval=strdup(yytext); num_chars+=yyleng; return ADD_ASS;	 }
"-="            { yylval=strdup(yytext); num_chars+=yyleng; return SUB_ASS;	 }
"<<="           { yylval=strdup(yytext); num_chars+=yyleng; return LS_ASS;	 }
">>="           { yylval=strdup(yytext); num_chars+=yyleng; return RS_ASS;	 }
">>>="          { yylval=strdup(yytext); num_chars+=yyleng; return URS_ASS;	 }
"&="            { yylval=strdup(yytext); num_chars+=yyleng; return EMP_ASS;	 }
"^="            { yylval=strdup(yytext); num_chars+=yyleng; return XOR_ASS;	 }
"|="            { yylval=strdup(yytext); num_chars+=yyleng; return OR_ASS;	 }

"<<"            { /* shift */
                  yylval=strdup(yytext); num_chars+=yyleng; return LS;		 }
">>"            { yylval=strdup(yytext); num_chars+=yyleng; return RS;  	 }
">>>"           { yylval=strdup(yytext); num_chars+=yyleng; return URS; 	 }

"=="            { /* relational operator (noted for `=`, for the sack of the longest match rule) */
                  yylval=strdup(yytext); num_chars+=yyleng; return EQ;		 }
"="             { yylval=strdup(yytext); num_chars+=yyleng; return ASS; 	 }
"!="            { yylval=strdup(yytext); num_chars+=yyleng; return NE;  	 }
"<="            { yylval=strdup(yytext); num_chars+=yyleng; return LE;  	 }
">="            { yylval=strdup(yytext); num_chars+=yyleng; return GE;  	 }
"<"             { yylval=strdup(yytext); num_chars+=yyleng; return LT;  	 }
">"             { yylval=strdup(yytext); num_chars+=yyleng; return GT;  	 }

"&&"            { /* logical operator */
                  yylval=strdup(yytext); num_chars+=yyleng; return AND;		 }
"||"            { yylval=strdup(yytext); num_chars+=yyleng; return OR;  	 }
"!"             { yylval=strdup(yytext); num_chars+=yyleng; return NOT; 	 }

[&|^~*/%+\-?:.{}[\](),;]    { yylval=strdup(yytext); num_chars++; return *yytext;	      }
[0-9]			    { yylval=strdup(yytext); num_chars++; return *yytext; 	      }

{boolean_literal}	    { /* misc */
			      yylval=strdup(yytext); num_chars+=yyleng; return BOOL_LIT;      }
{null_literal}		    { yylval=strdup(yytext); num_chars+=yyleng; return NULL_LIT;      }
{integer_type_suffix}	    { yylval=strdup(yytext); num_chars+=yyleng; return INT_SUF;	      }
{float_type_suffix}	    { yylval=strdup(yytext); num_chars+=yyleng; return FLT_SUF;	      }
{hex_indicator}		    { yylval=strdup(yytext); num_chars+=yyleng; return HEX_INDI;      }
{exponent_indicator}	    { yylval=strdup(yytext); num_chars+=yyleng; return EXP_INDI;      }
{identifier}		    { yylval=strdup(yytext); num_chars+=yyleng; return ID;	      }
{single_character_wo_sp}    { yylval=strdup(yytext); num_chars+=yyleng; return SING_CH_WO_SP; }
{escape_sequence}	    { yylval=strdup(yytext); num_chars+=yyleng; return ESC;	      }
{comment}		    {
			      unsigned int len, i, contain_eol=0;
			      for (len=0, i=1; yytext[i+1]; len++, i++) {
				  if (yytext[i]=='\n') {
				      num_lines++;
				      len=0;
				      contain_eol = 1;
				  }
			      }
			      if (!contain_eol)
				  num_chars += yyleng;
			      else
				  num_chars = len;
			    }
{space}			    { num_chars++; }
{EOL}			    { num_chars=0; num_lines++; }

.			    {
			      printf("%3d:%-3d", num_lines, num_chars);
			      printf(" redundant character `%s`\n", yytext);
			      num_chars += yyleng;
			    }

%%

#ifndef yywrap
int yywrap() {
    return 1;
}
#endif
