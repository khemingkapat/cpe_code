//66070503408 Khem Ingkapat
#include "stdio.h"

int freq(int *arr,int size,int n);
int is_unique(int *arr,int size);

int main(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        scanf("%d",&arr[i]);
    }
    if(is_unique(arr,n)){
        printf("True\n");
    }else{
        printf("False\n");
    }

    return 0;
}

int freq(int *arr,int size,int n){
    int count = 0;
    for(int i = 0;i<size;i++){
        if(arr[i] == n){
            count += 1;
        }
    }
    return count;

}

int is_unique(int *arr,int size){
    for(int i = 0;i<size;i++){
        if(freq(arr,size,arr[i]) > 1){
            return 0;
        }
    }
    return 1;


}
