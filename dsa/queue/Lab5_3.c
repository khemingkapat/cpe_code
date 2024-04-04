// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "ctype.h"

typedef struct node {
    char val;
    struct node *next;
} node;

void enqueue(node **head, node **tail, char val);
void dequeue(node **head, node **tail);

int main() {
    node *vowel = NULL;
    node *vowel_tail = NULL;

    node *consonant = NULL;
    node *consonant_tail = NULL;

    node *other = NULL;
    node *other_tail = NULL;

    char str[1001];
    fgets(str, 1001, stdin);
    str[strcspn(str, "\n")] = '\0';
    int len = strlen(str);

    for (int i = 0; i < len; i++) {
        char c = str[i];
        // get vowels
        if (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' ||
            c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U') {
            enqueue(&vowel,&vowel_tail,c);
            // get consonant
        } else if (isalpha(c)) {
            enqueue(&consonant,&consonant_tail,c);
            // get others
        } else {
            enqueue(&other,&other_tail,c);
        }
    }
    while(vowel != NULL){
        printf("%c",vowel->val);
        vowel = vowel->next;
    }
    while(other != NULL){
        printf("%c",other->val);
        other = other->next;
    }
    while(consonant != NULL){
        printf("%c",consonant->val);
        consonant = consonant->next;
    }
    puts("");


    return 0;
}

void enqueue(node **head, node **tail, char val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;

    if (*head == NULL) {
        *head = new_node;
        *tail = new_node;
        return;
    }

    node *cur = *tail;
    new_node->next = cur->next;
    cur->next = new_node;
    *tail = cur->next;
}

void dequeue(node **head, node **tail) {
    if (*head == NULL) {
        return;
    }
    node *temp = *head;
    *head = temp->next;

    if (*head == NULL) {
        *tail = NULL;
    }
}
