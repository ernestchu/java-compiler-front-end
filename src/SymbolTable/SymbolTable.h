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

typedef char* string;
typedef struct node {
    string key;
    struct node* next;
} Node;

Node** table;

int create(void);
Node* lookup(const string s);
Node* insert(const string s);
void dump(void);

int hash(const char ch);
void destroy(void);
