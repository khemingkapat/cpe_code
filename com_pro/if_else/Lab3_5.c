// 66070503408 Khem Ingkapat
#include "stdio.h"

void angle_in_polygon(void){
    int n_sides,angle;
    scanf("%d",&n_sides);

    angle = (n_sides - 2)*180;

    printf("%d\n",angle);

}

int main(){
    angle_in_polygon();

    return 0;
}
