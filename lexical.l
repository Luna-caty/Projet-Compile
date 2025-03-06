%{
    #include <stdio.h>
    #include "syntaxique.tab.h"
    extern int nb_ligne = 1;
    extern int col = 0;
    
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
/* Mots-clé */
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
"@define"   { return @define; }
"Const"     { return Const; }


/* symboles et opérateurs */
":=" {return aff;}
":"  {return separ_dec; }
";"  { return pvg; }
","  { return vg }
"+"  { return add; }
"-"  { return sous; }
"*"  { return mult; }
"/"  { return div; }
"<=" { return inf_egal; }
">=" { return sup_egal; }
"<"  {return inf; }
">"  { return sup; }
"=" { return aff_const; }
"=="  { return egal; }
"!="  { return not_egal; }
"{"  { return acc_ouv; }
"}"  { return acc_fer; }
"("  { return par_ouv; }
")"  { return par_fer; }
"["  { return crochet_ouv; }
"]"  { return crochet_fer; }
"\"" { printf(" Guillemets \n"); }

/* opérateurs logique */
"AND" { return AND; }
"OR"  { return OR; }
"!"   { return not; }

{IDF} { 
    if (yyleng <= 14)  
        printf("IDF\n");  
    else  
        printf("Erreur lexicale : IDF trop long\n");  
}
{constante} { printf(" Constante entiere : %s \n", yytext); }
{float} { printf(" Constante flottante : %s \n", yytext); }
{chaine} { printf(" Chaine de caracteres : %s \n", yytext); }


{commentLigne}  { printf(" Commentaire sur une seule ligne \n"); }
{commentLignes} { printf(" Commentaire sur plusieurs lignes \n"); }


[ \t]  ;  
\n { nb_ligne++; }  


. { printf("Erreur lexicale à la ligne %d: caractere inattendu '%s' \n", nb_ligne, yytext); }

%%

int main ()
{
    yylex();
    return 0;
}

