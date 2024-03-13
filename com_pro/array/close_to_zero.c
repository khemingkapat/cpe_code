#include "stdio.h"
#include "stdlib.h"

void close_to_zero() {
    int n, result[2], min = 1000;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (abs(arr[i] + arr[j]) < min && i != j) {
                result[0] = arr[i];
                result[1] = arr[j];
                min = abs(arr[i] + arr[j]);
            }
        }
    }
    printf("%d\n", result[0]);
    printf("%d\n", result[1]);
}
int main() {
    close_to_zero();

    return 0;
}
