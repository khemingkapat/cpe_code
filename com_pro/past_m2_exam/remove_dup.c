#include "stdio.h"

void remove_dup(int *arr, int i, int max);
int main(void) { 
    int n;
    scanf("%d",&n);
    int arr[n];
    for (int i = 0; i<n; i++) {
        scanf("%d",&arr[i]);
    
    }
    remove_dup(arr, 0, n);


    return 0; }

void remove_dup(int *arr, int i, int max) {
    if (i >= max)
        return;
    if (i == 0) {
        printf("%d\n", arr[i]);
        return remove_dup(arr, 1, max);
    }

    if (arr[i] != arr[i - 1]) {
        printf("%d\n", arr[i]);
    }
    return remove_dup(arr, i + 1, max);
}
