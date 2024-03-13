//66070503408 Khem Ingkapat
#include "stdio.h"
#include "string.h"

void encode(char *s,int i,int max);

int main(){
    char str[100];
    scanf("%s",str);
    int len = strlen(str);
    encode(str,0,len);
    printf("\n");

    return 0;
}

void encode(char *s,int i,int max){
    if(i >= max) return;

    if(s[i] >= 48 && s[i] <= 57){
        for(int j = 0;j<s[i] - 48;j++){
            printf("%c",s[i+1]);
        }
        i++;
    }else{
        printf("%c",s[i]);
    }

    encode(s, i+1, max);


}
