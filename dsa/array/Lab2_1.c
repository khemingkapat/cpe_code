//66070503408
// tbh, at the first place, I didn't know how to do it with normal array
// so I use linked list
#include "stdio.h"
#include "stdlib.h"

// linked list node struct
typedef struct node{
    int val;
    struct node *next;
} Node;

int main(){
    // basically O(n)
    int n;
    scanf("%d",&n);
    // allocate the head(first) node in linked list
    Node *head = (Node *) malloc(sizeof(Node));
    Node *current = head;
    for(int i = 0;i<n;i++){
        int d;
        scanf("%d",&d);
        current->val = d;
        current->next = (Node * ) malloc(sizeof(Node));
        current = current->next;
    }
    // last node pointed to NULL
    current->next=NULL;
    int remainder;
    scanf("%d",&remainder);
    int idx = 0;
    int count = 0;
    // going until next node is NULL
    while(head->next){
        if(idx%2 == remainder){
            printf("%d ",head->val);
            count++;
        }
        idx++;
        head = head->next;
    }
    if(!count){
        printf("none");
    }
    puts("");
    free(head);
    return 0;
}
