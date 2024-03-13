#include "stdio.h"
#include "stdlib.h"
int len(char* str){
    int count = 0;
    while(str[count]!='\0'){
        count++;
    }
    return count;
}
char* reverse_string(char * str){
    int size = len(str);
    if(size <= 1){
        return str;
    }else{
        char *new_str = malloc(sizeof(char) * size);
        for(int i = 1;i<size;i++){
            new_str[i-1] = str[i];
        }
        char *new_rev_str = reverse_string(new_str);
        char *rev_str = malloc(sizeof(char) * (size+1));
        for(int i = 0;i<size;i++){
            rev_str[i] = new_rev_str[i];
        }
        rev_str[size-1] = str[0];
        return rev_str;
    }
}

int main(){
    char str[5] = "hello";
    printf("reverse string of %s is %s\n",str,reverse_string(str));

    return 0;
}
