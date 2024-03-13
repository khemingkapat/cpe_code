// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

void swap(int *aPtr, int *bPtr);
void sort_array(int *arr,int size);

int main(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        scanf("%d",&arr[i]);
    }
    sort_array(arr, n);
    for(int i = 0;i<n;i++){
        printf("%d\n",arr[i]);
    }
    return 0;
}

void sort_array(int *arr,int size){
    for(int i = 0;i<size-1;i++){
        for(int j = 0;j<size-i-1;j++){
            if(arr[j] > arr[j+1] ){
                swap(&arr[j],&arr[j+1]);
            }
        }
    }
}

void swap(int *aPtr,int *bPtr){
    int temp = *aPtr;
    *aPtr = *bPtr;
    *bPtr = temp;
}

