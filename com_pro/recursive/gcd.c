#include "stdio.h"

int gcd(int a ,int b){
    int low,high;
    if(a < b){
        low = a;
        high = b;
    }else{
        low = b;
        high = a;
    }
    if(low == 0){
        return high;
    }else if(low == 1){
        return 1;
    }else{
        return gcd(low,high%low);
    }
}

int main(){
    printf("gcd of 12 and 24 is %d\n",gcd(12,24));

    return 0;
}
