#include "common.h"
#include <pthread.h>

int arr[SIZE];

int main() {
    pthread_t t1, t2;

    reset_array();

    pthread_create(&t1, NULL, worker, NULL);
    pthread_join(t1, NULL);

    pthread_create(&t2, NULL, worker, NULL);
    pthread_join(t2, NULL);

    printf("Single-thread (2 passes, each in a thread) sum = %lld\n", array_sum());
    return 0;
}

