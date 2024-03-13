#include "stdio.h"
#include "string.h"

void decode(char *str);

int main(){
    char str[100];
    scanf("%s",str);
    decode(str);

    return 0;
}

void decode(char *str){
    int len = strlen(str);
    for (int i = 0; i<len; i++) {
        if(str[i] >=48 && str[i]<= 57){
            for(int j = 0;j<str[i] - 48;j++){
                printf("%c",str[i+1]);
            }
            i++;
        }else{
            printf("%c",str[i]);
        }
    }
    printf("\n");
}
