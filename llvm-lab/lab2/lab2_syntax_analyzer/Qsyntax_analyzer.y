%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/common.h"
#include "syntax_tree/SyntaxTree.h"

#include "lab1_lexical_analyzer/lexical_analyzer.h"

// external functions from lex
extern int yylex();
extern int yyparse();
extern int yyrestart();
extern FILE * yyin;

// external variables from lexical_analyzer module
extern int lines;
extern char * yytext;
extern int yylval;

// Global syntax tree.
SyntaxTree * gt, new;

void yyerror(const char * s);
%}

%union {
/********** TODO: Fill in this union structure *********/
char * string;
void vval;
SyntaxTreeNode * n;
}

/********** TODO: Your token definition here ***********/
%token <vval> ERROR
%token <string> ADD SUB MUL DIV
%token <string> LT LTE GT GTE EQ NEQ
%token <string> ASSIN
%token <string> SEMICOLON COMMA
%token <string> LPARENTHESE RPARENTHESE LBRACKET RBRACKET LBRACE RBRACE
%token <string> ELSE IF INT RETURN VOID WHILE
%token <string> IDENTIFIER
%token <string> NUMBER LETTER
%token <string> ARRAY
%token <vval> EOL COMMENT BLANK
%type <n> program declarationlist declaration vardeclaration typespecifier fundeclaration params
%type <n> paramlist param compoundstmt localdeclarations statementlist statement expressionstmt
%type <n>selectionstmt iterationstmt returnstmt expression var simpleexpression relop
%type <n> additiveexpression addop term mulop factor call args arglist 
/* compulsory starting symbol */
%start program

%%
/*************** TODO: Your rules here *****************/
program : declarationlist { gt = newSyntaxTree(); gt->root = newSyntaxTreeNode("program"); $$ = gt->root; SyntaxTreeNode_AddChild($$, $1); printSyntaxTree(stdout, gt); }
	;
declarationlist : declarationlist declaration { $$ = newSyntaxTreeNode("declarationlist"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| declaration { $$ = newSyntaxTreeNode("declarationlist"); SyntaxTreeNode_AddChild($$, $1); }
	;
declaration : vardeclaration { $$ = newSyntaxTreeNode("declaration"); SyntaxTreeNode_AddChild($$, $1); }
	| fundeclaration { $$ = newSyntaxTreeNode("declaration"); SyntaxTreeNode_AddChild($$, $1); }
	;
vardeclaration :typespecifier IDENTIFIER { $2 = newSyntaxTreeNode(yytext); } SEMICOLON { $3 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("vardeclaration"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| typespecifier IDENTIFIER { $2 = newSyntaxTreeNode(yytext); } LBRACKET { $3 = newSyntaxTreeNode("["); } NUMBER { $4 = newSyntaxTreeNode(yytext); } RBRACKET { $5 = newSyntaxTreeNode("]"); } SEMICOLON { $6 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("vardeclaration"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); SyntaxTreeNode_AddChild($$, $5); SyntaxTreeNode_AddChild($$, $6); }
	;
typespecifier : INT { $1 = newSyntaxTreeNode("int"); $$ = newSyntaxTreeNode("typespecifier"); SyntaxTreeNode_AddChild($$, $1); }
	| VOID { $1 = newSyntaxTreeNode("void"); $$ = newSyntaxTreeNode("typespecifier"); SyntaxTreeNode_AddChild($$, $1); }
	;
fundeclaration : typespecifier IDENTIFIER { $2 = newSyntaxTreeNode(yytext); } LPARENTHESE params RPARENTHESE compoundstmt { $3 = newSyntaxTreeNode("("); $5 = newSyntaxTreeNode(")"); $$ = newSyntaxTreeNode("fundeclaration"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); SyntaxTreeNode_AddChild($$, $5); SyntaxTreeNode_AddChild($$, $6); }
	;
params : paramlist { $$ = newSyntaxTreeNode("params"); SyntaxTreeNode_AddChild($$, $1); }
	| VOID { $1 = newSyntaxTreeNode("void"); $$ = newSyntaxTreeNode("params"); SyntaxTreeNode_AddChild($$, $1); }
	;
paramlist: paramlist COMMA param { $2 = newSyntaxTreeNode(","); $$ = newSyntaxTreeNode("paramlist"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| param { $$ = newSyntaxTreeNode("paramlist"); SyntaxTreeNode_AddChild($$, $1); }
	;
param : typespecifier IDENTIFIER { $2 = newSyntaxTreeNode(yytext); $$ = newSyntaxTreeNode("param"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| typespecifier IDENTIFIER { $2 = newSyntaxTreeNode(yytext); } ARRAY { $3 = newSyntaxTreeNode("[]"); $$ = newSyntaxTreeNode("param"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	;
compoundstmt : LBRACE localdeclarations statementlist RBRACE { $1 = newSyntaxTreeNode("{"); $4 = newSyntaxTreeNode("}"); $$ = newSyntaxTreeNode("compoundstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); }
	;
localdeclarations : localdeclarations vardeclaration { $$ = newSyntaxTreeNode("localdeclarations"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| /* empty */ { new = newSyntaxTreeNode("epsilon"); $$ = newSyntaxTreeNode("localdeclarations"); SyntaxTreeNode_AddChild($$, new); }
	;
statementlist : statementlist statement { $$ = newSyntaxTreeNode("statementlist"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| /* empty */ { new = newSyntaxTreeNode("epsilon"); $$ = newSyntaxTreeNode("statementlist"); SyntaxTreeNode_AddChild($$, new); }
	;
statement : expressionstmt { $$ = newSyntaxTreeNode("statement"); SyntaxTreeNode_AddChild($$, $1); }
	| compoundstmt { $$ = newSyntaxTreeNode("statement"); SyntaxTreeNode_AddChild($$, $1); }
	| selectionstmt { $$ = newSyntaxTreeNode("statement"); SyntaxTreeNode_AddChild($$, $1); }
	| iterationstmt { $$ = newSyntaxTreeNode("statement"); SyntaxTreeNode_AddChild($$, $1); }
	| returnstmt { $$ = newSyntaxTreeNode("statement"); SyntaxTreeNode_AddChild($$, $1); }
	;
expressionstmt : expression SEMICOLON { $2 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("expressionstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| SEMICOLON { $1 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("expressionstmt"); SyntaxTreeNode_AddChild($$, $1); }
	;
selectionstmt : IF LPARENTHESE expression RPARENTHESE statement { $1 = newSyntaxTreeNode("if"); $2 = newSyntaxTreeNode("("); $4 = newSyntaxTreeNode(")"); $$ = newSyntaxTreeNode("selectionstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); SyntaxTreeNode_AddChild($$, $5); }
	| IF LPARENTHESE expression RPARENTHESE statement ELSE statement { $1 = newSyntaxTreeNode("if"); $2 = newSyntaxTreeNode("("); $4 = newSyntaxTreeNode(")"); $6 = newSyntaxTreeNode(")"); $$ = newSyntaxTreeNode("selectionstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); SyntaxTreeNode_AddChild($$, $5); SyntaxTreeNode_AddChild($$, $6); SyntaxTreeNode_AddChild($$, $7); }
	;
iterationstmt : WHILE LPARENTHESE expression RPARENTHESE statement { $1 = newSyntaxTreeNode("while"); $2 = newSyntaxTreeNode("("); $4 = newSyntaxTreeNode(")"); $$ = newSyntaxTreeNode("iterationstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); SyntaxTreeNode_AddChild($$, $5); }
	;
returnstmt : RETURN SEMICOLON { $1 = newSyntaxTreeNode("return"); $2 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("returnstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); }
	| RETURN expression SEMICOLON { $1 = newSyntaxTreeNode("return"); $3 = newSyntaxTreeNode(";"); $$ = newSyntaxTreeNode("returnstmt"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	;
expression : var ASSIN expression { $$ = newSyntaxTreeNode("expression"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| simpleexpression { $$ = newSyntaxTreeNode("expression"); SyntaxTreeNode_AddChild($$, $1); }
	;
var : IDENTIFIER { $1 = newSyntaxTreeNode(yytext); $$ = newSyntaxTreeNode("var"); SyntaxTreeNode_AddChild($$, $1); }
	| IDENTIFIER { $1 = newSyntaxTreeNode(yytext); } LBRACKET expression RBRACKET { $2 = newSyntaxTreeNode("["); $4 = newSyntaxTreeNode("]"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); }
	;
simpleexpression : additiveexpression relop additiveexpression { $$ = newSyntaxTreeNode("simpleexpression"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| additiveexpression { $$ = newSyntaxTreeNode("simpleexpression"); SyntaxTreeNode_AddChild($$, $1); }
	;
relop : LTE { $1 = newSyntaxTreeNode("<="); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	| LT { $1 = newSyntaxTreeNode("<"); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	| GT { $1 = newSyntaxTreeNode(">"); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	| GTE { $1 = newSyntaxTreeNode(">="); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	| EQ { $1 = newSyntaxTreeNode("=="); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	| NEQ { $1 = newSyntaxTreeNode("!="); $$ = newSyntaxTreeNode("relop"); SyntaxTreeNode_AddChild($$, $1); }
	;
additiveexpression : additiveexpression addop term { $$ = newSyntaxTreeNode("term"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| term { $$ = newSyntaxTreeNode("term"); SyntaxTreeNode_AddChild($$, $1); }  
	;
addop : ADD { $1 = newSyntaxTreeNode("+"); $$ = newSyntaxTreeNode("addop"); SyntaxTreeNode_AddChild($$, $1); }
	| SUB { $1 = newSyntaxTreeNode("-"); $$ = newSyntaxTreeNode("addop"); SyntaxTreeNode_AddChild($$, $1); }
	;
term : term mulop factor { $$ = newSyntaxTreeNode("term"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| factor { $$ = newSyntaxTreeNode("term"); SyntaxTreeNode_AddChild($$, $1); }
	;
mulop : MUL { $1 = newSyntaxTreeNode("*"); $$ = newSyntaxTreeNode("mulop"); SyntaxTreeNode_AddChild($$, $1); }
	| DIV { $1 = newSyntaxTreeNode("/"); $$ = newSyntaxTreeNode("mulop"); SyntaxTreeNode_AddChild($$, $1); }
	;
factor : LPARENTHESE expression RPARENTHESE { $$ = newSyntaxTreeNode("factor"); $1 = newSyntaxTreeNode("("); $3 = newSyntaxTreeNode(")"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| var { $$ = newSyntaxTreeNode("factor"); SyntaxTreeNode_AddChild($$, $1); }
	| call { $$ = newSyntaxTreeNode("factor"); SyntaxTreeNode_AddChild($$, $1); }
	| NUMBER { $1 = newSyntaxTreeNode(yytext); $$ = newSyntaxTreeNode("factor"); SyntaxTreeNode_AddChild($$, $1); }
	;
call :IDENTIFIER { $1 = newSyntaxTreeNode(yytext); } LPARENTHESE args RPARENTHESE { $2 = newSyntaxTreeNode("("); $4 = newSyntaxTreeNode(")"); $$ = newSyntaxTreeNode("call"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); SyntaxTreeNode_AddChild($$, $4); }
	;
args : arglist { $$ = newSyntaxTreeNode("args"); SyntaxTreeNode_AddChild($$, $1); }
	| /* empty */ { $$ = newSyntaxTreeNode("args"); new = newSyntaxTreeNode("epsilon"); SyntaxTreeNode_AddChild($$, new); }
	;
arglist : arglist COMMA expression { $2 = newSyntaxTreeNode(","); $$ = newSyntaxTreeNode("arglist"); SyntaxTreeNode_AddChild($$, $1); SyntaxTreeNode_AddChild($$, $2); SyntaxTreeNode_AddChild($$, $3); }
	| expression { $$ = newSyntaxTreeNode("arglist"); SyntaxTreeNode_AddChild($$, $1); }
	;

%%

void yyerror(const char * s)
{
	// TODO: variables in Lab1 updates only in analyze() function in lexical_analyzer.l
	//       You need to move position updates to show error output below
	fprintf(stderr, "%s:%d syntax error for %s\n", s, lines, yytext);
}

/// \brief Syntax analysis from input file to output file
///
/// \param input basename of input file
/// \param output basename of output file
void syntax(const char * input, const char * output)
{
	gt = newSyntaxTree();

	char inputpath[256] = "./testcase/";
	char outputpath[256] = "./syntree/";
	strcat(inputpath, input);
	strcat(outputpath, output);

	if (!(yyin = fopen(inputpath, "r"))) {
		fprintf(stderr, "[ERR] Open input file %s failed.", inputpath);
		exit(1);
	}
	yyrestart(yyin);
	printf("[START]: Syntax analysis start for %s\n", input);
	FILE * fp = fopen(outputpath, "w+");
	if (!fp)	return;

	// yyerror() is invoked when yyparse fail. If you still want to check the return value, it's OK.
	// `while (!feof(yyin))` is not needed here. We only analyze once.
	yyparse();

	printf("[OUTPUT] Printing tree to output file %s\n", outputpath);
	printSyntaxTree(fp, gt);
	deleteSyntaxTree(gt);
	gt = 0;

	fclose(fp);
	printf("[END] Syntax analysis end for %s\n", input);
}

/// \brief starting function for testing syntax module.
///
/// Invoked in test_syntax.c
int syntax_main(int argc, char ** argv)
{
	char filename[10][256];
	char output_file_name[256];
	const char * suffix = ".syntax_tree";
	int fn = getAllTestcase(filename);
	for (int i = 0; i < fn; i++) {
			int name_len = strstr(filename[i], ".cminus") - filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			syntax(filename[i], output_file_name);
	}
	return 0;
}
