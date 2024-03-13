// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "stdbool.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void push(node **head,int val);
void pop(node **head);
void peep(node **head);
int is_empty(node **head);


int main(){
    node *head = NULL;
    while(true){
        char mode;
        scanf("%c",&mode);
        if(mode == 112){
            int val;
            scanf("%d",&val);
            push(&head,val);
        }else if(mode == 111){
            pop(&head);
        }else if(mode == 116){
            peep(&head);
        }else if(mode == 101){
            int empty = is_empty(&head);
            printf("%d\n",empty);
        }else if(mode == 113){
            break;
        }

    }
    return 0;
}

int is_empty(node **head){
    return *head == NULL;
}

void push(node **head,int val){   
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    if(*head == NULL){
        new_node->next = NULL;
        *head = new_node;
        return ;
    }
    new_node->next = *head;
    *head = new_node;
}

void pop(node **head){
    if(*head == NULL){
        puts("empty");
        return ;
    }

    node *cur = *head;
    printf("%d\n",cur->val);
    *head = cur->next;
}

void peep(node **head){
    if(*head == NULL){
        puts("empty");
        return ;
    }
    node *cur = *head;
    printf("%d\n",cur->val);
    
}
