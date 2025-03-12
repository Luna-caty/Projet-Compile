%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "syntaxique.tab.h"
    #include "table_sym.h"

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


"MainPrgm"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return MainPrgm; 
}
"Var"       { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return Var; 
}
"BeginPg"   { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return BeginPg; 
}
"EndPg"     { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return EndPg; 
}
"input"     { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return input_var; 
}
"output"    { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return output_var; 
}
"Int"       { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return Int; 
}
"Float"     { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return reel; 
}
"let"       { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return let; 
}
"if"        { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return IF; 
}
"then"      { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return THEN; 
}
"else"      { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return ELSE; 
}
"do"        { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return DO; 
}
"while"     { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return WHILE; 
}
"for"       { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return FOR; 
}
"from"      { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return FROM; 
}
"to"        { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return TO; 
}
"step"      { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return STEP; 
}
"define"    { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return define; 
}
"@"         { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return at_sign; 
}
"Const"     { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Mot cle", 1);
    }
    return constante; 
}


":=" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return aff; 
}
"="  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return affect_val; 
}
":"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return separ_dec; 
}
";"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return pvg; 
}
","  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return vg; 
}
"+"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return add; 
}
"-"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return sous; 
}
"*"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return mult; 
}
"/"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return division; 
}
"<=" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return inf_egal; 
}
">=" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return sup_egal; 
}
"<"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return inf; 
}
">"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return sup; 
}
"==" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return egal; 
}
"!=" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return not_egal; 
}
"{"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return acc_ouv; 
}
"}"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return acc_fer; 
}
"("  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return par_ouv; 
}
")"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return par_fer; 
}
"["  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return crochet_ouv; 
}
"]"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Separateur", 1);
    }
    return crochet_fer; 
}



"AND" { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return AND; 
}
"OR"  { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return OR; 
}
"!"   { 
    if(!rechercherMcSep(yytext)) {
        insererMcSep(yytext, "Operateur", 1);
    }
    return NOT; 
}

{IDF} { 
    if (yyleng <= 14)  
        yylval.chaine = strdup(yytext); 
    else  
        printf("Erreur lexicale : Identificateur trop long '%s' (ligne %d)\n", yytext, nb_ligne);
    
    if(!rechercherIdfConst(yytext))
    {
        insererIdfConst(yytext,"IDF","","",1);
    }
    return IDF;
}
{constante} { yylval.entier = atoi(yytext);
 if (yylval.entier < -32768 || yylval.entier > 32767) 
    printf("Erreur lexicale : Constante entière hors limites '%s' (ligne %d)\n", yytext, nb_ligne);
if(!rechercherIdfConst(yytext))
    {
        insererIdfConst(yytext,"constante","int",yytext,1);
    }
    return constante; }

{float} { yylval.reel = atof(yytext); return reel; 
if(!rechercherIdfConst(yytext))
    {
        insererIdfConst(yytext,"constante","float",yytext,1);
    }


}
{chaine} { yylval.chaine = strdup(yytext); return chaine; }
{commentLigne}  {printf("Commentaire sur une seule ligne"); }
{commentLignes} {printf("Commentaire sur plusieurs lignes");}

[ \t]  ;

\n { nb_ligne++; }

. { printf("Erreur lexicale à la ligne %d: caractère inattendu '%s'\n", nb_ligne, yytext); }

%%

