// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void reverse(node **head, int start, int stop);

int main() {
    node *head = (node *)malloc(sizeof(node));
    node *cur = head;
    while (1) {
        char in[5];
        scanf("%s", in);
        if (strcmp(in, "END") == 0) {
            break;
        }
        int val = atoi(in);
        node *new_node = (node *)malloc(sizeof(node));
        new_node->val = val;
        cur->next = new_node;
        cur = cur->next;
    }
    if(head == NULL){
        return 0;
    }
    head = head->next;
    int start,stop;
    scanf("%d %d",&start,&stop);
    reverse(&head,start,stop);

    node *ptr = head;
    while (ptr) {
        printf("%d ", ptr->val);
        ptr = ptr->next;
    }
    puts("");

    return 0;
}

void reverse(node **head, int start, int stop) {
    // case reverse single element;
    if (start == stop) {
        return;
    }
    node *start_node= *head, *end_node=*head, *runner = *head,*reversed_tail;
    int count = 1;
    node *reversed = NULL;
    while (runner) {
        if(count >= start && count <= stop){
            node *new_node = (node *)malloc(sizeof(node));
            new_node->val = runner->val;
            new_node->next = NULL;
            if(reversed == NULL){
                reversed = new_node;
                reversed_tail = new_node;
            }else{
                new_node->next = reversed;
                reversed = new_node;
            }
        }

        if (count < start-1) {
            start_node = start_node->next;
        }

        if (count < stop) {
            end_node = end_node->next;
        }
        runner = runner->next;
        count++;
    }

    /* printf("start =  %d,stop = %d\n",start_node->val,end_node->val); */
    reversed_tail->next = end_node->next;
    if(start == 1){
        *head = reversed;
        return;
    }
    start_node->next = reversed;
}
