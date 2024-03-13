#include "stdio.h"

typedef struct time {
    int hour;
    int min;
    int sec;
    int timestamp;
} Time ;
void set_timestamp(Time *time);

int main(){
    Time time1,time2;
    int diff;
    scanf("%d:%d:%d",&time1.hour,&time1.min,&time1.sec);
    scanf("%d:%d:%d",&time2.hour,&time2.min,&time2.sec);
    set_timestamp(&time1);
    set_timestamp(&time2);

    if(time2.timestamp >= time1.timestamp){
        diff = time2.timestamp - time1.timestamp;
    }else{
        diff = (86400 - time1.timestamp) + time2.timestamp;
    }

    if(diff >=25200 && diff <= 36000){
        printf("True\n");
    }else{
        printf("False\n");
    }

    return 0;
}

void set_timestamp(Time *time){
    time->timestamp = time->hour*3600 + time->min*60+time->sec;
}


