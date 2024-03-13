//66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void push(node **head,int val);
int pop(node **head);

int main(){
    int n,base;
    scanf("%d",&n);
    scanf("%d",&base);
    if(base < 2 || base > 36 || n<0){
        puts("invalid");
        exit(0);
    }

    if(n == 0){
        puts("0");
        exit(0);
    }
    
    node *head = NULL;
    while(n > 0){
        int remainder = n % base;
        push(&head,remainder);
        n /= base;
    }

    while(head != NULL){
        int digit = pop(&head);
        if(digit > 9){
            printf("%c",digit+55);
        }else{
            printf("%d",digit);
        }
    }
    puts("");




    return 0;
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

int pop(node **head){

    node *cur = *head;
    *head = cur->next;
    return cur->val;
}


