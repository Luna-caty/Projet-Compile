%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
    char* type; // pour les types
    struct {
        char* nature;  // "int", "float", "idf", "constante", "reel", "expression", etc.
        float valeur;  // valeur si connue (0 par défaut pour idf)
        char* nom;     // utile pour IDF : nom de la variable
        char*type;
    } expr;
}
%type <expr> expression
%type <chaine> liste_idf
%type <type> type

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
    IDF
    {
        IdfConstTS* symbole = rechercherIdfConst($1);
        if (!symbole || symbole->declared == 0) {
        printf("Erreur semantique : identifiant '%s' non declaree a la ligne %d\n", $1, nb_ligne);
        nombre_erreurs_semantiques++;
        }
        $$.nature = strdup("idf");
        $$.nom = strdup($1);
        $$.valeur = 0;
        
        if (symbole && strlen(symbole->value) > 0) {
            $$.valeur = atof(symbole->value);
        }
    }
    | constante 
    {
        $$.nature = strdup("constante");
        $$.valeur = $1;
        char tempStr[20];
        sprintf(tempStr, "%d", $1);
        $$.nom = strdup(tempStr);
    }
    | reel 
    {
        $$.nature = strdup("reel");
        $$.valeur = $1;
        char tempStr[20];
        sprintf(tempStr, "%f", $1);
        $$.nom = strdup(tempStr);
    }
    | chaine
    {
        $$.nature = strdup("chaine");
        $$.nom = strdup($1);
        $$.valeur = 0;
    }
    | IDF crochet_ouv expression crochet_fer
    {
        $$.nature = strdup("tableau_elem");
        $$.nom = strdup($1);
        $$.valeur = 0;
    } 
    | expression op_cmp expression
    {
        $$.nature = strdup("condition");
        $$.nom = strdup("condition");
        $$.valeur = 0;

    }
    | par_ouv expression AND expression par_fer
    {
        $$.nature = strdup("logique");
        $$.nom = strdup("and");
        $$.valeur = 0; 
    }
    | par_ouv expression OR expression par_fer
    {
        $$.nature = strdup("logique");
        $$.nom = strdup("or");
        $$.valeur = 0; 
    }
    | NOT par_ouv expression par_fer
    {
        $$.nature = strdup("logique");
        $$.nom = strdup("not");
        $$.valeur = 0; 
    }
    | expression add expression
{
    $$.nature = strdup("expression");
    
    // Déterminer le type de l'expression résultante
    char *type1 = NULL, *type2 = NULL;
    
    // Obtenir le type de la première expression
    if (strcmp($1.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($1.nom);
        if (sym) type1 = sym->type;
    } else if (strcmp($1.nature, "constante") == 0) {
        type1 = "Int";
    } else if (strcmp($1.nature, "reel") == 0) {
        type1 = "Float";
    } else if (strcmp($1.nature, "expression") == 0) {
        // Supposons que le type est stocké d'une certaine manière
        type1 = $1.type;
    }
    
    // Obtenir le type de la seconde expression
    if (strcmp($3.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($3.nom);
        if (sym) type2 = sym->type;
    } else if (strcmp($3.nature, "constante") == 0) {
        type2 = "Int";
    } else if (strcmp($3.nature, "reel") == 0) {
        type2 = "Float";
    } else if (strcmp($3.nature, "expression") == 0) {
        type2 = $3.type;
    }
    
    // Déterminer le type résultant (Float si l'une des expressions est Float)
    if (type1 != NULL && type2 != NULL) {
        if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
            $$.type = strdup("Float");
        } else {
            $$.type = strdup("Int");
        }
    } else {
        $$.type = NULL;  // Type indéterminé
    }
    
    // Calcul de la valeur si constantes
    if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
        (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
        $$.valeur = $1.valeur + $3.valeur;
        char tempStr[20];
        sprintf(tempStr, "%f", $$.valeur);
        $$.nom = strdup(tempStr);
    } else {
        $$.nom = strdup("expr");
        $$.valeur = 0;
    }
    
    // Vérification de compatibilité pour l'addition
    if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
        printf("Erreur semantique : incompatibilite de types pour l'addition entre expressions de types %s et %s a la ligne %d\n", 
               type1, type2, nb_ligne);
        nombre_erreurs_semantiques++;
    }
    }
    
    
    | expression sous expression
    {
    $$.nature = strdup("expression");
    
    // Déterminer le type de l'expression résultante
    char *type1 = NULL, *type2 = NULL;
    
    // Obtenir le type de la première expression
    if (strcmp($1.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($1.nom);
        if (sym) type1 = sym->type;
    } else if (strcmp($1.nature, "constante") == 0) {
        type1 = "Int";
    } else if (strcmp($1.nature, "reel") == 0) {
        type1 = "Float";
    } else if (strcmp($1.nature, "expression") == 0) {
        // Supposons que le type est stocké d'une certaine manière
        type1 = $1.type;
    }
    
    // Obtenir le type de la seconde expression
    if (strcmp($3.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($3.nom);
        if (sym) type2 = sym->type;
    } else if (strcmp($3.nature, "constante") == 0) {
        type2 = "Int";
    } else if (strcmp($3.nature, "reel") == 0) {
        type2 = "Float";
    } else if (strcmp($3.nature, "expression") == 0) {
        type2 = $3.type;
    }
    
    // Déterminer le type résultant (Float si l'une des expressions est Float)
    if (type1 != NULL && type2 != NULL) {
        if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
            $$.type = strdup("Float");
        } else {
            $$.type = strdup("Int");
        }
    } else {
        $$.type = NULL;  // Type indéterminé
    }
    
    // Calcul de la valeur si constantes
    if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
        (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
        $$.valeur = $1.valeur + $3.valeur;
        char tempStr[20];
        sprintf(tempStr, "%f", $$.valeur);
        $$.nom = strdup(tempStr);
    } else {
        $$.nom = strdup("expr");
        $$.valeur = 0;
    }
    
    // Vérification de compatibilité pour l'addition
    if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
        printf("Erreur semantique : incompatibilite de types pour l'addition entre expressions de types %s et %s a la ligne %d\n", 
               type1, type2, nb_ligne);
        nombre_erreurs_semantiques++;
    }
    }
    
    
    
    | expression mult expression
    {
        $$.nature = strdup("expression");
    
    // Déterminer le type de l'expression résultante
    char *type1 = NULL, *type2 = NULL;
    
    // Obtenir le type de la première expression
    if (strcmp($1.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($1.nom);
        if (sym) type1 = sym->type;
    } else if (strcmp($1.nature, "constante") == 0) {
        type1 = "Int";
    } else if (strcmp($1.nature, "reel") == 0) {
        type1 = "Float";
    } else if (strcmp($1.nature, "expression") == 0) {
        // Supposons que le type est stocké d'une certaine manière
        type1 = $1.type;
    }
    
    // Obtenir le type de la seconde expression
    if (strcmp($3.nature, "idf") == 0) {
        IdfConstTS* sym = rechercherIdfConst($3.nom);
        if (sym) type2 = sym->type;
    } else if (strcmp($3.nature, "constante") == 0) {
        type2 = "Int";
    } else if (strcmp($3.nature, "reel") == 0) {
        type2 = "Float";
    } else if (strcmp($3.nature, "expression") == 0) {
        type2 = $3.type;
    }
    
    // Déterminer le type résultant (Float si l'une des expressions est Float)
    if (type1 != NULL && type2 != NULL) {
        if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
            $$.type = strdup("Float");
        } else {
            $$.type = strdup("Int");
        }
    } else {
        $$.type = NULL;  // Type indéterminé
    }
    
    // Calcul de la valeur si constantes
    if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
        (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
        $$.valeur = $1.valeur + $3.valeur;
        char tempStr[20];
        sprintf(tempStr, "%f", $$.valeur);
        $$.nom = strdup(tempStr);
    } else {
        $$.nom = strdup("expr");
        $$.valeur = 0;
    }
    
    // Vérification de compatibilité pour l'addition
    if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
        printf("Erreur semantique : incompatibilite de types pour l'addition entre expressions de types %s et %s a la ligne %d\n", 
               type1, type2, nb_ligne);
        nombre_erreurs_semantiques++;
    }
    }
    | expression division expression
    {
        // Vérification de division par zéro
        if ((strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0) && $3.valeur == 0) {
            printf("Erreur semantique : division par zero a la ligne %d\n", nb_ligne);
            nombre_erreurs_semantiques++;
        }
        else if (strcmp($3.nature, "idf") == 0) {
            IdfConstTS* symbole = rechercherIdfConst($3.nom);
            if (symbole && strlen(symbole->value) > 0 && atof(symbole->value) == 0) {
                printf("Erreur semantique : division par variable de valeur zero a la ligne %d\n", nb_ligne);
                nombre_erreurs_semantiques++;
            }
        }
        
        $$.nature = strdup("expression");
        // Calcul de la valeur si constantes et pas de division par zéro
        if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
            (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0) &&
            $3.valeur != 0) {
            $$.valeur = $1.valeur / $3.valeur;
            char tempStr[20];
            sprintf(tempStr, "%f", $$.valeur);
            $$.nom = strdup(tempStr);
        } else {
            $$.nom = strdup("expr");
            $$.valeur = 0;
        }
        if ((strcmp($1.nature, "idf") == 0) && (strcmp($3.nature, "idf") == 0)) {
            IdfConstTS* sym1 = rechercherIdfConst($1.nom);
            IdfConstTS* sym3 = rechercherIdfConst($3.nom);
            if (sym1 && sym3 && !typesCompatibles(sym1->type, sym3->type)) {
                printf("Erreur semantique : incompatibilite de types pour l'addition entre '%s' (%s) et '%s' (%s) a la ligne %d\n", 
                       $1.nom, sym1->type, $3.nom, sym3->type, nb_ligne);
                nombre_erreurs_semantiques++;
            }
        }
    }
    | par_ouv expression par_fer
    {
        $$.nature = strdup($2.nature);
        $$.nom = strdup($2.nom);
        $$.valeur = $2.valeur;
    }

    
;
type:
    Int
    {
        $$ = strdup("Int");
    }
  | reel
    {
        $$ = strdup("Float");
    }
;

declaration:
    let liste_idf separ_dec type pvg 
    {
        // On doit traiter la liste d'identificateurs
        char* token;
        char* str = strdup($2);  // Faire une copie car strtok modifie la chaîne
        
        // Première découpe de la chaîne
        token = strtok(str, ",");
        
        while (token != NULL) {
            // Enlever les espaces éventuels
            while (*token == ' ') token++;
            
            // Rechercher l'identifiant dans la table
            IdfConstTS* sym = rechercherIdfConst(token);
            if (sym && sym->declared == 1) {
                // L'identifiant est déja déclaré, c'est une erreur
                printf("Erreur semantique : identifiant '%s' deja declare a la ligne %d\n", token, nb_ligne);
                nombre_erreurs_semantiques++;
            } else if (sym) {
                // L'identifiant existe mais n'est pas déclaré, le marquer comme déclaré
                sym->declared = 1;
                strcpy(sym->type, $4);
            }
            
            // Passer au token suivant
            token = strtok(NULL, ",");
        }
        
        free(str);
    }
  | let liste_idf separ_dec declaration_tableau 
;

declaration_tableau:
    crochet_ouv type pvg constante crochet_fer pvg
;

liste_idf:
    IDF
    {
        $$ = $1;
    }
    | liste_idf vg IDF
    {
        // Traiter chaque identifiant séparément plutôt que de construire une chaîne
        IdfConstTS* sym = rechercherIdfConst($1);
        if (sym) {
            sym->declared = 1;
        }
        
        IdfConstTS* sym3 = rechercherIdfConst($3);
        if (sym3) {
            sym3->declared = 1;
        }
        
        $$ = $3;  // On renvoie simplement le dernier identifiant
    }
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
    | output_var par_ouv expression par_fer pvg
    | output_var par_ouv chaine par_fer pvg
;

affectation:
    IDF aff expression pvg
    {
        IdfConstTS* sym = rechercherIdfConst($1);
        if (!sym) {
            printf("Erreur semantique : identifiant '%s' non declare a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else {
            if (strcmp(sym->code, "CONST") == 0) {
                printf("Erreur semantique : tentative de modification de la constante '%s' a la ligne %d\n", $1, nb_ligne);
                nombre_erreurs_semantiques++;
            } else {
                // Déterminer le type de l'expression
                char* exprType = NULL;
                
                if (strcmp($3.nature, "constante") == 0) {
                    exprType = "Int";
                } 
                else if (strcmp($3.nature, "reel") == 0) {
                    exprType = "Float";
                } 
                else if (strcmp($3.nature, "idf") == 0) {
                    IdfConstTS* exprSym = rechercherIdfConst($3.nom);
                    if (exprSym) {
                        exprType = exprSym->type;
                    }
                }
                else if (strcmp($3.nature, "expression") == 0 && $3.type != NULL) {
                    // Utiliser le type propagé depuis l'expression
                    exprType = $3.type;
                }
                
                // Vérifier la compatibilité des types
                if (exprType != NULL) {
                    if (strcmp(sym->type, "Int") == 0 && strcmp(exprType, "Float") == 0) {
                        printf("Erreur semantique : incompatibilite de types - affectation d'une expression de type Float a '%s' de type Int a la ligne %d\n", 
                               $1, nb_ligne);
                        nombre_erreurs_semantiques++;
                    }
                }
                
                // Mettre a jour la valeur dans la table des symboles si possible
                if (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0) {
                    char tempValue[20];
                    sprintf(tempValue, "%f", $3.valeur);
                    strcpy(sym->value, tempValue);
                } 
                else if (strcmp($3.nature, "idf") == 0) {
                    IdfConstTS* exprSym = rechercherIdfConst($3.nom);
                    if (exprSym && strlen(exprSym->value) > 0) {
                        strcpy(sym->value, exprSym->value);
                    } else {
                        strcpy(sym->value, "");  // Valeur inconnue
                    }
                } 
                else {
                    strcpy(sym->value, "");  // Expression complexe
                }
            }
        }
    }
    | IDF crochet_ouv expression crochet_fer aff expression pvg
    {
        IdfConstTS* sym = rechercherIdfConst($1);
        if (!sym) {
            printf("Erreur semantique : identifiant '%s' non declare a la ligne %d\n", $1, nb_ligne);
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
    fprintf(stderr, "Erreur syntaxique a la ligne %d, colonne %d : %s\n", nb_ligne, col, msg);
}