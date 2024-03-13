// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "string.h"

char *sort(char *s);
int matching(char *a, char *b);

int main() {
    char str1[100];
    scanf("%s",str1);
    char *s1 = sort(str1);

    char st2[100];
    scanf("%s",st2);
    char *s2 = sort(st2);

    if(matching(s1, s2)){
        printf("True\n");
    }else{
        printf("False\n");
    }

    return 0;
}

char *sort(char *str) {
    int size = strlen(str);
    for (int i = 1; i < size; i++) {
        int val = str[i];
        int test_slot = i - 1;
        while (test_slot > -1 && str[test_slot] > val) {
            str[test_slot + 1] = str[test_slot];
            test_slot -= 1;
        }
        str[test_slot + 1] = val;
    }
    return str;
}

int matching(char *a,char *b){
    int size1 = strlen(a);
    int size2 = strlen(b);

    if(size1 != size2){
        return 0;
    }
    for(int i = 0;i<size1;i++){
        if(a[i] !=  b[i]){
            return 0;
        }
    }
    return 1;
}
