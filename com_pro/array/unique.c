#include "stdio.h"

void unique(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        scanf("%d",&arr[i]);
    }

    for(int i = 0;i<n;i++){
        int is_unique = 1;
        for(int j = 0;j<n;j++){
            if(arr[j] == arr[i] && i != j){
                is_unique = 0;
                break;
            }
        }
        if(is_unique){
            printf("%d\n",arr[i]);

        }

    }
}

int main(){
    unique();

    return 0;
}
