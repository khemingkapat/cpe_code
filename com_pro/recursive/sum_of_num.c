#include "stdio.h"
int sum_of_num(int n){
    if(n == 0){
        return 0;
    }else{
        return n%10 + sum_of_num(n/10);
    }
}

int main(){
    printf("sum of 142 is %d\n",sum_of_num(142));

    return 0;
}
