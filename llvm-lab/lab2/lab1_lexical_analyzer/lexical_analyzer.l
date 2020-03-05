%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>
#include "../lab1_lexical_analyzer/lexical_analyzer.h"
//#include "lexical_analyzer.h"
#include "../common/common.h"
#include "../syntax_tree/SyntaxTree.h"
#include "../syntax_tree/SyntaxTree.c"
#define YYSTYPE SyntaxTreeNode*

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif

int lines=1;
int pos_start;
int pos_end;
int last_comment=0;
int n=0;
SyntaxTreeNode* yylval; 

/*****************声明和选项设置  end*****************/






%}

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/
%%
[+]	{yylval = newSyntaxTreeNode("+");pos_end=pos_start+1;return ADD;}      
[-]	{yylval = newSyntaxTreeNode("-");pos_end=pos_start+1;return SUB;}	
[*]	{yylval = newSyntaxTreeNode("*");pos_end=pos_start+1;return MUL;}	
[/]	{yylval = newSyntaxTreeNode("/");pos_end=pos_start+1;return DIV;}	
[<]	{yylval = newSyntaxTreeNode("<");pos_end=pos_start+1;return LT;}	
[<][=]	{yylval = newSyntaxTreeNode("<=");pos_end=pos_start+2;return LTE;}	
[>]	{yylval = newSyntaxTreeNode(">");pos_end=pos_start+1;return GT;}	
[>][=]	{yylval = newSyntaxTreeNode(">=");pos_end=pos_start+2;return GTE;}	
[=][=]	{yylval = newSyntaxTreeNode("==");pos_end=pos_start+2;return EQ;}	
[!][=]	{yylval = newSyntaxTreeNode("!=");pos_end=pos_start+2;return NEQ;}	
[=]	{yylval = newSyntaxTreeNode("=");pos_end=pos_start+1;return ASSIN;}	
[;]	{yylval = newSyntaxTreeNode(";");pos_end=pos_start+1;return SEMICOLON;}	
[,]	{yylval = newSyntaxTreeNode(",");pos_end=pos_start+1;return COMMA;}	
\(	{yylval = newSyntaxTreeNode("(");pos_end=pos_start+1;return LPARENTHESE;}	
\)	{yylval = newSyntaxTreeNode(")");pos_end=pos_start+1;return RPARENTHESE;}	
\[	{yylval = newSyntaxTreeNode("[");pos_end=pos_start+1;return LBRACKET;}	
\]	{yylval = newSyntaxTreeNode("]");pos_end=pos_start+1;return RBRACKET;}	
\{	{yylval = newSyntaxTreeNode("{");pos_end=pos_start+1;return LBRACE;}	
\}	{yylval = newSyntaxTreeNode("}");pos_end=pos_start+1;return RBRACE;}	
else	{yylval = newSyntaxTreeNode("else");pos_end=pos_start+4;return ELSE;}	
if	{yylval = newSyntaxTreeNode("if");pos_end=pos_start+2;return IF;}			
int	{yylval = newSyntaxTreeNode("int");pos_end=pos_start+3;return INT;}	
return	{yylval = newSyntaxTreeNode("return");pos_end=pos_start+6;return RETURN;}	
void	{yylval = newSyntaxTreeNode("void");pos_end=pos_start+4;return VOID;}	
while	{yylval = newSyntaxTreeNode("while");pos_end=pos_start+5;return WHILE;}	
[0-9]+	{yylval = newSyntaxTreeNode(yytext);pos_end=pos_start+strlen(yytext);return NUMBER;} 	
\n|\r	{lines++;pos_start=1;pos_end=1;/*return EOL;*/}
\/\*([^\*]|(\*)*[^\*\/])*(\*)*\*\/	{
			last_comment=-pos_start;
			for(int i=0;i<strlen(yytext);i++)
				{if(yytext[i]=='\n')
					{lines++;
					last_comment=i;
					n=1;
					}
				} 
					pos_start=strlen(yytext)-last_comment; 
					pos_end=strlen(yytext)-last_comment;	
			/*return COMMENT;*/
			}
[ ]|\t	{pos_start++;pos_end++;/*return BLANK;*/}		
[a-zA-Z]+	{yylval = newSyntaxTreeNode(yytext);pos_end=pos_start+strlen(yytext);return IDENTIFIER;}	
\[\]		{pos_end=pos_start+2;return ARRAY;}	
. {return ERROR;}


 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");

	int token;
	while(token = yylex()){
		switch(token){
			case ERROR:
				pos_end=pos_start+strlen(yytext);
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				pos_start=pos_end;
				break;
			case COMMENT:
			case BLANK:
				break;
			case EOL:
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
				pos_start=pos_end;
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[50][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	int files_count;
	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			analyzer(filename[i],output_file_name);
	}
	return 0;
}
/****************C代码 end*************/
