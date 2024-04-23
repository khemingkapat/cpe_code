#include "stdio.h"
#include "stdlib.h"

void merge_sort(int *arr, int l, int r);

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
    merge_sort(arr, 0, n - 1);
    printf("sorted arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");

    return 0;
}

void merge(int *arr, int l, int m, int r) {
    int l_idx, r_idx, arr_idx;
    int l_len = m - l + 1;
    int r_len = r - m;

    int L[l_len], R[r_len];

    for (l_idx = 0; l_idx < l_len; l_idx++) {
        L[l_idx] = arr[l + l_idx];
    }
    for (r_idx = 0; r_idx < r_len; r_idx++) {
        R[r_idx] = arr[m + 1 + r_idx];
    }

    for (l_idx = 0, r_idx = 0, arr_idx = l; arr_idx <= r; arr_idx++) {
        if ((l_idx < l_len) && (r_idx >= r_len || L[l_idx] <= R[r_idx])) {
            arr[arr_idx] = L[l_idx];
            l_idx++;
        } else {
            arr[arr_idx] = R[r_idx];
            r_idx++;
        }
    }
}

void merge_sort(int *arr, int l, int r) {
    if (r - l == 0) {
        return;
    }
    int m = l + (r - l) / 2;
    merge_sort(arr, l, m);
    merge_sort(arr, m + 1, r);

    merge(arr, l, m, r);
}
