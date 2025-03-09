flex lexical.l 
bison -d -v syntaxique.y
gcc lex.yy.c syntaxique.tab.c  -lfl -ly -o  test
test.exe < programme.txt
pause
