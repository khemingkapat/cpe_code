#include "stdio.h"
#include "string.h"

int in(char *str, char c);
void mapping(char *s1, char *s2);

int main() {
    char str1[100];
    scanf("%s", str1);

    char str2[100];
    scanf("%s", str2);
    mapping(str1, str2);

    return 0;
}

int in(char *str, char c) {
    int size = strlen(str);
    for (int i = 0; i < size; i++) {
        if (str[i] == c) {
            return 1;
        }
    }
    return 0;
}

void mapping(char *s1, char *s2) {
    int max_replaced = strlen(s2);
    int replaced = 0;
    int size1 = strlen(s1);

    for (int i = 0; i < size1; i++) {
        if (!in(s2, s1[i]) || replaced >= max_replaced) {
            printf("X");

        } else {
            printf("%c", s1[i]);
            replaced++;
        }
    }
    printf("\n");
}
