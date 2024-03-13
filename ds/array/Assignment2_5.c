// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"

int main() {
    // get matrix
    int row, col;
    scanf("%d %d", &row, &col);
    int **matrix = (int **)malloc(sizeof(int *) * row);
    for (int i = 0; i < row; i++) {
        matrix[i] = (int *)malloc(sizeof(int) * col);
        for (int j = 0; j < col; j++) {
            scanf("%d", &matrix[i][j]);
        }
    }

    // create limit
    int top = 0,left = 0,down=row-1,right=col-1;
    int di = 0;
    // work until limit collapse
    // di=1; print l->r
    // di=2; print t->d
    // di=3; print r->l
    // di=4; print b->t
    while(top <= down && left<=right){
        // when finishing printing any direction
        // we update the limit
        if(di == 0){
            for(int i = left;i<=right;i++){
                printf("%d ",matrix[top][i]);
            }
            top++;
        }else if(di == 1){
            for(int i = top;i<=down;i++){
                printf("%d ",matrix[i][right]);
            }
            right--;
        }else if(di == 2){
            for(int i = right;i>=left;i--){
                printf("%d ",matrix[down][i]);
            }
            down--;
        }else{
            for(int i = down;i>=top;i--){
                printf("%d ",matrix[i][left]);
            }
            left++;
        }
        di = (di+1)%4;
    }
    puts("");
    free(matrix);

    return 0;
}
