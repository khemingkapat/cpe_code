#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    int fd[2];

    if (pipe(fd) == -1) {
        perror("pipe");
        return 1;
    }

    int pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        close(fd[0]); // close read end
        printf("Child: Child PID: %d\n", getpid());

	char message[100];
	snprintf(message, sizeof(message), "Hello from child PID: %d", getpid());
	sleep(20);
	write(fd[1], message, strlen(message));

        close(fd[1]);

    } else {
        // Parent
        close(fd[1]); // close write end
        printf("Parent: Parent PID: %d\n", getpid());

        char buffer[100];
        read(fd[0], buffer, sizeof(buffer));
        printf("Parent: %s\n", buffer);

        close(fd[0]);
    }

    return 0;
}
