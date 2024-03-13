// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void decimal_to_binary() {
    int result[10], n, i;
    scanf("%d", &n);
    for (i = 0; n > 0; i++) {
        result[i] = n % 2;
        n = n / 2;
    }
    for (i = i - 1; i >= 0; i--) {
        printf("%d", result[i]);
    }
    printf("\n");
}

void decimal_to_binary_no_array() {
    int n, exp = 0;
    scanf("%d", &n);
    while (pow(2, exp) <= n) {
        exp++;
    }
    for (int i = exp - 1; i >= 0; i--) {
        int temp_result = 1;
        for (int j = 0; j < i; j++) {
            temp_result = temp_result * 2;
        }
        if (temp_result <= n) {
            printf("1");
            n = n - temp_result;
        } else {
            printf("0");
        }
    }
    printf("\n");
}

int main() {
    decimal_to_binary();

    return 0;
}
