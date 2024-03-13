#include "stdio.h"

void min_max();

int main(){
    min_max();
    return 0;
}

void min_max(){
    int n,max = -1001,min = 1001;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        int num;
        scanf("%d",&num);
        if(num < min){
            min = num;
        }

        if(num > max){
            max = num;
        }
    }

    printf("%d\n%d\n",max,min);
}



