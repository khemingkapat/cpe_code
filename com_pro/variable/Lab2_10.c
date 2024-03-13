#include <stdio.h>

int main()
{
    long radius;
    double area;
    double pi = 3.1415;
    scanf("%ld",&radius);
    area = pi * radius * radius;
    printf("%.3lf\n",area);

    return 0;
}

