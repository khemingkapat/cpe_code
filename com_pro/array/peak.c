#include "stdio.h"

void first_peak() {
    int n, j;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    for (j = 1; j < n - 1; j++) {
        if (arr[j - 1] < arr[j] && arr[j] > arr[j + 1]) {
            break;
        }
    }
    printf("%d\n", j);
}

int main() {
    first_peak();

    return 0;
}
