#include "stdio.h"
#include "math.h"

int in_arr(int arr[], int val, int n) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == val) {
            return 1;
            break;
        }
    }
    return 0;
}

int frequency(int arr[],double val,int size){
    int result = 0;
    for(int i = 0;i<size;i++){
        if(arr[i] == val){
            result++;
        }
    }
    return result;
}


void mode(int arr[],int size){
    int m[2];
    int max_count = 0;

    for(int i = 0;i<size;i++){
        int count = 0;
        for(int j = 0;j<size;j++){
            if(arr[i] == arr[j]){
                count++;
            }
        }

        if(count >= max_count){
            max_count = count;
        }

    }
    int mode_counter = 0;
    for(int k = 0;k<size;k++){
        int found = 0;
        if(frequency(arr,arr[k],size) == max_count){
            if(!in_arr(m,arr[k], mode_counter)){
                m[mode_counter] = arr[k];
                mode_counter++;
            }
        }
    }
    

    if(mode_counter > 2){
        printf("NONE\n");
    }else{
        for(int y = 0;y<mode_counter;y++){
            printf("%d ",m[y]);
        }
        printf("\n");
    }

}

void stat() {
    int n;
    int result = 0;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    for (int j = 0; j < n; j++) {
        result = result + arr[j];
    }

    double mean = (double)result / n;

    double sum_dist = 0;
    for(int k = 0;k<n;k++){
        sum_dist = sum_dist + (double)pow((arr[k]-mean),2);
    }


    double std = sqrt(sum_dist/n);
    printf("%.2lf\n",mean);
    mode(arr,n);
    printf("%.2lf\n",std);
}

int main(){
    int arr[5] = {1,1,2,3,3};
    mode(arr, 5);

    return 0;
}
