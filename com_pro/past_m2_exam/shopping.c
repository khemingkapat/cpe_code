#include "stdio.h"
#include "string.h"

typedef struct item {
    char name[20];
    int quantity;
    int price;
    int total_price;
    int used;
} Item;

void create_item(Item *item, char *name, int quantity, int price);
Item* insertion(Item* arr,int size);


int main() {
    int n;
    scanf("%d", &n);
    Item s[n];
    for (int i = 0; i < n; i++) {
        char name[20];
        int quantity, price;
        scanf("%s %d %d", name, &quantity, &price);
        create_item(&s[i], name, quantity, price);
    }
    Item *shopping = insertion(s, n);

    int p = 0;
    for (int i = 0; i < n; i++) {
        int count_common = 0;
        if (shopping[i].used == 1) {
            continue;
        }
        for (int j = 0; j < n; j++) {
            if (shopping[i].total_price == shopping[j].total_price && i != j) {
                if (count_common == 0) {
                    printf("%s %s ", shopping[i].name, shopping[j].name);
                } else {
                    printf("%s ", shopping[j].name);
                }
                p++;
                count_common++;
                shopping[j].used = 1;
            }
        }
        if(count_common){
            printf("\n");
        }
    }
    if (p== 0) {
        printf("None\n");
    }
    return 0;
}

void create_item(Item *item, char name[20], int quantity, int price) {
    strcpy(item->name, name);
    item->quantity = quantity;
    item->price = price;
    item->total_price = price * quantity;
    item->used = 0;
}

Item* insertion(Item* arr,int size){
    for(int slot=1;slot<size;slot++){
        Item val = arr[slot];
        int test_slot = slot-1;
        while(test_slot > -1 && arr[test_slot].total_price > val.total_price){
            arr[test_slot + 1] = arr[test_slot];
            test_slot -= 1;
        }
        arr[test_slot+1] = val;
    }
    return arr;
}
