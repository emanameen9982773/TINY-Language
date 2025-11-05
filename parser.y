%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE  
%token NUMBER IDENT WHILE LOOP ENDLOOP READ WRITE AND OR NOT TRUE FALSE
%token ASSIGN EQ NEQ LT GT LTE GTE ADD SUB MULT DIV

%left OR
%left AND
%right NOT
%left ASSIGN
%left LT GT LTE GTE EQ NEQ
%left ADD SUB
%left MULT DIV

%%
program: PROGRAM IDENT decleration BEGIN_PROGRAM block END_PROGRAM ;


decleration: IDENT ':' INTEGER ';'
           | IDENT ':' ARRAY '(' NUMBER ')' OF INTEGER ';'
           | IDENT ',' multi_id ':' INTEGER ';'
           | IDENT ',' multi_id ':' ARRAY '(' NUMBER ')' OF INTEGER ';'
           | ;

multi_id: IDENT
        | IDENT ',' multi_id ;


block: statement
     | statement block
     ;

statement: read
         | write
         | if_statement
         | loop
         | assignment
         ;

read: ;
write: ;
if_statement: ;
loop: ;
assignment: ;
%%