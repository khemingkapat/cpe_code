// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    char val;
    struct node *next;
} node;

void push(node **head, char val);
char *peep(node **head);
void pop(node **head);
void enqueue(node **head, node **tail, char val);
void dequeue(node **head, node **tail);

int main() {
    char str[1000000];
    fgets(str, 256, stdin);
    str[strcspn(str, "\n")] = '\0';

    node *stack_head = NULL;
    node *queue_head = NULL;
    node *queue_tail = NULL;

    // O(n) enqueue for each char
    int len = strlen(str);
    for (int i = 0; i < len; i++) {
        char c = str[i];
        push(&stack_head, c);
        enqueue(&queue_head, &queue_tail, c);
    }


    // these 2 for loops would get max of O(n)
    while (queue_head != NULL) {
        // skipping if we see matching char, redundance
        if(queue_head->val == *peep(&stack_head)){
            /* printf("queue_head = %c",queue_head->val); */
            stack_head = stack_head->next;
        }
        // printing from queue
        dequeue(&queue_head, &queue_tail);
    }
    while (stack_head != NULL) {
        // printing from stack
        pop(&stack_head);
    }
    puts("");

    return 0;
}

void push(node **head, char val) {
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

// remove from the item;
void pop(node **head) {
    if (*head == NULL) {
        return;
    }

    node *cur = *head;
    *head = cur->next;
    printf("%c",cur->val);
}

// O(1), peeking for the head item;
char *peep(node **head) {
    if (*head == NULL) {
        return NULL;
    }
    node *cur = *head;
    return &cur->val;
}

// O(1) ,keeping tail, no traverse
void enqueue(node **head, node **tail, char val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    new_node->next = NULL;

    if (*head == NULL) {
        *head = new_node;
        *tail = new_node;
        return;
    }

    node *cur = *tail;
    cur->next = new_node;
    *tail = cur->next;
}

// O(1) dequeue, move to next head
void dequeue(node **head, node **tail) {
    if (*head == NULL) {
       return ;
    }
    node *temp = *head;
    *head = temp->next;
    printf("%c",temp->val);

    if (*head == NULL) {
        *tail = NULL;
    }
}
