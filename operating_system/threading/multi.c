#include "common.h"
#include <pthread.h>

int arr[SIZE];

int main() {
    pthread_t t1, t2;

    reset_array();

    // Two threads, each runs worker once
    pthread_create(&t1, NULL, worker, NULL);
    pthread_create(&t2, NULL, worker, NULL);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    printf("Multi-thread (2 threads) sum = %lld\n", array_sum());
    return 0;
}

