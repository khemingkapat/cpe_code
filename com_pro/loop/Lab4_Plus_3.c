// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"

void fibonacci() {
    int n, out, t1, t2;
    scanf("%d", &n);
    t1 = 1, t2 = 1;
    printf("%d %d ", t1, t2);

    for (int i = 2; i < n; i++) {
        out = t1 + t2;
        printf("%d ", out);
        t1 = t2;
        t2 = out;
    }
    printf("\n");
}

int main() {
    fibonacci();

    return 0;
}
