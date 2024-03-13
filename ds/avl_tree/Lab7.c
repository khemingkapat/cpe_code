// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct node {
    int val;
    struct node *left;
    struct node *right;
} node;

int height(node *root);
int balance_factor(node *root);
bool is_balance(node *root);
void right_rotation(node **root);
void left_rotation(node **root);
void insert(node **root, int val);
void delete(node **root, int val);
void print_preorder(node *root);
void deallocate(node *root);

int main() {
    node *root = NULL;
    char mode[256];
    while (true) {
        scanf("%s", mode);
        if (strcmp(mode, "INSERT") == 0) {
            int val;
            char symb;
            do {
                scanf("%d%c", &val, &symb);
                insert(&root, val);
            } while (symb != '\n');
        } else if (strcmp(mode, "DELETE") == 0) {
            int val;
            char symb;
            do {
                scanf("%d%c", &val, &symb);
                delete(&root, val);
            } while (symb != '\n');
        } else if (strcmp(mode, "PRINT") == 0) {
            if (root == NULL) {
                puts("Tree is empty.");
                continue;
            }
            print_preorder(root);
            puts("");
        } else if (strcmp(mode, "EXIT") == 0) {
            break;
        } else {
            puts("Invalid command.");
        }
    }
    deallocate(root);
    return 0;
}

int height(node *root) {
    if (root == NULL) {
        return 0;
    }
    int left_height = height(root->left);
    int right_height = height(root->right);

    if (left_height > right_height) {
        return left_height + 1;
    }
    return right_height + 1;
}
int balance_factor(node *root) {
    if (root == NULL) {
        return 0;
    }
    return height(root->left) - height(root->right);
}

bool is_balance(node *root) {
    int balance = balance_factor(root);
    return balance >= -1 && balance <= 1;
}

void print_preorder(node *root) {
    if (root == NULL) {
        return;
    }
    printf("%d ", root->val);
    print_preorder(root->left);
    print_preorder(root->right);
}

void insert(node **root, int val) {
    if (*root == NULL) {
        node *new_root = (node *)malloc(sizeof(node));
        new_root->val = val;
        new_root->left = NULL;
        new_root->right = NULL;
        *root = new_root;
    } else {
        if (val < (*root)->val) {
            insert(&(*root)->left, val);
        } else if (val > (*root)->val) {
            insert(&(*root)->right, val);
        }
    }

    int bF = balance_factor(*root);
    if (bF > 1 && val < (*root)->left->val) {
        right_rotation(root);
        return;
    }

    if (bF < -1 && val > (*root)->right->val) {
        left_rotation(root);
        return;
    }

    if (bF > 1 && val > (*root)->left->val) {
        left_rotation(&(*root)->left);
        right_rotation(root);
        return;
    }

    if (bF < -1 && val < (*root)->right->val) {
        right_rotation(&(*root)->right);
        left_rotation(root);
        return;
    }
}

void right_rotation(node **root) {
    node *new_root = (*root)->left;
    node *t2 = new_root->right;

    new_root->right = *root;
    (*root)->left = t2;
    *root = new_root;
}

void left_rotation(node **root) {
    node *new_root = (*root)->right;
    node *t2 = new_root->left;

    new_root->left = *root;
    (*root)->right = t2;
    *root = new_root;
}

void delete(node **root, int val) {
    if (*root == NULL) {
        puts("Node not found.");
        return;
    }
    node *ptr = *root;

    if (val < ptr->val) {
        delete (&ptr->left, val);
    } else if (val > ptr->val) {
        delete (&ptr->right, val);
    } else if (ptr->left != NULL && ptr->right != NULL) {
        // if there is both left child and right child in current node
        node *cur = (*root)->right;
        while (cur->left != NULL) {
            cur = cur->left;
        }
        (*root)->val = cur->val;
        delete (&(*root)->right, cur->val);
    } else {
        if (ptr->left == NULL && ptr->right == NULL) {
            *root = NULL;
        } else if (ptr->left != NULL) {
            *root = ptr->left;
        } else {
            *root = ptr->right;
        }
    }

    int bF = balance_factor(*root);
    if (bF > 1 && balance_factor((*root)->left) >= 0) {
        right_rotation(root);
        return;
    }

    if (bF < -1 && balance_factor((*root)->right) <= 0) {
        left_rotation(root);
        return;
    }

    if (bF > 1 && balance_factor((*root)->left) < 0) {
        left_rotation(&(*root)->left);
        right_rotation(root);
        return;
    }

    if (bF < -1 && balance_factor((*root)->right) > 0) {
        right_rotation(&(*root)->right);
        left_rotation(root);
        return;
    }
}

void deallocate(node *root) {
    if (root == NULL) {
        return;
    }
    deallocate(root->left);
    deallocate(root->right);
    free(root);
}
