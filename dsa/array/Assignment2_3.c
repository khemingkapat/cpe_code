// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

int main(){
    // getting matrix
    int row,col;
    scanf("%d %d",&row,&col);
    int **matrix = (int **)malloc(sizeof(int *)*row);
    for(int i = 0;i<row;i++){
        matrix[i] = (int *)malloc(sizeof(int)*col);
        for(int j = 0;j<col;j++){
            scanf("%d",&matrix[i][j]);
        }
    }
    // supposed that matrix is sym and skew sym
    int sym = 1;
    int skew = 1;
    for(int i = 0;i<row;i++){
        for(int j = 0;j<col;j++){
            // checking for normal sym
            if(matrix[i][j] != matrix[j][i]){
                sym = 0;
            }
// checking for skew sym
            if(matrix[i][j] != -1*matrix[j][i] && i!=j){
                skew = 0;
            }
        }
    }
    free(matrix);
    if(sym){
        puts("This matrix is symmetric");
        return 0;
    }
    if(skew){
        puts("This matrix is skew-symmetric");
        return 0;
    }
    
    puts("None");
    return 0;
}
