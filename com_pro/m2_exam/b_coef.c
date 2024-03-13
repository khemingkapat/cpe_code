//66070503408 Khem Ingkapat
#include "stdio.h"

int combination(int n,int r);

int main(){
    int n;
    scanf("%d",&n);
    for(int r = 0;r<=n;r++){
        if(r == n){
            printf("%d",combination(n,r));
        }else{
            printf("%d ",combination(n,r));
        }
    }
    printf("\n");

    return 0;
}


int combination(int n,int r){
    if(n == 0 || r == 0){
        return 1;
    }
    if(n == 1 && r == 1){
        return 1;
    }
     
    if(n<r){
        return 0;
    }
    return combination(n-1, r-1) + combination(n-1, r) ;
}


