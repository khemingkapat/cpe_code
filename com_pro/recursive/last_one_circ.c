#include "stdio.h"

int *last_one(int *arr, int size, int n);

int main() {
    int size, n;
    scanf("%d %d", &size, &n);
    int arr[size];
    for (int i = 1; i <= size; i++) {
        arr[i - 1] = i;
    }
    int result = last_one(arr, size, n)[0];
    printf("%d\n", result);

    return 0;
}

int *last_one(int *arr, int size, int n) {
    if (size <= 1) {
        return arr;
    } else {
        int new_arr[size - 1];
        int index = 0;
        int new_n = n;
        while(new_n>size){
            new_n -= size;
        }
        /* printf("new_n = %d <- ->",new_n); */
        /* for (int i = 0; i < size; i++) { */
        /*     if (i == new_n - 1) { */
        /*         printf("_ "); */
        /*         continue; */
        /*     } */
        /*     printf("%d ", arr[i]); */
        /* } */
        /* printf("\n"); */
        for (int i = new_n; i < size; i++) {
            new_arr[index] = arr[i];
            index++;
        }
        for (int i = 0; i < new_n - 1; i++) {
            new_arr[index] = arr[i];
            index++;
        }
        /* int new_arr_1[size-1]; */
        /* int index = 0; */
        /* for (int i = n-1 ; i < size-1; i++) { */
        /*     printf("choosing index %d to fill new_arr_1\n",i); */
        /*     new_arr_1[index] = new_arr[i]; */
        /*     index++; */
        /* } */
        /* for (int i = 0; i < n-1; i++) { */
        /*     new_arr_1[index] = new_arr[i]; */
        /*     index++; */
        /* } */
        return last_one(new_arr, size - 1, n);
    }
}
