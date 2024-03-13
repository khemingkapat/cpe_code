// assume we are in 2009
// input would be day and month of the year
// output would be day of the week of that date
//
#include "stdio.h"

int main(){
    int d,m;
    scanf("%d",&d);
    scanf("%d",&m);

    int day_in_month[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

    int total_day = 0;

    for(int i = 0;i<m-1;i++){
        total_day += day_in_month[i];
    }

    total_day += d;

    char day_in_week[7][10] = {"Thursday","Friday","Saturday","Sunday","Monday","Tuesday","Wednesday"};

    printf("%s\n",day_in_week[(total_day-1)%7]);


    return 0;
}
