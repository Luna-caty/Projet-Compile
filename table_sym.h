#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// pour idf et const 
typedef struct {
    int state;
    char name [20];
    char code [20];
    char type [20];
    char value [20];
}IdfConstTS;

// pour mot clé et separateur 
typedef struct {
    int state;
    char name [20];
    char type [20];
}mcSepTS;


void initialization();
void inserer(char entite[], char code[], char type[], char val[], int i, int y);
void rechercher(char entite[], char code[], char type[], char val[], int y);
void afficher();