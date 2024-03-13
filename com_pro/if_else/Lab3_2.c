// 66070503408 Khem Ingkapat
#include "stdio.h"

void check_triangle(void){
    int a,b,c;
    scanf("%d %d %d",&a,&b,&c);

    if(a+b > c && b+c > a && a+c > b){
        puts("Yes");
    }else {
        puts("No");
    }
}

int main(){
    check_triangle();

    return 0;
}
