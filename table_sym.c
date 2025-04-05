#include "table_sym.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


IdfConstTS* listeIdfConst = NULL;
mcSepTS* listeMcSep = NULL;

void initialization() {
    listeIdfConst = NULL;
    listeMcSep = NULL;
}

void insererIdfConst(char entite[], char code[], char type[], char val[], int state) {
    IdfConstTS* existant = rechercherIdfConst(entite);
    if (existant) {
        // Mettre à jour un identifiant existant
        strcpy(existant->code, code);
        strcpy(existant->type, type);
        strcpy(existant->value, val);
        existant->state = state;
        existant->declared = 1;  // Marquer comme déclaré
    } else {
        // Créer un nouvel identifiant
        IdfConstTS* new = (IdfConstTS*)malloc(sizeof(IdfConstTS));
        new->state = state;
        strcpy(new->name, entite);
        strcpy(new->code, code);
        strcpy(new->type, type);
        strcpy(new->value, val);
        new->declared = 1;  // Déclaré
        new->array_size = 0; 
        new->suiv = NULL;
        
        if (listeIdfConst == NULL) {
            listeIdfConst = new;
        } else {
            IdfConstTS* temp = listeIdfConst;
            while (temp->suiv != NULL) {
                temp = temp->suiv;
            }
            temp->suiv = new;
        }
    }
}
void insererMcSep(char entite[], char type[], int state)
{
    mcSepTS* new = (mcSepTS*)malloc(sizeof(mcSepTS));
    new->state = state;
    strcpy(new->name, entite);
    strcpy(new->type, type);
    new->suiv = NULL;
    
    if (listeMcSep == NULL) {
        listeMcSep = new;
    } else {
        mcSepTS* temp = listeMcSep;
        while (temp->suiv != NULL) {
            temp = temp->suiv;
        }
        temp->suiv = new;
    }
}
IdfConstTS* rechercherIdfConst(char entite[])
{
    IdfConstTS* current = listeIdfConst;
    while (current != NULL) {
        if (strcmp(current->name, entite) == 0) {
            return current;
        }
        current = current->suiv;
    }
    return NULL;
}
mcSepTS* rechercherMcSep(char entite[])
{
    mcSepTS* current = listeMcSep;
    while (current != NULL) {
        if (strcmp(current->name, entite) == 0) {
            return current;
        }
        current = current->suiv;
    }
    return NULL;
}


void afficher() {
    printf("\n/*************** Table des Identificateurs et Constantes ***************/\n");
    printf("-----------------------------------------------------------------------\n");
    printf("| Nom         | Code       | Type       | Valeur     | Etat  | Declared \n");
    printf("-----------------------------------------------------------------------\n");
    
    IdfConstTS* currentIdfConst = listeIdfConst;
    // tant que on est pas arrivé a la fin de la liste 
    while (currentIdfConst != NULL) {
        printf("| %-11s | %-10s | %-10s | %-10s | %-5d | %-5d |\n", 
            // on avvance dans la liste    
            currentIdfConst->name, currentIdfConst->code, currentIdfConst->type, currentIdfConst->value, currentIdfConst->state,currentIdfConst->declared);
        currentIdfConst = currentIdfConst->suiv;
    }
    printf("-----------------------------------------------------------------------\n");

    printf("\n/*************** Table des Mots Cles et Separateurs ***************/\n");
    printf("---------------------------------------------------\n");
    printf("| Nom         | Type       | Etat  |\n");
    printf("---------------------------------------------------\n");
    
    mcSepTS* currentMcSep = listeMcSep;
    while (currentMcSep != NULL) {
        printf("| %-11s | %-10s | %-5d |\n", 
               currentMcSep->name, currentMcSep->type, currentMcSep->state);
        currentMcSep = currentMcSep->suiv;
    }
    printf("---------------------------------------------------\n");
}
int typesCompatibles(const char* type1, const char* type2) 
{

    if (strcmp(type1, type2) == 0) 
    {
        return 1;
    }
    if (strcmp(type1, "Int") == 0 && strcmp(type2, "Float") == 0) 
    {
        return 1;
    }
    if (strcmp(type1, "Float") == 0 && strcmp(type2, "Int") == 0) {
        return 1;
    }
            
            
    return 0;
}