%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *msg);
extern int line_num;
int yylex(void);
extern FILE *yyin;
%}

%union { int ival; }

%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE
%token IDENT WHILE LOOP ENDLOOP READ WRITE AND OR NOT
%token ASSIGN EQ NEQ LT GT LTE GTE ADD SUB MULT DIV COLON
%token <ival> NUMBER TRUE FALSE

%type <ival> expression bool_exp

%left OR
%left AND
%right NOT
%left ASSIGN
%left LT GT LTE GTE EQ NEQ
%left ADD SUB
%left MULT DIV

%%

program:
    PROGRAM IDENT ';' declarations BEGIN_PROGRAM block END_PROGRAM
    ;

declarations:
    declarations declaration
    | 
    ;

declaration:
    multi_id COLON INTEGER ';'
    | multi_id COLON ARRAY '(' NUMBER ')' OF INTEGER ';'
    |error {yyerror("invalid declaration"); yyerrok; yyclearin;}
    ;

multi_id:
    IDENT
    | IDENT ',' multi_id
    ;

block:
    statement_list
    ;

statement_list:
    statement_list statement
    | 
    ;

statement:
    read
    | write
    | if_statement
    | loop
    | assignment
    ;

read:
    READ variable_list ';'
    ;

write:
    WRITE variable_list ';'
    ;

if_statement:
    IF bool_exp THEN block ENDIF
    | IF bool_exp THEN block ELSE block ENDIF ';'
    ;

loop:
    WHILE bool_exp LOOP block ENDLOOP ';'
    ;

assignment: variable ASSIGN expression ';'
          | error   {yyerror(" \":=\" expected"); yyerrok; yyclearin; }
    ;

variable_list:
    variable
    | variable_list ',' variable
    ;

variable:
    IDENT
    | IDENT '(' expression ')'
    ;

bool_exp:
      bool_exp OR bool_exp        { $$ = $1 || $3; }
    | bool_exp AND bool_exp       { $$ = $1 && $3; }
    | NOT bool_exp                { $$ = !$2; }
    | expression EQ expression    { $$ = $1 == $3; }
    | expression NEQ expression   { $$ = $1 != $3; }
    | expression LT expression    { $$ = $1 < $3; }
    | expression GT expression    { $$ = $1 > $3; }
    | expression LTE expression   { $$ = $1 <= $3; }
    | expression GTE expression   { $$ = $1 >= $3; }
    | TRUE                        { $$ = 1; }
    | FALSE                       { $$ = 0; }
    | '(' bool_exp ')'            { $$ = $2; }
    ;

expression:
      expression ADD expression   { $$ = $1 + $3; }
    | expression SUB expression   { $$ = $1 - $3; }
    | expression MULT expression  { $$ = $1 * $3; }
    | expression DIV expression   { if($3==0){ yyerror("Division by zero"); $$=0;} else $$=$1/$3; }
    | '(' expression ')'          { $$ = $2; }
    | NUMBER                      { $$ = $1; }
    | variable                    { $$ = 0; } 
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", line_num, msg);
}

int main(int argc, char *argv[]) {
    if(argc!=2) { fprintf(stderr,"Usage: %s <file>\n",argv[0]); return 1; }
    FILE *f = fopen(argv[1],"r");
    if(!f) { perror("fopen"); return 1; }
    yyin = f;
    int res = yyparse();
    fclose(f);
    if(res==0) printf("Parsing finished successfully.\n");
    else printf("Parsing failed.\n");
    return res;
}
