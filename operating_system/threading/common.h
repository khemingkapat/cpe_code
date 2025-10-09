#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>

#define SIZE 100000

extern int arr[SIZE];

static inline int transform(int val) {
    if (val % 2 == 0) return val / 2;
    return val * 3 + 1;
}

// worker logic (one pass over array)
static inline void* worker(void* arg) {
    for (int i = 0; i < SIZE; i++) {
        int val = arr[i];
        val = transform(val);
        arr[i] = val;
    }
    return NULL;
}

static inline void reset_array() {
    for (int i = 0; i < SIZE; i++) arr[i] = i + 1;
}

static inline long long array_sum() {
    long long sum = 0;
    for (int i = 0; i < SIZE; i++) sum += arr[i];
    return sum;
}

#endif

