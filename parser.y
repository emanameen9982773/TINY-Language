%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *msg);   // declaration
extern int line_num;               // if using line numbers from lexer

int yylex(void);                 // declare the lexer function
extern FILE *yyin; 

%}

%union{
        int ival;
}

%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN 
%token ENDIF ELSE IDENT WHILE LOOP ENDLOOP READ WRITE AND OR NOT 
%token ASSIGN EQ NEQ LT GT LTE GTE ADD SUB MULT DIV COLON
%token <ival> NUMBER TRUE FALSE

%type <ival> bool_exp expression 

%left OR
%left AND
%right NOT
%left ASSIGN
%left LT GT LTE GTE EQ NEQ
%left ADD SUB
%left MULT DIV

%%
program: PROGRAM IDENT ';' declerations BEGIN_PROGRAM block END_PROGRAM
       | ;

declerations: decleration declerations
            | ;

decleration: multi_id COLON INTEGER ';'
           | multi_id COLON ARRAY '(' NUMBER ')' OF INTEGER ';' ;

multi_id: IDENT
        | IDENT ',' multi_id ;


block: block statement  
     | 
     ;

statement: read
         | write
         | if_statement
         | loop
         | assignment
         ;

read: READ variables ';' ;

write: WRITE variables ';' ;

if_statement: IF bool_exp THEN statement ENDIF
            | IF bool_exp THEN statement ELSE statement ENDIF ;

loop:  WHILE bool_exp LOOP statement ENDLOOP  ;

assignment: variable ASSIGN expression ';'  
          | variable '=' expression  ';'   {yyerror("\":=\" expected"); } 
          | error                        {yyerror("invalid assignment"); yyerrok;} ;


variables: variables ',' variable
         | variable ;

variable: IDENT
        | IDENT '(' expression ')' ;

bool_exp: bool_exp OR bool_exp           {$$=$1||$3;}
        | bool_exp AND bool_exp          {$$=$1&&$3;}
        | NOT bool_exp                   {$$=!$2;}
        | expression EQ expression       {$$=$1==$3;}
        | expression NEQ expression      {$$=$1!=$3;}
        | expression LT expression       {$$=$1<$3;}
        | expression GT expression       {$$=$1>$3;}
        | expression LTE expression      {$$=$1<=$3;}
        | expression GTE expression      {$$=$1>=$3;}
        | TRUE                           {$$=1;}
        | FALSE                          {$$=0;}
        | '(' bool_exp ')'               {$$=$2;}
        ;

expression: expression SUB expression    {$$=$1-$3;}
          | expression ADD expression    {$$=$1+$3;}
          | expression MULT expression   {$$=$1*$3;}
          | expression DIV expression    {if($3 == 0) { 
                                             yyerror("Division by zero"); 
                                             $$ = 0;}
                                          else 
                                             $$ = $1 / $3; }
                                                
          |'('expression')'              {$$=$2;}
          | variable                     {$$=0;}
          |NUMBER ;
%%

void yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", line_num, msg);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <source_file>\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("fopen");
        return 1;
    }

    yyin = f;      // yyin is used by Flex to read input
    int result = yyparse();
    fclose(f);

    if (result == 0) {
        printf("Parsing finished successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }

    return result;
}

