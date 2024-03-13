// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void sum_serie() {
    int n, result = 0;
    scanf("%d", &n);

    for (int i = 0; i < n; i++) {
        for (int j = 0; j <= i; j++) {
            result += 9 * pow(10, j);
        }
    }
    printf("%d\n", result);
}

int main() {
    sum_serie();

    return 0;
}
