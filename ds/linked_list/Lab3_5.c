// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int val;
    struct node *next;
} node;

void insert(node **tail, int val);
void delete(node **tail, int val);

int main() {
    node *tail = NULL;

    while(1){
        char mode;
        scanf("%c",&mode);
        if(mode == 73){
            int val;
            scanf("%d",&val);
            insert(&tail,val);
        }else if(mode == 68){
            int val;
            scanf("%d",&val);
            delete(&tail,val);
        }else if(mode == 69){
            break;
        }
    }

    if (tail == NULL) {
        puts("Empty");
        return 0;
    }
    node *cur = tail->next;
    do {
        printf("%d ", cur->val);
        cur = cur->next;
    } while (cur != tail->next);
    puts("");

    return 0;
}

void insert(node **tail, int val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;

    if (*tail == NULL) {
        new_node->next = new_node;
        *tail = new_node;
        return;
    }

    node *cur = *tail;
    new_node->next = cur->next;
    cur->next = new_node;
    *tail = cur->next;
}

void delete(node **tail, int val) {
    // empty list -> ignore
    if(*tail == NULL){
        return ;
    }


    // single item->delete it
    node *cur = *tail;
    if(cur->next == cur && cur->val == val){
        *tail = NULL;
        return ;
    }
    
    node *temp = *tail;
    int found = 0;
    temp = temp->next;

    do{
        if(temp->next->val == val){
            found++;
            break;
        }
        temp = temp->next;
    }while(temp != cur->next);

    if(found == 0){
        puts("not found");
        return ;
    }
    node *temp_2 = temp->next;
    temp->next = temp_2->next;
    if(temp_2 == *tail){
        *tail = temp;
    }
    free(temp_2);
    temp_2 = NULL;

}


