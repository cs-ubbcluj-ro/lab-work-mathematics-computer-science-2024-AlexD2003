%{
#include "parser.tab.h"
%}

%%

"int"       { return INT; }
"float"     { return FLOAT; }
"char"      { return CHAR; }
"void"      { return VOID; }
"bool"      { return BOOL; }
"class"     { return CLASS; }
"return"    { return RETURN; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"true"|"false" { return BOOLEAN_LITERAL; }

[a-zA-Z_][a-zA-Z0-9_]*   { yylval.strval = strdup(yytext); return IDENTIFIER; }
[0-9]+                   { yylval.intval = atoi(yytext); return INT_CONST; }
'.'                      { return CHAR_CONST; }
\".*\"                   { return STRING_CONST; }
[+*/%=-]                 { return OPERATOR; }
[><]=?                   { return OPERATOR; }    // Handle >, <, >=, <=
[{}();,.]                { return SEPARATOR; }   // Include . and , as separators
[ \t\n]                  { /* ignore whitespace */ }
.                        { printf("Unrecognized character: %s\\n", yytext); }

%%
