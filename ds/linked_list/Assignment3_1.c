// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct node {
    int id;
    int score;
    struct node *next;
} student;

void sort_id(student **head,int n);
void sort_score(student **head,int n);

int main(){
    int n;
    scanf("%d",&n);
    student *head = (student * )malloc(sizeof(student));
    student *cur = head;
    for(int i = 0;i<n;i++){
        int id,score;
        scanf("%d %d",&id,&score);
        student *new_student = (student *)malloc(sizeof(student));
        new_student->id = id;
        new_student->score = score;
        cur->next = new_student;
        cur=cur->next;
    }
    head = head->next;
    int mode;
    scanf("%d",&mode);
    if(mode == 0){
        sort_id(&head,n);
    }else if(mode == 1){
        sort_score(&head,n);
    }

    student *ptr = head;
    while(ptr){
        printf("%d ",ptr->score);
        ptr = ptr->next;
    }
    puts("");

    return 0;
}

student *swap(student *ptr1,student *ptr2){
    student *temp = ptr2->next;
    ptr2->next = ptr1;
    ptr1->next = temp;
    return ptr2;
}

void sort_id(student **head,int n){
    for(int i = n;i>1;i--){
        student **ptr = head;
        int swapped = 0;
        for(int j = 0;j<i-1;j++){
            student *cur = *ptr;
            student *next = cur->next;
            
            if(cur->id > next->id){
                *ptr = swap(cur,next);
                swapped = 1;
            }
            ptr = &(*ptr)->next;
        }
        if(swapped == 0){
            break;
        }
    }
}

void sort_score(student **head,int n){
    for(int i = n;i>1;i--){
        student **ptr = head;
        int swapped = 0;
        for(int j = 0;j<i-1;j++){
            student *cur = *ptr;
            student *next = cur->next;
            
            if(cur->score > next->score){
                *ptr = swap(cur,next);
                swapped = 1;
            }
            ptr = &(*ptr)->next;
        }
        if(swapped == 0){
            break;
        }
    }
}
