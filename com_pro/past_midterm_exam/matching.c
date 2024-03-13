#include "stdio.h"
#include "math.h"


int in_arr(int arr[], int val, int n) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == val) {
            return 1;
            break;
        }
    }
    return 0;
}

void matching() {
    int n1;
    scanf("%d", &n1);
    int arr1[n1];
    for (int i = 0; i < n1; i++) {
        int inp1;
        scanf("%d", &inp1);
        arr1[i] = inp1;
    }
    int n2;
    scanf("%d", &n2);
    int arr2[n2];
    for (int l = 0; l < n2; l++) {
        int inp2;
        scanf("%d", &inp2);
        arr2[l] = inp2;
    }

    int is_subset = 1;
    if (n1 < n2) {
        for (int j = 0; j < n1; j++) {
            if (!in_arr(arr2, arr1[j], n2)) {
                is_subset = 0;
                break;
            }
        }
    } else {
        for (int k = 0; k < n2; k++) {
            if (!in_arr(arr1, arr2[k], n1)) {
                is_subset = 0;
                break;
            }
        }
    }
    if (is_subset) {
        printf("True\n");
    } else {
        printf("False\n");
    }
}

int main(){
    matching();

    return 0;
}
