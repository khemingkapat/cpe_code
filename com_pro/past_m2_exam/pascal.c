#include "stdio.h"

int factorial(int n);
int combination(int n,int r);
void print_pascal_triangle(int n);

int main(){
    int n;
    scanf("%d",&n);
    print_pascal_triangle(n);

    return 0;
}

int factorial(int n){
    if(n<=1){
        return 1;
    }else{
        return n*factorial(n-1);
    }
}

int combination(int n,int r){
    return factorial(n)/(factorial(n-r)*factorial(r)); 
}

void print_pascal_triangle(int n){
    for(int line =  0;line<n;line++){
        for(int i=0;i<=line;i++){
            printf("%d ",combination(line,i));
        }
        printf("\n");
    }
}
