#include "stdio.h"
#include "stdlib.h"

void quick_sort(int *arr,int l,int r);

int main(){
    int n;
    scanf("%d", &n);
    int *arr = (int *)malloc(sizeof(int) * n);
    for (int i = 0; i < n; i++) {
        scanf("%d", arr + i);
    }
    printf("original arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts(" ");
    quick_sort(arr, 0, n - 1);
    printf("sorted arr : ");
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");

    return 0;
}
int partition(int *arr,int l,int r){
    int i=l,j=r;
    int pivot_val = arr[l];
    while(i <= j){
        while(arr[i]<=pivot_val){
            i++;
        }

        while(arr[j]>pivot_val){
            j--;
        }
        
        int temp = arr[i];
        arr[i]=arr[j];
        arr[j]=temp;
    }
    arr[l]=arr[j];
    arr[j]=pivot_val;

    for(int i = l;i<=r;i++){
        printf("%d ",arr[i]);
    }
    puts("");

    return j;
}

void quick_sort(int *arr,int l,int r){
    if(r-l <= 0){
        return ;
    }
    int pivot = partition(arr, l, r);
    /* printf("pivot = %d>>%d : arr => ",pivot,arr[pivot]); */
    /* for(int i = l;i<=r;i++){ */
    /*     printf("%d ",arr[i]); */
    /* } */
    /* puts(""); */
    quick_sort(arr, l, pivot-1);
    quick_sort(arr, pivot+1, r);
}
