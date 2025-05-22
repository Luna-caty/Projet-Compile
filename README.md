# Compilateur MiniSoft

Un mini-compilateur pour le langage **MiniSoft** développé avec FLEX et BISON 

## Description

Ce projet implémente un compilateur complet pour le langage MiniSoft, incluant :
- Analyse lexicale (FLEX)
- Analyse syntaxique (BISON) 
- Analyse sémantique
- Gestion de la table des symboles

## Langage MiniSoft

### Structure générale
```
MainPrgm nom_programme ;
Var
    <!-- Déclarations -->
BeginPg
{
    {-- Instructions --}
}
EndPg ;
```

### Types supportés
- `Int` : entiers entre -32768 et 32767
- `Float` : nombres réels avec point décimal

### Déclarations
- **Variables** : `let x,y : Int ;`
- **Tableaux** : `let A,B : [Int;10] ;`
- **Constantes** : `@define Const PI : Float = 3.14 ;`

### Instructions
- **Affectation** : `x := 5 ;`
- **Condition** : `if (x > 0) then { ... } else { ... }`
- **Boucles** : 
  - `do { ... } while (condition) ;`
  - `for i from 1 to 10 step 2 { ... }`
- **E/S** : `input(x) ;` `output("Résultat: ", x) ;`

### Opérateurs
- **Arithmétiques** : `+`, `-`, `*`, `/`
- **Logiques** : `AND`, `OR`, `!`
- **Comparaison** : `>`, `<`, `>=`, `<=`, `==`, `!=`

## Fonctionnalités implémentées

### Analyse sémantique
- Vérification des identificateurs non déclarés
- Détection des doubles déclarations
- Contrôle de compatibilité des types
- Vérification des divisions par zéro
- Protection contre la modification des constantes
- Contrôle des bornes des tableaux

### Table des symboles
Stockage des informations : nom, type, valeur, code entité, etc.

### Gestion d'erreurs
Messages d'erreur détaillés avec numéro de ligne et colonne.

## Compilation et exécution
Créer un fichier texte avec votre code MiniSoft  
   
Exécuter le fichier commande.bat



