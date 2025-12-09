#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    char c;
    int stack[5];
    int count = 0;
    int id = 0;

    FILE *file = fopen(argv[1], "r");

    while ((c = fgetc(file)) != EOF) {
        switch (c) {
        case 'a':
            // Push a new element on the stack
            stack[count] = id;
            // This can lead to overflows as no check is done on full stack
            count++;
            id++;
            break;

        case 'r':
            // Pop the last added element from the stack
            // This can lead to underflows as no check is done on empty stack
            count--;
            break;

        case 'p':
            // Print all stack elements
            for (int idx = count - 1; idx >= 0; idx--) {
                    printf("%d ", stack[idx]);
            }
            printf("\n");
            break;
        }
    }

    fclose(file);

    return 0;
}
