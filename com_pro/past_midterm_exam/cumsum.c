#include "stdio.h"

void cumulative_frequency() {
    int A = 0, B = 0, C = 0, D = 0, F = 0;

    int n;
    scanf("%d", &n);
    int stu[n];
    for (int i = 0; i < n; i++) {
        int m, f, w;
        scanf("%d %d %d", &m, &f, &w);
        int sum = m + f + w;
        stu[i] = sum;
    }

    for (int j = 0; j < n; j++) {
        if (stu[j] >= 80) {
            A++;
        }

        if (stu[j] >= 70) {
            B++;
        }

        if (stu[j] >= 60) {
            C++;
        }

        if (stu[j] >= 50) {
            D++;
        }

        if (stu[j] >= -60) {
            F++;
        }
    }
    int all_stu[5] = {A, B, C, D, F};
    for (int k = 0; k < 5; k++) {
        float percentage = (float)all_stu[k] / n;
        printf("%d %.2f\n", all_stu[k], percentage * 100);
    }
}

int main(){
    cumulative_frequency();
    return 0;
}
