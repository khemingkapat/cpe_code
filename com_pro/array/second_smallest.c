#include "stdio.h"

void find_second_smallest() {
    int n, min = 1000;
    scanf("%d", &n);
    int arr[n];

    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
        if (arr[i] <= min) {
            min = arr[i];
        }
    }

    /* some better things */
    int new_min = arr[0];
    int min_idx;
    for (int j = 0; j < n; j++) {
        if (arr[j] < new_min && arr[j] > min) {
            new_min = arr[j];
            min_idx = j;
        }
    }
    printf("%d\n", new_min);
    printf("%d\n", min_idx);
}

int main() {
    find_second_smallest();

    return 0;
}
