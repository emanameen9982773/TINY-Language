%{
#include <stdio.h>
#include <stdlib.h> // For exit()
#include <string.h> // For strlen()
#include "parser.tab.h"

int line_num = 1;
int col_num = 1;

void update_col() {
    col_num += yyleng;
}
%}


DIGIT    [0-9]
LETTER   [a-zA-Z]
ID       {LETTER}({LETTER}|{DIGIT}|_)*
NUMBER   {DIGIT}+
INVALID_IDSTART ({DIGIT}|_)({LETTER}|{DIGIT}|_)*
%%

"program"       { printf("PROGRAM\n"); update_col(); return PROGRAM; }
"beginprogram"  { printf("BEGIN_PROGRAM\n"); update_col(); return BEGIN_PROGRAM; }
"endprogram"    { printf("END_PROGRAM\n"); update_col(); return END_PROGRAM; }
"integer"       { printf("INTEGER\n"); update_col(); return INTEGER; }
"array"         { printf("ARRAY\n"); update_col(); return ARRAY; }
"of"            { printf("OF\n"); update_col(); return OF; }
"if"            { printf("IF\n"); update_col(); return IF; }
"then"          { printf("THEN\n"); update_col(); return THEN; }
"endif"         { printf("ENDIF\n"); update_col(); return ENDIF; }
"else"          { printf("ELSE\n"); update_col(); return ELSE; }
"while"         { printf("WHILE\n"); update_col(); return WHILE; }
"loop"          { printf("LOOP\n"); update_col(); return LOOP; }
"endloop"       { printf("ENDLOOP\n"); update_col(); return ENDLOOP; }
"read"          { printf("READ\n"); update_col(); return READ; }
"write"         { printf("WRITE\n"); update_col(); return WRITE; }
"and"           { printf("AND\n"); update_col(); return AND; }
"or"            { printf("OR\n"); update_col(); return OR; }
"not"           { printf("NOT\n"); update_col(); return NOT; }
"true"          { printf("TRUE\n"); update_col(); return TRUE; }
"false"         { printf("FALSE\n"); update_col(); return FALSE; }

[ \t]+          { update_col(); }
\n              { line_num++; col_num = 1; }
"--".*          { /* comment line */ }

":="            { printf("ASSIGN\n"); update_col(); return ASSIGN; }
"<="            { printf("LTE\n"); update_col(); return LTE; }
">="            { printf("GTE\n"); update_col(); return GTE; }
"<>"            { printf("NEQ\n"); update_col(); return NEQ; }
"+"             { printf("ADD\n"); update_col(); return ADD; }
"-"             { printf("SUB\n"); update_col(); return SUB; }
"*"             { printf("MULT\n"); update_col(); return MULT; }
"/"             { printf("DIV\n"); update_col(); return DIV; }
"="             { printf("EQ\n"); update_col(); return EQ; }
"<"             { printf("LT\n"); update_col(); return LT; }
">"             { printf("GT\n"); update_col(); return GT; }
";"             { printf("SEMICOLON\n"); update_col(); return (';'); }
":"             { printf("COLON\n"); update_col(); return (':'); }
","             { printf("COMMA\n"); update_col(); return (','); }
"("             { printf("L_PAREN\n"); update_col(); return ('('); }
")"             { printf("R_PAREN\n"); update_col(); return (')'); }


{NUMBER} {
    printf("NUMBER %s\n", yytext);
    update_col();
    yylval=atoi(yytext);
    return NUMBER;
}

{ID} {
    if (yytext[yyleng - 1] == '_') {
        fprintf(stderr,
            "Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n",
            line_num, col_num, yytext);
        exit(1);
    } else {
        printf("IDENT %s\n", yytext);
        update_col();
        return IDENT;
    }
}

{INVALID_IDSTART} {
    fprintf(stderr,
        "Error at line %d, column %d: identifier \"%s\" must begin with a letter\n",
        line_num, col_num, yytext);
    exit(1);
}

. {
    fprintf(stderr,
        "Error at line %d, column %d: unrecognized symbol \"%s\"\n",
        line_num, col_num, yytext);
    exit(1);
}

%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Error: Could not open file '%s'\n", argv[1]);
        return 1;
    }

    yylex();
    fclose(yyin);
    return 0;
}

int yywrap() {
    return 1;
}
