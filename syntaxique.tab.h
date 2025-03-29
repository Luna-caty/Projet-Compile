
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     MainPrgm = 258,
     Var = 259,
     BeginPg = 260,
     EndPg = 261,
     input_var = 262,
     output_var = 263,
     Const = 264,
     IDF = 265,
     let = 266,
     define = 267,
     at_sign = 268,
     chaine = 269,
     Int = 270,
     constante = 271,
     reel = 272,
     IF = 273,
     THEN = 274,
     ELSE = 275,
     DO = 276,
     WHILE = 277,
     FOR = 278,
     FROM = 279,
     TO = 280,
     STEP = 281,
     OR = 282,
     AND = 283,
     NOT = 284,
     aff = 285,
     affect_val = 286,
     pvg = 287,
     vg = 288,
     separ_dec = 289,
     add = 290,
     sous = 291,
     mult = 292,
     division = 293,
     inf_egal = 294,
     sup_egal = 295,
     inf = 296,
     sup = 297,
     egal = 298,
     not_egal = 299,
     acc_ouv = 300,
     acc_fer = 301,
     par_ouv = 302,
     par_fer = 303,
     crochet_ouv = 304,
     crochet_fer = 305
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 14 "syntaxique.y"

    int entier;
    float reel;
    char* chaine;
    struct {
        char* type;  // Pour stocker le type de l'expression
        int valeur_int;
        float valeur_float;
        char* chaine;
    } expr;



/* Line 1676 of yacc.c  */
#line 116 "syntaxique.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif

extern YYLTYPE yylloc;

