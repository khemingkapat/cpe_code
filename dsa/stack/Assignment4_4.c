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
char pop(node **head);
char peep(node **head);
bool is_empty(node **head);
int importance(char operator);

int main() {
    char expression[1000];
    scanf("%s", expression);
    int length = strlen(expression);

    node *head = NULL;

    for (int i = 0; i < length; i++) {
        char current = expression[i];
        if (current == 40) {
            push(&head, current);
        } else if (current == 41) {
            while (!is_empty(&head) && peep(&head) != 40) {
                printf("%c", pop(&head));
            }
            pop(&head);
        } else if (importance(current) == 0) {
            printf("%c", current);
        } else {
            while (!is_empty(&head) &&
                   importance(current) <= importance(peep(&head))) {
                printf("%c", pop(&head));
            }
            push(&head, current);
        }
    }

    while (!is_empty(&head)) {
        printf("%c", pop(&head));
    }
    puts("");

    return 0;
}

bool is_empty(node **head) { return *head == NULL; }

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

char pop(node **head) {
    if (*head == NULL) {
        return 0;
    }

    node *cur = *head;
    *head = cur->next;
    return cur->val;
}

char peep(node **head) {
    if (*head == NULL) {
        return 0;
    }
    node *cur = *head;
    return cur->val;
}

int importance(char operator) {
    if (operator== 42 || operator== 47) {
        return 2;
    } else if (operator== 43 || operator== 45) {
        return 1;
    }
    return 0;
}
