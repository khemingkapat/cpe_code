#include "stdio.h"
int lcm(int a,int b){
    int t = a%b;
    if(t == 0){
        return a;
    }else{
        return a*lcm(b, t) / t;
    }
}

int main(){
    int a,b;
    scanf("%d",&a);
    scanf("%d",&b);
    if(a == 0 || b == 0){
        printf("ERROR\n");
        return 0;
    }
    int result = lcm(a,b);
    printf("%d\n",result);
    return 0;
}
