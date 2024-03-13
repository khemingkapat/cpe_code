//66070503408 Khem Ingkapat
#include "stdio.h"

int lenstr(char *str);

int main(){
    char str[100];
    scanf("%s",str);
    printf("%d\n",lenstr(str));

    return 0;
}

int lenstr(char *str){
    int len = 0;
    while(str[len] != '\0'){
        len++;
    }
    return len;
}


