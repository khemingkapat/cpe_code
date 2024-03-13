#include "stdio.h"

int sum_prime(int n);
int is_prime(int n, int i);

int main() {
    int n;
    scanf("%d", &n);
    int pf = sum_prime(n);
    if (is_prime(pf, 2)) {
        printf("True\n");
    } else {
        printf("False\n");
    }

    return 0;
}

int is_prime(int n, int i) {
    if (n <= 2) {
        if(n==2){
            return 1;
        }else{
            return 0;
        }
    }

    if (n % i == 0) {
        return 0;
    }

    if (i * i > n) {
        return 1;
    }

    return is_prime(n, i + 1);
}

int sum_prime(int n) {
    int result = 0;
    if(n<=1){
        return result;
    }
    while (!is_prime(n, 2)) {
        for (int j = 2; j < n; j++) {
            if (is_prime(j, 2) && n % j == 0) {
                result += j;
                n = n / j;
                break;
            }
        }
    }

    return result + n;
}
