%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_sym.h"
extern int nb_ligne;
extern int col;
extern int yylex();  
int nombre_erreurs_semantiques = 0;
int tableau_courant_taille = 0;

void yyerror(const char *msg);
int yywrap();
%}



%union {
    int entier;
    float reel;
    char* chaine;
    char* type; 
    struct {
        char* nature;
        float valeur;
        char* nom;     
        char* type;
    } expr;
    struct {
        char* type;
        int size;
    } array_info;
}
%type <expr> expression
%type <array_info> declaration_tableau
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

%nonassoc THEN
%nonassoc ELSE




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
        IdfConstTS* symbole = rechercherIdfConst($1);
        if (!symbole || symbole->declared == 0) {
            printf("Erreur semantique : identifiant '%s' non declaree a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else if (symbole->array_size <= 0) {
            printf("Erreur semantique : '%s' n'est pas un tableau a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else {
            // Vérifier si l'indice est une constante
            if (strcmp($3.nature, "constante") == 0) {
                if ($3.valeur < 0 || $3.valeur >= symbole->array_size) {
                    printf("Erreur semantique : indice %d hors limites pour le tableau '%s' de taille %d a la ligne %d\n", 
                        (int)$3.valeur, $1, symbole->array_size, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
            }
        }
        
        $$.nature = strdup("tableau_elem");
        $$.nom = strdup($1);
        $$.valeur = 0;
        
        // Récupérer le type de l'élément du tableau
        if (symbole) {
            $$.type = strdup(symbole->type);
        } else {
            $$.type = NULL;
        }
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

        char *type1 = NULL, *type2 = NULL;

        // Détermination des types pour la première expression
        if (strcmp($1.nature, "idf") == 0) {
            IdfConstTS* sym = rechercherIdfConst($1.nom);
            if (sym) type1 = sym->type;
        } else if (strcmp($1.nature, "constante") == 0) {
            type1 = "Int";
        } else if (strcmp($1.nature, "reel") == 0) {
            type1 = "Float";
        } else if (strcmp($1.nature, "expression") == 0) {
            type1 = $1.type;
        }
        
        // Détermination des types pour la seconde expression
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
        
        // Détermination du type résultant
        if (type1 != NULL && type2 != NULL) {
            if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
                $$.type = strdup("Float");
            } else {
                $$.type = strdup("Int");
            }
        } else {
            $$.type = NULL;
        }
        
        // Calcul et vérification des valeurs
        if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
            (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
            $$.valeur = $1.valeur + $3.valeur;
            
            // Vérifier si le résultat est dans les limites pour le type déterminé
            if ($$.type != NULL && strcmp($$.type, "Int") == 0) {
                if ($$.valeur < -32768 || $$.valeur > 32767) {
                    printf("Erreur semantique : le resultat de l'addition (%f) est hors limite pour le type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
                // Si résultat fractionnaire pour type Int
                if ($$.valeur != (int)$$.valeur) {
                    printf("Erreur semantique : l'addition produit une valeur avec partie fractionnaire (%f) pour un resultat de type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
            }
            
            char tempStr[20];
            sprintf(tempStr, "%f", $$.valeur);
            $$.nom = strdup(tempStr);
        } else {
            $$.nom = strdup("expr");
            $$.valeur = 0;
        }
        
        // Vérification de la compatibilité des types
        if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
            printf("Erreur semantique : incompatibilite de types pour l'addition entre expressions de types %s et %s a la ligne %d\n", 
                type1, type2, nb_ligne);
            nombre_erreurs_semantiques++;
        }
    }
    
    
    | expression sous expression
    {
        $$.nature = strdup("expression");

        char *type1 = NULL, *type2 = NULL;

        // Détermination des types pour la première expression
        if (strcmp($1.nature, "idf") == 0) {
            IdfConstTS* sym = rechercherIdfConst($1.nom);
            if (sym) type1 = sym->type;
        } else if (strcmp($1.nature, "constante") == 0) {
            type1 = "Int";
        } else if (strcmp($1.nature, "reel") == 0) {
            type1 = "Float";
        } else if (strcmp($1.nature, "expression") == 0) {
            type1 = $1.type;
        }
        
        // Détermination des types pour la seconde expression
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
        
        // Détermination du type résultant
        if (type1 != NULL && type2 != NULL) {
            if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
                $$.type = strdup("Float");
            } else {
                $$.type = strdup("Int");
            }
        } else {
            $$.type = NULL;
        }
        
        // Calcul et vérification des valeurs
        if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
            (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
            $$.valeur = $1.valeur - $3.valeur;  // Soustraction ici
            
            // Vérifier si le résultat est dans les limites pour le type déterminé
            if ($$.type != NULL && strcmp($$.type, "Int") == 0) {
                if ($$.valeur < -32768 || $$.valeur > 32767) {
                    printf("Erreur semantique : le resultat de la soustraction (%f) est hors limite pour le type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
                // Si résultat fractionnaire pour type Int
                if ($$.valeur != (int)$$.valeur) {
                    printf("Erreur semantique : la soustraction produit une valeur avec partie fractionnaire (%f) pour un resultat de type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
            }
            
            char tempStr[20];
            sprintf(tempStr, "%f", $$.valeur);
            $$.nom = strdup(tempStr);
        } else {
            $$.nom = strdup("expr");
            $$.valeur = 0;
        }
        
        // Vérification de la compatibilité des types
        if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
            printf("Erreur semantique : incompatibilite de types pour la soustraction entre expressions de types %s et %s a la ligne %d\n", 
                type1, type2, nb_ligne);
            nombre_erreurs_semantiques++;
        }
    }
    
    | expression mult expression
    {
        $$.nature = strdup("expression");

        char *type1 = NULL, *type2 = NULL;

        // Détermination des types pour la première expression
        if (strcmp($1.nature, "idf") == 0) {
            IdfConstTS* sym = rechercherIdfConst($1.nom);
            if (sym) type1 = sym->type;
        } else if (strcmp($1.nature, "constante") == 0) {
            type1 = "Int";
        } else if (strcmp($1.nature, "reel") == 0) {
            type1 = "Float";
        } else if (strcmp($1.nature, "expression") == 0) {
            type1 = $1.type;
        }
        
        // Détermination des types pour la seconde expression
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
        
        // Détermination du type résultant
        if (type1 != NULL && type2 != NULL) {
            if (strcmp(type1, "Float") == 0 || strcmp(type2, "Float") == 0) {
                $$.type = strdup("Float");
            } else {
                $$.type = strdup("Int");
            }
        } else {
            $$.type = NULL;
        }
        
        // Calcul et vérification des valeurs
        if ((strcmp($1.nature, "constante") == 0 || strcmp($1.nature, "reel") == 0) &&
            (strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0)) {
            $$.valeur = $1.valeur * $3.valeur;  // Multiplication ici
            
            // Vérifier si le résultat est dans les limites pour le type déterminé
            if ($$.type != NULL && strcmp($$.type, "Int") == 0) {
                if ($$.valeur < -32768 || $$.valeur > 32767) {
                    printf("Erreur semantique : le resultat de la multiplication (%f) est hors limite pour le type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
                // Si résultat fractionnaire pour type Int
                if ($$.valeur != (int)$$.valeur) {
                    printf("Erreur semantique : la multiplication produit une valeur avec partie fractionnaire (%f) pour un resultat de type Int a la ligne %d\n", 
                        $$.valeur, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
            }
            
            char tempStr[20];
            sprintf(tempStr, "%f", $$.valeur);
            $$.nom = strdup(tempStr);
        } else {
            $$.nom = strdup("expr");
            $$.valeur = 0;
        }
        
        // Vérification de la compatibilité des types
        if (type1 != NULL && type2 != NULL && !typesCompatibles(type1, type2)) {
            printf("Erreur semantique : incompatibilite de types pour la multiplication entre expressions de types %s et %s a la ligne %d\n", 
                type1, type2, nb_ligne);
            nombre_erreurs_semantiques++;
        }
    }
    | expression division expression
    {
        
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
       
        char* token;
        char* str = strdup($2);  
        token = strtok(str, ",");
        while (token != NULL) {
           
            while (*token == ' ') token++;
            
            IdfConstTS* sym = rechercherIdfConst(token);
            if (sym && sym->declared == 1) {
                printf("Erreur semantique : identifiant '%s' deja declare a la ligne %d\n", token, nb_ligne);
                nombre_erreurs_semantiques++;
            } else if (sym) {
                sym->declared = 1;
                strcpy(sym->type, $4);
            }
            
           
            token = strtok(NULL, ",");
        }
        
        free(str);
    }
 | let liste_idf separ_dec declaration_tableau 
    {
        char* token;
        char* str = strdup($2);  
        token = strtok(str, ",");
        while (token != NULL) {
            while (*token == ' ') token++;
            
            IdfConstTS* sym = rechercherIdfConst(token);
            if (sym && sym->declared == 1) {
                printf("Erreur semantique : identifiant '%s' deja declare a la ligne %d\n", token, nb_ligne);
                nombre_erreurs_semantiques++;
            } else if (sym) {
                sym->declared = 1;
                strcpy(sym->type, $4.type);           // Type du tableau - Fixed!
                sym->array_size = tableau_courant_taille;  // Taille du tableau
            }
            
            token = strtok(NULL, ",");
        }
        
        free(str);
    }
;

declaration_tableau:
    crochet_ouv type pvg constante crochet_fer pvg
    {
        tableau_courant_taille = $4;  
        $$.type = strdup($2);         
        $$.size = tableau_courant_taille;  
    }

;

liste_idf:
    IDF
    {
        $$ = $1;
    }
    | liste_idf vg IDF
    {
        IdfConstTS* sym = rechercherIdfConst($1);
        if (sym) {
            sym->declared = 1;
        }
        
        IdfConstTS* sym3 = rechercherIdfConst($3);
        if (sym3) {
            sym3->declared = 1;
        }
        
        $$ = $3;  
    }
;
const_declaration:
    at_sign define Const IDF separ_dec type affect_val constante pvg
    {
        IdfConstTS* sym = rechercherIdfConst($4);
        if (!sym) {
            printf("Erreur : identifiant '%s' non trouvé ligne %d\n", $4, nb_ligne);
            nombre_erreurs_semantiques++;
        } else if (sym->declared == 1) {
            printf("Erreur : '%s' déjà déclaré ligne %d\n", $4, nb_ligne);
            nombre_erreurs_semantiques++;
        }
    }
;
declarations: 
    /* vide */ 
    | declaration declarations
    | const_declaration declarations
;

inOut:
    input_var par_ouv IDF par_fer pvg
    {
        IdfConstTS* sym = rechercherIdfConst($3);
        if (!sym || sym->declared == 0) {
          printf("Erreur semantique : identifiant '%s' non declare a la ligne %d\n", $3, nb_ligne);
          nombre_erreurs_semantiques++;
        }
    }
    | output_var par_ouv chaine par_fer pvg
;

affectation:
    IDF aff expression pvg
    {
        IdfConstTS* sym = rechercherIdfConst($1);
       if(!sym || sym->declared == 0) { 
            printf("Erreur semantique : identifiant '%s' non declare a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else {
            if (strcmp(sym->code, "CONST") == 0) {
                printf("Erreur semantique : tentative de modification de la constante '%s' a la ligne %d\n", $1, nb_ligne);
                nombre_erreurs_semantiques++;
            } else {
                char* exprType = NULL;
                
                if (strcmp($3.nature, "constante") == 0) {
                    exprType = "Int";
                    // Vérifier si la valeur est dans les limites acceptables pour le type
                    if (strcmp(sym->type, "Int") == 0) {
                        // Pour Int, vérifier si la valeur est entre -32768 et 32767
                        if ($3.valeur < -32768 || $3.valeur > 32767) {
                            printf("Erreur semantique : la valeur %f est hors limite pour le type Int a la ligne %d\n", 
                                   $3.valeur, nb_ligne);
                            nombre_erreurs_semantiques++;
                        }
                    }
                } 
                else if (strcmp($3.nature, "reel") == 0) {
                    exprType = "Float";
                    if (strcmp(sym->type, "Int") == 0) {
                        printf("Erreur semantique : incompatibilite de types - affectation d'un reel a '%s' de type Int a la ligne %d\n", 
                               $1, nb_ligne);
                        nombre_erreurs_semantiques++;
                    }
                } 
                else if (strcmp($3.nature, "idf") == 0) {
                    IdfConstTS* exprSym = rechercherIdfConst($3.nom);
                    if (exprSym) {
                        exprType = exprSym->type;
                        // Vérifier la compatibilité des valeurs si connues
                        if (strcmp(sym->type, "Int") == 0 && strcmp(exprSym->type, "Float") == 0 && 
                            strlen(exprSym->value) > 0) {
                            float val = atof(exprSym->value);
                            if (val != (int)val) {  // Si la valeur a une partie fractionnaire
                                printf("Erreur semantique : incompatibilite de valeur - la valeur %f de '%s' a une partie fractionnaire et ne peut pas être affectée a '%s' de type Int a la ligne %d\n", 
                                       val, exprSym->name, $1, nb_ligne);
                                nombre_erreurs_semantiques++;
                            }
                        }
                    }
                }
                else if (strcmp($3.nature, "expression") == 0 && $3.type != NULL) {
                    exprType = $3.type;
                }
                
                // Vérification générale de compatibilité de types
                if (exprType != NULL) {
                    if (strcmp(sym->type, "Int") == 0 && strcmp(exprType, "Float") == 0) {
                        printf("Erreur semantique : incompatibilite de types - affectation d'une expression de type Float a '%s' de type Int a la ligne %d\n", 
                               $1, nb_ligne);
                        nombre_erreurs_semantiques++;
                    }
                }
                
                // Mise à jour de la valeur dans la table des symboles
                if ((strcmp($3.nature, "constante") == 0 || strcmp($3.nature, "reel") == 0) && 
                    !(strcmp(sym->type, "Int") == 0 && strcmp($3.nature, "reel") == 0)) {
                    char tempValue[20];
                    sprintf(tempValue, "%f", $3.valeur);
                    strcpy(sym->value, tempValue);
                } 
                else if (strcmp($3.nature, "idf") == 0) {
                    IdfConstTS* exprSym = rechercherIdfConst($3.nom);
                    if (exprSym && strlen(exprSym->value) > 0) {
                        // Pour Int, vérifier que la valeur est entière si source est Float
                        if (strcmp(sym->type, "Int") == 0 && strcmp(exprSym->type, "Float") == 0) {
                            float val = atof(exprSym->value);
                            if (val == (int)val) {  // Si c'est un nombre entier
                                sprintf(sym->value, "%d", (int)val);
                            }
                        } else {
                            strcpy(sym->value, exprSym->value);
                        }
                    } else {
                        strcpy(sym->value, "");
                    }
                } 
                else {
                    strcpy(sym->value, "");  
                }
            }
        }
    }






    // pour gérer l'incompatibilité de types lors de l'affectation d'une expression à un tableau
    | IDF crochet_ouv expression crochet_fer aff expression pvg
    {
        IdfConstTS* sym = rechercherIdfConst($1);
        if (!sym) {
            printf("Erreur semantique : identifiant '%s' non declare a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else if (sym->array_size <= 0) {
            printf("Erreur semantique : '%s' n'est pas un tableau a la ligne %d\n", $1, nb_ligne);
            nombre_erreurs_semantiques++;
        } else {
            // Vérification de l'indice
            if (strcmp($3.nature, "constante") == 0 && 
                ($3.valeur < 0 || $3.valeur >= sym->array_size)) {
                printf("Erreur semantique : indice %d hors limites pour '%s' (taille %d) ligne %d\n", 
                      (int)$3.valeur, $1, sym->array_size, nb_ligne);
                nombre_erreurs_semantiques++;
            }
            char* exprType = NULL;
            if (strcmp($6.nature, "constante") == 0) exprType = "Int";
            else if (strcmp($6.nature, "reel") == 0) exprType = "Float";
            else if (strcmp($6.nature, "idf") == 0) {
                IdfConstTS* exprSym = rechercherIdfConst($6.nom);
                if (exprSym) exprType = exprSym->type;
            }
            else if (strcmp($6.nature, "expression") == 0) exprType = $6.type;
            else if (strcmp($6.nature, "chaine") == 0) exprType = "String";
            if (exprType) {
                char* arrayType = sym->type;
                if (strcmp(arrayType, "Int") == 0) {
                    if (strcmp(exprType, "String") == 0) {
                        printf("Erreur : chaine -> Int pour '%s' ligne %d\n", $1, nb_ligne);
                        nombre_erreurs_semantiques++;
                    }
                    else if (strcmp(exprType, "Float") == 0) {
                        printf("Erreur : Float -> Int pour '%s' ligne %d\n",
                               $1, nb_ligne);
                        nombre_erreurs_semantiques++;
                    }
                }
                else if (strcmp(arrayType, "Float") == 0 && strcmp(exprType, "String") == 0) {
                    printf("Erreur : chaine -> Float pour '%s' ligne %d\n", $1, nb_ligne);
                    nombre_erreurs_semantiques++;
                }
            }
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