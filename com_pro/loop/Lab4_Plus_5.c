// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"

int is_prime(int num) {
    if (num <= 1) {
        return 0;
    }
    for (int i = 2; i < num - 1; i++) {
        if (num % i == 0) {
            return 0;
        }
    }
    return 1;
}

void prime_factor() {
    int n;
    printf("Enter the number: ");
    scanf("%d", &n);
    printf("The factor of %d is ", n);

    while (!is_prime(n)) {

        for (int j = 2; j < n; j++) {
            if (is_prime(j) && n % j == 0) {
                printf("%d*", j);
                n = n / j;
                break;
            }
        }
    }
    printf("%d\n", n);
}

int main() {
    prime_factor();

    return 0;
}
