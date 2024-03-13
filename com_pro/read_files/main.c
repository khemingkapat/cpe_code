#include "stdio.h"
#include "stdlib.h"

int code_index(char *str);

int main(void) {
    char term[20];
    char code[10];
    char name[100];
    double credit;
    double grade;

    FILE *cfPtr = fopen("./read_files/transcript.csv", "r");
    FILE *write = fopen("./read_files/result.csv", "w");

    if (cfPtr == NULL) {
        puts("unable to open file");
        return 1;
    }
    char cur_term = '1';
    double total_grade = 0;
    double total_credit = 0;
    double grades[3] = {0, 0, 0};
    double credits[3] = {0, 0, 0};
    int init_grade = 10;
    int init_term = 1;
    int term_count = 1;

    for (int i = 0; i < 87; i++) { // hardcoded
        fscanf(cfPtr, "%20[^,],%10[^,],%100[^,],%lf,%lf", term, code, name,
               &credit, &grade);

        char term_num = term[14];
        if (i == 0) {
            term_num = term[12];
        }
        int sub_idx = code_index(code);
        if (sub_idx > -1) {
            grades[sub_idx] += grade * credit;
            credits[sub_idx] += credit;
        }
        if (cur_term != term_num) {
            double gpa = total_grade / total_credit;
            fprintf(write, "Grade%d Term%d,ENG,%.2lf\n", init_grade, init_term,
                    grades[0] / credits[0]);
            fprintf(write, "Grade%d Term%d,SCI,%.2lf\n", init_grade, init_term,
                    grades[1] / credits[1]);
            fprintf(write, "Grade%d Term%d,MTH,%.2lf\n", init_grade, init_term,
                    grades[2] / credits[2]);
            fprintf(write, "Grade%d Term%d,ALL,%.2lf\n", init_grade, init_term,
                    gpa);

            total_grade = 0;
            total_credit = 0;
            if(term_count%2 == 0){
                init_grade++;
            }
            term_count++;
            if (init_term == 1) {
                init_term = 2;
            } else {
                init_term = 1;
            }
            for (int i = 0; i < 3; i++) {
                grades[i] = 0;
                credits[i] = 0;
            }
        }
        cur_term = term_num;
        total_grade += (credit * grade);
        total_credit += credit;
    }
    fprintf(write, "Grade%d Term%d,ENG,%.2lf\n", init_grade, init_term,
            grades[0] / credits[0]);
    fprintf(write, "Grade%d Term%d,SCI,%.2lf\n", init_grade, init_term,
            grades[1] / credits[1]);
    fprintf(write, "Grade%d Term%d,MTH,%.2lf\n", init_grade, init_term,
            grades[2] / credits[2]);
    fprintf(write, "Grade%d Term%d,ALL,%.2lf\n", init_grade, init_term, total_grade/total_credit);

    fclose(cfPtr);
    fclose(write);

    return 0;
}

int code_index(char *str) {
    int c = str[2];
    switch (c) {
    case -83: // อ
        return 0;
        break;
    case -89: // ว
        return 1;
        break;
    case -124: // ค
        return 2;
        break;
    default:
        return -1;
        break;
    }
}
