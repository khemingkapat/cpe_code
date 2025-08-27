#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

long fork_recursive(long count) {
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        return count;
    }

    if (pid == 0) {
        pause();
        exit(0);
    }

    return fork_recursive(count + 1);
}

int main() {
    long total = fork_recursive(1); // 1 for the parent
    printf("Total processes created (including parent): %ld\n", total);

    // Cleanup: reap all children
    return 0;
}

