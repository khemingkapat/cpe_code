// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    struct node *prev;
    int val;
    struct node *next;
} node;

void add(node **head, int val);
void del(node **head, int val);
void search(node **head, int val);
void print(node **head);

int main() {
    node *head = NULL;
    while (1) {
        char *mode;
        scanf("%s", mode);
        if (strcmp(mode, "ADD") == 0) {
            int val;
            scanf("%d", &val);
            add(&head, val);
        } else if (strcmp(mode, "DEL") == 0) {
            int val;
            scanf("%d", &val);
            del(&head, val);
        } else if (strcmp(mode, "SCH") == 0) {
            int val;
            scanf("%d", &val);
            search(&head, val);
        } else if (strcmp(mode, "END") == 0) {
            break;
        }
    }
    print(&head);

    return 0;
}

void add(node **head, int val) {
    node *new_node = (node *)malloc(sizeof(node));
    new_node->val = val;
    new_node->next = NULL;

    if (*head == NULL) {
        new_node->prev = NULL;
        *head = new_node;
        return;
    }
    node *cur = *head;
    while (cur->next) {
        cur = cur->next;
    }
    cur->next = new_node;
    new_node->prev = cur;
}

// doing with removing first element
void del(node **head, int val) {
    if(*head == NULL){
        return ;
    }

    node *cur = *head;
    node *dummy = (node *)malloc(sizeof(node));
    dummy->next = *head;
    node *prev = dummy;

    while (cur) {
        if(cur->val == val){
            break;
        }
        prev=cur;
        cur=cur->next;
    }

    if(cur == NULL){
        return ;
    }

    if (cur->next == NULL && cur->prev == NULL) {
        // delete single ele
        *head = NULL;
    } else if (cur->prev == NULL) {
        // for deleting first node
        cur = cur->next;
        cur->prev = NULL;
        *head = cur;
    } else if (cur->next == NULL) {
        // deleting last node
        cur = cur->prev;
        cur->next = NULL;
        return;
    } else {
        prev->next = cur->next;
        prev->next->prev = prev;
    }
}

void search(node **head, int val) {
    node *cur = *head;
    while (cur) {
        if(cur->val == val){
            break;
        }
        cur = cur->next;
    }
    if (cur == NULL) {
        printf("none\n");
        return ;
    }

    if (cur->prev != NULL) {
        printf("%d ", cur->prev->val);
    } else {
        printf("NULL ");
    }

    if (cur->next != NULL) {
        printf("%d\n", cur->next->val);
    } else {
        printf("NULL\n");
    }
}

void print(node **head) {
    node *cur = *head;
    int count = 0;
    while (cur) {
        printf("%d ", cur->val);
        cur = cur->next;
        count++;
    }
    if (count == 0) {
        printf("none");
    }
    puts("");
    free(cur);
    node *prev = *head;
    while (prev && prev->next) {
        prev = prev->next;
    }
    int rev_count = 0;
    while (prev) {
        printf("%d ", prev->val);
        prev = prev->prev;
        rev_count++;
    }
    if (rev_count == 0) {
        printf("none");
    }
    puts("");
    free(prev);
}

