#include <stdio.h>
#include <string.h>

int main(void) {
    // Define a buffer of size 30
    char buffer[30];

    // Unsafely read the whole line. [^\n] allows to get spaces in buffer as well.
    // Can lead to buffer overflow
    if (scanf("%[^\n]", buffer) == 0) {
        return -1;
    }

    // Display string
    printf("You entered: %s\n", buffer);

    return 0;
}

