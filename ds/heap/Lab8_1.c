// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "stdbool.h"
#include "string.h"

typedef struct heap {
    int *arr;
    int size;
} heap_t;

heap_t *init_heap();
void insert(heap_t **root,int val);
void delete(heap_t **root,int val);
void print_heap(heap_t *heap){
    for(int i = 0;i<heap->size;i++){
        printf("%d ",heap->arr[i]);
    }
    puts("");
}
void deallocate(heap_t *root){
    root->size = 0;
    root->arr = NULL;
    free(root);
}

int main(){
    heap_t *heap = init_heap();
    char mode[256];
    while (true) {
        scanf("%s", mode);
        if (strcmp(mode, "INSERT") == 0) {
            int val;
            char symb;
            do {
                scanf("%d%c", &val, &symb);
                insert(&heap, val);
            } while (symb != '\n');
        } else if (strcmp(mode, "DELETE") == 0) {
            int val;
            char symb;
            do {
                scanf("%d%c", &val, &symb);
                delete(&heap, val);
            } while (symb != '\n');
        } else if (strcmp(mode, "PRINT") == 0) {
            print_heap(heap);
        } else if (strcmp(mode, "EXIT") == 0) {
            break;
        } 
    }
    deallocate(heap);


    return 0;
}

heap_t *init_heap(){
    heap_t *heap = (heap_t *)malloc(sizeof(heap_t));
    heap->size = 0;
    heap->arr = NULL;
    return heap; 
}

void insert(heap_t **root,int val){
    heap_t *heap = *root;
    heap->size += 1;
    heap->arr = (int *)realloc(heap->arr,sizeof(int)*heap->size);

    heap->arr[heap->size-1] = val;
    
    int target_idx = heap->size-1;
    int parent_idx = (target_idx-1)/2;

    while(heap->arr[target_idx] < heap->arr[parent_idx] && target_idx >= 0){
        int temp = heap->arr[parent_idx];
        heap->arr[parent_idx] = heap->arr[target_idx];
        heap->arr[target_idx] = temp;

        target_idx = parent_idx;
        parent_idx = (target_idx-1)/2;
    }
}

void delete(heap_t **root,int val){
    heap_t *heap = *root;
    int target_idx;
    for(target_idx = 0;target_idx<heap->size;target_idx++){
        if(heap->arr[target_idx] == val){
            break;
        }
    }

    int temp = heap->arr[target_idx];
    heap->arr[target_idx] = heap->arr[heap->size-1];
    heap->arr[heap->size-1] = temp;

    heap->size--;
    heap->arr = (int *)realloc(heap->arr,sizeof(int)*heap->size);

    for(int i = 0;i<heap->size;i++){
        if(heap->arr[i] > heap->arr[(2*i)+1] && (2*i)+1<heap->size){
            int temp = heap->arr[i];
            heap->arr[i] = heap->arr[(2*i)+1];
            heap->arr[(2*i)+1] = temp;
        }

        if(heap->arr[i] > heap->arr[(2*i)+2] && (2*i)+2<heap->size){
            int temp = heap->arr[i];
            heap->arr[i] = heap->arr[(2*i)+2];
            heap->arr[(2*i)+2] = temp;
        }
    }
}


