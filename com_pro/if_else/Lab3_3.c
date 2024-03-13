// 66070503408 Khem Ingkapat
#include "stdio.h"

void number_of_bags(void) {
    int weight,bag_cap,num_bag;
    scanf("%d %d",&weight,&bag_cap);

    num_bag = (weight + bag_cap - 1)/bag_cap;

    printf("%d\n",num_bag);

}

int main(){
    number_of_bags();

    return 0;
}
