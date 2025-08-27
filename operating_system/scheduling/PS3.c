#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PROCESSES 100

// you may change this if needed
typedef struct {
    int pid;        // process id (int)
    int arrival;    // arrival time
    int burst;      // burst time
    int remaining;  // remaining burst time
    int finished;   // 0 = not finished, 1 = done
} Process;

void print_processes(Process *procs,int n){
    for(int i = 0;i<n;i++){
	printf("process : %d\n\tarrive at %d\n\tburst %d\n\tremaining %d\n\tfinished %d\n",procs[i].pid,procs[i].arrival,procs[i].burst,procs[i].remaining,procs[i].finished);
    }

}


void simulate_stfc(Process *procs, int n) {
    int time = 0;
    int total_remaining = 0;

    for (int i = 0; i < n; i++) {
        total_remaining += procs[i].burst;
    }

    int prev_run_pid = -2;
    int interval_start = 0;

    while (total_remaining > 0) {
        int to_run_idx = -1;

        for (int i = 0; i < n; i++) {
            if (procs[i].arrival <= time && procs[i].finished == 0) {
                if (to_run_idx == -1) {
                    to_run_idx = i;
                } else {
                    if (procs[i].remaining < procs[to_run_idx].remaining ||
                       (procs[i].remaining == procs[to_run_idx].remaining &&
                        procs[i].pid < procs[to_run_idx].pid)) {
                        to_run_idx = i;
                    }
                }
            }
        }

        int current_pid = (to_run_idx == -1) ? -1 : procs[to_run_idx].pid;
        if (current_pid != prev_run_pid) {
            if (prev_run_pid != -2) {
                printf("[%d-%d]: ", interval_start, time-1);
                if (prev_run_pid == -1) {
                    printf("IDLE\n");
                } else {
                    printf("P%d\n", prev_run_pid);
                }
            }
            interval_start = time;
            prev_run_pid = current_pid;
        }

        if (to_run_idx == -1) {
            time += 1;
            continue;
        }

        time += 1;
        procs[to_run_idx].remaining -= 1;

        if (procs[to_run_idx].remaining == 0) {
            procs[to_run_idx].finished = 1;
        }

        total_remaining -= 1;
    }

    printf("[%d-%d]: ", interval_start, time-1);
    if (prev_run_pid == -1) {
        printf("IDLE\n");
    } else {
        printf("P%d\n", prev_run_pid);
    }
}



int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <csvfile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("Error opening file");
        return 1;
    }

    Process procs[MAX_PROCESSES];
    int n = 0;
    char line[256];

    // skip header line
    fgets(line, sizeof(line), fp);

    // read each row
    // you may change this if needed
    while (fgets(line, sizeof(line), fp) && n < MAX_PROCESSES) {
        int pid, arrival, burst;
        if (sscanf(line, "%d,%d,%d", &pid, &arrival, &burst) == 3) {
            procs[n].pid = pid;
            procs[n].arrival = arrival;
            procs[n].burst = burst;
            procs[n].remaining = burst;
            procs[n].finished = 0;
            n++;
        }
    }
    fclose(fp);
    // print_processes(procs,n);

    simulate_stfc(procs, n);
    // print_processes(procs,n);

    return 0;
}
