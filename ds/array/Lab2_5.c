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
int assignStartEnd(int idx, int size) {

    int res = idx % size;
    return res < 0 ? res + size : res;
}

// slicing depend on step, go to l-> r or r-> l
LIST_T *slice(LIST_T *list, int start, int end, int step) {
    LIST_T *sliced = initList();

    if(start<list->size*-1){
        start = 0;
    }else if(start > list->size){
        start = list->size-1;
    }

    if(end < list->size*-1){
        end = 0;
    }else if(end >list->size){
        end = list->size;
    }
    start = assignStartEnd(start, list->size);
    end = assignStartEnd(end, list->size);

    if (step > 0) {
        for (int i = start; i < end; i += step) {
            append(sliced, *(list->arr + i));
        }
    } else {
        for (int i = start; i > end; i += step) {
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
    /* printList(list); */

    int start, end, step;
    scanf("%d %d %d", &start, &end, &step);

    LIST_T *sliced = slice(list, start, end, step);
    printList(sliced);

    free(list);
    return 0;
}

