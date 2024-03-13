// 66070503408 Khem Ingkapat
#include "stdio.h"

// recursive function for minimum jump from index k to end
int min_jump(int arr[],int start,int end){
    if(start >= end){
        return 0;
    }
    
    int min = 10000;
    // recursively checking all reachable index and get min
    for(int i = 1;i<=start[arr];i++){
        int jump = min_jump(arr,start+i,end);
        if(jump < min){
            min = jump;
        }
    }
    // case that it doesn't go to the end
    if(min==10000 && start+arr[start]+1 < end){
        return -10000;
    }
    return 1+min;
}

int main(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        scanf("%d",&arr[i]);
    }
    int min = min_jump(arr, 0, n-1);
    if(min < 0){
        puts("Not possible");
        return 0;
    }
    printf("%d\n",min);


    return 0;
}
