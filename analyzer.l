%{
#include <stdio.h>
#include <stdlib.h> // For exit()
#include <string.h> // For strlen()

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

"program"       { printf("PROGRAM\n"); update_col(); }
"beginprogram"  { printf("BEGIN_PROGRAM\n"); update_col(); }
"endprogram"    { printf("END_PROGRAM\n"); update_col(); }
"integer"       { printf("INTEGER\n"); update_col(); }
"array"         { printf("ARRAY\n"); update_col(); }
"of"            { printf("OF\n"); update_col(); }
"if"            { printf("IF\n"); update_col(); }
"then"          { printf("THEN\n"); update_col(); }
"endif"         { printf("ENDIF\n"); update_col(); }
"else"          { printf("ELSE\n"); update_col(); }
"while"         { printf("WHILE\n"); update_col(); }
"loop"          { printf("LOOP\n"); update_col(); }
"endloop"       { printf("ENDLOOP\n"); update_col(); }
"read"          { printf("READ\n"); update_col(); }
"write"         { printf("WRITE\n"); update_col(); }
"and"           { printf("AND\n"); update_col(); }
"or"            { printf("OR\n"); update_col(); }
"not"           { printf("NOT\n"); update_col(); }
"true"          { printf("TRUE\n"); update_col(); }
"false"         { printf("FALSE\n"); update_col(); }

[ \t]+          { update_col(); }
\n              { line_num++; col_num = 1; }
"--".*          { /* comment line */ }

":="            { printf("ASSIGN\n"); update_col(); }
"<="            { printf("LTE\n"); update_col(); }
">="            { printf("GTE\n"); update_col(); }
"<>"            { printf("NEQ\n"); update_col(); }
"+"             { printf("ADD\n"); update_col(); }
"-"             { printf("SUB\n"); update_col(); }
"*"             { printf("MULT\n"); update_col(); }
"/"             { printf("DIV\n"); update_col(); }
"="             { printf("EQ\n"); update_col(); }
"<"             { printf("LT\n"); update_col(); }
">"             { printf("GT\n"); update_col(); }
";"             { printf("SEMICOLON\n"); update_col(); }
":"             { printf("COLON\n"); update_col(); }
","             { printf("COMMA\n"); update_col(); }
"("             { printf("L_PAREN\n"); update_col(); }
")"             { printf("R_PAREN\n"); update_col(); }

{NUMBER} {
    printf("NUMBER %s\n", yytext);
    update_col();
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
