// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    int *val;
    int size;
    struct node *next;
} node;

void enqueue(node **head, node **tail, int *val, int size);
node dequeue(node **head, node **tail);

int main() {
    int size;
    scanf("%d", &size);
    int *og_queue = (int *)malloc(sizeof(int)*size);
    /* int og_queue[size]; */
    for (int i = 0; i < size; i++) {
        int val;
        scanf("%d", &val);
        og_queue[i] = val;
    }

    node *q4 = NULL;
    node *q4_tail = NULL;

    node *q3 = NULL;
    node *q3_tail = NULL;

    node *q2 = NULL;
    node *q2_tail = NULL;

    node *q1 = NULL;
    node *q1_tail = NULL;

    int l = 0;
    int r = 0;

    // O(n), is the maximum, it could be much more less
    // I would say it is a amortized case
    while (r <= size - 1) {
        int current_sum = 0;
        // getting group of 4
        while (current_sum + og_queue[r] <= 4 && r < size) {
            current_sum += og_queue[r];
            r++;
        }

        // create group
        int group_size = 0;
        int *val = (int *)malloc(sizeof(int) * (r - l));
        for (int i = l; i < r; i++) {
            val[i - l] = og_queue[i];
            group_size += og_queue[i];
        }

        // enqueue for each priority
        if (group_size == 4) {
            enqueue(&q4, &q4_tail, val, r - l);
        } else if (group_size == 3) {
            enqueue(&q3, &q3_tail, val, r - l);
        } else if (group_size == 2) {
            enqueue(&q2, &q2_tail, val, r - l);
        } else {
            enqueue(&q1, &q1_tail, val, r - l);
        }
        l = r;
    }

    // O(n) dequeue each item from queue;
    while (q4 != NULL) {
        for (int i = 0; i < q4->size; i++) {
            printf("%d ", q4->val[i]);
        }
        puts("");
        *q4 = dequeue(&q4, &q4_tail);
    }
    
    while(q3 != NULL){
        for(int i = 0;i<q3->size;i++){
            printf("%d ",q3->val[i]);
        }
        puts("");
        *q3 = dequeue(&q3, &q3_tail);
    }
    
    while(q2 != NULL){
        for(int i = 0;i<q2->size;i++){
            printf("%d ",q2->val[i]);
        }
        puts("");
        *q2 = dequeue(&q2, &q2_tail);
    }
    
    while(q1 != NULL){
        for(int i = 0;i<q1->size;i++){
            printf("%d ",q1->val[i]);
        }
        puts("");
        *q1 = dequeue(&q1, &q2_tail);
    }
    
    return 0;
}

// O(1) enqueue, to the tail, we keep tail, no traversing
void enqueue(node **head, node **tail, int *val, int size) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    new_node->size = size;
    new_node->next = NULL;

    if (*head == NULL) {
        *head = new_node;
        *tail = new_node;
        return ;
    }

    node *cur = *tail;
    cur->next = new_node;
    *tail = cur->next;
}

// O(1) dequeue, move to next head
node dequeue(node **head, node **tail) {
    node *temp = *head;
    if (*head == NULL) {
        return *temp;
    }
    *head = temp->next;

    if (*head == NULL) {
        *tail = NULL;
    }
    return *temp;
}
