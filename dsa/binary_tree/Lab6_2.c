// 66070503408 Khem Ingkapat
#include "stdio.h"
#include "stdlib.h"
#include "stdbool.h"
#include "string.h"

typedef struct node {
    int val;
    struct node *left;
    struct node *right;
} node;
void insert(node **root,int val);
void print_preorder(node *root);
void print_inorder(node *root);
void print_postorder(node *root);

int main(){
    node *root = NULL;
    while(true){
        char mode[256];
        scanf("%s",mode);
        if(strcmp(mode,"INS") == 0){
            int val;
            scanf("%d",&val);
            insert(&root,val);
        }else if(strcmp(mode,"PREORDER")==0){
            print_preorder(root);
            puts("");
        }else if(strcmp(mode,"INORDER")==0){
            print_inorder(root);
            puts("");
        }else if(strcmp(mode,"POSTORDER")==0){
            print_postorder(root);
            puts("");
        }else if(strcmp(mode,"END")==0){
            break;
        }
    }
    print_inorder(root);
    puts("");

    return 0;
}

void insert(node **root,int val){
    if(*root == NULL){
        node *new_root = (node *)malloc(sizeof(node));
        new_root->val = val;
        new_root->left = NULL;
        new_root->right = NULL;
        *root = new_root;
    }

    node *cur = *root;
    if(val < cur->val){
        insert(&(*root)->left,val);
    }else if(val > cur->val){
        insert(&(*root)->right,val);
    }
}

void print_preorder(node *root){
    if(root == NULL){
        return ;
    }
    printf("%d ",root->val);
    print_preorder(root->left);
    print_preorder(root->right);
}

void print_inorder(node *root){
    if(root == NULL){
        return ;
    }

    print_inorder(root->left);
    printf("%d ",root->val);
    print_inorder(root->right);
}

void print_postorder(node *root){
    if(root == NULL){
        return ;
    }

    print_postorder(root->left);
    print_postorder(root->right);
    printf("%d ",root->val);
}
