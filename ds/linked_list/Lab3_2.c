// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void insert(node **head, int val,int ins_val);
void append(node **head, int val,int ins_val);

int main() {
    int n;
    scanf("%d", &n);
    node *head = (node *)malloc(sizeof(node));
    node *cur = head;
    for (int i = 0; i < n; i++) {
        int val;
        scanf("%d", &val);
        cur->next = (node *)malloc(sizeof(node));
        cur->next->val = val;
        cur = cur->next;
    }
    head = head->next;
    while(1){
        char mode;
        scanf("%c",&mode);
        if(mode == 65){
            int val,ins_val;
            scanf("%d %d",&val,&ins_val);
            append(&head, val, ins_val);
        }else if(mode == 66){
            int val,ins_val;
            scanf("%d %d",&val,&ins_val);
            insert(&head, val, ins_val);
        }else if(mode == 69){
            break;
        }
    }
    while (head) {
        printf("%d ",head->val);
        head = head->next;
    }
    puts("");

    return 0;
}

void append(node **head, int val,int ins_val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = ins_val;
    new_node->next = NULL;

    node *cur = *head;
    while(cur){
        if(cur->val == val){
            new_node->next = cur->next;
            cur->next =new_node;
            return ;
        }
        cur = cur->next;
    }
    free(cur);

}

void insert(node **head,int val,int ins_val){
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = ins_val;
    new_node->next = NULL;

    node *cur = *head;
    if(cur->val == val){
        new_node->next = *head;
        *head = new_node;
        return ;
    }
    node *precur = *head;
    cur = cur->next;
    while(cur){
        if(cur->val == val){
            precur->next = new_node;
            new_node->next = cur;
            return ;
        }
        precur = precur->next;
        cur = cur->next;
    }
    free(cur);
}

