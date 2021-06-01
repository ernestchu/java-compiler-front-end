/*
 * Author: Ernie Chu
 * Filename: B073040018.l
 * Description: Lexical scanner for JAVA programming language
 * Reference:
 *      https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
 *      http://db.cse.nsysu.edu.tw/~changyi/slides/compiler/lab/Java.doc
 *	https://stackoverflow.com/questions/16700462/flex-grammar-produces-error-scanner-push-back-overflow
 */

%{
    #define YYSTYPE char*
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    unsigned num_chars = 1, num_lines = 1;
    void handler(void);
%}

boolean_literal		    true|false
null_literal		    null

escape_sequence		    \\[tbnrf\'\"\\]
character_literal	    \'[^\'\\\n]|{escape_sequence}\'
string_literal		    \"([^\"\\\n]|{escape_sequence})*\"

digits			    [0-9]+
decimal_integer_literal	    0|([1-9]{digits}?)[lL]?
hex_integer_literal	    0[xX][0-9a-fA-F]+[lL]?
octal_integer_literal	    0[0-7]+[lL]?
integer_literal		    {decimal_integer_literal}|{hex_integer_literal}|{octal_integer_literal}

floating_point_literal	    ({digits}\.{digits}?([eE][/+/-]?{digits})?[fFdD]?)|(\.{digits}([eE][/+/-]?{digits})?[fFdD]?)

identifier		    ([a-zA-Z_$])([a-zA-Z0-9_$])*
comment			    (\/\/.*\n)|(\/\*([^\*]|\*+[^\*\/])*\*+\/)
space			    [ \t]

%%

abstract		    { /* keyward */
                	      handler(); return ABSTRACT;     }
boolean			    { handler(); return BOOLEAN;      }
break			    { handler(); return BREAK;        }
byte			    { handler(); return BYTE;         }
case			    { handler(); return CASE;         }
catch			    { handler(); return CATCH;        }
char			    { handler(); return CHAR;         }
class			    { handler(); return CLASS;        }
const			    { handler(); fprintf(stderr, "`const' is a keyword but not used in Java\n"); }
continue		    { handler(); return CONTINUE;     }
default			    { handler(); return DEFAULT;      }
do			    { handler(); return DO;           }
double			    { handler(); return DOUBLE;       }
else			    { handler(); return ELSE;         }
extends			    { handler(); return EXTENDS;      }
final			    { handler(); return FINAL;        }
finally			    { handler(); return FINALLY;      }
float			    { handler(); return FLOAT;        }
for			    { handler(); return FOR;          }
goto			    { handler(); fprintf(stderr, "`goto' is a keyword but not used in Java\n"); }
if			    { handler(); return IF;           }
implements		    { handler(); return IMPLEMENTS;   }
import			    { handler(); return IMPORT;       }
instanceof		    { handler(); return INSTANCEOF;   }
int			    { handler(); return INT;          }
interface		    { handler(); return INTERFACE;    }
long			    { handler(); return LONG;         }
native			    { handler(); return NATIVE;       }
new			    { handler(); return NEW;          }
package			    { handler(); return PACKAGE;      }
private			    { handler(); return PRIVATE;      }
protected		    { handler(); return PROTECTED;    }
public			    { handler(); return PUBLIC;       }
return			    { handler(); return RETURN;       }
short			    { handler(); return SHORT;        }
static			    { handler(); return STATIC;       }
super			    { handler(); return SUPER;        }
switch			    { handler(); return SWITCH;       }
synchronized    	    { handler(); return SYNCHRONIZED; }
this			    { handler(); return THIS;         }
throw	    		    { handler(); return THROW;        }
throws	    		    { handler(); return THROWS;       }
transient		    { handler(); return TRANSIENT;    }
try	        	    { handler(); return TRY;          }
void	    		    { handler(); return VOID;         }
volatile		    { handler(); return VOLATILE;     }
while	    		    { handler(); return WHILE;        }

"="             	    { /* assignment operator */
			      handler(); return ASS;	      }
"*="            	    { handler(); return MUL_ASS;      }
"/="            	    { handler(); return DIV_ASS;      }
"%="            	    { handler(); return MOD_ASS;      }
"+="            	    { handler(); return ADD_ASS;      }
"-="            	    { handler(); return SUB_ASS;      }
"<<="           	    { handler(); return LS_ASS;	      }
">>="           	    { handler(); return RS_ASS;	      }
">>>="          	    { handler(); return URS_ASS;      }
"&="            	    { handler(); return EMP_ASS;      }
"^="            	    { handler(); return XOR_ASS;      }
"|="            	    { handler(); return OR_ASS;	      }

"<<"            	    { /* shift */
                	      handler(); return LS;	      }
">>"            	    { handler(); return RS; 	      }
">>>"           	    { handler(); return URS;	      }

"=="            	    { /* relational operator (noted for `=`, for the sack of the longest match rule) */
                	      handler(); return EQ;	      }
"!="            	    { handler(); return NE;	      }
"<="            	    { handler(); return LE;  	      }
">="            	    { handler(); return GE;  	      }
"<"             	    { handler(); return LT;  	      }
">"             	    { handler(); return GT;  	      }

"&&"            	    { /* logical operator */
                	      handler(); return AND;	      }
"||"            	    { handler(); return OR;  	      }
"!"             	    { handler(); return NOT; 	      }

"++"			    { /* increment/decrement */
			      handler(); return INC;	      }
"--"			    { handler(); return DEC;	      }

[&|^~*/%+\-?:.{}[\](),;]    { handler(); return *yytext;      }

{boolean_literal}	    { /* literal and misc */
			      handler(); return BOOL_LIT;     }
{null_literal}		    { handler(); return NULL_LIT;     }
{character_literal}	    { handler(); return CHAR_LIT;     }
{string_literal}	    { handler(); return STR_LIT;      }
{integer_literal}	    { handler(); return INT_LIT;      }
{floating_point_literal}    { handler(); return FLT_LIT;      }
{identifier}		    { handler(); return ID;	      }
{comment}		    {
			      unsigned int len, i, contain_eol=0;
			      for (len=1, i=0; yytext[i]; len++, i++) {
				  if (yytext[i]=='\n') {
				      num_lines++;
				      len=1;
				      contain_eol = 1;
				      if (DEBUG == 1)
					  fprintf(stderr, "\n%6u  ", num_lines);
				  }
				  else
				      if (DEBUG == 1)
					  fprintf(stderr, "%c", yytext[i]);
			      }
			      if (!contain_eol)
				  num_chars += yyleng;
			      else
				  num_chars = len;
			    }
{space}+		    { 
			      num_chars+=yyleng; 
			      if (DEBUG == 1)
				  fprintf(stderr, "%s", yytext);
			    }
\n/.|\n			    { 
			      num_chars=1;
			      num_lines++; 
			      if (DEBUG == 1)
				  fprintf(stderr, "%s%6u  ", yytext, num_lines);
			    }
.			    {
			      num_chars += yyleng;
			      if (DEBUG == 1)
				  fprintf(stderr, "%s", yytext);
			      fprintf(stderr, "\033[1m");
			      fprintf(stderr, "\n%6u:%u: ", num_lines, num_chars);
			      fprintf(stderr, "\033[0;31m");
			      fprintf(stderr, "\033[1m");
			      fprintf(stderr, "syntax error: ");
			      fprintf(stderr, "\033[0m");
			      fprintf(stderr, "\033[1m");
			      fprintf(stderr, "redundant character `%s`", yytext);
			      fprintf(stderr, "\033[22m");
			    }

%%

#ifndef yywrap
int yywrap() {
    return 1;
}
#endif

void handler(void) {
    if (DEBUG == 1)
	fprintf(stderr, "%s", yytext);

    yylval=strdup(yytext); 
    num_chars+=yyleng;
}
