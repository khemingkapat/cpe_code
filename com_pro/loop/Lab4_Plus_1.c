// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"

void summation() {
    int n, result = 0;
    scanf("%d", &n);
    for (int i = 1; i <= n; i++) {
        result = result + i;
    }

    printf("%d\n", result);
}

int main() {
    summation();

    return 0;
}
