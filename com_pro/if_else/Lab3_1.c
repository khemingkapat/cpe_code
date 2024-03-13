// 66070503408 Khem Ingkapat
#include "stdio.h"

void celsius_to_farenheit(void){
    double celsius;
    double farenheit;

    scanf("%lf",&celsius);
    farenheit = (celsius * 9/5) + 32;

    printf("%f\n",farenheit);
}

int main(){
    celsius_to_farenheit();

    return 0;
}
