// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void insert(node **head, int val);
void append(node **head, int val);

int main() {
    int n,mode;
    scanf("%d %d", &n,&mode);
    if(n <= 0){
        puts("Invalid");
        return 0;
    }

    if(mode < 1 || mode > 2){
        puts("Invalid");
        return 0;
    }
    node *head = NULL;
    for (int i = 0; i < n; i++) {
        int d;
        scanf("%d", &d);
        if(mode == 1){
            insert(&head,d);
        }else if(mode == 2){
            append(&head,d);
        }
    }
    while (head) {
        printf("%d ",head->val);
        head = head->next;
    }
    puts("");

    return 0;
}

void insert(node **head, int val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    new_node->next = NULL;

    if (*head == NULL) {
        *head = new_node;
        return;
    }
    new_node->next = *head;
    *head = new_node;
}

void append(node **head,int val){
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    new_node->next = NULL;

    if (*head == NULL) {
        *head = new_node;
        return;
    }
    node *cur = *head;
    while(cur->next){
        cur = cur->next;
    }
    cur->next = new_node;
}

