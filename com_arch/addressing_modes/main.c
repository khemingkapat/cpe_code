#include "stdio.h"

long fib(int num);
long rec_fib(int num);
int main(void) {
    long fib44 = fib(44);
    printf("the 44th fibonacci is %ld\n", fib44);
    return 0;
}

long fib(int num) {
    int fibs[num + 1]; // initialize array size of num (number of fib we want)

    // initialize first 2 value
    fibs[0] = 0;
    fibs[1] = 1;

    // loop for new value start with the 3rd one since first two if fixed
    for (int i = 2; i <= num; i++) {
        fibs[i] = fibs[i - 1] + fibs[i - 2];
    }

    // return the fibonacci number at the location we want
    return fibs[num];
}
