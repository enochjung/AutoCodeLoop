digit			[0-9]
letter			[A-Z_]
delim			[ \t]
whitespace		{delim}+

%{
#define YYSTYPE_IS_DECLARED 1 
typedef long YYSTYPE;
#include <stdlib.h>
#include "y.tab.h"

char* allocate_string(char* str);

extern YYSTYPE yylval;
%}

%%
{whitespace}	{ }
\$FOR			{ return FOR; }
\$IF			{ return IF; }
\$ELIF			{ return ELIF; }
\$ELSE			{ return ELSE; }
\$ENDIF			{ return ENDIF; }
"(" 			{ yylval=(YYSTYPE)allocate_string(yytext); return LP; }
")" 			{ yylval=(YYSTYPE)allocate_string(yytext); return RP; }
"," 			{ yylval=(YYSTYPE)allocate_string(yytext); return COMMA; }
\$'				{ return QUOTE; }
\$\$			{ return I_VALUE; }
\${digit}+						{ yylval=atoi(yytext+1); return INTEGER; }
\${letter}({letter}|{digit})*	{ yylval=(YYSTYPE)allocate_string(yytext+1); return IDENTIFIER; }
[^$(),]+						{ yylval=(YYSTYPE)allocate_string(yytext); return CODE; }
%%
