a.out: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c

#syntax_analyzer.o: syntax_analyzer.c syntax_analyzer.h y.tab.h type.h
#	gcc syntax_analyzer.c -c

y.tab.c: cg.y
	yacc -d cg.y

lex.yy.c: cg.l
	lex cg.l

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h
