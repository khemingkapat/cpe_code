#include "stdio.h"

int power(int n,int pwr){
    if(pwr == 0){
        return 1;
    }else{
        return n * power(n,pwr-1);
    }
}

int main(){
    printf("2 to the power of 5 is %d\n",power(2,5));

    return 0;
}
