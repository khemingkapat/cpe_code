#include "stdio.h"
#include "string.h"

int in(char *str, char c);
void is_substring(char *s1, char *s2);

int main() {
    char str1[100];
    scanf("%s", str1);

    char str2[100];
    scanf("%s", str2);
    is_substring(str1, str2);

    return 0;
}

int in(char *str, char c) {
    int size = strlen(str);
    for (int i = 0; i < size; i++) {
        if (str[i] == c) {
            return i;
        }
    }
    return -1;
}

void is_substring(char *s1, char *s2) {
    int size1 = strlen(s1);
    int size2 = strlen(s2);
    char *larger = s2;
    char *smaller = s1;
    if (size1 > size2) {
        larger = s1;
        smaller = s2;
    }
    int s_large = strlen(larger);
    int s_small = strlen(smaller);

    int start = in(larger, smaller[0]);
    if (start == -1) {
        printf("False\n");
        return;
    }

    for (int i = 0; i < s_small; i++) {
        if (larger[i + start] != smaller[i]) {
            printf("False\n");
            return;
        }
    }
    printf("True\n");
    return;
}
