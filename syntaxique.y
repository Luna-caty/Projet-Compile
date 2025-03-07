%{
#include <stdio.h>
int nb_ligne = 1;
int col = 0;    
%}

/* Specificaton des types */
%union {
    int entier;
    float reel;
    char* chaine;
}
/* partie token */
%token <chaine> MainPrgm Var BeginPg EndPg input output   
%token <chaine>IDF let @define chaine
%token <entier> Int constante 
%token <reel> Float
%token <chaine> if then else do while for from to step 
%token <chaine> OR  AND not
%token <chaine> aff aff_const pvg vg separ_dec add sous mult div   
%token <chaine> inf_egal sup_egal inf sup egal not_egal
%token <chaine> acc_ouv acc_fer
%token <chaine> par_ouv par_fer
%token <chaine> crochet_ouv crochet_fer


/* specification des priorités */
%left OR
%left AND
%left !
%left '<' '>' '<=' '>=' '==' '!='
%left '+' '-'
%left '*' '/'
/* L'axiome */
%start prgm

%%
/* regle grammaire */
prgm: MainPrgm IDF pvg Var BeginPg  acc_ouv acc_fer EndPg pvg
{printf("Structure correcte\n");}
    ;

inOut:
    input par_ouv IDF par_fer pvg
    | output par_ouv chaine par_fer pvg

affectation :
    IDF aff constante pvg
    | IDF aff_const constante pvg
    | IDF aff_const Float pvg
    | IDF aff_const chaine pvg