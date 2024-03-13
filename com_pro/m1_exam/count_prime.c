// input enter inclusive interval
// output n elements of prime number in that open interval
//
#include "stdio.h"
int is_prime(int n) {
    if (n <= 1) {
        return 0;
    }
    for (int i = 2; i < n; i++) {
        if (n % i == 0) {
            return 0;
        }
    }
    return 1;
}
int main(void) {
    int start,end,prime_count = 0;
    scanf("%d", &start);
    scanf("%d", &end);

    if (start <= 0) {
        start = 0;
    }
    if (end <= 0) {
        end = 0;
    }

    for(int i = start;i<=end;i++){
        if(is_prime(i)){
            prime_count++;
        }
    }
    printf("%d\n",prime_count);

    return 0;
}
