#include "stdio.h"
#include "math.h"

void move_zero(void) {
    int n, z_counter = 0;
    scanf("%d", &n);
    int arr[n];

    for (int i = 0; i < n; i++) {
        int inp;
        scanf("%d", &inp);
        arr[i] = inp;
    }

    for (int j = 0; j < n; j++) {
        if (arr[j] != 0) {
            printf("%d\n", arr[j]);
        } else {
            z_counter++;
        }
    }

    for (int k = 0; k < z_counter; k++) {
        printf("0\n");
    }
}

int main(){
    move_zero();

    return 0;
}
