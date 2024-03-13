// 66070503408 Khem Ingkapat
#include <stdio.h>
#include <stdlib.h>

// struct of list contain both size and array
typedef struct LIST {
    int size;
    int *arr;

} LIST_T;

// create function init array to create empty list
LIST_T *initList() {
    LIST_T *list = (LIST_T *)malloc(sizeof(LIST_T));
    list->size = 0;
    list->arr = NULL;
    return list;
}

// append item to list
void append(LIST_T *list, int val) {
    list->size++;
    list->arr = realloc(list->arr, sizeof(int) * list->size);
    list->arr[list->size - 1] = val;
}

// print list
void printList(LIST_T *list) {
    if (list->size == 0) {
        printf("empty\n");
        return;
    }

    for (int i = 0; i < list->size; i++) {
        printf("%d ", *(list->arr + i));
    }

    printf("\n");
}

// using modulo for turning negative index to positive index
int assignStartEnd(int idx, int size,int pos) {

    if(idx < -size){
        return 0;
    }else if(idx < 0){
        return idx += size;
    }else if(idx > size){
        return size-1+pos;
    }
    return idx;

}

// slicing depend on step, go to l-> r or r-> l
LIST_T *slice(LIST_T *list, int start, int end, int step) {
    LIST_T *sliced = initList();


    start = assignStartEnd(start, list->size,0);
    end = assignStartEnd(end, list->size,1);

    if (step > 0) {
        /* puts("positive step"); */
        for (int i = start; i < end; i += step) {
            /* puts("hello"); */
            append(sliced, *(list->arr + i));
        }
    } else {
        for (int i = start;i> -1 && i > end; i += step) {
            append(sliced, *(list->arr + i));
        }
    }

    return sliced;
}

int main() {
    LIST_T *list = initList();
    int n;
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        int temp;
        scanf("%d", &temp);
        append(list, temp);
    }
    /* printf("orignal list = "); */
    /* printList(list); */

    int start, end, step;
    scanf("%d %d %d", &start, &end, &step);

    if(step == 0){
        puts("empty");
        exit(0);
    }
    if(start >= n && end >= n){
        puts("empty");
        exit(0);
    }else if(start <= -n && end <= -n){
        puts("empty");
        exit(0);
    }

    LIST_T *sliced = slice(list, start, end, step);
    printList(sliced);

    free(list);
    free(sliced);
    return 0;
}


