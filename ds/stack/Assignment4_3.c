// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    char val;
    struct node *next;
} node;

void push(node **head, int val);
void pop(node **head);
char peep(node **head);
bool is_empty(node **head);

int main() {
    char s[1000];
    scanf("%s", s);
    int length = strlen(s);
    node *head = NULL;

    for (int i = 0; i < length; i++) {
        char current = s[i];
        // filter only bracket
        if (current == 40 || current == 91 || current == 123 || current == 41 ||
            current == 93 || current == 125) {
            if (!is_empty(&head) &&
                (peep(&head) == current - 2 || peep(&head) == current - 1)) {
                pop(&head);
            } else {
                push(&head, current);
            }
        }
    }
    if (is_empty(&head)) {
        puts("The string is balanced");
    } else {
        puts("The string is not balanced");
    }

    return 0;
}

void push(node **head, int val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    if (*head == NULL) {
        new_node->next = NULL;
        *head = new_node;
        return;
    }
    new_node->next = *head;
    *head = new_node;
}

void pop(node **head) {

    if (*head == NULL) {
        return;
    }

    node *cur = *head;
    *head = cur->next;
    /* return cur->val; */
}

char peep(node **head) {
    if (*head == NULL) {
        return 0;
    }
    node *cur = *head;
    return cur->val;
}

bool is_empty(node **head) { return *head == NULL; }
