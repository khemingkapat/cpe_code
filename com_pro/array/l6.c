#include "stdio.h"
#include "math.h"

void move_zero(void) {
    int n, z_counter = 0;
    scanf("%d", &n);
    int arr[n];

    for (int i = 0; i < n; i++) {
        int inp;
        scanf("%d", &inp);
        arr[i] = inp;
    }

    for (int j = 0; j < n; j++) {
        if (arr[j] != 0) {
            printf("%d\n", arr[j]);
        } else {
            z_counter++;
        }
    }

    for (int k = 0; k < z_counter; k++) {
        printf("0\n");
    }
}

void odd_even() {
    int n;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        int inp;
        scanf("%d", &inp);
        arr[i] = inp;
    }

    for (int j = 0; j < n; j++) {
        if (arr[j] % 2 == 1) {
            printf("%d ", arr[j]);
        }
    }
    printf("\n");

    for (int j = 0; j < n; j++) {
        if (arr[j] % 2 == 0) {
            printf("%d ", arr[j]);
        }
    }
    printf("\n");
}

int in_arr(int arr[], int val, int n) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == val) {
            return 1;
            break;
        }
    }
    return 0;
}

int is_prime(int n) {
    for (int i = 2; i < n; i++) {
        if (n % i == 0) {
            return 0;
            break;
        }
    }
    return 1;
}

int reverse_number(int n) {
    int result = 0, r;
    while (n > 0) {
        r = n % 10;
        result = (result * 10) + r;
        n = n / 10;
    }
    return result;
}

void matching() {
    int n1;
    scanf("%d", &n1);
    int arr1[n1];
    for (int i = 0; i < n1; i++) {
        int inp1;
        scanf("%d", &inp1);
        arr1[i] = inp1;
    }

    printf("-------------------------\n");

    int n2;
    scanf("%d", &n2);
    int arr2[n2];
    for (int l = 0; l < n2; l++) {
        int inp2;
        scanf("%d", &inp2);
        arr2[l] = inp2;
    }

    int is_subset = 1;
    if (n1 < n2) {
        for (int j = 0; j < n1; j++) {
            if (!in_arr(arr2, arr1[j], n2)) {
                is_subset = 0;
                break;
            }
        }
    } else {
        for (int k = 0; k < n2; k++) {
            if (!in_arr(arr1, arr2[k], n1)) {
                is_subset = 0;
                break;
            }
        }
    }
    if (is_subset) {
        printf("True\n");
    } else {
        printf("False\n");
    }
}

void prime_palindrome() {
    int n;
    scanf("%d", &n);
    int m = n + 1;
    while (1) {
        if (is_prime(m) && (m == reverse_number(m))) {
            printf("%d\n", m);
            break;
        }
        m++;
    }
}

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

        if (stu[j] >= 0) {
            F++;
        }
    }
    int all_stu[5] = {A, B, C, D, F};
    for (int k = 0; k < 5; k++) {
        float percentage = (float)all_stu[k] / n;
        printf("%d %.2f\n", all_stu[k], percentage * 100);
    }
}

int frequency(int arr[],double val,int size){
    int result = 0;
    for(int i = 0;i<size;i++){
        if(arr[i] == val){
            result++;
        }
    }
    return result;
}

void mode(int arr[],int size){
    int m[2];
    int max_count = 0;

    for(int i = 0;i<size;i++){
        printf("now counting or %d",arr[i]);
        int count = 0;
        for(int j = 0;j<size;j++){
            if(arr[i] == arr[j]){
                count++;
            }
        }

        if(count >= max_count){
            printf("%d has more max cout",arr[i]);
            max_count = count;
        }

    }
    int mode_counter = 0;
    for(int k = 0;k<size;k++){
        int found = 0;
        if(frequency(arr,arr[k],size) == max_count){
            if(!in_arr(m,arr[k], mode_counter)){
                m[mode_counter] = arr[k];
                mode_counter++;
            }
        }
    }
    

    if(mode_counter > 2){
        printf("NONE\n");
    }else{
        for(int y = 0;y<mode_counter;y++){
            printf("%d ",m[y]);
        }
        printf("\n");
    }

}

void stat() {
    int n;
    int result = 0;
    scanf("%d", &n);
    int arr[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
    }

    for (int j = 0; j < n; j++) {
        result = result + arr[j];
    }

    double mean = (double)result / n;

    double sum_dist = 0;
    for(int k = 0;k<n;k++){
        sum_dist = sum_dist + (double)pow((arr[k]-mean),2);
    }


    double std = sqrt(sum_dist/n);
    printf("%.2lf\n",mean);
    mode(arr,n);
    printf("%.2lf\n",std);
}

int main() {
    stat();
    return 0;
}
