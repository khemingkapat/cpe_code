// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

void insert(int *tree, int size, int idx, int val);
int idx(int tree[], int size, int target);
void print_tree(int tree[], int size);

int main() {
    int size;
    scanf("%d", &size);

    int *tree = (int *)malloc(sizeof(int) * size);
    for(int i = 0;i<size;i++){
        *(tree+i) = -999;
    }

    while (true) {
        char mode[256];
        scanf("%s", mode);
        if (strcmp(mode, "ROOT") == 0) {
            if (tree[0] != -999) {
                puts("cannot create duplicated root");
                continue;
            }
            int val;
            scanf("%d", &val);
            *tree = val;
        } else if (strcmp(mode, "INSL") == 0 || strcmp(mode, "INSR") == 0) {
            int par, val;
            scanf("%d %d", &par, &val);
            int index = idx(tree, size, par);
            if (index == -1) {
                puts("not found");
                continue;
            }
            int ins_index = 2*index + 1;
            if(strcmp(mode,"INSR") == 0){
                ins_index++;
            }

            insert(tree, size, ins_index, val);
        } else if (strcmp(mode, "END") == 0) {
            break;
        }
    }
    print_tree(tree, size);
    return 0;
}

int idx(int tree[], int size, int target) {
    for (int i = 0; i < size; i++) {
        if (tree[i] == target) {
            return i;
        }
    }
    return -1;
}

void insert(int *tree, int size, int idx, int val) {
    if (idx >= size) {
        puts("overflow");
        return;
    }

    if (tree[idx] != -999) {
        puts("node already presented");
        return;
    }

    tree[idx] = val;
}

void print_tree(int tree[], int size) {
    for (int i = 0; i < size; i++) {
        if (tree[i] == -999) {
            printf("null ");
            continue;
        }
        printf("%d ", tree[i]);
    }
    puts("");
}
