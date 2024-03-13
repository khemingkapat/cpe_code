#include "stdio.h"

double is_power(double n, int base);

int main() {
    double n;
    scanf("%lf", &n);
    if (is_power(n, 2)) {
        puts("True");
    } else {
        puts("False");
    }

    if (is_power(n, 3)) {
        puts("True");
    } else {
        puts("False");
    }

    if (is_power(n, 4)) {
        puts("True");
    } else {
        puts("False");
    }

    return 0;
}

double is_power(double n,int base){
    if(n<1){
        return 0;
    }else if(n == 1){
        return 1;
    }else{
        return is_power(n/base,base);
    }
}
