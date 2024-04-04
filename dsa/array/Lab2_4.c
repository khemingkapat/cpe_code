// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"


void printArray(int arr[], int size);

// reallocating array to size+1 
int insertArray(int *arr, int size, int index, int value) {
    if(index >= size){
        printf("Index out of bounds\n");
        return size;
    }
    arr = realloc(arr, sizeof(int) * (size + 1));
    for (int i = size; i > index; i--) {
        *(arr + i) = *(arr + i - 1);
    }
    *(arr + index) = value;
    printArray(arr, size+1);
    
    return size + 1;
}

// remove that index,shift item remove size
int deleteArray(int *arr, int size, int index) {
    if(index >= size){
        printf("Index out of bounds\n");
        return size;
    }
    int skip = 0;
    for (int i = 0; i < size; i++) {
        if (i == index) {
            *(arr + i) = *(arr + i + 1);
            skip++;
            continue;
        }
        *(arr + i) = *(arr + i + skip);
    }
    arr = realloc(arr, sizeof(int) * (size - 1));
    printArray(arr, size-1);

    return size - 1;
}

// allocate new array and then push 2 array together
int *mergeArray(int *arr1, int size1, int *arr2, int size2) {
    int *new_arr = (int *)malloc(sizeof(int)*(size1+size2));
    int idx = 0;
    for(int i = 0;i<size1;i++){
        *(new_arr+idx) = *(arr1+i);
        idx++;
    }
    for(int j = 0;j<size2;j++){
        *(new_arr+idx) = *(arr2+j);
        idx++;
    }
    printArray(new_arr, size1+size2);
    return new_arr;
}


void printArray(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    puts("");
}

int main() {
    int n;
    scanf("%d", &n);
    int *arr1 = (int *)malloc(sizeof(int) * n);
    for (int i = 0; i < n; i++) {
        scanf("%d", (arr1 + i));
    }
    int m;
    scanf("%d", &m);
    int *arr2 = (int *)malloc(sizeof(int) * m);
    for (int i = 0; i < m; i++) {
        scanf("%d", (arr2 + i));
    }
    int index, value, del_index;
    scanf("%d %d %d", &index, &value, &del_index);

    n = insertArray(arr1, n, index, value);
    /* printArray(arr1, n); */
    n = deleteArray(arr1, n, del_index);
    /* printArray(arr1, n); */
    int *new_arr = mergeArray(arr1, n, arr2, m);
    /* printArray(new_arr, n+m); */
    free(arr1);
    free(arr2);
    free(new_arr);

    return 0;
}
