#include "stdio.h"
#include "stdlib.h"

void check_date(int d,int m,int y);

void get_input(){
    int d,m,y;
    scanf("%d/%d/%d",&d,&m,&y);

    check_date(d,m,y);
}

int is_leap(int n){
    if(n%4 == 0 && n%100 != 0 || n%400 == 0){
        return 1;
    }
    return 0;
}

void check_date(int d,int m,int y){
    int day_in_month[12] = {31,28+is_leap(y),31,30,31,30,31,31,30,31,30,31};
    if(d<= 0){
        printf("Input date is invalid. Enter a valid data again\n");
    }
    if(m<= 0){
        printf("Input date is invalid. Enter a valid data again\n");
    }
    if(y<= 0){
        printf("Input date is invalid. Enter a valid data again\n");
    }
    if(d <= day_in_month[m-1]){
        printf("Inpute date is valid\n");
    }else{
        printf("Input date is invalid. Enter a valid data again\n");
    }
    get_input();
}

int main(){
    get_input();

    return 0;
}



