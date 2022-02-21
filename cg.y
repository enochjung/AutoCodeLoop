%token FOR IF ELIF ELSE ENDIF LP RP COMMA QUOTE I_VALUE INTEGER IDENTIFIER CODE

%{
#define YYSTYPE_IS_DECLARED 1 
typedef long YYSTYPE;
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

typedef struct _node {
	char* code;
	struct _node* next;
	int is_i_value;
} node;

node* link(node* a, node* b);
node* make_node(char* str);
node* make_i_value_node();
node* copy_node(node* n);
node* change_i(node* n, int i);
char* int_to_char(int val);
int get_value(char* ident_name);
char* allocate_string(char* str);
void print_entire_code(node* n, char* file_name);
int yylex();
void yyerror(char const *s);
int yywrap();

extern YYSTYPE yylval;
extern char* yytext;
extern int errno;

node* program_code;
%}

%start program

%%
program // node*
	: translation_unit { program_code=(node*)$1; }
	;
translation_unit // node*
	: code_or_unit { $$=$1; }
	| translation_unit code_or_unit { $$=(YYSTYPE)link((node*)$1,(node*)$2); }
	;
code_or_unit // node*
	: code { $$=$1; }
	| unit { $$=$1; }
	;
code // node*
	: CODE { $$=(YYSTYPE)make_node((char*)$1); }
	| LP { $$=(YYSTYPE)make_node((char*)$1); }
	| RP { $$=(YYSTYPE)make_node((char*)$1); }
	| COMMA { $$=(YYSTYPE)make_node((char*)$1); }
	;
unit // node*
	: value { $$=(YYSTYPE)make_node(int_to_char($1)); }
	| FOR LP value COMMA value COMMA string COMMA string RP {
		int i;
		node* n = change_i(copy_node((node*)$7), $3);
		for (i=$3+1; i<$5; ++i) {
			link(n, copy_node((node*)$9));
			link(n, change_i(copy_node((node*)$7), i));
		}
		$$ = (YYSTYPE)n;
	}
	| IF LP value COMMA value RP translation_unit if_next {
		if ($3 == $5)
			$$ = $7;
		else
			$$ = $8;
	}
	;
if_next // node*
	: if_final { $$=$1; }
	| ELIF LP value COMMA value RP translation_unit if_next {
		if ($3 == $5)
			$$ = $7;
		else
			$$ = $8;
	}
	;
if_final // node*
	: ENDIF { $$=(YYSTYPE)NULL; }
	| ELSE translation_unit ENDIF { $$=$2; }
	;
value // int
	: INTEGER { $$=$1; }
	| IDENTIFIER { $$=get_value((char*)$1); }
	;
string // node*
	: QUOTE QUOTE { $$=(YYSTYPE)NULL; }
	| QUOTE string_unit QUOTE { $$=$2; }
	;
string_unit // node*
	: string_component { $$=$1; }
	| string_unit string_component { $$=(YYSTYPE)link((node*)$1,(node*)$2); }
	;
string_component // node*
	: code { $$=$1; }
	| value { $$=(YYSTYPE)make_node(int_to_char($1)); }
	| i_value { $$=$1; }
	;
i_value // node*
	: I_VALUE { $$=(YYSTYPE)make_i_value_node(); }
	;
%%

node* link(node* a, node* b) {
	node* n = a;
	while (n->next)
		n = n->next;
	n->next = b;
	return a;
}

node* make_node(char* str) {
	node* n = (node*)malloc(sizeof(node));
	n->code = str;
	n->next = NULL;
	n->is_i_value = 0;
	return n;
}

node* make_i_value_node() {
	node* n = (node*)malloc(sizeof(node));
	n->code = NULL;
	n->next = NULL;
	n->is_i_value = 1;
	return n;
}

node* copy_node(node* n) {
	node* head = (node*)malloc(sizeof(node));
	node* nn = head;

	while (1) {
		nn->code = n->code;
		nn->is_i_value = n->is_i_value;
		if (n->next != NULL) {
			nn->next = (node*)malloc(sizeof(node));
			nn = nn->next;
			n = n->next;
		}
		else {
			nn->next = NULL;
			break;
		}
	}

	return head;
}

node* change_i(node* n, int i) {
	node* start = n;

	while (1) {
		if (n->is_i_value == 1)
			n->code = int_to_char(i);
		if (n->next == NULL)
			break;
		n = n->next;
	}

	return start;
}

char* int_to_char(int val) {
	char* str;
	char buf[100];
	int len;

	sprintf(buf, "%d", val);
	len = (int)strlen(buf);
	str = malloc((len+1) * sizeof(char));
	strcpy(str, buf);

	return str;
}

int get_value(char* ident_name) {
	char* var;
	long val;

	if ((var = getenv(ident_name)) == NULL) {
		fprintf(stderr, "ERROR: environment variable '%s' is not defined.\n", ident_name);
		exit(1);
	}

	val = strtol(var, NULL, 10);
	if (errno != 0) {
		fprintf(stderr, "ERROR: environment variable '%s' is not integer.\n"
						"       %s=%s\n", ident_name, ident_name, var);
		exit(1);
	}

	return (int)val;
}

char* allocate_string(char* str) {
	char* new_str;
	int len;

	len = (int)strlen(str);
	new_str = malloc((len+1) * sizeof(char));
	strncpy(new_str, str, len+1);

	return new_str;
}

void initialize(char* file_name) {
	if (freopen(file_name, "r", stdin) == NULL) {
		fprintf(stderr, "ERROR: file '%s' is not found.\n", file_name);
		exit(1);
	}
}

void print_entire_code(node* n, char* file_name) {
	FILE* fp = fopen(file_name, "w");
	if (fp == NULL) {
		fprintf(stderr, "ERROR: cannot write file '%s'.\n", file_name);
		exit(1);
	}
	while (n != NULL) {
		if (n->code != NULL)
			fprintf(fp, "%s", n->code);
		n = n->next;
	}
	fclose(fp);
	return;
}

int main(int argc, char** argv) {
	if (argc != 3) {
		fprintf(stderr, "USAGE: ./acl <input_file> <output_file>\n");
		exit(1);
	}
	initialize(argv[1]);
	yyparse();
	print_entire_code(program_code, argv[2]);
	return 0;
}

int yywrap() {
	return 1;
}

void yyerror(char const *s) {
	fprintf(stderr, "ERROR: syntax error(%s) near: %s\n", s, yytext);
	exit(1);
}
