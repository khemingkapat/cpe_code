#include "stdio.h"
#include "stdlib.h"

void insertion_sort(int *arr, int n);

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
    insertion_sort(arr, n);
    printf("sorted arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");

    return 0;
}

void insertion_sort(int *arr, int n) {
    for(int i = 1;i<n;i++){
        int temp = arr[i];
        int j = i-1;
        while(temp < arr[j] && j>= 0){
            arr[j+1] = arr[j];
            j--;
        }
        arr[j+1] = temp;
    }
}
