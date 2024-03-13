// 66070503408 Khem Ingkapat
#include "stdio.h"

void pascal_pyramid() {
    int n, i, j;
    scanf("%d", &n);

    for (i = 1; i <= n; i++) {
        for (int space = 1; space <= n - i; space++) {
            printf("  ");
        }
        int coef = 1;
        for (int j = 1; j <= i; j++) {
            printf("%4d", coef);
            coef = coef * (i - j) / j;
        }
        printf("\n");
    }
}

int main(){

    return 0;
}
