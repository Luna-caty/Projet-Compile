%{
#include <stdio.h>
int nb_ligne = 1;
int col = 0;  
extern int yylex();  
void yyerror(const char *msg);
int yywrap();
%}

/* Specificaton des types */
%union {
    int entier;
    float reel;
    char* chaine;
}
/* partie token */
%token <chaine> MainPrgm Var BeginPg EndPg input_var output_var Const  
%token <chaine>IDF let define chaine
%token <entier> Int constante
%token <reel> Float
%token <chaine> IF THEN ELSE DO WHILE FOR FROM TO STEP
%token <chaine> OR  AND NOT
%token <chaine> aff aff_const pvg vg separ_dec add sous mult division   
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
programme: MainPrgm IDF pvg Var declarations BeginPg  acc_ouv instructions acc_fer EndPg pvg
{printf("Structure correcte\n");}
    ;

/* ce non terminal veut dire que une instruction peut etre une aff input/output condition boucle */
instruction:
    affectation
  | inOut
  | condition
  | boucle
;

op_cmp :
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
    instruction pvg
  | instructions instruction pvg
;

/* c'est pour les expressions conditionelles et logique 
comapaison entre une variable et une constante
comparaison entre deux variables
..........
 */

expression:
    IDF op_cmp constante
  | IDF op_cmp IDF
  | expression AND expression
  | expression OR expression
  | NOT expression
  | expression add expression
  | expression sous expression
  | expression mult expression
  | expression division expression
;
type:
    Int
  | Float
;
declaration:
    let liste_idf separ_dec type pvg
  | let liste_idf separ_dec crochet_ouv type pvg constante crochet_fer pvg
;
liste_idf:
    IDF
  | liste_idf vg IDF
;
const_declaration:
    define Const IDF separ_dec type constante pvg

declarations:
    declaration
  | const_declaration   
  | declarations declaration
  | declarations const_declaration
inOut:
    input_var par_ouv IDF par_fer pvg
    | output_var par_ouv chaine par_fer pvg

affectation :
    IDF aff constante pvg
    | IDF aff_const constante pvg
    | IDF aff_const Float pvg
    | IDF aff_const chaine pvg

condition :
    IF par_ouv expression par_fer THEN acc_ouv instructions acc_fer
    | IF par_ouv expression par_fer THEN acc_ouv instructions acc_fer ELSE acc_ouv instructions acc_fer

boucle:
    DO acc_ouv instructions acc_fer WHILE par_ouv expression par_fer pvg
    | FOR IDF FROM constante TO constante STEP constante acc_ouv instructions acc_fer


%%
int main ()
{
    return yyparse ();
}
void yyerror(const char *msg)
{
    fprintf(stderr, "Erreur syntaxique : %s\n", msg);
}
