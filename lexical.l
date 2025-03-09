%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "syntaxique.tab.h"

    extern int nb_ligne;
    extern int col;

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

/* Mots-clés */
"MainPrgm"  { return MainPrgm; }
"Var"       { return Var; }
"BeginPg"   { return BeginPg; }
"EndPg"     { return EndPg; }
"input"     { return input; }
"output"    { return output; }
"Int"       { return Int; }
"Float"     { return Float; }
"let"       { return let; }
"if"        { return if; }
"then"      { return then; }
"else"      { return else; }
"do"        { return do; }
"while"     { return while; }
"for"       { return for; }
"from"      { return from; }
"to"        { return to; }
"step"      { return step; }
"@define"   { return define; }
"Const"     { return Const; }

/* Symboles et opérateurs */
":=" { return aff; }
":"  { return separ_dec; }
";"  { return pvg; }
","  { return vg; }
"+"  { return add; }
"-"  { return sous; }
"*"  { return mult; }
"/"  { return div; }
"<=" { return inf_egal; }
">=" { return sup_egal; }
"<"  { return inf; }
">"  { return sup; }
"="  { return aff_const; }
"==" { return egal; }
"!=" { return not_egal; }
"{"  { return acc_ouv; }
"}"  { return acc_fer; }
"("  { return par_ouv; }
")"  { return par_fer; }


/* Opérateurs logiques */
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
{constante} { yylval.entier = atoi(yytext); return constante; }
{float} { yylval.reel = atof(yytext); return Float; }
{chaine} { yylval.chaine = strdup(yytext); return chaine; }
{commentLigne}  { /* Ignorer les commentaires sur une ligne */ }
{commentLignes} { /* Ignorer les commentaires multi-lignes */ }

[ \t]  ;

\n { nb_ligne++; }

/* Gestion des erreurs lexicales */
. { printf("Erreur lexicale à la ligne %d: caractère inattendu '%s'\n", nb_ligne, yytext); }

%%

int main() {
    yylex();
    free(yylval.chaine);

    return 0;
}
