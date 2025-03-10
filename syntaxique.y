%{
#include <stdio.h>
extern int nb_ligne;
extern int col;
extern int yylex();  
void yyerror(const char *msg);
int yywrap();
%}

/* Specification des types */
%union {
    int entier;
    float reel;
    char* chaine;
}
/* partie token */
%token <chaine> MainPrgm Var BeginPg EndPg input_var output_var Const  
%token <chaine>IDF let define at_sign chaine 
%token <entier> Int constante
%token <reel> reel
%token <chaine> IF THEN ELSE DO WHILE FOR FROM TO STEP
%token <chaine> OR AND NOT
%token <chaine> aff affect_val pvg vg separ_dec add sous mult division   
%token <chaine> inf_egal sup_egal inf sup egal not_egal
%token <chaine> acc_ouv acc_fer
%token <chaine> par_ouv par_fer
%token <chaine> crochet_ouv crochet_fer


/* specification des priorités */
%left OR
%left AND
%left NOT
%left inf sup inf_egal sup_egal egal not_egal
%left add sous
%left mult division
/* L'axiome */
%start programme

%%
/* regle grammaire */
programme: MainPrgm IDF pvg Var declarations BeginPg acc_ouv instructions acc_fer EndPg pvg
{printf("Structure correcte\n");}
    ;

/* ce non terminal veut dire que une instruction peut etre une aff input/output condition boucle */
instruction:
    affectation
  | inOut
  | condition
  | boucle
;

op_cmp:
    inf_egal
    | sup_egal
    | inf
    | sup
    | egal
    | not_egal
;

//pour assurer que chaque instruction se termine par un point virgule
//gerer une ou plusieurs instructions 
/* instructions -> instruction pvg | instructions instruction pvg */

instructions:
    instruction
  | instructions instruction
;

/* c'est pour les expressions conditionelles et logique 
comapaison entre une variable et une constante
comparaison entre deux variables
..........
 */

expression:
    IDF
    | constante
    | reel
    | chaine
    | IDF crochet_ouv expression crochet_fer  /* pour les tableaux */
    | expression op_cmp expression
    | par_ouv expression AND expression par_fer
    | par_ouv expression OR expression par_fer
    | NOT par_ouv expression par_fer
    | expression add expression
    | expression sous expression
    | expression mult expression
    | expression division expression
    | par_ouv expression par_fer
;

type:
    Int
  | reel
;

declaration:
    let liste_idf separ_dec type pvg
  | let liste_idf separ_dec declaration_tableau
;

declaration_tableau:
    crochet_ouv type pvg constante crochet_fer pvg
;

liste_idf:
    IDF
    | liste_idf vg IDF
;

const_declaration:
    at_sign define Const IDF separ_dec type affect_val constante pvg
;
declarations:
    declaration
  | const_declaration   
  | declarations declaration
  | declarations const_declaration
  | /* vide */
;

inOut:
    input_var par_ouv IDF par_fer pvg
    | output_var par_ouv IDF par_fer pvg
    | output_var par_ouv expression par_fer pvg
    | output_var par_ouv chaine par_fer pvg
;

affectation:
    IDF aff expression pvg
    | IDF crochet_ouv expression crochet_fer aff expression pvg
;

condition:
    IF par_ouv expression par_fer THEN acc_ouv instructions acc_fer
    | IF par_ouv expression par_fer THEN acc_ouv instructions acc_fer ELSE acc_ouv instructions acc_fer
;

boucle:
    DO acc_ouv instructions acc_fer WHILE par_ouv expression par_fer pvg
    | FOR IDF FROM constante TO constante STEP constante acc_ouv instructions acc_fer
;

%%
int main ()
{
    return yyparse ();
}
void yyerror(const char *msg) {
    printf("Erreur syntaxique à la ligne %d, colonne %d : %s\n", nb_ligne, col, msg);
}