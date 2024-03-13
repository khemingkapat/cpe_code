#include "stdio.h"
#include "math.h"

int is_prime(int n) {
    if(n <=1){
        return 0;
    }
    for (int i = 2; i < n; i++) {
        if (n % i == 0) {
            return 0;
            break;
        }
    }
    return 1;
}

int reverse_number(int n) {
    int result = 0, r;
    while (n > 0) {
        r = n % 10;
        result = (result * 10) + r;
        n = n / 10;
    }
    return result;
}

void prime_palindrome() {
    int n;
    scanf("%d", &n);
    int m = n + 1;
    while (1) {
        if (is_prime(m) && (m == reverse_number(m))) {
            printf("%d\n", m);
            break;
        }
        m++;
    }
}

int main(){
    prime_palindrome();

    return 0;
}
