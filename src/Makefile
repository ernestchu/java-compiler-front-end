CC   = gcc# C compiler
LC   = flex# Lex compiler
YC   = bison# Yacc compiler
CCF  = -Wall# C compiler flag
LL   = -ll -ly# link lib
LT   = B073040018# Lex target
YT   = B073040018# Yacc target
LEX  = lex.yy# Lex output
YACC = y.tab# Yacc output
STT  = SymbolTable/SymbolTable# Symbol table target
EXEC = JavaCompiler

.PHONY: all
all: $(LEX).c $(YACC).c $(STT).c
	$(CC) $(CCF) $(YACC).c -o $(EXEC)

$(LEX).c: $(LT).l $(YACC).h
	$(LC) $(LT).l

$(YACC).h: $(YT).y
	$(YC) -dy $(YT).y

.PHONY: clean
clean:
	rm -f $(LEX).c $(YACC).*

