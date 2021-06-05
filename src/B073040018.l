/*
 * Author: Ernie Chu
 * Filename: B073040018.l
 * Description: Lexical scanner for JAVA programming language
 * Reference:
 *      https://cs.au.dk/~amoeller/RegAut/JavaBNF.html
 *	http://titanium.cs.berkeley.edu/doc/java-langspec-1.0/3.doc.html#48198
 */

%{
    #define YYSTYPE char*
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    unsigned numChars = 1, numLines = 1;
    void handler(void);
%}

BooleanLiteral		    true|false
NullLiteral		    null

EscapeSequence		    \\[tbnrf\'\"\\]
CharacterLiteral	    \'[^\'\\\n]|{EscapeSequence}\'
StringLiteral		    \"([^\"\\\n]|{EscapeSequence})*\"

Digits			    [0-9]+
DecimalIntegerLiteral	    0|([1-9]{Digits}?)[lL]?
HexIntegerLiteral	    0[xX][0-9a-fA-F]+[lL]?
OctalIntegerLiteral	    0[0-7]+[lL]?
IntegerLiteral		    {DecimalIntegerLiteral}|{HexIntegerLiteral}|{OctalIntegerLiteral}

FloatingPointLiteral	    ({Digits}\.{Digits}?([eE][/+/-]?{Digits})?[fFdD]?)|(\.{Digits}([eE][\+\-]?{Digits})?[fFdD]?)

Identifier		    ([a-zA-Z_$])([a-zA-Z0-9_$])*
Comment			    (\/\/.*\n)|(\/\*([^\*]|\*+[^\*\/])*\*+\/)
Space			    [ \t]

%%

abstract		    { /* keyward */
                	      handler();  return ABSTRACT;     }
boolean			    { handler();  return BOOLEAN;      }
break			    { handler();  return BREAK;        }
byte			    { handler();  return BYTE;         }
case			    { handler();  return CASE;         }
catch			    { handler();  return CATCH;        }
char			    { handler();  return CHAR;         }
class			    { handler();  return CLASS;        }
const			    { handler();  fprintf(stderr, "`const' is a keyword but not used in Java\n"); }
continue		    { handler();  return CONTINUE;     }
default			    { handler();  return DEFAULT;      }
do			    { handler();  return DO;           }
double			    { handler();  return DOUBLE;       }
else			    { handler();  return ELSE;         }
extends			    { handler();  return EXTENDS;      }
final			    { handler();  return FINAL;        }
finally			    { handler();  return FINALLY;      }
float			    { handler();  return FLOAT;        }
for			    { handler();  return FOR;          }
goto			    { handler();  fprintf(stderr, "`goto' is a keyword but not used in Java\n"); }
if			    { handler();  return IF;           }
implements		    { handler();  return IMPLEMENTS;   }
import			    { handler();  return IMPORT;       }
instanceof		    { handler();  return INSTANCEOF;   }
int			    { handler();  return INT;          }
interface		    { handler();  return INTERFACE;    }
long			    { handler();  return LONG;         }
native			    { handler();  return NATIVE;       }
new			    { handler();  return NEW;          }
package			    { handler();  return PACKAGE;      }
private			    { handler();  return PRIVATE;      }
protected		    { handler();  return PROTECTED;    }
public			    { handler();  return PUBLIC;       }
return			    { handler();  return RETURN;       }
short			    { handler();  return SHORT;        }
static			    { handler();  return STATIC;       }
super			    { handler();  return SUPER;        }
switch			    { handler();  return SWITCH;       }
synchronized    	    { handler();  return SYNCHRONIZED; }
this			    { handler();  return THIS;         }
throw	    		    { handler();  return THROW;        }
throws	    		    { handler();  return THROWS;       }
transient		    { handler();  return TRANSIENT;    }
try	        	    { handler();  return TRY;          }
void	    		    { handler();  return VOID;         }
volatile		    { handler();  return VOLATILE;     }
while	    		    { handler();  return WHILE;        }

"="             	    { /* assignment operator */
			      handler();  return ASS;	       }
"*="            	    { handler();  return MUL_ASS;      }
"/="            	    { handler();  return DIV_ASS;      }
"%="            	    { handler();  return MOD_ASS;      }
"+="            	    { handler();  return ADD_ASS;      }
"-="            	    { handler();  return SUB_ASS;      }
"<<="           	    { handler();  return LS_ASS;       }
">>="           	    { handler();  return RS_ASS;       }
">>>="          	    { handler();  return URS_ASS;      }
"&="            	    { handler();  return EMP_ASS;      }
"^="            	    { handler();  return XOR_ASS;      }
"|="            	    { handler();  return OR_ASS;       }

"<<"            	    { /* shift */
                	      handler();  return LS;	       }
">>"            	    { handler();  return RS; 	       }
">>>"           	    { handler();  return URS;	       }

"=="            	    { /* relational operator */
                	      handler();  return EQ;	       }
"!="            	    { handler();  return NE;	       }
"<="            	    { handler();  return LE;  	       }
">="            	    { handler();  return GE;  	       }
"<"             	    { handler();  return LT;  	       }
">"             	    { handler();  return GT;  	       }

"&&"            	    { /* logical operator */
                	      handler();  return AND;	       }
"||"            	    { handler();  return OR;  	       }
"!"             	    { handler();  return NOT; 	       }

"++"			    { /* increment/decrement */
			      handler();  return INC;	       }
"--"			    { handler();  return DEC;	       }

[&|^~*/%+\-?:.{}[\](),;]    { handler();  return *yytext;      }

{BooleanLiteral}	    { /* literal and misc */
			      handler();  return BOOL_LIT;     }
{NullLiteral}		    { handler();  return NULL_LIT;     }
{CharacterLiteral}	    { handler();  return CHAR_LIT;     }
{StringLiteral}		    { handler();  return STR_LIT;      }
{IntegerLiteral}	    { handler();  return INT_LIT;      }
{FloatingPointLiteral}	    { handler();  return FLT_LIT;      }
{Identifier}		    { handler();  return ID;	       }
{Comment}		    {
			      unsigned int len, i, contain_eol=0;
			      for (len=1, i=0; yytext[i]; len++, i++) {
				  if (yytext[i]=='\n') {
				      numLines++;
				      len=1;
				      contain_eol = 1;
				      if (DEBUG)
					  fprintf(stderr, "\n%6u  ", numLines);
				  }
				  else
				      if (DEBUG)
					  fprintf(stderr, "%c", yytext[i]);
			      }
			      if (!contain_eol)
				  numChars += yyleng;
			      else
				  numChars = len;
			    }
{Space}+		    { 
			      numChars+=yyleng; 
			      if (DEBUG)
				  fprintf(stderr, "%s", yytext);
			    }
\n/.|\n			    { 
			      numChars=1;
			      numLines++; 
			      if (DEBUG)
				  fprintf(stderr, "%s%6u  ", yytext, numLines);
			    }
.			    {
			      numChars += yyleng;
			      if (DEBUG)
				  fprintf(stderr, "%s", yytext);
			      fprintf(stderr, "\033[1m");
			      fprintf(stderr, "\n%6u:%u: ", numLines, numChars);
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
    if (DEBUG)
	fprintf(stderr, "%s", yytext);
    yylval=strdup(yytext); 
    numChars+=yyleng;
}
