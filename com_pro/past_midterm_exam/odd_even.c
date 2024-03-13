#include "math.h"
#include "stdio.h"
#include "stdlib.h"

void odd_even() {
    int n;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        int inp;
        scanf("%d",&inp);
        arr[i] = inp;
    }


    int odd_counter = 0;
    for (int j = 0; j < n; j++) {
        if (abs(arr[j]) % 2 == 1) {
            printf("%d ", arr[j]);
            odd_counter++;
        }
    }
    if(odd_counter){
        printf("\n");
    }else{
        printf("None\n");
    }


    int even_counter = 0;
    for (int j = 0; j < n; j++) {
        if (abs(arr[j])  % 2 == 0) {
            printf("%d ", arr[j]);
            even_counter++;
        }
    }
    if(even_counter){
        printf("\n");
    }else{
        printf("None\n");
    }
    
}

int main() {
    odd_even();

    return 0;
}
