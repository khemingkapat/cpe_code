#include "stdio.h"

void convert_to_bin(int n);

int main(){
    int n;
    scanf("%d",&n);
    convert_to_bin(n);

    return 0;
}

void convert_to_bin(int n){
    int result = 0,place = 1;
    while(n){
        int rem = n%2;
        result = result + (rem*place);
        place = place*10;
        n = n / 2;
    }

    printf("%d\n",result);
}

