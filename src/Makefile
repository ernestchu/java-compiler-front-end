CC    = gcc# C compiler
LC    = flex# Lex compiler
YC    = bison# Yacc compiler
DEBUG = 0# Debugging flag, level 0, 1, 2
CCF   = -Wall -DDEBUG=$(DEBUG)# C compiler flag
YCF   = -dy# Yacc compiler flag
LL    = -ll -ly# link lib
LT    = B073040018# Lex target
YT    = B073040018# Yacc target
LEX   = lex.yy# Lex output
YACC  = y.tab# Yacc output
STT   = SymbolTable/SymbolTable# Symbol table target
EXEC  = JavaParser

ifeq ($(DEBUG), 1) 
	YCF = -dy
endif
ifeq ($(DEBUG), 2) 
	YCF = -dtvy
endif

.PHONY: all
all: clean $(LEX).c $(YACC).c $(STT).c
	$(CC) $(CCF) $(YACC).c $(STT).c -o $(EXEC)

$(LEX).c: $(LT).l $(YACC).h
	$(LC) $(LT).l

$(YACC).h: $(YT).y
	$(YC) $(YCF) $(YT).y

.PHONY: clean
clean:
	rm -f $(EXEC) $(LEX).c $(YACC).* y.output

