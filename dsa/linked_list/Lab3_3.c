// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;


int main() {
    int n;
    scanf("%d",&n);
    node *head = (node *) malloc(sizeof(node));
    node *cur = head;
    for(int i = 0;i<n;i++){
        int val;
        scanf("%d",&val);
        cur->next = (node *)malloc(sizeof(node));
        cur->next->val = val;
        cur = cur->next;
    }
    head = head->next;
    while(1 && head){
        char mode;
        scanf("%c",&mode);
        if(mode == 70){
            // F
            head = head->next;
        }else if(mode ==76){
            // L
            if(head->next == NULL){
                head = NULL;
                continue;
            }
            node *cur = head;
            while(cur->next->next != NULL){
                cur = cur->next;
            }
            free(cur->next);
            cur->next = NULL;
        }else if(mode ==78){
            // N
            int target;
            node *n = head->next;
            scanf("%d",&target);
            if(head->next == NULL && head->val == target){
                head = NULL;
                continue;
            }
            node *dummy = (node *)malloc(sizeof(node));
            dummy->next=head;
            node *cur = head;
            node *prev = dummy;
            while(cur){
                if(cur->val == target){
                    prev->next = cur->next;
                    cur = cur->next;
                    break;
                }else{
                    prev = cur;
                    cur = cur->next;
                }
            }
            head = dummy->next;
            
        }else if(mode == 69){
            break;
        }
    }
    int count = 0;
    while(head != NULL){
        printf("%d ",head->val);
        head = head->next;
        count++;
    }
    if(count == 0){
        printf("none");
    }
    puts("");


    return 0;
}



