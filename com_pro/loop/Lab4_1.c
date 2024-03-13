// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void gcd() {
    int a, b;
    scanf("%d %d", &a, &b);

    int max = (a < b) ? a : b;
    for (int i = max; i >= 1; i--) {
        if (a % i == 0 && b % i == 0) {
            printf("%d\n", i);
            break;
        }
    }
}

int main() {
    gcd();

    return 0;
}
