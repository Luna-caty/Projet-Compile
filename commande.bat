flex lexical.l 
bison -d -v syntaxique.y
gcc lex.yy.c syntaxique.tab.c  -o  test
test.exe < programme.txt
pause
