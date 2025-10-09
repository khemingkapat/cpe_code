#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

#define N 5

sem_t forks[N];

void *philosopher(void *num) {
    int id = *(int *)num;
    int left = id;
    int right = (id - 1) % N;

    while (1) {
        printf("Philosopher %d is thinking\n", id);
        sleep(1);

        printf("Philosopher %d is hungry\n", id);

	if(id % 2){
	    sem_wait(&forks[left]);
	    printf("Philosopher %d picked up LEFT fork %d\n", id, left);

	    sleep(1);

	    sem_wait(&forks[right]);
	    printf("Philosopher %d picked up RIGHT fork %d\n", id, right);
	}else{
	    sem_wait(&forks[right]);
	    printf("Philosopher %d picked up LEFT fork %d\n", id, left);

	    sleep(1);

	    sem_wait(&forks[left]);
	    printf("Philosopher %d picked up RIGHT fork %d\n", id, right);
	}

        printf("Philosopher %d is eating\n", id);
        sleep(2);

        sem_post(&forks[left]);
        sem_post(&forks[right]);
        printf("Philosopher %d put down both forks\n", id);
    }
}

int main() {
    pthread_t threads[N];
    int ids[N];

    for (int i = 0; i < N; i++)
        sem_init(&forks[i], 0, 1);

    for (int i = 0; i < N; i++) {
        ids[i] = i;
        pthread_create(&threads[i], NULL, philosopher, &ids[i]);
    }

    for (int i = 0; i < N; i++)
        pthread_join(threads[i], NULL);

    return 0;
}

