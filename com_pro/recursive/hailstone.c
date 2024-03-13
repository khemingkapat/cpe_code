#include "stdio.h"

int hailstone(int x);

int main(){
    int n;
    scanf("%d",&n);
    hailstone(n);

    return 0;
}

int hailstone(int x){
    printf("%d\n",x);
    if(x == 1){
        return 1;
    }else{
        if(x % 2 == 0){
            return hailstone(x/2);
        }else{
            return hailstone((3*x) + 1);
        }
    }
}
