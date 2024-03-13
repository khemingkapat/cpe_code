// 66070503408 Khem Ingkapat
#include "math.h"
#include "stdbool.h"
#include "stdio.h"

void print_month() {
    int m, d, y, f;
    char months[12][10] = {"January",   "Febuary", "March",    "April",
                           "May",       "June",    "July",     "August",
                           "September", "October", "November", "December"};
    if (y % 400 == 0) {
        f = 29;
    } else if (y % 100 == 0) {
        f = 28;
    } else if (y % 4 == 0) {
        f = 29;
    } else {
        f = 28;
    }
    int day_in_month[12] = {31, f, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    printf("Enter the month(jan = 1) :");
    scanf("%d", &m);
    printf("Enter the start day(sun = 1) :");
    scanf("%d", &d);
    printf("Enter the year :");
    scanf("%d", &y);

    int day = day_in_month[m - 1];

    printf("%s %d\n", months[m - 1], y);
    printf("S  M  T  W  T  F  S\n");
    for (int i = 0; i < d - 1; i++) {
        printf("   ");
    }
    for (int i = 1; i <= day; i++) {

        if (i < 10) {
            printf("%d  ", i);
        } else {
            printf("%d ", i);
        }

        if ((i + d - 1) % 7 == 0) {
            printf("\n");
        }
    }
    printf("\n");
}

int main() { return 0; }
