#include <stdio.h>

int main() {
    int a, b, c, d, e;

    a = 10;
    c = a + 30; // rely on line 6, so need line 6 to be executed first
    b = 20;
    d = b + 20;        // rely on line 8
    e = a + b + c + d; // rely on all preceeding line 5,6,7,8

    return e;
}
