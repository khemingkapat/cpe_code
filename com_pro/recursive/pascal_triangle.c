#include "stdio.h"
#include "stdlib.h"

int* pascal_triangle(int n){
    if(n == 1){
        int *arr = malloc(sizeof(int) * 1);
        arr[0] = 1;
        return arr;
    }else{

        int *line = malloc(sizeof(int)*n);
        line[0] = 1;
        int *previous = pascal_triangle(n-1);
        for(int i = 1;i<n-1;i++){
            line[i] = previous[i-1] + previous[i];
        }
        line[n-1] = 1;
        return line;

    }
}
int main(){
    int *p = pascal_triangle(5);
    for(int i = 0;i<5;i++){
        printf("%d ",p[i]);
    }
    printf("\n");

    return 0;
}
