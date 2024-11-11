%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 1000

typedef struct {
    char *name;
    int index;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

void add_symbol(const char *name);
int lookup_symbol(const char *name);
void print_symbol_table();
void print_pif(const char *token, int index);
void lexical_error(const char *msg);
%}

%option noyywrap

%%
[ \t\n]+                    ; 
"int"|"float"|"char"         { print_pif(yytext, -1); }
"if"|"else"|"while"|"for"|"return" { print_pif(yytext, -1); }
"true"|"false"               { print_pif(yytext, -1); }

[0-9]+                       { add_symbol(yytext); print_pif(yytext, lookup_symbol(yytext)); }

[a-zA-Z_][a-zA-Z0-9_]*       { add_symbol(yytext); print_pif(yytext, lookup_symbol(yytext)); }

"+"|"-"|"*"|"/"|"="|"<"|">"|"=="|"!="|"&&"|"||"|"!" { print_pif(yytext, -1); }

";"|","|"\("|"\)"|"\{"|"\}"|\[|\] { print_pif(yytext, -1); }

'\''[a-zA-Z0-9]'\''           { add_symbol(yytext); print_pif(yytext, lookup_symbol(yytext)); }


\"([^\\\"\n]|\\.)*\"          { add_symbol(yytext); print_pif(yytext, lookup_symbol(yytext)); }

.                            { lexical_error("Unexpected character"); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return EXIT_FAILURE;
        }
        yyin = file;
    }

    yylex();
    print_symbol_table(); 
    return 0;
}

void add_symbol(const char *name) {
    if (symbol_count >= MAX_SYMBOLS) return; // Prevent overflow
    if (lookup_symbol(name) == -1) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].index = symbol_count;
        symbol_count++;
    }
}

int lookup_symbol(const char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].index;
        }
    }
    return -1; 
}

void print_symbol_table() {
    printf("Symbol table:\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("%s\t%d\n", symbol_table[i].name, symbol_table[i].index);
    }
}

void print_pif(const char *token, int index) {
    static int pif_index = 0;
    printf("%s\t%d\n", token, index);
}

void lexical_error(const char *msg) {
    fprintf(stderr, "Lexical error: %s '%s' at line %d\n", msg, yytext, yylineno);
}
