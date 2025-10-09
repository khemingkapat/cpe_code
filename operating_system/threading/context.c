#include "common.h"
#include <pthread.h>
#include <sched.h>   // for sched_yield

int arr[SIZE];

static inline void* worker_with_yield(void* arg) {
    for (int i = 0; i < SIZE; i++) {
        register int reg = arr[i]; // load
        reg = transform(reg);      // modify
        sched_yield();             // force context switch
        arr[i] = reg;              // store
    }
    return NULL;
}

int main() {
    pthread_t t1, t2;

    reset_array();

    // Run two threads concurrently
    pthread_create(&t1, NULL, worker_with_yield, NULL);
    pthread_create(&t2, NULL, worker_with_yield, NULL);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    printf("Concurrent threads with forced yield sum = %lld\n", array_sum());
    return 0;
}

