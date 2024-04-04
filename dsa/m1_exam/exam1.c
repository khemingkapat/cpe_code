// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

typedef struct sortedset {
    int *elements;
    int idx;
    int size;
} set;

// Function prototypes
void init(set *s, int size);
int checkDuplicate(set *s, int target);
void insertElement(set *s, int newNum);
void printArray(set *s);
void insertion(int *arr, int size);

int main() {
    int size;
    scanf("%d", &size);

    // create empty set
    set *s = (set *)malloc(sizeof(set));

    // init set
    init(s, size);

    // adding element;
    for (int i = 0; i < size; i++) {
        int val;
        scanf("%d", &val);
        insertElement(s, val);
    }

    // sorting elements
    insertion(s->elements, s->idx);

    // creating another set
    set *new_s = (set *)malloc(sizeof(set));
    init(new_s, size);

    // checking for duplicate
    for (int i = 0; i < s->idx; i++) {
        if (checkDuplicate(new_s, s->elements[i])==0) {
            insertElement(new_s, s->elements[i]);
        }
    }

    // printing array
    printf("%d\n", new_s->idx);
    printArray(new_s);
    free(s);

    return 0;
}

// O(1) init set by malloc and set size and index;
void init(set *s, int size) {
    s->elements = (int *)malloc(sizeof(int) * size);
    s->size = size;
    s->idx = 0;
}

// O(n) for loop for counting if the elements we looking for is in the set already
// return the amount of time we found the target
int checkDuplicate(set *s, int target) {
    int found = 0;
    for (int i = 0; i < s->idx; i++) {
        if (s->elements[i] == target) {
            found++;
        }
    }
    return found;
}

// O(1)
// add element into the set without sorting
void insertElement(set *s, int newNum) {
    if (s->idx > s->size - 1) {
        return;
    }
    s->elements[s->idx] = newNum;
    s->idx++;
}

// O(n)
// just printing
void printArray(set *s) {
    printf("{");
    for (int i = 0; i < s->idx; i++) {
        printf("%d", s->elements[i]);
        if (i < s->idx - 1) {
            printf(", ");
        }
    }
    printf("}\n");
}

// O(n^2);
// using insertion sort, comparing with slot and try to insert the smaller element
// into the front;
void insertion(int *arr, int size) {
    for (int slot = 1; slot < size; slot++) {
        int val = arr[slot];
        int test_slot = slot - 1;
        while (test_slot > -1 && arr[test_slot] > val) {
            arr[test_slot + 1] = arr[test_slot];
            test_slot -= 1;
        }
        arr[test_slot + 1] = val;
    }
}
