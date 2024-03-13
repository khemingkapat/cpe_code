// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void print_prime_number() {
    int n;
    scanf("%d", &n);
    bool is_not_prime;
    for (int i = 2; i <= n; i++) {
        for (int j = 2; j <= sqrt(i); j++) {
            is_not_prime = false;
            if (i % j == 0) {
                is_not_prime = true;
                break;
            }
        }
        if (!is_not_prime) {
            printf("%d ", i);
        }
    }
    printf("\n");
}

int main() {

    print_prime_number();

    return 0;
}
