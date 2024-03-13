#include "stdio.h"
#include "stdlib.h"

int * last_one(int *arr,int size);

int main(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 1;i<=n;i++){
        arr[i-1] = i;
    }
    int result = last_one(arr, n)[0];
    printf("%d\n",result);

    return 0;
}

int * last_one(int *arr,int size){
    if(size == 1){
        return arr;
    }else{
        int * new_arr = malloc(sizeof(int) * (size/2));
        for(int i = 0;i<size/2;i++){
            new_arr[i] = arr[2*i + 1];
        }
        return last_one(new_arr, size/2);
    }
}
