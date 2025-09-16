#include <stdio.h>
#include <stdlib.h>
int x = 20;
void display(){
    int x;
    printf(" Display value of x: %d\n", x);
    printf(" Adress of x (in display function): %p\n\n", &x);
}
void main(){
    int x;
    printf(" Print value of x: %d\n", x);
    printf(" Adress of x (in main function): %p\n\n", &x);
    display();
}
