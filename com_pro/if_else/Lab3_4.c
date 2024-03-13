// 66070503408 Khem Ingkapat
#include "stdio.h"

void quotient_and_remainder(void){
    int numerator,denominator,quotient,remainder;
    scanf("%d %d",&numerator,&denominator);

    quotient = numerator/denominator;
    remainder = numerator % denominator;

    printf("%d %d\n",quotient,remainder);
}

int main(){
    quotient_and_remainder();

    return 0;
}
