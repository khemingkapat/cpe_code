// O(3n) => O(n);
#include "stdio.h"


int main() {
    int n;
    scanf("%d", &n);
    // n
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    int set[n];
    int last_idx = 0;
    // n
    for (int i = 0; i < n; i++) {
        if (i == 0 || arr[i] != arr[i - 1]) {
            set[last_idx] = arr[i];
            last_idx++;
        }
    }
    printf("%d\n", last_idx);
    // n
    for (int i = 0; i < last_idx; i++) {
        printf("%d ", set[i]);
    }
    puts("");

    return 0;
}
