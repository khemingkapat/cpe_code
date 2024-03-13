#include "stdio.h"

int min_by_con(int *arr, int size, int exc, int *idxs);
int in(int *arr, int size, int n);
int idx(int *arr, int size, int n,int *idxs);
unsigned long long int smallest(int n);


int main() {
    // setting up array
    int n;
    scanf("%d", &n);
    unsigned long long int result = smallest(n);
    printf("%llu\n",result);

    return 0;
}

int min_by_con(int *arr, int size, int exc, int *idxs) {
    /*
    10 would be great because it is the largest number that would be possible to exceed
    so but something might be happen if there is no min
    */
    int min = 10;
    for (int i = 0; i < size; i++) {
        if (arr[i] < min && arr[i] != exc && !in(idxs, size, i)) {
            /* printf("current min is %d\n", arr[i]); */
            min = arr[i];
        }
    }
    if(min == 10){
        return 0;
    }
    return min;

}

int in(int *arr, int size, int n) {
    for (int i = 0; i < size; i++) {
        if (arr[i] == n) {
            return 1;
        }
    }
    return 0;
}
int idx(int *arr, int size, int n,int *idxs) {
    for (int i = 0; i < size; i++) {
        if (arr[i] == n && !in(idxs,size,i)) {
            return i;
        }
    }
    return -1;
}

unsigned long long int smallest(int n){
    int arr[n];
    int idxs[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
        idxs[i] = -1;
    }
    unsigned long long int result = min_by_con(arr, n, 0, idxs);
    idxs[0] = idx(arr, n, result,idxs);
    for (int i = 1; i < n; i++) {
        int num = min_by_con(arr, n, -1, idxs);
        result = result * 10 + num;
        idxs[i] = idx(arr, n, num,idxs);
    }
    return result;

}
