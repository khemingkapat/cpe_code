// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

int **get_matrix(int row, int col);
void multiply_matrix(int **m1, int r1, int c1, int **m2, int r2, int c2);

int main(void) {
    // getting matrices
    int row1, col1, row2, col2;
    scanf("%d %d", &row1, &col1);
    int **mat1 = get_matrix(row1, col1);
    scanf("%d %d", &row2, &col2);
    int **mat2 = get_matrix(row2, col2);
    multiply_matrix(mat1, row1, col1, mat2, row2, col2);

    return 0;
}

// function for getting matrix
int **get_matrix(int row, int col) {
    int **matrix;
    matrix = (int **)malloc(row * sizeof(int *));
    for (int i = 0; i < row; i++) {
        matrix[i] = (int *)malloc(col * sizeof(int));
        for (int j = 0; j < col; j++) {
            scanf("%d", &matrix[i][j]);
        }
    }
    return matrix;
}

// multiplying matrix together
void multiply_matrix(int **m1, int r1, int c1, int **m2, int r2, int c2){
    int **mat;
    if (c1 != r2) {
        printf("Not Compatible\n");
        return;
    }
    mat = (int **)malloc(r1 * sizeof(int *));
    for (int i = 0; i < r1; i++) {
        mat[i] = (int *)malloc(c1 * sizeof(int));
        for (int j = 0; j < c2; j++) {
            for (int k = 0; k < r2; k++) {
                mat[i][j] += m1[i][k] * m2[k][j];
            }
        }
    }
    for (int i = 0; i < r1; i++) {
        for (int j = 0; j < c2; j++) {
            printf("%d ",mat[i][j]);
        }
        printf("\n");
    }
}



