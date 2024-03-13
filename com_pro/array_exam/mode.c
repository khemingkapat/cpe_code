// 66070503408 Khem Ingkapat
#include "stdio.h"

void mode(int *arr, int size);
int freq(int *arr, int n, int size);
int in(int *arr, int n, int size);

int main() {
    int n;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }
    mode(arr, n);

    return 0;
}

void mode(int *arr, int size) {
    int max_count = 0;

    for (int i = 0; i < size; i++) {
        if (freq(arr, arr[i], size) >= max_count) {
            max_count = freq(arr, arr[i], size);
        }
    }

    int mode[size], mode_counter = 0;
    for (int i = 0; i < size; i++) {
        if (freq(arr, arr[i], size) == max_count && !in(mode, arr[i], 2)) {
            mode[mode_counter] = arr[i];
            mode_counter++;
        }
    }
    if (mode_counter > 2) {
        printf("NONE\n");
        return;
    }

    for(int i = 0;i<mode_counter;i++){
        printf("%d ",mode[i]);
    }
    printf("\n");
}

int freq(int *arr, int n, int size) {
    int count = 0;
    for (int i = 0; i < size; i++) {
        if (arr[i] == n) {
            count += 1;
        }
    }
    return count;
}

int in(int *arr, int n, int size) {
    for (int i = 0; i < size; i++) {
        if (arr[i] == n) {
            return 1;
        }
    }
    return 0;
}
