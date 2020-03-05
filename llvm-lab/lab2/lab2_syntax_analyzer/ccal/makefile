cal: cal.l cal.y
	bison -d cal.y
	flex cal.l
	gcc -o cal cal.tab.c lex.yy.c -lfl

clean:
	rm -rf cal.tab*
	rm -rf lex.yy.c
	rm -rf cal
