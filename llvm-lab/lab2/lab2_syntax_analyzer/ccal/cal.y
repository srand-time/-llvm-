%{
//在%{和%}中的代码会被原样照抄到生成的name.tab.c文件的开头，可以在这里书写声明与定义
#include <stdio.h>
%}

/*声明tokens，告诉bison在语法分析程序中记号的名称*/
%token NUMBER
%token ADD SUB MUL DIV ABS
%token EOL

%%
/*该部分定义规则，C的动作代码在每条规则后用花括号括起*/
calclist: /*空规则*/
	| calclist exp EOL { printSyntaxTree(stdout, tree); }
	;
exp:factor {  }
	| exp ADD factor {  }
	| exp SUB factor {  }
	;
factor:term {  }
	| factor MUL term { }
	| factor DIV term { }
	;
term:NUMBER {  }
	| ABS term {  }
	;
%%

int main(int argc, char **argv){
    yyparse();
    return 0;
}
int yyerror(char *s) {
    fprintf(stderr, "error: %s\n", s);
}
