/*
 * Author: Ernie Chu
 * Filename: SymbolTable.c
 * Description: Symbol table implementation using hash table
 */

#include "SymbolTable.h"


Scope* getScope(int level, int local) {
    int i;
    Scope* s = root;
    if (!s) 
	s = root = newScope(local);
    for (i = 0; i < level; i++) {
	if (!s->next)
	    s = s->next = newScope(local);
	else
	    s = s->next;
    }
    if (local>=0) s->local = local;
    return s;
}
Scope* newScope(int local) {
    Scope* s = (Scope*)malloc(sizeof(Scope));
    s->next = NULL;
    s->local = local;
    s->table = (Node**)malloc(NUM_CHARSET * sizeof(Node*));
    if (s->table == NULL) {
	perror("newScope(): ");
	exit(1);
    }
    int i;
    for (i = 0; i < NUM_CHARSET; i++)
        s->table[i] = NULL;
    return s;
}
Node* lookup(const Scope* s,const char* k) {
    int hval = hash(*k);
    Node* bucket = s->table[hval];
    if (bucket)
        do {
            if (!strcmp(bucket->key, k)) return bucket;
        } while ((bucket=bucket->next));
    return NULL;
}

Node* insert(const Scope* s,const Node* n) {
    Node* found = lookup(s, n->key);
    if (found) return NULL;
    int hval = hash(n->key[0]);
    Node* bucket = s->table[hval];
    if (bucket) {
        while (bucket->next) bucket=bucket->next;
        bucket->next = (Node*)malloc(sizeof(Node));
	bucket->next->key	    = strdup(n->key);
	bucket->next->value	    = strdup(n->value);
	bucket->next->type	    = strdup(n->type);
	bucket->next->occurrence    = n->occurrence;
	bucket->next->next	    = NULL;
        return bucket->next;
    }
    bucket = (Node*)malloc(sizeof(Node));
    bucket->key		= strdup(n->key);
    bucket->value	= strdup(n->value);
    bucket->type	= strdup(n->type);
    bucket->occurrence	= n->occurrence;
    bucket->next	= NULL;
    s->table[hval] = bucket;
    return bucket;
}
void dumpUnusedWarning(FILE* os) {
    Scope* current = root;
    while (current) {
	if (!current->local) {
	    current = current->next;
	    continue;
	}
	int i;
	for (i = 0; i < NUM_CHARSET; i++) {
	    Node* bucket = current->table[i];
	    if (bucket) {
		do {
		    if (bucket->occurrence) continue;
		    fprintf(os, "\033[0;35m\033[1m warning: \033[0m");
		    fprintf(os, "\033[1munused variable: `%s`\033[22m\n", bucket->key);
		} while ((bucket=bucket->next));
	    }
	}
	current = current->next;
    }
}
void dump(FILE* os) {
    fprintf(os, "\nThe symbol table:\n");
    Scope* current = root;
    int scope = 0;
    while (current) {
	int i;
	for (i = 0; i < 20*4; i++) fprintf(os, "-"); fprintf(os, "\n");
	fprintf(os, "Scope: %d%s\n", scope++, ((current->local)? " (local)": ""));
	fprintf(os, "%20s%20s%20s%20s\n", "Name", "Value", "Type", "Occurrence");
	for (i = 0; i < 20*4; i++) fprintf(os, "-"); fprintf(os, "\n");
	for (i = 0; i < NUM_CHARSET; i++) {
	    Node* bucket = current->table[i];
	    if (bucket) {
		do {
		    fprintf(os, "%20s", bucket->key);
		    fprintf(os, "%20s", bucket->value);
		    fprintf(os, "%20s", bucket->type);
		    fprintf(os, "%20d\n", bucket->occurrence);
		} while ((bucket=bucket->next));
	    }
	}
	current = current->next;
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
    Scope *current = root, *prev = NULL;
    while (current) {
	for (i = 0; i < NUM_CHARSET; i++) {
	    Node* bucket = current->table[i];
	    if (bucket) {
		do {
		    Node* next = bucket->next;
		    free(bucket);
		    bucket = next;
		} while (bucket);
	    }
	}
	free(current->table);
	free(prev);
	prev = current;
	current = current->next;
    }
}
