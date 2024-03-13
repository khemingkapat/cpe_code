//66070503408 Khem Ingkapat
#include "stdio.h"

int cube(int n);

int main(){
    int n;
    scanf("%d",&n);
    printf("%d\n",cube(n));

    return 0;
}

int cube(int n){
    return n*n*n;
}
