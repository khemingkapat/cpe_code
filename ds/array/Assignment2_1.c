// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "math.h"

// get student struct
typedef struct student {
    char name[100];
    double score;
    
} student_t;

// create mean function (named bar bcuz naming problem)
double bar(student_t students[],int size){
    double sum = 0;
    for(int i = 0;i<size;i++){
        sum += students[i].score;
    }
    return sum / size;

}

// create std function (again, naming problem)
double stnd(student_t students[],int size,double mean){
    double sum = 0;
    for(int i = 0;i<size;i++){
        sum += pow((mean-students[i].score),2);
    }
    return pow(sum/(size),0.5);
}

int main(){
    int n;
    scanf("%d",&n);
    // list of student
    student_t *students = (student_t *)malloc(sizeof(student_t)*n);
    // keep track of max and min
    char max_name[100],min_name[100];
    double max = -1,min=101;

    for(int i = 0;i<n;i++){
        char name[100];
        double score;
        scanf("%s",name);
        scanf("%lf",&score);
        if(score > max){
            max = score;
            strcpy(max_name,name);
        }

        if(score < min){
            min = score;
            strcpy(min_name,name);
        }

        strcpy((students+i)->name,name);
        (students+i)->score = score;


    }
    // calculate mean and std
    double mean = bar(students,n);
    double std = stnd(students,n,mean);
    printf("%.2lf %.2lf %s %s\n",mean,std,max_name,min_name);
    return 0;
}
