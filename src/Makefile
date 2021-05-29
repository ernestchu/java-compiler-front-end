CC  = gcc# C compiler
CCF = -Wall# C compiler flag
LL  = -ll# link lib
LEXD = Scanner# Lex directory
LEX  = lex.yy# Lex output

all: clean $(LEX).c

$(LEX).c:
	$(MAKE) -wC $(LEXD)
	cp $(LEXD)/$(LEX).c .

clean:
	$(MAKE) -wC $(LEXD) clean
	rm -f $(LEX).c

