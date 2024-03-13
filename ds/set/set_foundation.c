#include <stdio.h>

// n
void printArr(int n, int arr[]) {
    if(n == 0){
        printf("empty\n");
        return ;
    }
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    puts("");
}

// n
int in(int size,int *arr,int n){
    for(int i = 0;i<size;i++){
        if(arr[i] == n){
            return 1;
        }
    }
    return 0;
}

// n
int getSetfromArray(int size,int arr[],int *set){
    int set_idx = 0;
    for(int i = 0;i<size;i++){
        if(i == 0 || arr[i] != arr[i-1]){
            set[set_idx] = arr[i];
            set_idx++;
        }
    }
    return set_idx;
}

// n
int getSet(int size, int *arr, int m, int n) {
    /*
    inset code of getting the set and return the size of the set
    where the members in set are in the range of m to n if it's not, print
    "empty" and return 0
    */

    int set_size = 0;
    for (int i = 0; i < size; i++) {
        int d;
        scanf("%d",&d);
        if (i == 0 || arr[set_size - 1] != d) {
            if (d < m || d > n) {
                continue;
            } else {
                arr[set_size] = d;
                set_size++;
            }
        }
    }
    return set_size;
}

// n-m
void genUniverse(int m, int n, int *u) {
    int idx = 0;
    for(int i = m;i<=n;i++){
        u[idx] = i;
        idx++;
    }
}

// 2(sizeA + sizeB)
void Union(int sizeA, int sizeB, int A[], int B[]) {
    int combine[sizeA + sizeB];

    int i = 0, j = 0;
    int idx = 0;

    // sizeA + sizeB
    while (i < sizeA && j < sizeB) {
        if (A[i] < B[j]) {
            combine[idx] = A[i];
            i++;
        } else if(A[i] > B[j]){
            combine[idx] = B[j];
            j++;
        }else{
            combine[idx] = A[i];
            i++;
            j++;
        }
        idx++;
    }
    for (int ii = i; ii < sizeA; ii++) {
        combine[idx] = A[ii];
        idx++;
    }
    for (int jj = j; jj < sizeB; jj++) {
        combine[idx] = B[jj];
        idx++;
    }
    printArr(idx,combine);
}

void Intersection(int sizeA, int sizeB, int A[], int B[]) {
    
    int ins_set[sizeA];
    int idx = 0;
    // n^2
    for(int i = 0;i<sizeA;i++){
        if(in(sizeB,B,A[i])){
            ins_set[idx] = A[i];
            idx++;
        }
    }
    int set[idx];
    // n
    int set_size = getSetfromArray(idx, ins_set, set);
    printArr(set_size, set);
}

void Difference(int sizeA, int sizeB, int A[], int B[]) {
    // insert code here
    int dif_set[sizeA];
    int idx = 0;
    // n^2
    for(int i = 0;i<sizeA;i++){
        if(!in(sizeB,B,A[i])){
            dif_set[idx]=A[i];
            idx++;
        }
    }
    int set[idx];
    int set_size = getSetfromArray(idx, dif_set, set);
    printArr(set_size, set);

}

int main() {
    int m, n;
    scanf("%d %d", &m, &n);

    int u[n - m + 1];
    genUniverse(m, n, u);

    int size_a;
    scanf("%d", &size_a);
    int A[size_a];
    int sizeA = getSet(size_a, A, m,n);

    int size_b;
    scanf("%d", &size_b);
    int B[size_b];
    int sizeB = getSet(size_b, B, m,n);

    printArr(sizeA,A);
    printArr(sizeB,B);
    // Union
    Union(sizeA, sizeB, A, B);

    // Intersection
    Intersection(sizeA, sizeB, A, B);

    // Difference (A-B)
    Difference(sizeA, sizeB, A, B);

    // Difference (B-A)
    Difference(sizeB, sizeA, B, A);

    // Complement (U-A)
    Difference(n - m + 1, sizeA, u, A);

    // Complement (U-B)
    Difference(n - m + 1, sizeB, u, B);

    return 0;
}
