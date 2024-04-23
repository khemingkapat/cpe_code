#include "stdio.h"
#include "stdlib.h"

void bubble_sort(int *arr,int n);

int main(){
    int n;
    scanf("%d",&n);
    int *arr = (int *)malloc(sizeof(int)*n);
    for(int i = 0;i<n;i++){
        scanf("%d",arr+i);
    }
    printf("original arr : ");
    for(int i = 0;i<n;i++){
        printf("%d ",arr[i]);
    }
    puts(" ");
    bubble_sort(arr,n);
    printf("sorted arr : ");
    for(int i = 0;i<n;i++){
        printf("%d ",arr[i]);
    }
    puts("");
    

    return 0;
}

void bubble_sort(int *arr,int n){
    for(int i = n;i>=1;i--){
        for(int j = 1;j<i;j++){
            if(arr[j-1] > arr[j]){
                int temp = arr[j];
                arr[j] = arr[j-1];
                arr[j-1] = temp;
            }
        }
    }

}
