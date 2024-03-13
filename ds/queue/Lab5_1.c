// 66070503408 Khem Ingkapat
#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct song {
    char name[256];
    char artist[256];
    int duration;
    struct song *next;
} song_t;

void enqueue(song_t **head, song_t **tail, char name[256], char artist[256],
             int duration);
void dequeue(song_t **head, song_t **tail);

int main() {
    song_t *head = NULL;
    song_t *tail = NULL;
    char name[256], artist[256], duration[256], mode[256];

    while (true) {
        fgets(mode, 256, stdin);
        mode[strcspn(mode, "\n")] = '\0';
        if (strcmp(mode, "add") == 0) {
            fgets(name, 256, stdin);
            name[strcspn(name, "\n")] = '\0';
            fgets(artist, 256, stdin);
            artist[strcspn(artist, "\n")] = '\0';
            fgets(duration, 256, stdin);
            enqueue(&head, &tail, name, artist, atoi(duration));
        } else if (strcmp(mode, "play") == 0) {
            dequeue(&head, &tail);
        } else if (strcmp(mode, "sum") == 0) {
            break;
        }
    }

    if (head == NULL) {
        puts("No songs in the playlist");
        return 0;
    }

    puts("Songs in the playlist:");
    int remaining_time = 0;
    while (head != tail->next) {
        printf("%s by %s %d\n", head->name, head->artist, head->duration);
        remaining_time += head->duration;
        head = head->next;
    }

    printf("Remaining Time: %d\n", remaining_time);

    return 0;
}

void enqueue(song_t **head, song_t **tail, char name[256], char artist[256],
             int duration) {
    song_t *new_song = (song_t *)malloc(sizeof(song_t));

    strcpy(new_song->name, name);
    strcpy(new_song->artist, artist);
    new_song->duration = duration;
    new_song->next = NULL;

    if (*head == NULL) {
        *head = new_song;
        *tail = new_song;
        return;
    }

    song_t *cur = *tail;
    cur->next = new_song;
    *tail = cur->next;
}

void dequeue(song_t **head, song_t **tail) {
    if (*head == NULL) {
        puts("No songs in the playlist");
        return;
    }
    song_t *temp = *head;
    printf("Now playing: %s by %s\n", temp->name, temp->artist);
    *head = temp->next;

    if(*head == NULL){
        *tail = NULL;
    }
}

