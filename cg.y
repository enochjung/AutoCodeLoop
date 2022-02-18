%token IDENTIFIER DOLLAR_DOLLAR FOR LP RP COMMA DOLLAR_QUOTE INTEGER CODE

%{
#define YYSTYPE_IS_DECLARED 1 
typedef long YYSTYPE;
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _node
{
	char* code;
	struct _node* next;
} node;

typedef struct _identifier
{
	char* name;
	int value;
	struct _identifier* next;
} identifier;

node* link(node* a, node* b);
node* make_node(char* str);
node* copy_node(node* n);
node* change_i(node* n, int i);
void make_identifier(char* name, int value);
char* int_to_char(int val);
int get_value(char* ident_name);
char* allocate_string(char* str);
void print_entire_code(node* n);
int yylex();
void yyerror(char const *s);
int yywrap();

extern YYSTYPE yylval;
extern char* yytext;
identifier* identifier_head;
node* program_code;

/*
extern A_ID* current_id;
extern int current_level;
extern int syntax_err;
extern A_NODE* root;
extern A_TYPE* int_type;
*/
%}

%start program

%%
program 
	: translation_unit { program_code=(node*)$1; }
	;
translation_unit
	: code_or_unit { $$=$1; }
	| translation_unit code_or_unit { $$=(YYSTYPE)link((node*)$1,(node*)$2); }
	;
code_or_unit
	: code { $$=$1; }
	| unit { $$=$1; }
	;
code
	: CODE { $$=(YYSTYPE)make_node((char*)$1); }
	| COMMA { $$=(YYSTYPE)make_node((char*)$1); }
	| LP { $$=(YYSTYPE)make_node((char*)$1); }
	| RP { $$=(YYSTYPE)make_node((char*)$1); }
	;
unit
	: IDENTIFIER { $$=(YYSTYPE)make_node(int_to_char(get_value((char*)$1))); }
	| FOR LP for_expression RP { $$=$3; }
	;
for_expression
	: value value DOLLAR_QUOTE for_translation_unit DOLLAR_QUOTE COMMA DOLLAR_QUOTE code DOLLAR_QUOTE { int i;node* n=change_i(copy_node((node*)$4),$1);for(i=($1)+1;i<$2;++i){link(n,copy_node((node*)$8));link(n,change_i(copy_node((node*)$4),i));}$$=(YYSTYPE)n; }
	;
value
	: INTEGER COMMA { $$=$1; }
	| IDENTIFIER COMMA { $$=get_value((char*)$1); }
	;
for_translation_unit
	: for_code_or_unit { $$=$1; }
	| for_translation_unit for_code_or_unit { $$=(YYSTYPE)link((node*)$1,(node*)$2);}
	;
for_code_or_unit
	: code { $$=$1; }
	| unit { $$=$1; }
	| i_value { $$=$1; }
	;
i_value
	: DOLLAR_DOLLAR { $$=(YYSTYPE)make_node("$$"); }
	;
%%

node* link(node* a, node* b)
{
	node* n = a;
	while (n->next)
		n = n->next;
	n->next = b;
	return a;
}

node* make_node(char* str)
{
	node* n = (node*)malloc(sizeof(node));
	n->code = str;
	n->next = NULL;
	return n;
}

node* copy_node(node* n)
{
	node* head = (node*)malloc(sizeof(node));
	node* nn = head;

	while (1)
	{
		nn->code = n->code;
		if (n->next != NULL)
		{
			nn->next = (node*)malloc(sizeof(node));
			nn = nn->next;
			n = n->next;
		}
		else
		{
			nn->next = NULL;
			break;
		}
	}

	return head;
}

node* change_i(node* n, int i)
{
	node* start = n;

	while (1)
	{
		if (strcmp(n->code, "$$") == 0)
			n->code = int_to_char(i);
		if (n->next == NULL)
			break;
		n = n->next;
	}

	return start;
}

void make_identifier(char* name, int value)
{
	identifier* ident;

	ident = (identifier*)malloc(sizeof(identifier));
	ident->name = (char*)malloc(strlen(name)+1);
	strcpy(ident->name, name);
	ident->value = value;
	ident->next = identifier_head;
	identifier_head = ident;

	return;
}

char* int_to_char(int val)
{
	char* str;
	char buf[100];
	int len;

	sprintf(buf, "%d", val);
	len = (int)strlen(buf);
	str = malloc((len+1) * sizeof(char));
	strcpy(str, buf);

	return str;
}

int get_value(char* ident_name)
{
	identifier* ident = identifier_head;

	while (ident != NULL)
	{
		if (strcmp(ident->name, ident_name+1) == 0)
			return ident->value;
		ident = ident->next;
	}

	fprintf(stderr, "ERROR: %s는 parameter 파일에 정의되어 있지 않습니다.\n", ident_name+1);
	exit(1);
}

char* allocate_string(char* str)
{
	char* new_str;
	int len;

	len = (int)strlen(str);
	new_str = malloc((len+1) * sizeof(char));
	strncpy(new_str, str, len+1);

	return new_str;
}

void initialize()
{
	FILE* fp;
	char name[100];
	int value;
	identifier* ident;

	fp = fopen("parameter", "r");
	if (fp == NULL)
	{
		fprintf(stderr, "ERROR: parameter 파일이 없습니다.\n");
		exit(1);
	}

	while (fscanf(fp, " %s %d", name, &value) == 2)
		make_identifier(name, value);

	fclose(fp);
}

void print_entire_code(node* n)
{
	while (n != NULL)
	{
		printf("%s", n->code);
		n = n->next;
	}
	return;
}

int main()
{
	initialize();
	yyparse();
	print_entire_code(program_code);
	return 0;
}

int yywrap()
{
	return 1;
}

void yyerror(char const *s)
{
	printf("yyerror(%s)\n", s);
	fprintf(stderr, "error %s near: %s\n", s, yytext);
	exit(1);
}
