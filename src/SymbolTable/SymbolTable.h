/*
 * Author: Ernie Chu
 * Filename: SymbolTable.h
 * Description: Symbol table header
 */

#pragma once
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#define NUM_CHARSET 54
/* identifier leading charset = [a-zA-Z_$] */

typedef struct node {
    char* key;
    char* value;
    char* type;
    int occurrence;
    struct node* next;
} Node;

typedef struct scope {
    Node** table;
    int local;
    struct scope* next;
} Scope;


Scope* getScope(int level, int local);
Scope* newScope(int local);
Node* lookup(const Scope* s,const char* k);
Node* insert(const Scope* s,const Node* n);
void dumpUnusedWarning(FILE* os);
void dump(FILE* os);
int hash(const char ch);
void destroy(void);

static Scope* root = NULL;

/************************************************
 * Data Structure				*
 ************************************************
 *
 * Root
 * |
 * V
 * Scope 0 -> table[NUM_CHARSET] -> subroot 0 -> node 0 ... -> NULL 
 * |				 |                              
 * V		    		 -> subroot 1 -> node 0 ... -> NULL 
 * Scope 1	    		 |                              
 * |		    		 -> subroot 2 -> node 0 ... -> NULL 
 * V		    		 .
 * Scope 2	    		 .
 * |		    		 .
 * V		    		 -> subroot NUM_CHARSET-1
 * Scope 3
 * .
 * .
 * .
 * |
 * V
 * NULL
 */
