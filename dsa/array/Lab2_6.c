// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

int main(){
    int row,col;
    scanf("%d %d",&row,&col);
    if(row != col){
        printf("ERROR\n");
        return 0;
    }
    // getting matrix
    int **matrix;
    matrix = (int **)malloc(row*sizeof(int *));
    for(int i= 0;i<row;i++){
        matrix[i] = (int *)malloc(sizeof(int)*col);
        for(int j = 0;j<col;j++){
            scanf("%d",&matrix[i][j]);
        }
    }
    int primary = 0;
    int secondary = 0;
    for(int i = 0;i<row;i++){
        for(int j = 0;j<col;j++){
            if(i == j){
                primary += matrix[i][j];
            }

            if(i+j == row-1){
                secondary += matrix[i][j];
            }
        }
    }
    printf("Primary: %d\n",primary);
    printf("Secondary: %d\n",secondary);
    free(matrix);
}
