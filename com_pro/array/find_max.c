#include "stdio.h"

void find_max_idx() {
    int n;
    scanf("%d", &n);
    int arr[n];

    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    int max = arr[0];
    int max_idx = 0;

    for (int j = 1; j < n; j++) {
        if (arr[j] > max) {
            max = arr[j];
            max_idx = j;
        }
    }
    printf("%d\n", max);
    printf("%d\n", max_idx);
}

int main(){
    find_max_idx();
    return 0;
}
