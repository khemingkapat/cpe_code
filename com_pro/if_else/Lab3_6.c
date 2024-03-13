// 66070503408 Khem Ingkapat
#include "stdio.h"

void height_of_tower(void){
    int t,height;

    scanf("%d",&t);

    height = ((t*10)/2)*t;
    printf("%d\n",height);

}

int main(){
    height_of_tower();

    return 0;
}
