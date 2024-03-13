// 66070503408
// again, i used linked list
#include "stdio.h"
#include "stdlib.h"

typedef struct node{
    int val;
    struct node *next;
} Node;


void max_min_arr(){
    int n;
    // keep track of index of max and min
    int l_idx = 0,s_idx = 0;
    // max will be the lowest possible at first and min is the highest possible
    int min = 2147483647;
    int max = -2147483648;
    scanf("%d",&n);
    Node *head = (Node *) malloc(sizeof(Node));
    Node *current = head;
    // traversing through linked list
    for(int i = 0;i<n;i++){
        int d;
        scanf("%d",&d);
        current->val = d;
        current->next = (Node *) malloc(sizeof(Node));
        current = current->next;
    }

    int idx = 0;
    while(head->next){
        if(head->val > max){
            max = head->val;
            l_idx = idx;
        }

        if(head->val < min){
            min = head->val;
            s_idx = idx;
        }
        head = head->next;
        idx++;
    }
    // print in the function
    printf("%d %d\n",max,l_idx);
    printf("%d %d\n",min,s_idx);
    free(head);

}

int main(){
    max_min_arr();

    return 0;
}
