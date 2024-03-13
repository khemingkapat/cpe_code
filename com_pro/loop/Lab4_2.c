// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void average() {
    int result = 0, count = 0, n;
    while (true) {
        if (scanf("%d", &n) == 0)
            break;
        result = result + n;
        count++;
        /* count = count+1 */
    }
    if (count == 0) {
        printf("None\n");
    } else {
        int avg = result / count;
        printf("%d\n", avg);
    }
}

int main() {
    average();

    return 0;
}
