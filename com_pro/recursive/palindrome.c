#include "stdio.h"

int len(char* str){
    int count = 0;
    while(str[count]!='\0'){
        count++;
    }
    return count;
}

int palindrome_string(char * str){
    int size = len(str);
    if(size <= 1){
        return str[0] == str[size-1];
    }else{
        char new_str[size-2];
        for(int i = 1;i<size-1;i++){
            new_str[i-1] = str[i];
        }
        return (str[0] == str[size-1]) && palindrome_string(new_str);
    }
}

int main(){
    char str[5] = "hello";
    if(palindrome_string(str)){
        printf("Yes\n");
    }else{
        printf("No\n");
    }

    return 0;
}
