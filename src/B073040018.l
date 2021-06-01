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
    void handler(void);
%}

boolean_literal		true|false
null_literal		null
escape_sequence		\\[tbnrf\'\"\\]
single_character	[^\'\\\n]|{escape_sequence}
char_literal		\'{single_character}\'
string_character	[^\"\\\n]|{escape_sequence}
string_literal		\"{string_character}*\"
integer_type_suffix	[lL]
hex_indicator		[xX]
identifier		([a-zA-Z_$])([a-zA-Z0-9_$])*
comment			(\/\/.*\n)|(\/\*([^\*]|\*+[^\*\/])*\*+\/)
space			[ \t]
EOL			\n

%%

abstract	{ /* keyward */
                  handler(); return ABSTRACT;     }
boolean		{ handler(); return BOOLEAN;      }
break		{ handler(); return BREAK;        }
byte		{ handler(); return BYTE;         }
case		{ handler(); return CASE;         }
catch		{ handler(); return CATCH;        }
char		{ handler(); return CHAR;         }
class		{ handler(); return CLASS;        }
const		{ handler(); fprintf(stderr, "`const' is a keyword but not used\n"); }
continue	{ handler(); return CONTINUE;     }
default		{ handler(); return DEFAULT;      }
do		{ handler(); return DO;           }
double		{ handler(); return DOUBLE;       }
else		{ handler(); return ELSE;         }
extends		{ handler(); return EXTENDS;      }
final		{ handler(); return FINAL;        }
finally		{ handler(); return FINALLY;      }
float		{ handler(); return FLOAT;        }
for		{ handler(); return FOR;          }
goto		{ handler(); fprintf(stderr, "`goto' is a keyword but not used\n"); }
if		{ handler(); return IF;           }
implements	{ handler(); return IMPLEMENTS;   }
import		{ handler(); return IMPORT;       }
instanceof	{ handler(); return INSTANCEOF;   }
int		{ handler(); return INT;          }
interface	{ handler(); return INTERFACE;    }
long		{ handler(); return LONG;         }
native		{ handler(); return NATIVE;       }
new		{ handler(); return NEW;          }
package		{ handler(); return PACKAGE;      }
private		{ handler(); return PRIVATE;      }
protected	{ handler(); return PROTECTED;    }
public		{ handler(); return PUBLIC;       }
return		{ handler(); return RETURN;       }
short		{ handler(); return SHORT;        }
static		{ handler(); return STATIC;       }
super		{ handler(); return SUPER;        }
switch		{ handler(); return SWITCH;       }
synchronized    { handler(); return SYNCHRONIZED; }
this		{ handler(); return THIS;         }
throw	    	{ handler(); return THROW;        }
throws	    	{ handler(); return THROWS;       }
transient	{ handler(); return TRANSIENT;    }
try	        { handler(); return TRY;          }
void	    	{ handler(); return VOID;         }
volatile	{ handler(); return VOLATILE;     }
while	    	{ handler(); return WHILE;        }

"="             { /* assignment operator */
		  handler(); return ASS; 	 }
"*="            { handler(); return MUL_ASS;	 }
"/="            { handler(); return DIV_ASS;	 }
"%="            { handler(); return MOD_ASS;	 }
"+="            { handler(); return ADD_ASS;	 }
"-="            { handler(); return SUB_ASS;	 }
"<<="           { handler(); return LS_ASS;	 }
">>="           { handler(); return RS_ASS;	 }
">>>="          { handler(); return URS_ASS;	 }
"&="            { handler(); return EMP_ASS;	 }
"^="            { handler(); return XOR_ASS;	 }
"|="            { handler(); return OR_ASS;	 }

"<<"            { /* shift */
                  handler(); return LS;		 }
">>"            { handler(); return RS;  	 }
">>>"           { handler(); return URS; 	 }

"=="            { /* relational operator (noted for `=`, for the sack of the longest match rule) */
                  handler(); return EQ;		 }
"!="            { handler(); return NE;  	 }
"<="            { handler(); return LE;  	 }
">="            { handler(); return GE;  	 }
"<"             { handler(); return LT;  	 }
">"             { handler(); return GT;  	 }

"&&"            { /* logical operator */
                  handler(); return AND;	 }
"||"            { handler(); return OR;  	 }
"!"             { handler(); return NOT; 	 }

"++"		{ /* increment/decrement */
		  handler(); return INC;	 }
"--"		{ handler(); return DEC;	 }

[&|^~*/%+\-?:.{}[\](),;]    { handler(); return *yytext;	      }
[0-9a-fA-F]		    { handler(); return *yytext; 	      }

{boolean_literal}	    { /* literal and misc */
			      handler(); return BOOL_LIT;      }
{null_literal}		    { handler(); return NULL_LIT;      }
{char_literal}		    { handler(); return CHAR_LIT;      }
{string_literal}	    { handler(); return STR_LIT;       }
{integer_type_suffix}	    { handler(); return INT_SUF;	      }
{hex_indicator}		    { handler(); return HEX_INDI;      }
{identifier}		    { handler(); return ID;	      }
{comment}		    {
			      unsigned int len, i, contain_eol=0;
			      for (len=1, i=1; yytext[i]; len++, i++) {
				  if (yytext[i]=='\n') {
				      num_lines++;
				      len=1;
				      contain_eol = 1;
				  }
			      }
			      if (!contain_eol)
				  num_chars += yyleng;
			      else
				  num_chars = len;
			    }
{space}+		    { num_chars+=yyleng; }
{EOL}			    { num_chars=1; num_lines++; }

.			    {
			      fprintf(stderr, "%3d:%-3d", num_lines, num_chars);
			      fprintf(stderr, " redundant character `%s`\n", yytext);
			      num_chars += yyleng;
			    }

%%

#ifndef yywrap
int yywrap() {
    return 1;
}
#endif

void handler(void) {
    if (DEBUG == 1) {
	fprintf(stderr, "%3d:%-3d", num_lines, num_chars);
	fprintf(stderr, " %-10s\n", yytext);
    }
    yylval=strdup(yytext); 
    num_chars+=yyleng;
}
