#include "stdio.h"

int c_to_f(int c);
int f_to_c(int f);

int main(){
    int c,f;
    scanf("%d",&c);
    scanf("%d",&f);
    //output
    printf("%d\n",c_to_f(c));
    printf("%d\n",f_to_c(f));

    return 0;
}

int c_to_f(int c){
    return ((9*c)/5) +32;
}

int f_to_c(int f){
    double ff = f-32;
    ff = ff*5;
    ff = ff/9;
    return ff;
}
