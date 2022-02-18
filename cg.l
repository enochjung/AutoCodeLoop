digit	[0-9]
letter	[A-Z_]
delim	[ \t]
ws		{delim}+

%{
#define YYSTYPE_IS_DECLARED 1 
typedef long YYSTYPE;
#include <stdlib.h>
#include "y.tab.h"

char* allocate_string(char* str);

extern YYSTYPE yylval;
%}

%%
{ws}		{ }
"$$"		{ return DOLLAR_DOLLAR; }
"$FOR"		{ return FOR; }
"(" 		{ yylval=(YYSTYPE)allocate_string(yytext); return LP; }
")" 		{ yylval=(YYSTYPE)allocate_string(yytext); return RP; }
"," 		{ yylval=(YYSTYPE)allocate_string(yytext); return COMMA; }
"$'"		{ return DOLLAR_QUOTE; }
"$"{digit}+						{ yylval=atoi(yytext+1); return(INTEGER); }
"$"{letter}({letter}|{digit})*	{ yylval=(YYSTYPE)allocate_string(yytext); return IDENTIFIER; }
[^$^(^)^,]+						{ yylval=(YYSTYPE)allocate_string(yytext); return CODE; }
%%
