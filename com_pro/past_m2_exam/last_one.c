#include "stdio.h"

int last_one(int fp, int lp, int player, int n);

int main() {
    int n;
    scanf("%d", &n);

    int result =
        last_one(1, 1, 1, n) || last_one(1, 2, 1, n) || last_one(1, 3, 1, n);
    /* for(int i =1;i<=1000;i++){ */
    /* int result = */
    /*     last_one(1, 1, 1, i) || last_one(1, 2, 1, i) || last_one(1, 3, 1, i); */
    /* int result2 = i%2; */
    /* if(result != result2){ */
    /*         printf("%d\n",i); */
    /*     } */
    /*  */
    /* } */
    if(result){
        printf("True\n");
    }else{
        printf("False\n");
    }


    return 0;
}

int last_one(int fp, int lp, int player, int n) {
    if (n <= 3) {
        return player;
    }
    if (n - 3 >= fp && n - 3 <= lp) {
        return !player;
    }

    return last_one(lp + 1, lp + 1, !player, n) ||
           last_one(lp + 1, lp + 2, !player, n) ||
           last_one(lp + 1, lp + 3, !player, n);
}
