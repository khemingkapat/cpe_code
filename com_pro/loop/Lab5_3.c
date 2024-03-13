// 66070503408 Khem Ingkapat
#include "stdio.h"

void floyd_pyramid() {
    int n, i, j, counter = 1;

    scanf("%d", &n);

    for (i = 0; i < n; i++) {
        for (j = 0; j <= i; j++) {
            printf("%3d", counter);
            counter++;
        }
        printf("\n");
    }
}

int main(){

    return 0;
}
