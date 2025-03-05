%{
    #include <stdio.h>
    int nb_ligne = 1;
    int col = 0;
    
    int yywrap(void) {
        return 1;
    }
%}

lettre [a-z]
chiffre [0-9]
IDF {lettre}({lettre}|{chiffre})*(_({lettre}|{chiffre})+)?
cst {chiffre}+                           
flt {chiffre}+"."{chiffre}+              
chaine \"([^\"\\]|\\.)*\"                
commentLigne "<!-"[^\n-].*?"-!>"
commentLignes "{--"(.|\n)*"--}"
%%

"MainPrgm"  { printf(" Mot cle : Main Program \n"); }
"var"       { printf(" Debut de la partie declaration \n"); }
"Beginpg"   { printf(" Debut du programme \n"); }
"Endpg"     { printf(" Fin du programme \n"); }
"input"     { printf(" Instruction de lecture \n"); }
"output"    { printf(" Instruction d'ecriture \n"); }
"Int"       { printf(" Type entier \n"); }
"float"     { printf(" Type flottant \n"); }
"let"       { printf(" Declaration de variable \n"); }
"if"        { printf(" Instruction conditionnelle if \n"); }
"then"      { printf(" Instruction conditionnelle then \n"); }
"else"      { printf(" Instruction conditionnelle else \n"); }
"do"        { printf(" Boucle do-while \n"); }
"while"     { printf(" Boucle while \n"); }
"for"       { printf(" Boucle for \n"); }
"from"     { printf(" Mot-cle 'from' dans une boucle \n"); }
"to"        { printf(" Mot-cle 'to' dans une boucle \n"); }
"step"      { printf(" Mot-cle 'step' (pas de boucle) \n"); }
"@define"   { printf(" Definition de constante \n"); }
"Const"     { printf(" Mot-cle 'Const' \n"); }


":=" { printf(" Oprateur affectation \n"); }
":"  { printf(" Separateur de declaration de type \n"); }
";"  { printf(" Point-virgule \n"); }
","  { printf(" Virgule \n"); }
"+"  { printf(" Addition \n"); }
"-"  { printf(" Soustraction \n"); }
"*"  { printf(" Multiplication \n"); }
"/"  { printf(" Division \n"); }
"<=" { printf(" Inferieur ou égal \n"); }
">=" { printf(" Superieur ou égal \n"); }
"<"  { printf(" Inferieur \n"); }
">"  { printf(" Superieur \n"); }
"=="  { printf(" Operateur egalite \n"); }
"!="  { printf(" Operateur NOT \n"); }
"{"  { printf(" Accolade ouvrante \n"); }
"}"  { printf(" Accolade fermante \n"); }
"("  { printf(" Parenthese ouvrante \n"); }
")"  { printf(" Parenthese fermante \n"); }
"["  { printf(" Crochet ouvrant \n"); }
"]"  { printf(" Crochet fermant \n"); }
"\"" { printf(" Guillemets \n"); }


"and" { printf(" Operateur logique AND \n"); }
"or"  { printf(" Operateur logique OR \n"); }
"!"   { printf(" Operateur logique NOT \n"); }

{IDF} { 
    if (yyleng <= 14)  
        printf("IDF\n");  
    else  
        printf("Erreur lexicale : IDF trop long\n");  
}
{cst} { printf(" Constante entiere : %s \n", yytext); }
{flt} { printf(" Constante flottante : %s \n", yytext); }
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
