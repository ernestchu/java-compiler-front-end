CC   = gcc# C compiler
LC   = flex# Lex compiler
YC   = bison# Yacc compiler
CCF  = -Wall# C compiler flag
LL   = -ll# link lib
LT   = B073040018# Lex target
YT   = B073040018# Yacc target
LEX  = lex.yy# Lex output
YACC = y.tab# Yacc output

all: $(LEX).c

$(LEX).c:
	$(LC) $(LT).l

clean:
	rm -f $(LEX).c

