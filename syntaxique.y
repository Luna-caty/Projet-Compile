%{
#include <stdio.h>
#include "table_sym.h"
extern int nb_ligne;
extern int col;
extern int yylex();  
int nombre_erreurs_semantiques = 0;

void yyerror(const char *msg);
int yywrap();
%}


%union {
    int entier;
    float reel;
    char* chaine;
    struct {
        char* type;  // Pour stocker le type de l'expression
        int valeur_int;
        float valeur_float;
        char* chaine;
    } expr;
}

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
%type <expr> expression declaration_tableau type liste_idf





%left OR
%left AND
%left NOT
%left inf sup inf_egal sup_egal egal not_egal
%left add sous
%left mult division

%start programme

%%

programme: MainPrgm IDF pvg Var declarations BeginPg acc_ouv instructions acc_fer EndPg pvg
{printf("Structure correcte\n");}
    ;


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



instructions:
    instruction
  | instructions instruction
;



expression:
    IDF{
        IdfConstTS* var = rechercherIdfConst($1);
        if (!var) {
            fprintf(stderr, "Erreur semantique ligne %d: '%s' variable non declaree\n", nb_ligne, $1);
            nombre_erreurs_semantiques++;
        }
        else{
             $$.type = var->type;
        }
    }
    | constante {
        $$.type = "int";
        $$.valeur_int = $1;
    }
    | reel{
        $$.type = "float";
        $$.valeur_float = $1;
    }
    | chaine
    | IDF crochet_ouv expression crochet_fer {
        IdfConstTS* var = rechercherIdfConst($1);
        if (!var) {
            fprintf(stderr, "Erreur semantique ligne %d: '%s' variable non declaree\n", nb_ligne, $1);
            nombre_erreurs_semantiques++;
        }
    }
    | expression op_cmp expression
    | par_ouv expression AND expression par_fer
    | par_ouv expression OR expression par_fer
    | NOT par_ouv expression par_fer
    | expression add expression {
        if (!typesCompatibles($1.type, "int") || !typesCompatibles($3.type, "int")) {
            printf("Erreur ligne %d : incompatible types pour l'addition (%s + %s)\n", @1.first_line, $1.type, $3.type);
            nombre_erreurs_semantiques++;
        }
          $$.type = (strcmp($1.type, "float") == 0 || strcmp($3.type, "float") == 0) 
                 ? "float" : "int";
    }
    | expression sous expression {
        if (!typesCompatibles($1.type, "int") || !typesCompatibles($3.type, "int")) {
            printf("Erreur ligne %d : incompatible types pour la soustraction (%s - %s)\n", @1.first_line, $1.type, $3.type);
            nombre_erreurs_semantiques++;
        }
        $$.type = (strcmp($1.type, "float") == 0 || strcmp($3.type, "float") == 0) 
                 ? "float" : "int";
    }
    | expression mult expression {
        if (!typesCompatibles($1.type, "int") || !typesCompatibles($3.type, "int")) {
            printf("Erreur ligne %d : incompatible types pour la multiplication (%s * %s)\n", @1.first_line, $1.type, $3.type);
            nombre_erreurs_semantiques++;
        }
        $$.type = (strcmp($1.type, "float") == 0 || strcmp($3.type, "float") == 0) 
                 ? "float" : "int";
    }
    | expression division expression {
        if (!typesCompatibles($1.type, "int") || !typesCompatibles($3.type, "int")) {
            printf("Erreur ligne %d : incompatible types pour la division (%s / %s)\n", @1.first_line, $1.type, $3.type);
            nombre_erreurs_semantiques++;
        }
       if (strcmp($3.type, "int") == 0 && $3.valeur_int == 0) {
            printf("Erreur ligne %d : division par zero\n", @3.first_line);
            nombre_erreurs_semantiques++;
        }
         $$.type = "float";  
    }
   // int + int → int
   //int + float → float
   //float + int → float
    //float + float → float
    | par_ouv expression par_fer
;

type:
    Int{
        $$.valeur_int=$1;
        $$.type="int"
    }
  | reel{
    $$.valeur_float=$1;
    $$.type="float";
  }
;

declaration:
    let liste_idf separ_dec type pvg
  | let liste_idf separ_dec declaration_tableau{
    insererIdfConst($2.chaine,"array",$4.type,$4.valeur_int,1);
  }
;

declaration_tableau:
    crochet_ouv type pvg constante crochet_fer pvg {
        if ($4 <= 0) {
            printf("Erreur: taille de tableau invalide %d\n", $4);
        } else {
            $$.type = strdup($2.type);
            $$.valeur_int=$4;
            
        }
    }
;

liste_idf:
    IDF{
        
        IdfConstTS* existing = rechercherIdfConst($1);
        if (existing) {
            if (strcmp(existing->type, "Const") == 0) {
                fprintf(stderr, "Erreur ligne %d: '%s' est une constante\n", 
                      @1.first_line, $1);
            }
            else if (strcmp(existing->type, "int") == 0)  {
                fprintf(stderr, "Erreur ligne %d: '%s' est un tableau\n", 
                      @1.first_line, $1);
            }
            else  if (strcmp(existing->type, "int") == 0) {
                fprintf(stderr, "Erreur ligne %d: '%s' déjà déclaré\n", 
                      @1.first_line, $1);
            }
            nombre_erreurs_semantiques++;
        } else {
            insererIdfConst($1, "VAR", "", "", 0); // 0 = pas un tableau
            $$.chaine = strdup($1); 
        }
    }
    | liste_idf vg IDF{
        IdfConstTS* existing = rechercherIdfConst($3);
        if (existing) {
            if (strcmp(existing->type, "Const") == 0) {
                fprintf(stderr, "Erreur ligne %d: '%s' est une constante\n", 
                      @3.first_line, $3);
            }
            else if (strcmp(existing->type, "int") == 0)  {
                fprintf(stderr, "Erreur ligne %d: '%s' est un tableau\n", 
                      @3.first_line, $3);
            }
            else {
                fprintf(stderr, "Erreur ligne %d: '%s' déjà déclaré\n", 
                      @3.first_line, $3);
            }
            nombre_erreurs_semantiques++;
        } else {
            insererIdfConst($3, "VAR", "", "", 0);
            $$.chaine = strdup($3);
        }
    }
;







const_declaration:
    at_sign define Const IDF separ_dec type affect_val constante pvg{
        if (rechercherIdfConst($4)) {
            fprintf(stderr, "Erreur semantique ligne %d: '%s' est deja declare\n", nb_ligne, $4);
            nombre_erreurs_semantiques++;
        } else {
            insererIdfConst($4, "Const", "", "", 1);
        }
    }
;
;
declarations:
    declaration
  | const_declaration   
  | declarations declaration
  | declarations const_declaration
  | /* vide */
;

inOut:
    input_var par_ouv IDF par_fer pvg{
        IdfConstTS* var = rechercherIdfConst($3);
        if (!var) {
            fprintf(stderr, "Erreur semantique ligne %d: '%s' variable non declaree\n", nb_ligne, $3);
            nombre_erreurs_semantiques++;
        }
    }
    | output_var par_ouv IDF par_fer pvg{
        IdfConstTS* var = rechercherIdfConst($3);
        if (!var) {
            fprintf(stderr, "Erreur semantique ligne %d: '%s' variable non declaree\n", nb_ligne, $3);
            nombre_erreurs_semantiques++;
        }
    }
    | output_var par_ouv expression par_fer pvg
    | output_var par_ouv chaine par_fer pvg
;

affectation:
    IDF aff expression pvg {
        IdfConstTS* var = rechercherIdfConst($1);
        if (!var) {
            fprintf(stderr, "Erreur ligne %d: '%s' non déclaré\n", @1.first_line, $1);
            nombre_erreurs_semantiques++;
        }
        else if (!typesCompatibles(var->type, $3.type)) {  // Utilisation du type stocké
            fprintf(stderr, "Erreur ligne %d: affectation %s <- %s impossible\n",
                  @2.first_line, var->type, $3.type);
            nombre_erreurs_semantiques++;
        }
         else if (strcmp(var->type, "Const") == 0) {
            fprintf(stderr, "Erreur ligne %d: impossible de modifier la constante '%s'\n",
                  @2.first_line, $1);
            nombre_erreurs_semantiques++;
        }
    }
    | IDF crochet_ouv expression crochet_fer aff expression pvg {
        IdfConstTS* var = rechercherIdfConst($1);
        if (!var) {
            fprintf(stderr, "Erreur ligne %d: tableau '%s' non déclaré\n", @1.first_line, $1);
            nombre_erreurs_semantiques++;
        }
        
        else if (!typesCompatibles(var->type, $6.type)) {
            fprintf(stderr, "Erreur ligne %d: type %s incompatible avec %s\n",
                  @6.first_line, $6.type, var->type);
            nombre_erreurs_semantiques++;
        }
        else if (!verifierDepassementTableau($1, $3.valeur_int)) {
        nombre_erreurs_semantiques++;
    }
    }
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
    initialization();
    int result = yyparse();

    printf("Fin de l'analyse, code de retour : %d\n", result);
    printf("Nombre total d'erreurs semantiques : %d\n", nombre_erreurs_semantiques);
    afficher();
    return 0;
}

void yyerror(const char *msg) {
    fprintf(stderr, "Erreur syntaxique à la ligne %d, colonne %d : %s\n", nb_ligne, col, msg);
}