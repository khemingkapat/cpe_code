//66070503408 Khem Ingkapat
#include <stdio.h>
#include <string.h> //hint

// dict struct
typedef struct dict {
    char value[100];
    char key[100];
} dict_t;

void printdict(dict_t *dict, int size) { // for printing the output
    for (int i = 0; i < size; i++) {
        printf("%s : %s\n", dict[i].key, dict[i].value);
    }
}
int main() {
    int size;
    scanf("%d", &size);
    dict_t dicts[size];
    for(int i = 0;i<size;i++){
        char key[100],val[100];
        scanf("%s",key);
        scanf("%s",val);
        strcpy(dicts[i].key,key);
        strcpy(dicts[i].value,val);
    }
    char key[100],val[100];
    scanf("%s",key);
    scanf("%s",val);
    int changed = 0;
    for(int i = 0;i<size;i++){
        if(strcmp(dicts[i].key,key)==0){
            strcpy(dicts[i].value,val);
            changed++;
        }
    }
    if(!changed){
        puts("No change");
    }
    printdict(dicts, size);


    return 0;
}
