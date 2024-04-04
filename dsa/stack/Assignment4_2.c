//66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node{
    char val;
    struct node *next;
} node;

void push(node **head,char val);
void pop(node **head);
void palindrome(char str[]);
int is_empty(node **head);

int main(){
    char *s;
    scanf("%s",s);
    palindrome(s);

    return 0;
}

void palindrome(char str[]){
    int len = strlen(str);
    node *head = NULL;
    int left = 0,right = len-1;
    while(left <= right){
        push(&head,str[left]);
        if(head->val == str[right]){
            pop(&head);
        }else{
            push(&head,str[right]);
        }
        left++;
        right--;
    }

    if(is_empty(&head)){
        puts("yes");
    }else{
        puts("no");
    }

}

void push(node **head,char val){
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

    node *cur = *head;
    *head = cur->next;
}

int is_empty(node **head){
    return *head == NULL;
}


