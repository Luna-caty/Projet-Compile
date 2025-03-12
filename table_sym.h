#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// pour idf et const 
typedef struct IdfConstTS  {
    int state;
    char name [20];
    char code [20];
    char type [20];
    char value [20];
    struct IdfConstTS *suiv;
}IdfConstTS;

// pour mot clé et separateur 
typedef struct mcSepTS {
    int state;
    char name [20];
    char type [20];
    struct mcSepTS *suiv;
}mcSepTS;

extern IdfConstTS* listeIdfConst;
extern mcSepTS* listeMcSep;

void initialization();
void insererIdfConst(char entite[], char code[], char type[], char val[], int state);
void insererMcSep(char entite[], char type[], int state);
IdfConstTS* rechercherIdfConst(char entite[]);
mcSepTS* rechercherMcSep(char entite[]);
void afficher();
