// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "stdbool.h"

typedef struct stack {
    int size;
    int *stack;
    int top;

} stack_t;

stack_t *init_stack(int size){
    stack_t *stack = (stack_t *)malloc(sizeof(stack_t));
    stack->stack = (int *)malloc(sizeof(int)*size);
    stack->size= size;
    stack->top = -1;
    return stack;
}

void push(stack_t *stack,int val);
int pop(stack_t *stack);
void print_stack(stack_t *stack);
bool is_full(stack_t *stack);
bool is_empty(stack_t *stack);

int main(){
    int size;   
    scanf("%d",&size);
    if(size<1){
        puts("Please enter a positive number.");
        return 0;
    }
    stack_t *stack = init_stack(size);
    while(true){
        int mode;
        scanf("%d",&mode);
        if(mode == 1){
            int val;
            scanf("%d",&val);
            push(stack,val);
        }else if(mode == 2){
            pop(stack);
        }else if(mode == 3){
            print_stack(stack);
            break;
        }else if(mode == 4){
            puts("Exiting...");
            break;
        }else{
            puts("Invalid choice.");
            break;
        }
    
    }

    return 0;
}

bool is_full(stack_t *stack){
    if(stack->top >= stack->size-1){
        return true;
    }else{
        return false;
    }
}

bool is_empty(stack_t *stack){
    if(stack->top <= -1){
        return true;
    }else{
        return false;
    }
}

void push(stack_t *stack,int val){
    if(is_full(stack)){
        puts("Stack Overflow.");
        exit(0);
    }

    stack->top++;
    stack->stack[stack->top] = val;
}

int pop(stack_t *stack){
    if(is_empty(stack)){
        puts("Stack Underflow.");
        exit(0);
    }
    int result = stack->stack[stack->top];
    stack->top--;
    return result;
}

void print_stack(stack_t *stack){
    if(is_empty(stack)){
        puts("Stack is empty.");
        return ;
    }
    while(!is_empty(stack)){
        printf("%d\n",pop(stack));
    }
}
