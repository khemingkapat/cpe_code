#include "stdio.h"

int is_prime(int n);
void prime_range(int start,int stop);

int main(){
    int start,stop;
    scanf("%d",&start);
    scanf("%d",&stop);
    prime_range(start,stop);

    return 0;
}

int is_prime(int n){
    if(n<= 1){
        return 0;
    }

    for(int i = 2;i<n;i++){
        if(n%i == 0){
            return 0;
            break;
        }
    }
    return 1;
}

void prime_range(int start,int stop){
    int prime_count = 0;
    for(int i = start;i<= stop;i++){
        if(is_prime(i)){
            printf("%d\n",i);
            prime_count++;
        }
    }
    if(prime_count == 0){
        printf("None\n");
    }
}
