#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

void print_bin(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        printf("%d", arr[i]);
    }
    puts("");
}

int *dec_to_bin(int num, int size);
int *sign(int bin[], bool is_negative, int size);
int *ones_complement(int bin[], bool is_negative, int size);
int *twos_complement(int bin[], bool is_negative, int size);

int main() {
    int num, size;
    bool is_negative = false;
    int multiplier = 1;
    printf("Enter bit : ");
    scanf("%d", &size);
    long max = pow(2, size - 1);
    printf("Enter number in range of -%ld to %ld ", max - 1, max);
    scanf("%d", &num);

    if (num < 0) {
        is_negative = true;
        multiplier = -1;
    }

    int *bin = dec_to_bin(num * multiplier, size);
    printf("Binary of absolute value : ");
    print_bin(bin, size);

    int *signed_bin = sign(bin, is_negative, size);
    printf("Signed and Magnitude : ");
    print_bin(signed_bin, size);

    int *ones_cp = ones_complement(bin, is_negative, size);
    printf("Ones Complement : ");
    print_bin(ones_cp, size);

    int *twos_cp = twos_complement(bin, is_negative, size);
    printf("Twos Complement : ");
    print_bin(twos_cp, size);

    return 0;
}

int *dec_to_bin(int num, int size) {
    int *bin = (int *)malloc(sizeof(int) * size);

    for (int i = 0; i < size; i++) {
        bin[i] = 0;
    }

    int place = 1;
    while (num) {
        bin[size - place] = num % 2;
        place++;
        num = num / 2;
    }

    return bin;
}

int *sign(int bin[], bool is_negative, int size) {
    int *sign = (int *)malloc(size * sizeof(int));

    if (!is_negative) {
        sign[0] = 0;
    } else {
        sign[0] = 1;
    }

    for (int i = 1; i < size; i++) {
        sign[i] = bin[i];
    }

    return sign;
}

int *ones_complement(int bin[], bool is_negative, int size) {
    if (!is_negative) {
        return bin;
    }

    int *ones = (int *)malloc(sizeof(int) * size);
    for (int i = 0; i < size; i++) {
        ones[i] = !bin[i];
    }

    return ones;
}

int *twos_complement(int bin[], bool is_negative, int size) {
    if (!is_negative) {
        return bin;
    }

    int one_arr[size];
    for (int i = 0; i < size; i++) {
        one_arr[i] = 0;
    }
    one_arr[size - 1] = 1;
    int *ones = ones_complement(bin, is_negative, size);
    int *twos = (int *)malloc(sizeof(int) * size);

    int carry = 0;
    for (int i = size - 1; i >= 0; i--) {
        int sum = carry + ones[i] + one_arr[i];

        twos[i] = sum % 2;

        if (sum >= 2) {
            carry = 1;
        } else {
            carry = 0;
        }
    }
    return twos;
}
