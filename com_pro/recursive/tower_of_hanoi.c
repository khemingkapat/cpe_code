void tower_of_hanoi(int n,char s,char d, char a){
    if(n == 1){
        printf("Move disk 1 from source %c to destination %c\n",s,d);
    }else{
        tower_of_hanoi(n-1, s,a,d);
        printf("Move disk %d from source %c to destination %c\n",n,s,d);
        tower_of_hanoi(n-1, a,d,s);
    }
}

int main(){
    tower_of_hanoi(4,'A','B','C');

    return 0;
}
