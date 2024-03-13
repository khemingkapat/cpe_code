// 66070503408 Khem Ingkapat
#include "stdio.h"

void number_pyramid() {
    int n, i, j;
    scanf("%d", &n);

    for (i = 1; i <= n; i++) {
        for (int space = 1; space <= (n - i) * 2; space++) {
            printf(" ");
        }
        for (j = i; j < 2 * i - 1; j++) {
            printf("%d ", j);
        }
        for (j - 2; j >= i; j--) {
            printf("%d ", j);
        }
        printf("\n");
    }
}

int main() { return 0; }
