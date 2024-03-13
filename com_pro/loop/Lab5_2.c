// 66070503408 Khem Ingkapat
#include "stdio.h"

void printPascal() {
    int n;
    scanf("%d", &n);
    for (int line = 1; line <= n; line++) {
        for (int space = 1; space <= n - line; space++)
            printf("  ");
        // used to represent C(line, i)
        int coef = 1;
        for (int i = 1; i <= line; i++) {
            // The first value in a line
            // is always 1
            printf("%4d", coef);
            coef = coef * (line - i) / i;
        }
        printf("\n");
    }
}

int main() { return 0; }
