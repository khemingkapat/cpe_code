//66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

int **get_matrix(int row, int col);
void multiply_matrix(int **mat1, int row1, int col1, int **mat2, int row2,
                     int col2);

int main(void) {
    int row1, col1, row2, col2;
    scanf("%d %d", &row1, &col1);
    int **mat1 = get_matrix(row1, col1);
    scanf("%d %d", &row2, &col2);
    int **mat2 = get_matrix(row2, col2);
    multiply_matrix(mat1, row1, col1, mat2, row2, col2);

    return 0;
}

int **get_matrix(int row, int col) {
    int **mat;
    mat = (int **)malloc(row * sizeof(int *));
    for (int i = 0; i < row; i++) {
        mat[i] = (int *)malloc(col * sizeof(int));
        for (int j = 0; j < col; j++) {
            scanf("%d", &mat[i][j]);
        }
    }
    return mat;
}

void multiply_matrix(int **mat1, int row1, int col1, int **mat2, int row2,
                      int col2) {
    int **mat;
    if (col1 != row2) {
        printf("ERROR\n");
        return ;
    }
    mat = (int **)malloc(row1 * sizeof(int *));
    for (int i = 0; i < row1; i++) {
        mat[i] = (int *)malloc(col1 * sizeof(int));
        for (int j = 0; j < col2; j++) {
            for (int k = 0; k < row2; k++) {
                mat[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
    }
    for (int i = 0; i < row1; i++) {
        for (int j = 0; j < col2; j++) {
            printf("%d ", mat[i][j]);
        }
        printf("\n");
    }
}
