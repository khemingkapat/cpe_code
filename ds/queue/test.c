// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    char val;
    struct node *next;
} node;

void enqueue(node **head, node **tail, char val);
void dequeue(node **head, node **tail);

int main() {
    node *head = (node *)malloc(sizeof(node));
    head->next = (node *)malloc(sizeof(node));
    head->next->next = (node *)malloc(sizeof(node));
    head->next->next->next = NULL;

    node *vowel = head;
    node *vowel_tail = vowel;
    node *other = head->next;
    node *other_tail = other;
    node *consonant = head->next->next;
    node *consonant_tail = consonant;

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
        } else if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
            enqueue(&consonant,&consonant_tail,c);
            // get others
        } else {
            enqueue(&other,&other_tail,c);
        }
    }
    while(head != NULL){
        printf("[%c]",head->val);
        head = head->next;
    }

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
