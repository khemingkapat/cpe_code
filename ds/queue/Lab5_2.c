// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"

void enqueue(int *queue, int size, int *front, int *rear, int val);
int *dequeue(int *queue, int size, int *front, int *rear);
void print_queue(int queue[], int size, int front, int rear) {
    for (int i = front; i <= rear; i++) {

        printf("%d ", queue[i % size]);
    }
    puts("");
}

int main() {
    int size;
    scanf("%d", &size);
    int *queue = (int *)malloc(sizeof(int) * size);
    int front = -1, rear = -1;
    while (true) {
        char mode;
        scanf("%c", &mode);
        if (mode == 73) {
            int val;
            scanf("%d", &val);
            enqueue(queue, size, &front, &rear, val);
        } else if (mode == 68) {
            int *val = dequeue(queue, size, &front, &rear);
            if (val == NULL) {
                continue;
            }
            printf("%d\n", *val);
        } else if (mode == 83) {
            if (front == -1 && rear == -1) {
                puts("Queue is empty!!");
                continue;
            }
            printf("Front: %d\n", front);
            printf("Items: ");
            print_queue(queue, size, front, rear);
            printf("Rear: %d\n", rear);
        } else if (mode == 69) {
            break;
        }
    }

    return 0;
}

void enqueue(int *queue, int size, int *front, int *rear, int val) {
    if (*front == -1 && *rear == -1) {
        *front = *rear = 0;
    } else if ((*rear + 1 == *front) || (*rear - *front >= size - 1)) {
        puts("Queue is full!!");
        return;
    } else {
        *rear += 1;
    }
    queue[*rear % size] = val;
}

int *dequeue(int *queue, int size, int *front, int *rear) {

    if (*front == -1) {
        puts("Queue is empty!!");
        return NULL;
    }
    
    int *result = &queue[*front % size];
    
    if(*front == *rear){
        *front = *rear = -1;
    }else{
        *front += 1;
    }
    return result;
}
