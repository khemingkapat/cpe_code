#include "stdio.h"
#include "stdlib.h"

void selection_sort(int *arr, int n);

int main() {
    int n;
    scanf("%d", &n);
    int *arr = (int *)malloc(sizeof(int) * n);
    for (int i = 0; i < n; i++) {
        scanf("%d", arr + i);
    }
    printf("original arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts(" ");
    selection_sort(arr, n);
    printf("sorted arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");

    return 0;
}

int arg_min(int *arr, int n, int start) {
    int min = arr[start];
    int idx = start;

    for (int i = start; i < n; i++) {
        if (arr[i] < min) {
            min = arr[i];
            idx = i;
        }
    }
    return idx;
}

void selection_sort(int *arr, int n) {
    for (int i = 0; i < n; i++) {
        int min_idx = arg_min(arr, n, i);
        int temp = arr[min_idx];
        arr[min_idx] = arr[i];
        arr[i] = temp;
    }
}
