%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
void yyerror(const char *s);
%}

%union {
    int intval;
    char *strval;
}

%token CLASS INT FLOAT CHAR VOID BOOL RETURN IF ELSE WHILE FOR
%token IDENTIFIER INT_CONST CHAR_CONST STRING_CONST BOOLEAN_LITERAL
%token ASSIGN OPERATOR SEPARATOR

%left '+' '-'
%left '*' '/' '%'
%left '>' '<' GEQ LEQ EQ NEQ
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program : CLASS IDENTIFIER '{' decllist stmtlist '}'
        { printf("Program syntactic correct\n"); }
        ;

// Declarations

decllist : declaration ';' decllist
         | declaration
         ;

declaration : type identifier_list
            ;

identifier_list : IDENTIFIER ',' identifier_list
                | IDENTIFIER
                ;

// Types

type : INT
     | FLOAT
     | CHAR
     | VOID
     | BOOL
     | CLASS IDENTIFIER '{' decllist '}'
     ;

// Statements

stmtlist : stmt ';' stmtlist
         | stmt
         ;

stmt : simplstmt
     | structstmt
     ;

simplstmt : assignstmt
          | iostmt
          | returnstmt
          ;

structstmt : ifstmt
           | whilestmt
           | cmpdstmt
           ;

cmpdstmt : '{' stmtlist '}'
         ;

assignstmt : IDENTIFIER '=' expression
           ;

iostmt : "cout<<" '(' IDENTIFIER ')'
       | "cin>>" '(' expression ')'
       ;

ifstmt : IF '(' condition ')' stmt %prec LOWER_THAN_ELSE
       | IF '(' condition ')' stmt ELSE stmt
       ;

whilestmt : WHILE '(' condition ')' stmt
          ;

returnstmt : RETURN expression
           | RETURN
           ;

// Expressions

expression : expression '+' term
           | expression '-' term
           | term
           ;

term : term '*' factor
     | term '/' factor
     | term '%' factor
     | factor
     ;

factor : IDENTIFIER
       | INT_CONST
       | CHAR_CONST
       | STRING_CONST
       | '(' expression ')'
       ;

condition : expression rel_op expression
          ;

rel_op : EQ
       | NEQ
       | '<'
       | LEQ
       | '>'
       | GEQ
       ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
