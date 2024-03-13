// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void insert(node **tail, int val);

int main() {
    int size, step;
    scanf("%d %d", &size, &step);
    node *tail = NULL;
    for (int i = 0; i < size; i++) {
        int val;
        scanf("%d", &val);
        insert(&tail, val);
    }

    node *head = tail->next;
    while (head->next != head) {
        node *next = head;
        for (int i = 0; i < step-2; i++) {
            next = next->next;
        }
        next->next = next->next->next;
        head = next->next;
    }
    printf("%d\n", head->val);

    return 0;
}

void insert(node **tail, int val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;

    if (*tail == NULL) {
        new_node->next = new_node;
        *tail = new_node;
        return;
    }

    node *cur = *tail;
    new_node->next = cur->next;
    cur->next = new_node;
    *tail = cur->next;
}
