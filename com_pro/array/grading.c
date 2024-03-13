#include "stdio.h"

void grading(){
    int n;
    scanf("%d",&n);
    int arr[n];
    for(int i = 0;i<n;i++){
        int x,y,z;
        scanf("%d %d %d",&x,&y,&z);
        arr[i] = x+y+z;
    }
    int a,b,c,d;
    scanf("%d",&a);
    scanf("%d",&b);
    scanf("%d",&c);
    scanf("%d",&d);

    for(int i = 0;i<n;i++){
        if(arr[i] >= a){
            printf("A\n");
        }else if(arr[i] >= b){
            printf("B\n");
        }else if(arr[i] >= c){
            printf("C\n");
        }else if(arr[i] >= d){
            printf("D\n");
        }else{
            printf("F\n");
        }
    }


}
int main(){
    grading();

    return 0;
}
