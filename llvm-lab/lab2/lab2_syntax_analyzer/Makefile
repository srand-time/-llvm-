cal: lexical_analyzer.l syntax_analyzer.y
	bison -d syntax_analyzer.y
	flex cal.l
	gcc -o analyzer analyzer.tab.c lex.yy.c -lfl

clean:
	rm -rf analyzer.tab*
	rm -rf lex.yy.c
	rm -rf analyzer
