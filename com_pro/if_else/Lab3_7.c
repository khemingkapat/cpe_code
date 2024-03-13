// 66070503408 Khem Ingkapat
#include "stdio.h"

void check_character(void){
    char c;
    scanf(" %c",&c);

    if(c>=65 && c<=90){
        puts("Upper");
    }else if(c>=97 && c<=122){
        puts("Lower");
    }else{
        puts("Number");
    }
};

int main(){
    check_character();

    return 0;
}
