%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "syntaxique.tab.h"

     int nb_ligne=1;
     int col=0;

    int yywrap(void) {
        return 1;
    }
%}


lettre [a-zA-Z]
chiffre [0-9]
IDF {lettre}({lettre}|{chiffre}|_)*
constante [+-]?{chiffre}+
float [+-]?{chiffre}+\.{chiffre}+
chaine \"([^\"\\]|\\.)*\"
commentLigne "<!-"[^!]*"!->"
commentLignes "{--"(.|\n)*"--}"

%%


"MainPrgm"  { return MainPrgm; }
"Var"       { return Var; }
"BeginPg"   { return BeginPg; }
"EndPg"     { return EndPg; }
"input"     { return input_var; }
"output"    { return output_var; }
"Int"       { return Int; }
"Float"     { return reel; }
"let"       { return let; }
"if"        { return IF; }
"then"      { return THEN; }
"else"      { return ELSE; }
"do"        { return DO; }
"while"     { return WHILE; }
"for"       { return FOR; }
"from"      { return FROM; }
"to"        { return TO; }
"step"      { return STEP; }
"define"   { return define; }
"@"        { return at_sign; }
"Const"     { return constante; }


":=" { return aff; }
"="  { return affect_val; }
":"  { return separ_dec; }
";"  { return pvg; }
","  { return vg; }
"+"  { return add; }
"-"  { return sous; }
"*"  { return mult; }
"/"  { return division; }
"<=" { return inf_egal; }
">=" { return sup_egal; }
"<"  { return inf; }
">"  { return sup; }
"==" { return egal; }
"!=" { return not_egal; }
"{"  { return acc_ouv; }
"}"  { return acc_fer; }
"("  { return par_ouv; }
")"  { return par_fer; }
"["  { return crochet_ouv; }
"]"  { return crochet_fer; }



"AND" { return AND; }
"OR"  { return OR; }
"!"   { return NOT; }

{IDF} { 
    if (yyleng <= 14)  
        yylval.chaine = strdup(yytext); 
    else  
        printf("Erreur lexicale : Identificateur trop long '%s' (ligne %d)\n", yytext, nb_ligne);
    return IDF;
}
{constante} { yylval.entier = atoi(yytext);
 if (yylval.entier < -32768 || yylval.entier > 32767) 
    printf("Erreur lexicale : Constante entière hors limites '%s' (ligne %d)\n", yytext, nb_ligne);
    return constante; }

{float} { yylval.reel = atof(yytext); return reel; }
{chaine} { yylval.chaine = strdup(yytext); return chaine; }
{commentLigne}  {printf("Commentaire sur une seule ligne"); }
{commentLignes} {printf("Commentaire sur plusieurs lignes");}

[ \t]  ;

\n { nb_ligne++; }

. { printf("Erreur lexicale à la ligne %d: caractère inattendu '%s'\n", nb_ligne, yytext); }

%%

