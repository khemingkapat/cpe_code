#include "stdio.h"
#include "string.h"

char *sort(char *s);
void find_missing(char *s1, char *s2);

int main() {
    char str1[100];
    scanf("%s", str1); 
    char *s1 = sort(str1);

    char str2[100];
    scanf("%s", str2);
    char *s2 = sort(str2);
    find_missing(s1,s2);

    return 0;
}

char *sort(char *s) {
    int size = strlen(s);
    for (int slot = 1; slot < size; slot++) {
        int val = s[slot];
        int test_slot = slot - 1;
        while (test_slot > -1 && s[test_slot] > val) {
            s[test_slot + 1] = s[test_slot];
            test_slot -= 1;
        }
        s[test_slot + 1] = val;
    }
    return s;
}

void find_missing(char *s1, char *s2) {
    int size1 = strlen(s1);
    int size2 = strlen(s2);
    int use = size2;
    char *larger = s1;
    if (size1 < size2) {
        use=size1;
        larger = s2;
    }

    for (int i = 0; i < use; i++) {
        if (s1[i] != s2[i]) {
            
            printf("%c\n",larger[i]);
            return ;
        }
    }
    printf("%c\n",larger[use-1]);
}
