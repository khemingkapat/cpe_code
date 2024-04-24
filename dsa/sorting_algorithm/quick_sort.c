#include "stdio.h"
#include "stdlib.h"

void quick_sort(int *arr, int l, int r);
int partition(int *arr, int l, int r);

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
    quick_sort(arr, 0, n - 1);
    printf("sorted arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");

    return 0;
}
int partition(int *arr, int l, int r) {
    int pivot_val = arr[l];
    int i = l, j = r + 1;

    do {
        do {
            i++;
        } while (arr[i] < pivot_val);

        do {
            j--;
        } while (arr[j] > pivot_val);
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    } while (i < j);

    int temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;

    temp = arr[l];
    arr[l] = arr[j];
    arr[j] = temp;

    return j;
}

void quick_sort(int *arr, int l, int r) {
    if (r - l <= 0) {
        return;
    }
    int pivot = partition(arr, l, r);
    quick_sort(arr, l, pivot - 1);
    quick_sort(arr, pivot + 1, r);
}
