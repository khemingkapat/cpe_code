#include "stdio.h"

int is_perfect(int n);
void perfect_number_range(int start,int stop);

int main(){
    int start,stop;
    scanf("%d",&start);
    scanf("%d",&stop);
    perfect_number_range(start, stop);

    return 0;
}

int is_perfect(int n){
    if(n == 0){
        return 0;
    }
    int sum = 0;
    for(int i = 1;i<n;i++){
        if(n % i == 0){
            sum += i;
        }
    }

    if(sum == n){
        return 1;
    }else{
        return 0;
    }
}

void perfect_number_range(int start,int stop){
    int perfect_count = 0;
    for(int i = start;i<=stop;i++){
        if(is_perfect(i)){
            printf("%d\n",i);
            perfect_count++;
        }
    }

    if(perfect_count == 0){
        printf("None\n");
    }

}
