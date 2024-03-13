#include "stdio.h"

int freq(int *arr,int size, int n);
char * is_anagram(int *arr1,int size1, int *arr2,int size2);

int main(){
    int n1,n2;
    scanf("%d",&n1);
    int arr1[n1];
    for(int i = 0;i<n1;i++){
        scanf("%d",&arr1[i]);
    }
    scanf("%d",&n2);
    int arr2[n2];
    for(int i = 0;i<n2;i++){
        scanf("%d",&arr2[i]);
    }
    char * result = is_anagram(arr1,n1,arr2,n2); 
    printf("%s\n",result);
    return 0;
}

int freq(int *arr,int size,int n){
    int f = 0;
    for(int i = 0;i<size;i++){
        if(arr[i] == n){
            f++;
        }
    }
    return f;
}
char * is_anagram(int *arr1,int size1, int *arr2,int size2){
    if(size1 != size2){
        return "False";
    }

    for(int i = 0;i<size1;i++){
        int is_mem2 = freq(arr2,size2,arr1[i]);
        if(!is_mem2 || freq(arr1, size1, arr1[i]) != freq(arr2, size2, arr2[i])){
            return "False";
        }

    }
    return "True";
}
