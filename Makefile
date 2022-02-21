CC=gcc
TARGET=acl
#DEBUG=-g

acl: y.tab.c lex.yy.c 
	$(CC) y.tab.c lex.yy.c -o $(TARGET) $(DEBUG)

y.tab.c: cg.y
	yacc -d cg.y

lex.yy.c: cg.l
	lex cg.l

clean:
	rm -f $(TARGET) y.tab.c y.tab.h lex.yy.c
