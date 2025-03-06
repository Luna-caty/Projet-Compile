flex lexical.l 
gcc lex.yy.c -o test
test.exe < programme.txt
pause
