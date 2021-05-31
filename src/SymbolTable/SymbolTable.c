/*
 * Author: Ernie Chu
 * Filename: SymbolTable.c
 * Description: Symbol table implementation using hash table
 */

#include "SymbolTable.h"

int create(void) {
    table = (Node**)malloc(NUM_CHARSET * sizeof(Node*));
    if (table == NULL) return -1;
    int i;
    for (i = 0; i < NUM_CHARSET; i++)
        table[i] = NULL;
    return 0;
}
Node* lookup(const string s) {
    int hval = hash(s[0]);
    Node* bucket = table[hval];
    if (bucket)
        do {
            if (!strcmp(bucket->key, s)) return bucket;
        } while ((bucket=bucket->next));
    return NULL;
}

Node* insert(const string s) {
    Node* found = lookup(s);
    if (found) return found;
    int hval = hash(s[0]);
    Node* bucket = table[hval];
    if (bucket) {
        while (bucket->next) bucket=bucket->next;
        bucket->next = (Node*)malloc(sizeof(Node));
        bucket->next->key = strdup(s);
        bucket->next->next = NULL;
        return bucket->next;
    }
    bucket = (Node*)malloc(sizeof(Node));
    bucket->key = strdup(s);
    bucket->next = NULL;
    table[hval] = bucket;
    return bucket;
}
void dump(void) {
    printf("The symbol table contains:\n");
    int i;
    for (i = 0; i < NUM_CHARSET; i++) {
        Node* bucket = table[i];
        if (bucket) {
            do {
                printf("%s\n", bucket->key);
            } while ((bucket=bucket->next));
        }
    }
}

int hash(const char ch) {
    if (ch == '_')  return NUM_CHARSET - 2;
    if (ch == '$')  return NUM_CHARSET - 1;
    if (ch < 97)    return (int)ch-65;
    else            return (int)ch-97+26;
}
void destroy(void) {
    int i;
    for (i = 0; i < NUM_CHARSET; i++) {
        Node* bucket = table[i];
        if (bucket) {
            do {
                Node* next = bucket->next;
                free(bucket);
                bucket = next;
            } while (bucket);
        }
    }
    free(table);
}
