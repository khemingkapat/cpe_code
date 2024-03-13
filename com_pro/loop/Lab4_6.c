// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void pyramid() {
    int n, max_side_spc;
    scanf("%d", &n);
    max_side_spc = n - 1;

    for (int i = max_side_spc; i >= 0; i--) {
        for (int si = 0; si < i; si++) {
            printf(" ");
        }
        for (int j = 0; j < max_side_spc - i + 1; j++) {
            printf("* ");
        }
        for (int si2 = 0; si2 < i - 1; si2++) {
            printf(" ");
        }
        printf("\n");
    }
}

int main() {
    pyramid();

    return 0;
}
