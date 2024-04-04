//66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "stdbool.h"

void hanoi(int disk,char from,char to,char aux);
int count = 0;
int main(){
    int n;
    scanf("%d",&n);
    hanoi(n,'A','C','B');
    printf("Total moves: %d\n",count);

    return 0;
}

void hanoi(int disk,char from,char to,char aux){
    if(disk == 1){
        printf("Move disk %d from %c to %c\n",disk,from,to);
    }else{
        hanoi(disk-1,from,aux,to);
        printf("Move disk %d from %c to %c\n",disk,from,to);
        hanoi(disk-1,aux,to,from);
    }
    count++;
}
