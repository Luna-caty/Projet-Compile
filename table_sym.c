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
    // creation d'un noeud 
    IdfConstTS* new = (IdfConstTS*)malloc(sizeof(IdfConstTS));
    // affectation des valeurs enter en parametres 
    new->state = state;
    strcpy(new->name, entite);
    strcpy(new->code, code);
    strcpy(new->type, type);
    strcpy(new->value, val);
    // mettre a jour le pointeur
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
    printf("| Nom         | Code       | Type       | Valeur     | Etat  |\n");
    printf("-----------------------------------------------------------------------\n");
    
    IdfConstTS* currentIdfConst = listeIdfConst;
    // tant que on est pas arrivé a la fin de la liste 
    while (currentIdfConst != NULL) {
        printf("| %-11s | %-10s | %-10s | %-10s | %-5d |\n", 
            // on avvance dans la liste    
            currentIdfConst->name, currentIdfConst->code, currentIdfConst->type, currentIdfConst->value, currentIdfConst->state);
        currentIdfConst = currentIdfConst->suiv;
    }
    printf("-----------------------------------------------------------------------\n");

    printf("\n/*************** Table des Mots Clés et Séparateurs ***************/\n");
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



int estConstante(char* identifiant) {
    IdfConstTS* elem = rechercherIdfConst(identifiant);
    return (elem != NULL && strcmp(elem->code, "Const") == 0);
}

int verifierDepassementTableau(char* idf, int index) {
    IdfConstTS* elem = rechercherIdfConst(idf);
    
    if (elem) {
        int taille = atoi(elem->value);  // Convertit la taille stockÃ©e en string
        if (index < 0 || index >= taille) {
            printf("Erreur : DÃ©passement de tableau %s a l indice %d (taille %d)\n", idf, index, taille);
            fflush(stdout);
            return 0;  // DÃ©passement
        }
        return 1;  // AccÃ¨s valide
    }
}
int typesCompatibles(const char* type1, const char* type2) {
   
    return (strcmp(type1, type2) == 0);
}

