CC=gcc
TARGET=acl

acl: y.tab.c lex.yy.c 
	$(CC) y.tab.c lex.yy.c -o $(TARGET)

y.tab.c: cg.y
	yacc -d cg.y

lex.yy.c: cg.l
	lex cg.l

clean:
	rm -f $(TARGET) lex.yy.c y.tab.c y.tab.h
